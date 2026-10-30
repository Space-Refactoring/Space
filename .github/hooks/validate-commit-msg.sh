#!/usr/bin/env bash

MSG_FILE=$1
FIRST_LINE=$(head -n1 "$MSG_FILE")

# Regex Pattern: [TAG:scope]!? subject
PATTERN="^\[(FEAT|FIX|BUILD|CHORE|CI|DOCS|STYLE|REFACTOR|PERF|TEST)(:[a-zA-Z0-9_-]+)?\]!? [a-z].*$"

# 1. Check format and valid type
if [[ ! $FIRST_LINE =~ $PATTERN ]]; then
    echo "Error: Invalid commit format."
    echo "Expected: [TAG:scope] subject  OR  [TAG] subject"
    echo "Valid TAGs: FEAT, FIX, BUILD, CHORE, CI, DOCS, STYLE, REFACTOR, PERF, TEST"
    echo "Example: [FEAT:ui] add cash transaction feature"
    echo "Example (Breaking): [BUILD:docker]! deprecate win32 support"
    exit 1
fi

# 2. Check length (max 50 characters)
if [[ ${#FIRST_LINE} -gt 50 ]]; then
    echo -e "Error: The subject line is too long (${#FIRST_LINE} characters). Maximum allowed is 50."
    exit 1
fi

# 3. Forbid period at the end
if [[ $FIRST_LINE == *\. ]]; then
    echo "Error: The subject line must not end with a period (.)."
    exit 1
fi

exit 0
