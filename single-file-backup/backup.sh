#!/bin/bash

set -euo pipefail

log() {
    echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $1"
}

mapfile -t matching_files < <(find "$BACKUP_DIR" -type f -exec basename {} \; | grep -E "$PATTERN")

if [ ${#matching_files[@]} -eq 1 ]; then
    file="$BACKUP_DIR/${matching_files[0]}"

    mkdir archive/
    cp $file archive/${matching_files[0]}

    log "Compressing and encrypting..."
    tar -cf - archive | xz -9 > archive.tar.xz
    echo "$AGE_IDENTITY" > age.id
    age -i age.id -e -o archive.tar.xz.age archive.tar.xz

    log "Backing up with marmalade"
    marmalade backup -path archive.tar.xz.age
    log "Backup process completed successfully!"

    exit 0
elif [ ${#matching_files[@]} -gt 1 ]; then
    echo "Error: More than one file matches '$PATTERN'!" >&2
    for file in "${matching_files[@]}"; do
        echo "$file" >&2
    done

    exit 1
else
    echo "No files matching '$PATTERN' found. $BACKUP_DIR contains:" >&2
    ls -lah "$BACKUP_DIR"
    exit 1
fi

