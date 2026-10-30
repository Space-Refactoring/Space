#!/bin/bash

# Commit-Nachricht validieren
commit_msg=$(cat "$1")

# Erlaubte Tag_1 (Where) und Tag_2 (What)
tag1="API|CI|DAT|DEP|DOC|DPLY|ENV|IDE|MOD|OPS|ORG|SEC|TEST"
tag2="BFX|BREAK|BUG|DEL|DOCS|ENH|FEAT|ICM|PERF|REF|STYLE|TEST"

# Pattern: [CI SKIP] TAG_1:TAG_2 MESSAGE
pattern="^\[($tag1):($tag2)\] .+"

if ! echo "$commit_msg" | grep -qE "$pattern"; then
  echo ""
  echo "Ungültiges Commit-Format!"
  echo ""
  echo "Expected:  \"[TAG_1:TAG_2] MESSAGE\""
  echo "Example:   \"[MOD:ENH] Added linear regression to toolstack\""
  echo ""
  echo "Tag_1 (Where): API, CI, DAT, DEP, DOC, DPLY, ENV, IDE, MOD, OPS, ORG, SEC, TEST"
  echo "Tag_2 (What):  BFX, BREAK, BUG, DEL, DOCS, ENH, FEAT, ICM, PERF, REF, STYLE, TEST"
  echo ""
  exit 1
fi

exit 0
