#!/bin/bash
# Compresses images in assets/ into assets_web/, preserving directory structure.
# Resizes longest side to 1500px max, JPEG quality ~80. Skips PDFs and fonts.
# Run from the repo root: bash compress_assets.sh

SRC="assets"
DST="assets_web"

find "$SRC" -type f | while read -r file; do
  ext="${file##*.}"
  ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

  dest="$DST/${file#$SRC/}"
  mkdir -p "$(dirname "$dest")"

  case "$ext_lower" in
    jpg|jpeg|png)
      dest="${dest%.*}.jpg"
      ffmpeg -i "$file" \
        -vf "scale=1500:1500:force_original_aspect_ratio=decrease" \
        -q:v 4 "$dest" -y 2>/dev/null
      orig=$(du -k "$file" | cut -f1)
      new=$(du -k "$dest" | cut -f1)
      printf "  %-70s %5dK -> %4dK\n" "${file#$SRC/}" "$orig" "$new"
      ;;
    *)
      cp "$file" "$dest"
      printf "  %-70s (copied as-is)\n" "${file#$SRC/}"
      ;;
  esac
done

echo ""
echo "Done. Compressed images are in: $DST/"
echo "Original size:   $(du -sh "$SRC" | cut -f1)"
echo "Compressed size: $(du -sh "$DST" | cut -f1)"
echo ""
echo "To replace assets with compressed versions:"
echo "  rm -rf assets && mv assets_web assets"
