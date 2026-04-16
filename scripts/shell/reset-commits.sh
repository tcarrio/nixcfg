#!/usr/bin/env bash

# This script rewrites commit author (name/email) when needed.

set -euo pipefail

DEFAULT_HOSTNAME="obsidian"
DEFAULT_USERNAME="tcarrio"
PREFERRED_NAME="Tom Carrio"

show_usage() {
  echo "Usage: $(basename "$0") [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -u, --user USER     Git username (default: \$(whoami) or $DEFAULT_USERNAME)"
  echo "  -h, --host HOST     Hostname for email lookup (default: \$(hostname) or $DEFAULT_HOSTNAME)"
  echo "  -e, --email EMAIL   Git email (skips user/host lookup when provided)"
  echo "  -r, --ref REF       Target base ref for rebase (required)"
  echo "  -d, --date DATE     Date for amended commits (default: current date)"
  echo "      --help          Show this help message"
}

get_git_user_email_for_host() {
  host="$1"
  user="$2"

  nix eval --raw ".#homeConfigurations.\"$user@${host}\".config.programs.git.userEmail"
}

cli_hostname=""
cli_username=""
cli_email=""
cli_ref=""
cli_date=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--user)
      cli_username="$2"
      shift 2
      ;;
    -h|--host)
      cli_hostname="$2"
      shift 2
      ;;
    -e|--email)
      cli_email="$2"
      shift 2
      ;;
    -r|--ref)
      cli_ref="$2"
      shift 2
      ;;
    -d|--date)
      cli_date="$2"
      shift 2
      ;;
    --help)
      show_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_usage
      exit 1
      ;;
  esac
done

base_ref="${cli_ref:-}"
if [ -z "$base_ref" ]; then
  echo "Missing target base ref"
  exit 1
fi

if [ -n "$cli_email" ]; then
  preferred_email="$cli_email"
else
  derived_hostname="$(hostname)"
  hostname="${cli_hostname:-${derived_hostname:-$DEFAULT_HOSTNAME}}"

  derived_username="$(whoami)"
  username="${cli_username:-${derived_username:-$DEFAULT_USERNAME}}"

  preferred_email="$(get_git_user_email_for_host $hostname $username)"
fi

commit_date="${cli_date:-$(date -R)}"

git rebase \
  -i $base_ref \
  --exec "GIT_AUTHOR_NAME=\"$PREFERRED_NAME\" GIT_AUTHOR_EMAIL=\"$preferred_email\" GIT_COMMITTER_NAME=\"$PREFERRED_NAME\" GIT_COMMITTER_EMAIL=\"$preferred_email\" GIT_COMMITTER_DATE=\"$commit_date\" git commit --date=\"$commit_date\" --amend --no-edit --allow-empty"
