#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Randomly skips update.
if (( RANDOM % 2 == 0 )); then

  # Randomly picks a quote.
  QUOTE="$(cat ".github/scripts/quotes/quote-$(( RANDOM % 5 + 1 )).md")"

  # Exports variables for template.
  export QUOTE

  # Renders template.
  # shellcheck disable=SC2016
  envsubst \
    '${QUOTE}' \
    < ".github/scripts/templates/README.md" \
    > "README.md"

  # Checks for changes.
  if [[ "${CI:-}" == "true" && -n "$(git status --porcelain)" ]]; then

    # Commits changes.
    git add .
    git commit -m "Updates quote"

    # Pushes changes. Rebases, waits and
    # retries three times on conflict.
    for _ in 1 2 3; do
      if git push; then break; fi
      git pull --rebase origin main
      sleep 3
    done
  fi
fi
