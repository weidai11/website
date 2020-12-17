#!/usr/bin/env bash

# This script cleans up the web pages and style for the Crypto++ website.
# Please ensure you have both (1) HTML Tidy and (2) DOS Tools installed and on-path.

export LANG=en_US.utf8

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
    exit 1
fi

UNIX2DOS=$(command -v unix2dos)
if [[ -z "$UNIX2DOS" ]]; then
    echo "ERROR: could not locate unix2dos"
    exit 1
fi

# Cleanup HTML files
IFS= find . -type f -iname '*.html' -print | while read -r file
do
    echo "**************** $file ****************"

    echo "tidy: processing file $file..."
    "$HTML_TIDY" -utf8 --quiet yes --output-bom no --indent auto --indent-spaces 2 --wrap 90 -m "$file"

    echo "sed: processing file $file..."

    # Delete trailing whitespace
    "$SED" "${SED_OPTS[@]}" -e's/[[:space:]]*$//' "$file"

    # Fix encoding
    "$SED" "${SED_OPTS[@]}" -e's/opci&Atilde;&sup3;n/opción/g' "$file"

    echo "unix2dos: processing file $file..."

    # Fix CRLF endings after sed
    unix2dos "$file" 1>/dev/null

    # Delete the generator markup tag
    #"$SED" "${SED_OPTS[@]}" -e'/<meta name="generator".*/d' "$file"
    #"$SED" "${SED_OPTS[@]}" -e'/"HTML Tidy.*/d' "$file"
    #"$SED" "${SED_OPTS[@]}" -e'/"*see www.w3.org*/d' "$file"

    echo
done

IFS= find . -type f -iname '*.css' -print | while read -r file
do
    echo "**************** $file ****************"

    echo "sed: processing file $file..."

    # Delete the generator markup tag
    "$SED" "${SED_OPTS[@]}" -e'/<meta name="generator"/d' "$file"

    # Delete trailing whitespace
    "$SED" "${SED_OPTS[@]}" -e's/[[:space:]]*$//' "$file"

    echo "unix2dos: processing file $file..."

    # Fix CRLF endings after sed
    unix2dos "$file" 1>/dev/null
done

exit 0
