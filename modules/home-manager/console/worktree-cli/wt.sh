#!/usr/bin/env bash
# wt — portable Claude-style git worktree helper (extracted from phx-wt)
#
#   wt new --bare [name] [--base <ref>]   create worktree + claude/<name> branch, print path
#   wt new [name] [claude args...]        create via `claude --worktree`
#   wt where <name>                       print the worktree path for <name>
#   wt rm <name> [--force]                remove a worktree and its claude/<name> branch
#   wt list                               list worktrees under .claude/worktrees
#
# `new --bare` prints the worktree path to stdout (diagnostics to stderr) so you
# can drop into it:
#     fish:      cd (wt new --bare)
#     bash/zsh:  cd "$(wt new --bare)"

set -euo pipefail

# --- Claude-style name parts (kept in parity with `claude --worktree`) ---------
# shellcheck disable=SC2034
ADJECTIVES=(admiring amazing angry bold brave busy charming clever confident cool
  crisp curious dazzling determined eager elegant epic fervent flamboyant fluffy
  focused friendly gallant happy humble inspiring jolly jovial keen kind laughing
  loving lucid magical memoized mighty modest moonlit mystical nice optimistic
  peaceful pedantic pensive practical prancy priceless quirky recursing relaxed
  resilient robust romantic sad serene sharp silly sleepy stateless stoic strange
  stupefied suspicious sweet tender thirsty trusting unruffled upbeat vibrant
  vigilant wizardly wonderful xenodochial youthful zealous zen)

# shellcheck disable=SC2034
VERBING=(amortizing balancing bubbling caching chasing churning coalescing compiling
  crunching dancing diving drifting echoing evolving flowing forging gleaming gliding
  hashing hopping hovering jumping leaping looping merging orbiting parsing pivoting
  pulsing racing reducing roaming rolling roving searching seeking shifting shimmering
  singing sliding snuggling soaring sorting spinning swimming switching thinking
  tracing twirling walking wandering waving whirring whispering zipping)

# shellcheck disable=SC2034
SURNAMES=(antonelli archimedes babbage banach bardeen bell benz berners-lee bohr
  boltzmann boyd brahmagupta brattain buck carson cartwright cerf chandrasekhar
  chatelet chatterjee chebyshev church clarke cohen colden curie darwin davinci
  dijkstra dirac dubinsky easley edison einstein elgamal engelbart euclid euler
  faraday fermat fermi feynman franklin galileo galois gauss germain goldberg
  goldstine goldwasser golick goodall hamilton hawking heisenberg hellman hermann
  hertz heyrovsky hodgkin hofstadter hoover hopcroft hopper hugle hypatia jackson
  jang jemison jepsen johnson joliot jones kalam kapitsa kare keldysh keller kepler
  khayyam khorana kilby kirch knuth kowalevski lalande lamarr lamport leakey leavitt
  lederberg lehmann lewin lichterman liskov lovelace lumiere mahavira margulis
  matsumoto maxwell mayer mccarthy mcclintock mclaren mclean mcnulty mendel mendeleev
  merkle meitner meninsky mestorf micali mirzakhani moore morse moser murdock napier
  nash neumann newton nightingale nobel noether northcutt noyce panini pare pascal
  pasteur payne perlman pike planck poincare poitras proskuriakova ptolemy raman
  ramanujan rhodes ride rivest ritchie robinson roentgen rosalind rubin saha sammet
  sanderson satoshi shamir shannon shaw shirley shockley sinoussi snyder solomon
  spence sutherland swanson swartz swirles taussig tereshkova tesla tharp thompson
  torvalds tu turing varahamihira visvesvaraya volhard wescoff wilbur wiles williams
  williamson wilson wing wozniak wright wu yalow yonath zhukovsky)

# --- helpers -------------------------------------------------------------------
die() {
  echo "wt: $*" >&2
  exit 1
}

# Random element of an array named by $1 (bash 3.2-safe, no namerefs).
pick() {
  local arr="$1" count idx
  eval "count=\${#${arr}[@]}"
  idx=$((RANDOM % count))
  eval "printf '%s' \"\${${arr}[$idx]}\""
}

generate_name() { printf '%s-%s-%s' "$(pick ADJECTIVES)" "$(pick VERBING)" "$(pick SURNAMES)"; }

# Main worktree root, even when invoked from inside a linked worktree.
main_repo_root() {
  local common
  common=$(git rev-parse --path-format=absolute --git-common-dir) ||
    die "not inside a git repository"
  case "$common" in
  */.git) dirname "$common" ;;
  *) printf '%s' "$common" ;;
  esac
}

worktrees_base_dir() { printf '%s/.claude/worktrees' "$1"; }

branch_exists() { git show-ref --verify --quiet "refs/heads/claude/$1"; }

name_available() {
  local name="$1" root path
  root=$(main_repo_root)
  path="$(worktrees_base_dir "$root")/$name"
  [[ -e "$path" ]] && return 1
  branch_exists "$name" && return 1
  return 0
}

pick_available_name() {
  local i candidate
  for ((i = 0; i < 50; i++)); do
    candidate=$(generate_name)
    if name_available "$candidate"; then
      printf '%s' "$candidate"
      return 0
    fi
  done
  die "could not generate an unused worktree name after 50 attempts"
}

create_bare_worktree() {
  local name="$1" base="${2:-}" root path branch
  root=$(main_repo_root)
  path="$(worktrees_base_dir "$root")/$name"
  branch="claude/$name"
  if [[ -n "$base" ]]; then
    git -C "$root" worktree add "$path" -b "$branch" "$base" >&2
  else
    git -C "$root" worktree add "$path" -b "$branch" >&2
  fi
  printf '%s' "$path"
}

# --- commands ------------------------------------------------------------------
cmd_new() {
  local bare=0 args=() a
  for a in "$@"; do
    if [[ "$a" == "--bare" ]]; then bare=1; else args+=("$a"); fi
  done

  if [[ "$bare" -eq 0 ]]; then
    exec claude --worktree "${args[@]}"
  fi

  local name="" base="" i=0
  while [[ $i -lt ${#args[@]} ]]; do
    a="${args[$i]}"
    if [[ "$a" == "--base" ]]; then
      i=$((i + 1))
      base="${args[$i]:-}"
    elif [[ -z "$name" ]]; then
      name="$a"
    fi
    i=$((i + 1))
  done

  [[ -z "$name" ]] && name=$(pick_available_name)
  local path
  path=$(create_bare_worktree "$name" "$base")
  echo "wt: created $path" >&2
  printf '%s\n' "$path"
}

cmd_where() {
  local name="${1:-}"
  [[ -z "$name" ]] && die "where requires a <name>"
  local root path
  root=$(main_repo_root)
  path="$(worktrees_base_dir "$root")/$name"
  [[ -d "$path" ]] || die "no worktree named $name"
  printf '%s\n' "$path"
}

cmd_rm() {
  local force=0 name="" a
  for a in "$@"; do
    if [[ "$a" == "--force" ]]; then force=1; else name="$a"; fi
  done
  [[ -z "$name" ]] && die "rm requires a <name>"
  local root path branch="claude/$name"
  root=$(main_repo_root)
  path="$(worktrees_base_dir "$root")/$name"
  if [[ "$force" -eq 1 ]]; then
    git -C "$root" worktree remove --force "$path"
    git -C "$root" branch -D "$branch" 2>/dev/null || true
  else
    git -C "$root" worktree remove "$path"
    git -C "$root" branch -d "$branch"
  fi
  echo "removed worktree $name" >&2
}

cmd_list() {
  local root base
  root=$(main_repo_root)
  base=$(worktrees_base_dir "$root")
  [[ -d "$base" ]] || return 0
  local d
  for d in "$base"/*/; do
    [[ -d "$d" ]] || continue
    printf '%s\n' "${d%/}"
  done
}

main() {
  local cmd="${1:-}"
  shift || true
  case "$cmd" in
  new) cmd_new "$@" ;;
  where) cmd_where "$@" ;;
  rm | remove) cmd_rm "$@" ;;
  list | ls) cmd_list "$@" ;;
  "" | -h | --help)
    sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
    ;;
  *) die "unknown command: $cmd (try --help)" ;;
  esac
}

main "$@"
