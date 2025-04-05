#!/bin/bash

# Function to log with timestamp
log() {
    echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $1"
}

# Function to handle errors
handle_error() {
    log "Error: $1"
    exit 1
}

# Check if required commands are available
commands=("gh" "marmalade" "age")
for cmd in "${commands[@]}"; do
    if ! command -v $cmd &> /dev/null; then
        handle_error "$cmd is not installed"
    fi
done

# Check if required environment variables are set
if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_USERNAME" ] || [ -z "$AGE_IDENTITY" ] ; then
    handle_error "Missing required environment variables"
fi

git config --global credential.helper store
touch ~/.git-credentials
chmod 600 ~/.git-credentials
echo "https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com" > ~/.git-credentials

mkdir repos
cd repos

# Get list of all repositories
log "Fetching repository list..."
REPOS=$(gh repo list $GITHUB_USERNAME --json name --jq '.[].name' --limit 1000)

# Process each repository
for repo in $REPOS; do
    log "Cloning repository: $repo"

    # Clone repository with all branches
    git clone "https://github.com/$GITHUB_USERNAME/$repo" -q --mirror || handle_error "Failed to clone $repo"
done

log "Repositories loaded!"

cd ..

log "Compressing and encrypting..."

tar -cJf archive.tar.xz --options xz:compression-level=9 repos/
echo "$AGE_IDENTITY" > age.id
age -i age.id -e -o archive.tar.xz.age archive.tar.xz

log "Backing up with marmalade"

marmalade backup -path archive.tar.xz.age

log "Backup process completed successfully!"

