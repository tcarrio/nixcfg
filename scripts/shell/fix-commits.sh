#!/usr/bin/env bash

# This script rewrites commit author (name/email) when needed.

set -euo pipefail

PREFERRED_NAME="Tom Carrio"
DEFAULT_HOSTNAME="obsidian"
DEFAULT_USERNAME="tcarrio"
DEFAULT_BEFORE_HOST="sktc2"

show_usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -b, --before EMAIL  Email to search for (default: looked up via nix for user@\$DEFAULT_BEFORE_HOST)"
    echo "  -a, --after EMAIL   Email to replace with (default: looked up via nix for user@host)"
    echo "  -u, --user USER     Username for nix email lookup (default: \$(whoami) or $DEFAULT_USERNAME)"
    echo "  -h, --host HOST     Hostname for after-email lookup (default: \$(hostname) or $DEFAULT_HOSTNAME)"
    echo "  -r, --ref REF       Target base ref for rewrite (default: oldest commit from --before email)"
    echo "      --help          Show this help message"
}

get_git_user_email_for_host() {
    host="$1"
    user="$2"

    nix eval --raw ".#homeConfigurations.\"$user@${host}\".config.programs.git.userEmail"
}

cli_before=""
cli_after=""
cli_user=""
cli_hostname=""
cli_ref=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--before)
            cli_before="$2"
            shift 2
            ;;
        -a|--after)
            cli_after="$2"
            shift 2
            ;;
        -u|--user)
            cli_user="$2"
            shift 2
            ;;
        -h|--host)
            cli_hostname="$2"
            shift 2
            ;;
        -r|--ref)
            cli_ref="$2"
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

derived_hostname="$(hostname)"
hostname="${cli_hostname:-${derived_hostname:-$DEFAULT_HOSTNAME}}"

derived_username="$(whoami)"
username="${cli_user:-${derived_username:-$DEFAULT_USERNAME}}"

if [ -z "$cli_before" ]; then
    cli_before="$(get_git_user_email_for_host "$DEFAULT_BEFORE_HOST" "$username")"
fi

if [ -z "$cli_after" ]; then
    cli_after="$(get_git_user_email_for_host "$hostname" "$username")"
fi

if [ -z "$cli_ref" ]; then
    cli_ref="$(git log --committer="$cli_before" --pretty=format:"%H" | tail -n 1)"

    if [ -z "$cli_ref" ]; then
        echo "No commits found for email: $cli_before"
        exit 1
    fi
fi

git filter-branch -f --env-filter '
OLD_EMAIL="'"$cli_before"'"
CORRECT_EMAIL="'"$cli_after"'"
CORRECT_NAME="'"$PREFERRED_NAME"'"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]; then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]; then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' "$cli_ref"^..HEAD
