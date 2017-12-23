#!/usr/bin/env bash

# This script cleans up the web pages and style for the Crypto++ website.
# Please ensure you have both (1) HTML Tidy and (2) DOS Tools installed and on-path

SED=sed
SED_OPTS=

IS_DARWIN=$(uname -s | grep -i -c darwin)
if [[ "$IS_DARWIN" -ne 0 ]]; then
    SED_OPTS=(-i "")
else
    SED_OPTS=(-i)
fi

HTML_TIDY=$(command -v tidy)
if [[ -z "$HTML_TIDY" ]]; then
    HTML_TIDY=$(command -v htmltidy)
fi

if [[ -z "$HTML_TIDY" ]]; then
    echo "ERROR: could not locate HTML Tidy"
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

UNIX2DOS=$(command -v unix2dos)
if [[ -z "$UNIX2DOS" ]]; then
    echo "ERROR: could not locate unix2dos"
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

# Cleanup HTML files
for file in *.html
do
    echo "**************** $file ****************"

    echo "tidy: processing file $file..."
    "$HTML_TIDY" --quiet yes --output-bom no --indent auto --wrap 90 -m "$file"

    echo "sed: processing file $file..."

    # Delete trailing whitespace
    "$SED" "${SED_OPTS[@]}" -e's/[[:space:]]*$//' "$file"

    # Delete the generator markup tag
    "$SED" "${SED_OPTS[@]}" -e'/<meta name="generator".*/d' "$file"
    "$SED" "${SED_OPTS[@]}" -e'/"HTML Tidy.*/d' "$file"
    "$SED" "${SED_OPTS[@]}" -e'/"*see www.w3.org*/d' "$file"

    # Fix change from UTF-8 to ASCII
    "$SED" "${SED_OPTS[@]}" -e's/charset=us-ascii/charset=utf-8/g' "$file"

    # Fix CRLF endings after sed
    unix2dos "$file"

    echo
done

# Delete the generator markup tag
"$SED" "${SED_OPTS[@]}" -e'/<meta name="generator"/d' *.css

# Delete trailing whitespace
"$SED" "${SED_OPTS[@]}" -e's/[[:space:]]*$//' *.css

[[ "$0" = "$BASH_SOURCE" ]] && exit 0 || return 0
