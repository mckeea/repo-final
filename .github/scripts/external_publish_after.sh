#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/helpers/git-utils.sh"

echo "🧹 Cleaning up publish branch..."
run_git "deleting remote branch $PUBLISH_BRANCH" push origin --delete "$PUBLISH_BRANCH" || true
run_git "deleting remote tag $PUBLISH_BRANCH" push origin --delete "v-$PUBLISH_BRANCH" || true
