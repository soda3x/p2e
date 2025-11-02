#!/bin/bash

usage() {
    echo "Usage: $0 <directory> [recursive]"
    echo "Converts all PDF files in the specified directory (and optionally its subdirectories) to EPUB using p2e"
    echo "  <directory>  : The starting directory to search for PDFs."
    echo "  [recursive]  : Use the word 'recursive' (or 'r') as the second argument to search subdirectories."
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' not found."
    exit 1
fi

if [[ "$2" == "recursive" || "$2" == "r" ]]; then
    echo "Searching for PDFs recursively in: $TARGET_DIR"
    # The default find behavior is recursive
    FIND_COMMAND="find \"$TARGET_DIR\" -type f -iname '*.pdf'"
else
    echo "Searching for PDFs non-recursively in: $TARGET_DIR"
    # Limiting the search depth to 1 prevents recursive search
    FIND_COMMAND="find \"$TARGET_DIR\" -maxdepth 1 -type f -iname '*.pdf'"
fi

eval "$FIND_COMMAND" | while IFS= read -r pdf_file; do
    ./p2e.sh "$pdf_file"
done

echo "Done."