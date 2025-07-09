#!/bin/sh

# unp-wrapper.sh - A smart wrapper script for 'unp' that handles diverse archive formats,
#                 extracts into a temporary folder, and safely renames target directories
#                 to avoid collisions. Supports /tmp unpacking and POSIX-compliant flags.
#
# Generated and refined with the assistance of Microsoft Copilot, based on user-defined
# functionality and behavior expectations.
#
# 2025-07-09

set -e

usage() {
  echo "$(basename "$0") - wrapper script for 'unp'"
  echo ""
  echo "Safely unpacks archives into a named folder instead of the current directory."
  echo ""
  echo "Options:"
  echo "  -t   extract to /tmp instead of current directory"
  echo "  -h   show this help and exit"
  echo ""
  echo "This script was generated and refined collaboratively with Microsoft Copilot."
  exit 0
}

# Check that unp is available
if ! command -v unp >/dev/null 2>&1; then
  echo "Error: 'unp' command not found or not available in your PATH." >&2
  exit 1
fi

# Caution! Use absolute path for targetdir because we change PWD lateron...
targetdir="$(realpath ".")"

# Parse options
while getopts ":th" opt; do
  case "${opt}" in
    t) targetdir="/tmp" ;;
    h) usage ;;
    ?) echo "Unknown option: -${OPTARG}" >&2; usage ;;
  esac
done
shift $((OPTIND - 1))

# Check for archive file
[ "$#" -eq 1 ] || usage
if [ ! -f "$1" ]; then
  echo "Error: '$1' is not a valid file." >&2
  exit 1
fi

# All known archive and backup-style suffixes
known_suffixes="tar gz tgz bz2 tbz2 bz3 tbz3 xz txz zst tzst Z zip rar ace 7z lz lzop lzip zoo zx cab deb rpm dmg iso ar cpio afio lha lzh bak backup"

# Get destination folder from archive filename
archive="$(realpath "$1")"
name="$(basename "$1")"

# Strip suffixes (extensions and backups) iteratively
while :
do
  # Strip trailing ~ first (not a dot-based suffix)
  case "$name" in
    *~) name="${name%~}"; continue ;;
  esac

  # Get extension
  ext="${name##*.}"

  # Check if it’s known
  case " $known_suffixes " in
    *" $ext "*) name="${name%.*}" ;;
    *) break ;;
  esac
done

# Create temporary working directory
tmpdir="$(mktemp -d)"
cd "$tmpdir"

# Run unp and capture exit status
unp_status=0
unp "$archive" || unp_status=$?

# If unp failed and nothing was extracted, cleanup and exit
if [ "$unp_status" -ne 0 ]; then
  if [ ! "$(ls -A "$tmpdir")" ]; then
    echo "Error: 'unp' failed and no files were extracted." >&2
    rmdir "$tmpdir"
    exit "$unp_status"
  else
    echo "Warning: 'unp' did not fully succeed, but some files were extracted." >&2
  fi
fi

# Identify contents
contents="$(ls -A)"
num_items=$(echo "$contents" | wc -l)

# Case 1: exactly one directory and its name matches the archive base name
if [ "$num_items" -eq 1 ] && [ -d "$name" ] && [ "$(basename "$name")" = "$name" ]; then
  target="${targetdir}/${name}"
  if [ -e "$target" ]; then
    i=0
    while [ -e "${targetdir}/${name}.unp.${i}" ]; do
      i=$((i + 1))
    done
    target="${targetdir}/${name}.unp.${i}"
  fi
  mv "$name" "$target"
  rmdir "$tmpdir"
else
  # Case 2 and fallback: rename tempdir to archive name (with collision logic)
  target="${targetdir}/${name}"
  if [ -e "$target" ]; then
    i=0
    while [ -e "${targetdir}/${name}.unp.${i}" ]; do
      i=$((i + 1))
    done
    target="${targetdir}/${name}.unp.${i}"
  fi
  mv "$tmpdir" "$target"
fi
