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

work_email="$(get_git_user_email_for_host sktc2)"
preferred_email="$(get_git_user_email_for_host obsidian)"

oldest_ref="$(git log --committer="$work_email" --pretty=format:"%H" | tail -n 1)"

git rebase \
    -i $oldest_ref \
    --exec "GIT_AUTHOR_NAME=\"$PREFERRED_NAME\" GIT_AUTHOR_EMAIL=\"$preferred_email\" GIT_COMMITTER_NAME=\"$PREFERRED_NAME\" GIT_COMMITTER_EMAIL=\"$preferred_email\" git commit --amend --no-edit --allow-empty"
