#!/bin/bash

#
# pdf_to_png.sh
#
# Converts one or more PDF files to a series of PNG images, one image per page.
#
# DEPENDENCY: Requires 'pdftoppm', which is part of the 'poppler-utils' package.
# To install on Debian/Ubuntu: sudo apt install poppler-utils
# To install on Fedora/RHEL:   sudo dnf install poppler-utils
# To install on macOS (Homebrew): brew install poppler
#
# USAGE:
# ./pdf_to_png.sh your_file.pdf
# ./pdf_to_png.sh file1.pdf file2.pdf "file with spaces.pdf"
#
# OUTPUT:
# For a file named 'my_doc.pdf', it will create images named:
# my_doc-1.png, my_doc-2.png, my_doc-3.png, etc.

# --- Configuration ---
# Set the resolution in DPI (dots per inch).
# 150 is good for screen viewing. 300 is better for high quality.
DPI=300

# --- Check for dependency ---
if ! command -v pdftoppm &> /dev/null
then
    echo "Error: 'pdftoppm' command not found." >&2
    echo "Please install 'poppler-utils' to use this script." >&2
    exit 1
fi

# --- Check if any files were provided ---
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 file.pdf" >&2
    exit 1
fi

# --- Process each file ---
for pdf_file in "$@"
do
    # Check if the file exists
    if [ ! -f "$pdf_file" ]; then
        echo "Warning: File '$pdf_file' not found. Skipping."
        continue
    fi

    # Get the base filename without the '.pdf' extension
    # 'reports/my_doc.pdf' -> 'my_doc'
    base_prefix=$(basename "$pdf_file" .pdf)

    # Replace spaces with underscores for the output prefix
    output_prefix="${base_prefix// /_}"

    # Run the conversion
    # -png : Specifies the output format is PNG
    # -r $DPI : Sets the resolution (DPI)
    # "$pdf_file" : The input PDF file
    # "$output_prefix" : The prefix for all output PNG files.
    #                 pdftoppm will automatically add '-1.png', '-2.png', etc.
    rm -rf ./output
    mkdir -p ./output/images
    pushd ./output/images > /dev/null
    pdftoppm -png -r $DPI "$pdf_file" "$output_prefix" > /dev/null
    popd > /dev/null

    if [ $? -ne 0 ]; then
        echo "Error converting '$pdf_file'."
    fi
done
