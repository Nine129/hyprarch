#!/bin/bash
# Extract archive to current directory using ouch
# Usage: extract.sh <archive_file>

set -e

FILE="$1"

if [ -z "$FILE" ]; then
    echo "No file specified"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 1
fi

echo "Extracting: $(basename "$FILE")"

ouch d -y "$FILE"

echo "Done!"
