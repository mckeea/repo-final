#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/helpers/git-utils.sh"

echo "🧹 Cleaning up publish branch..."
run_git "deleting remote branch $GITHUB_REF_NAME" push origin --delete "$GITHUB_REF_NAME" || true
