#!/usr/bin/env bash

MSG_FILE=$1
FIRST_LINE=$(head -n1 "$MSG_FILE")

# Colors for terminal output
RED='\033[0;31m'
NC='\033[0m' # No Color

# Regex Pattern: [TAG:scope]!? subject
PATTERN="^\[(FEAT|FIX|BUILD|CHORE|CI|DOCS|STYLE|REFACTOR|PERF|TEST)(:[a-zA-Z0-9_-]+)?\]!? [a-z].*$"

# 1. Check format and valid type
if [[ ! $FIRST_LINE =~ $PATTERN ]]; then
    echo -e "${RED}Error: Invalid commit format.${NC}"
    echo "Expected: [TAG:scope] subject  OR  [TAG] subject"
    echo "Valid TAGs: FEAT, FIX, BUILD, CHORE, CI, DOCS, STYLE, REFACTOR, PERF, TEST"
    echo "Example: [FEAT:ui] add cash transaction feature"
    echo "Example (Breaking): [BUILD:docker]! deprecate win32 support"
    exit 1
fi

# 2. Check length (max 50 characters)
if [[ ${#FIRST_LINE} -gt 50 ]]; then
    echo -e "${RED}Error: The subject line is too long (${#FIRST_LINE} characters). Maximum allowed is 50.${NC}"
    exit 1
fi

# 3. Forbid period at the end
if [[ $FIRST_LINE == *\. ]]; then
    echo -e "${RED}Error: The subject line must not end with a period (.).${NC}"
    exit 1
fi

exit 0
