#!/bin/bash

# Usage:
# ./run-gh-script.sh <github_owner> <repo_name> <branch_or_tag> <path_to_script_in_repo> [args...]

OWNER="$1"
REPO="$2"
REF="$3"
SCRIPT_PATH="$4"
shift 4

TMP_DIR=$(mktemp -d)
trap 'echo -e "\nDeleting temporary directory: $TMP_DIR"; rm -rf "$TMP_DIR"' EXIT

echo "Cloning repo..."
git clone --depth 1 --branch "$REF" "https://github.com/${OWNER}/${REPO}.git" "$TMP_DIR"

SCRIPT="$TMP_DIR/$SCRIPT_PATH"
if [[ ! -f "$SCRIPT" ]]; then
  echo "Script not found: $SCRIPT"
  exit 1
fi

chmod +x "$SCRIPT"
"$SCRIPT" "$@"