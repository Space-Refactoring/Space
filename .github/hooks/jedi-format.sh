#!/bin/sh
set -eu

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

config=".github/config/pascal-format.cfg"
formatter="/usr/local/bin/jcf"

if [ ! -f "$config" ]; then
  echo "Fehler: Pascal-Format-Config nicht gefunden unter $config" >&2
  exit 1
fi

if [ ! -x "$formatter" ]; then
  echo "Fehler: Formatter '$formatter' nicht gefunden oder nicht ausführbar." >&2
  exit 1
fi

for file in "$@"; do
  [ -f "$file" ] || continue

  tmp="${file}.fmt"

  trap 'rm -f "$tmp"' EXIT

  if ! "$formatter" -config="$config" -out "$tmp" "$file"; then
    rm -f "$tmp"
    exit 1
  fi

  mv "$tmp" "$file"

  git add "$file"

  trap - EXIT
done
