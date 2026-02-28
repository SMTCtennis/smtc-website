#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LATEST_SRC="$(ls -td "$HOME/Downloads"/simply-static*/ 2>/dev/null | head -n 1 || true)"

if [[ -z "${LATEST_SRC}" ]]; then
  echo "Error: No directories matching $HOME/Downloads/simply-static*/ found."
  exit 1
fi

echo "Source: ${LATEST_SRC}"
echo "Dest:   ${DEST_DIR}"
echo

EXCLUDES=(
  "--exclude" ".git/"
  "--exclude" ".gitignore"
  "--exclude" "cp-static.sh"
  "--exclude" ".DS_Store"
)

# Dry-run: capture deletions (macOS rsync prints: 'deleting <path>')
DRYRUN_OUT="$(
  rsync -av --dry-run --delete \
    "${EXCLUDES[@]}" \
    "${LATEST_SRC}" "${DEST_DIR}/"
)"

DELETIONS="$(printf "%s\n" "${DRYRUN_OUT}" | sed -n 's/^deleting //p')"

if [[ -n "${DELETIONS}" ]]; then
  COUNT="$(printf "%s\n" "${DELETIONS}" | sed '/^$/d' | wc -l | tr -d ' ')"
  echo "Warning: ${COUNT} path(s) would be deleted from destination:"
  echo
  printf "%s\n" "${DELETIONS}"
  echo
  read -r -p "Proceed (will delete these)? Type 'YES' to continue: " ANSWER
  if [[ "${ANSWER}" != "YES" ]]; then
    echo "Aborted."
    exit 2
  fi
fi

echo "Running sync..."
rsync -av --delete \
  "${EXCLUDES[@]}" \
  "${LATEST_SRC}" "${DEST_DIR}/"

echo "Done."
