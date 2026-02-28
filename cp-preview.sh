#!/usr/bin/env bash
set -euo pipefail

# Destination = directory where this script lives (the smtc-website repo root)
DEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source = preview repo directory
SRC_DIR="$HOME/Code/SMTC/smtc-website-preview/"

if [[ ! -d "${SRC_DIR}" ]]; then
  echo "Error: Source directory not found: ${SRC_DIR}"
  exit 1
fi

echo "Source: ${SRC_DIR}"
echo "Dest:   ${DEST_DIR}"
echo

EXCLUDES=(
  "--exclude" ".git/"
  "--exclude" ".gitignore"
  "--exclude" "cp-preview.sh"
  "--exclude" ".DS_Store"
  "--exclude" "CNAME"
)

# Dry-run: capture deletions (macOS rsync prints: 'deleting <path>')
DRYRUN_OUT="$(
  rsync -av --dry-run --delete \
    "${EXCLUDES[@]}" \
    "${SRC_DIR}" "${DEST_DIR}/"
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
  "${SRC_DIR}" "${DEST_DIR}/"

echo "Done."
