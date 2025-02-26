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

KOPIA_CHECK_FOR_UPDATES=false

# Check if required commands are available
commands=("gh" "kopia")
for cmd in "${commands[@]}"; do
    if ! command -v $cmd &> /dev/null; then
        handle_error "$cmd is not installed"
    fi
done

# Check if required environment variables are set
if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_USERNAME" ] || [ -z "$KOPIA_CONFIG" ] ; then
    handle_error "Missing required environment variables"
fi

log "Connect kopia"
kopia repository connect from-config --token $KOPIA_CONFIG || handle_error "Could not connect kopia"
kopia repository status || handle_error "Could not get kopia status"

log "kopia maintenance"
kopia maintenance set --owner=me
kopia maintenance run

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

log "Backing up with kopia"
kopia snapshot create repos

log "Backup process completed successfully!"

