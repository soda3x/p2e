#!/bin/bash

USAGE="Usage: $0 <input_pdf_file>"

if [ "$#" -lt 1 ]; then
    echo "Error: Missing file." >&2
    echo "$USAGE" >&2
    exit 1
fi

FILENAME="$1"

if [[ $(file --mime-type -b "$FILENAME") != "application/pdf" ]]; then
    echo "Error: $FILENAME is not a PDF." >&2
    echo "$USAGE" >&2
    exit 1
fi

FILENAME_NO_EXT="${FILENAME%.*}"

echo "Converting $FILENAME to epub..."

source pdf_to_png.sh
source png_to_epub.sh

pushd ./output > /dev/null

EPUB_FILE="${FILENAME_NO_EXT}.epub"

zip -r "$EPUB_FILE" . > /dev/null

popd > /dev/null

# Clean-up
rm -rf ./output

echo "Created ${EPUB_FILE}."