#!/bin/bash

TITLE="${1:-Unknown}"

PREFIX_TO_TRIM="./output/"

cp -r template/* output/

pngs=()
pages=()
html_elems=()

for filepath in ./output/images/*; do
  if [ -f "$filepath" ]; then
    page="${filepath#$PREFIX_TO_TRIM}"
    pngs+=("$page")
  fi
done

echo "Processing ${#pngs[@]} pages..."

for index in "${!pngs[@]}"; do
  value="${pngs[index]}"
  page="<item href=\"$value\" id=\"id$((index + 1))\" media-type=\"image/png\"/>"
  pages+=("$page"$'\n')
done

for index in "${!pngs[@]}"; do
  value="${pngs[index]}"
  elem="<p class=\"paragraph\"><a id=\"id$((index + 1))\"></a><img src=\"$value\" class=\"image\"/></p>"
  html_elems+=("$elem"$'\n')
done


OLD_IFS="$IFS"
IFS=''

# Expand the array into a single string
pages_str="${pages[*]}"
elems_str="${html_elems[*]}"

# Restore the original IFS
IFS="$OLD_IFS"

uuid=$(uuidgen)

# Now do some token replacing and whatnot

perl -pi -e "s|CONTENT|${pages_str//|SPLIT|/}|g" ./output/content.opf
perl -pi -e "s|AUTHOR|Unknown|g" ./output/content.opf
perl -pi -e "s|CONTRIB|Unknown|g" ./output/content.opf
perl -pi -e "s|TITLE|${TITLE}|g" ./output/content.opf
perl -pi -e "s|UUID|${uuid}|g" ./output/content.opf
perl -pi -e "s|CONTENT|${elems_str//|SPLIT|/}|g" ./output/index.html
perl -pi -e "s|TITLE|${TITLE}|g" ./output/toc.ncx
perl -pi -e "s|UUID|${uuid}|g" ./output/toc.ncx