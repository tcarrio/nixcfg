#!/usr/bin/env bash

# This script rewrites commit author (name/email) when needed.

set -euo pipefail

PREFERRED_NAME="Tom Carrio"

derived_hostname="$(hostname)"
hostname="${derived_hostname:-obsidian}"

get_git_user_email_for_host() {
    hostname="$1"

    nix eval --raw ".#homeConfigurations.\"tcarrio@${hostname}\".config.programs.git.userEmail"
}

preferred_email="$(get_git_user_email_for_host obsidian)"

base_ref="${1:-}"
if [ -z "$base_ref" ]; then
  echo "Missing target base ref"
  exit 1
fi

git rebase \
    -i $base_ref \
    --exec "GIT_AUTHOR_NAME=\"$PREFERRED_NAME\" GIT_AUTHOR_EMAIL=\"$preferred_email\" GIT_COMMITTER_NAME=\"$PREFERRED_NAME\" GIT_COMMITTER_EMAIL=\"$preferred_email\" GIT_COMMITTER_DATE=\"$(date -R)\" git commit --date=\"$(date -R)\" --amend --no-edit --allow-empty"
