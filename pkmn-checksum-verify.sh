#!/usr/bin/env bash

ROM="$1"

if [ -z "$ROM" ]; then
	echo "Usage: ./check_pkmn2.sh <romfile.nds>"
	exit 1
fi

echo "Calculating SHA-1 hash for '$ROM' ..."
HASH=$(sha1sum "$ROM" | awk '{print $1}')
SIZE=$(stat -c%s "$ROM")

EXPECTED_HASH="2a574f699ecbd068cb78ad11f673a19c545b4815"
EXPECTED_SIZE_MIN=511000000
EXPECTED_SIZE_MAX=513000000

echo " -> Found SHA-1:  $HASH"
echo " -> File size:   $SIZE bytes"

if [[ "$HASH" == "$EXPECTED_HASH" ]] && (( SIZE > EXPECTED_SIZE_MIN && SIZE < EXPECTED_SIZE_MAX )); then
	echo "✅ ROM is a clean EU No-Intro dump."
else
	echo "❌ ROM has been modified, trimmed, or is not an official dump."
fi