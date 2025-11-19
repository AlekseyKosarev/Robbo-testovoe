#!/bin/bash
log_file="log_file.log" 

log() {
  local msg="$1" ts
  ts=$(date +"%Y-%m-%d %H:%M:%S")
  {
    echo "--- $ts ---"
    echo "$msg"
    echo "--- ^^^^^^^^^^^^^^^^^ ---"
    echo
  } >> "$log_file"
}

debug() {
  echo "DEBUG: $1"
}
error() {
  echo "ERROR: $1"
}