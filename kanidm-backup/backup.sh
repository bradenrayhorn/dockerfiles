#!/bin/bash

# Exit on error
set -e

# Required env vars:
#   PASSWORD
#   BACKUP_DIR
#   RETENTION_DAYS
#   B2_BUCKET_NAME
#   B2_APPLICATION_KEY_ID
#   B2_APPLICATION_KEY

# Configure variables
PW=$PASSWORD
TODAY=$(date +%Y-%m-%d)
RETENTION_CLEANUP_SECONDS=$(($RETENTION_DAYS * 24 * 60 * 60))

# List all files in the B2 bucket
echo "Listing all files in B2 bucket $B2_BUCKET_NAME..."
B2_FILES=$(b2 ls "b2://$B2_BUCKET_NAME")


# upload files
for FILE in $(find "$BACKUP_DIR" -type f | grep -E '[0-9]{4}-[0-9]{2}-[0-9]{2}'); do
    FILENAME=$(basename "$FILE")
  
    # Extract the date from the filename using regex
    if [[ $FILENAME =~ ([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
        FILE_DATE="${BASH_REMATCH[1]}"
        ENCRYPTED_FILE="/tmp/$FILE_DATE.age"

        echo "Encrypting file $FILENAME with date $FILE_DATE..."
        expect <<EOF > /dev/null 2>&1
        spawn age -o "$ENCRYPTED_FILE" -p "$FILE"
        send "$PW\r"
        send "$PW\r"
        expect eof
EOF

        echo "Uploading encrypted file to B2 as $FILE_DATE.age..."
        b2 file upload --no-progress "$B2_BUCKET_NAME" "$ENCRYPTED_FILE" "$FILE_DATE.age"

        # Clean up temporary encrypted file
        rm -f "$ENCRYPTED_FILE"
    fi
done

# Calculate date for old file cleanup
CUTOFF_DATE=$(date -d "@$(( $(date +%s) - $RETENTION_CLEANUP_SECONDS ))" +%Y-%m-%d)

echo "Cleaning up old backups (older than $CUTOFF_DATE)..."

for FILENAME in $B2_FILES; do
    # Extract the date from the filename using regex
    if [[ $FILENAME =~ ([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
        FILE_DATE="${BASH_REMATCH[1]}"
        # compare dates
        if [[ "$FILE_DATE" < "$CUTOFF_DATE" ]]; then
            echo "Deleting old backup: $FILENAME (from $FILE_DATE)..."
            b2 rm --no-progress --versions -r "b2://$B2_BUCKET_NAME/$FILENAME" || true
        fi
    else
        # delete file
        echo "Deleting unknown backup: $FILENAME..."
        b2 rm --no-progress --versions -r "b2://$B2_BUCKET_NAME/$FILENAME" || true
    fi
done

echo "Backup process completed successfully!"

