#!/bin/sh
set -eu

repo_root=$(git rev-parse --show-toplevel)
config="$repo_root/ptop.cfg"

for file do
  case "$file" in
    /*) ;;
    *) file="$repo_root/$file" ;;
  esac

  tmp="${file}.ptop-tmp"

  if ! ptop -c -i 2 "$config" "$file" "$tmp"; then
    rm -f "$tmp"
    exit 1
  fi

  mv "$tmp" "$file"
done
