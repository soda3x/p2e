#!/bin/bash
shopt -s extglob

TITLE="${1:-Unknown}"

PREFIX_TO_TRIM="./output/"

cp -r template/!(page.xhtml) output/

pngs=()
pages=()
spine_elems=()

# Get just the filenames of the images in ./output
for filepath in ./output/images/*; do
  if [ -f "$filepath" ]; then
    page="${filepath#$PREFIX_TO_TRIM}"
    pngs+=("$page")
  fi
done

echo "Processing ${#pngs[@]} pages..."

# Create the cover image element for the content.opf
cover="<item href=\"${pngs[0]}\" id=\"cover_image_id\" media-type=\"image/png\" properties=\"cover-image\"/>"

# Create the things required for the content.opf file
for index in "${!pngs[@]}"; do
  value="${pngs[index]}"
  pageNum="$((index + 1))"

  # Page reference elements
  page="<item href=\"page$pageNum.xhtml\" id=\"page$pageNum\" media-type=\"application/xhtml+xml\" properties=\"svg rendition:layout fixed\"/>"
  # Need to also add the image itself to the manifest
  img="<item href=\"$value\" id=\"img$pageNum\" media-type=\"image/png\"/>"
  pages+=("$page"$'\n')
  pages+=("$img"$'\n')

  # Spine elements
  spine="<itemref idref=\"page$pageNum\"/>"
  spine_elems+=("$spine"$'\n')

  # Create an xhtml file for the page
  PAGE_FILE="./output/page$pageNum.xhtml"
  cp template/page.xhtml $PAGE_FILE
  perl -pi -e "s|IMAGE_REF|${value}|g" $PAGE_FILE
  perl -pi -e "s|PAGE_NUM|Page ${pageNum}|g" $PAGE_FILE
done

# Keep the old IFS to restore after
OLD_IFS="$IFS"

# Create new IFS
IFS=''

# Expand the array into a single string
pages_str="${pages[*]}"
elems_str="${spine_elems[*]}"

# Restore the original IFS
IFS="$OLD_IFS"

# Generate a UUID to identify the book
uuid=$(uuidgen)

# Now populate the content.opf file
CONTENT_OPF_FILE=./output/content.opf

perl -pi -e "s|COVER|${cover}|g" $CONTENT_OPF_FILE
perl -pi -e "s|CONTENT|${pages_str//|SPLIT|/}|g" $CONTENT_OPF_FILE
perl -pi -e "s|SPINE|${elems_str//|SPLIT|/}|g" $CONTENT_OPF_FILE
perl -pi -e "s|AUTHOR|Unknown|g" $CONTENT_OPF_FILE
perl -pi -e "s|CONTRIB|Unknown|g" $CONTENT_OPF_FILE
perl -pi -e "s|TITLE|${TITLE}|g" $CONTENT_OPF_FILE
perl -pi -e "s|UUID|${uuid}|g" $CONTENT_OPF_FILE