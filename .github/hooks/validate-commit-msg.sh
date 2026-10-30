#!/bin/bash

# Commit-Nachricht validieren
commit_msg=$(cat "$1")

# Erlaubte Tag_1 (Where) und Tag_2 (What)
tag1="API|CI|COM|DAT|DEP|DOC|DPLY|ENV|EXP|IDE|MET|MOD|NBK|OPS|ORG|PPL|PRE|SEC|SEL|SUB|TRA|TEST"
tag2="BFX|BREAK|BUG|DEL|DOCS|ENH|FEAT|ICM|PERF|REF|STYLE|TEST"

# Pattern: [CI SKIP] TAG_1:TAG_2 MESSAGE
pattern="^(\[CI SKIP\] )?($tag1):($tag2) .+"

if ! echo "$commit_msg" | grep -qE "$pattern"; then
  echo ""
  echo "Ungültiges Commit-Format!"
  echo ""
  echo "Expected:  \"[CI SKIP] TAG_1:TAG_2 MESSAGE\""
  echo "Example:   \"MOD:ENH Added linear regression to toolstack\""
  echo ""
  echo "Tag_1 (Where): API, CI, COM, DAT, DEP, DOC, DPLY, ENV, EXP, IDE, MET, MOD, NBK, OPS, ORG, PPL, PRE, SEC, SEL, SUB, TRA, TEST"
  echo "Tag_2 (What):  BFX, BREAK, BUG, DEL, DOCS, ENH, FEAT, ICM, PERF, REF, STYLE, TEST"
  echo ""
  exit 1
fi

exit 0
