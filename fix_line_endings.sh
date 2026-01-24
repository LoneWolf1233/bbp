#!/bin/bash
# Script to fix line endings for noble.sh and toolbox.sh
# Run this on Linux/Kali after transferring the files

if command -v dos2unix >/dev/null 2>&1; then
    echo "Converting line endings using dos2unix..."
    dos2unix noble.sh toolbox.sh
    echo "Done! Files converted to Unix line endings."
elif command -v sed >/dev/null 2>&1; then
    echo "Converting line endings using sed..."
    sed -i 's/\r$//' noble.sh toolbox.sh
    echo "Done! Files converted to Unix line endings."
else
    echo "Error: Neither dos2unix nor sed found. Please install dos2unix:"
    echo "  sudo apt-get install dos2unix"
    exit 1
fi

chmod +x noble.sh toolbox.sh
echo "Files are now executable and ready to use!"
