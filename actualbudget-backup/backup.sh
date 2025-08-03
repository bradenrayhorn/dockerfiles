#!/bin/bash

set -euo pipefail

log() {
    echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $1"
}

to_backup="/data"
archive_dir="/archive/data"

mkdir -p $archive_dir

find "$to_backup" -type f | while IFS= read -r source_file; do
    relative_path="${source_file#$to_backup/}"
    target_file="$archive_dir/$relative_path"
    
    mkdir -p "$(dirname "$target_file")"
    
    if [[ "$source_file" == *.sqlite ]]; then
        log "Backing up sqlite to $target_file"
        sqlite3 "$source_file" ".backup '$target_file'"
    else
        log "Copying to $target_file"
        cp "$source_file" "$target_file"
    fi
done

log "Compressing..."

cd "$(dirname $archive_dir)"
archive_base=$(basename $archive_dir)
tar -cf - $archive_base | xz -9 > /archive.tar.xz

log "Backing up with marmalade"
marmalade backup -f /archive.tar.xz
log "Backup process completed successfully!"

