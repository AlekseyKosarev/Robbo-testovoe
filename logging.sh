#!/bin/bash
log_file="log_file.log" 

# args - сообщение об ошибке
log() {
  local msg="$1" ts
  ts=$(date +"%Y-%m-%d %H:%M:%S")
  {
    printf '--- %s ---\n' "$ts"
    printf '%s\n' "$msg"
    echo "--- ^^^^^^^^^^^^^^^^^ ---"
    echo
  } >> "$log_file"
}

debug() { printf 'DEBUG: %s\n' "$1"; }

error() { printf 'ERROR: %s\n' "$1" >&2; }