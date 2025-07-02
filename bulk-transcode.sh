#!/bin/bash

SRC_DIR="$1"

if [ -z "$SRC_DIR" ]; then
  echo "Usage: $0 /path/to/source/videos"
  exit 1
fi

OUT_DIR="$SRC_DIR/converted"
mkdir -p "$OUT_DIR"

EXTENSIONS="mp4 mkv avi mov webm flv m4v mpg"

find "$SRC_DIR" -type f \( $(printf -- "-iname '*.%s' -o " $EXTENSIONS | sed 's/ -o $//') \) | while read -r FILE; do
  BASENAME=$(basename "$FILE")
  FILENAME="${BASENAME%.*}"
  OUTFILE="$OUT_DIR/${FILENAME}.mp4"

  if [ -f "$OUTFILE" ]; then
    echo "Skipping $OUTFILE (already exists)"
    continue
  fi

  echo "Converting $FILE → $OUTFILE"

  ffmpeg -hide_banner -loglevel error -i "$FILE" \
    -c:v libx264 -preset fast -crf 23 \
    -c:a aac -b:a 128k \
    -movflags +faststart \
    "$OUTFILE"

  if [ $? -ne 0 ]; then
    echo "Error converting $FILE"
  fi
done

echo
echo "With great power comes great responsibility. Take care and use these files responsibly."
echo
echo "All done. Converted files are in $OUT_DIR"