#!/usr/bin/env bash

set -euo pipefail

if [[ -t 0 ]]; then
  printf 'Usage: cat cv.yaml | %s [output.pdf]\n' "$0" >&2
  exit 2
fi

script_dir="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")"
output_file="${1:-resume.pdf}"
cv_file="$(mktemp "$script_dir/.cv.XXXXXX")"
cv_name="$(basename -- "$cv_file")"

cleanup() {
  rm -f -- "$cv_file"
}
trap cleanup EXIT

cat > "$cv_file"
typst compile \
  --input "cv-file=$cv_name" \
  "$script_dir/main.typ" \
  "$output_file"
