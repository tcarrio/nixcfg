# Convert a video to an optimized GIF using a generated palette.

width=480
fps=15
force=0

usage() {
  cat <<USAGE
Usage: vid2gif [--width=N] [--fps=N] [--force] <input> <output.gif>

Options:
  -w, --width=N   Output width in pixels, height keeps aspect ratio (default: $width)
  --fps=N         Output frames per second (default: $fps)
  -f, --force     Overwrite the output file if it exists
  -h, --help      Show this help
USAGE
}

die() {
  echo "vid2gif: $*" >&2
  exit 1
}

positional=()
while [[ $# -gt 0 ]]; do
  case "$1" in
  --width=*)
    width="${1#*=}"
    shift
    ;;
  -w | --width)
    [[ $# -ge 2 ]] || die "$1 requires a value"
    width="$2"
    shift 2
    ;;
  --fps=*)
    fps="${1#*=}"
    shift
    ;;
  --fps)
    [[ $# -ge 2 ]] || die "$1 requires a value"
    fps="$2"
    shift 2
    ;;
  -f | --force)
    force=1
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  --)
    shift
    positional+=("$@")
    break
    ;;
  -*)
    usage >&2
    die "unknown option: $1"
    ;;
  *)
    positional+=("$1")
    shift
    ;;
  esac
done

if [[ ${#positional[@]} -ne 2 ]]; then
  usage >&2
  exit 1
fi

input="${positional[0]}"
output="${positional[1]}"

[[ "$width" =~ ^[0-9]+$ && "$width" -gt 0 ]] || die "--width must be a positive integer"
[[ "$fps" =~ ^[0-9]+(\.[0-9]+)?$ ]] || die "--fps must be a positive number"
[[ -f "$input" ]] || die "input not found: $input"
if [[ -e "$output" && "$force" -ne 1 ]]; then
  die "output exists: $output (use -f/--force to overwrite)"
fi

exec ffmpeg -hide_banner -loglevel warning -y -i "$input" \
  -vf "fps=${fps},scale=${width}:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  "$output"
