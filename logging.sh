#!/bin/bash

# $1 - log_file
clear_logs() {
  # удаление логов перед стартом
  rm -f "$1"
}

# $1 - log_file, $2 - msg
log() {
  local msg="$2" ts
  ts=$(date +"%Y-%m-%d %H:%M:%S")
  {
    echo "--- $ts ---"
    echo "$msg"
    echo "--- ^^^^^^^^^^^^^^^^^ ---"
    echo
  } >> "$1"
}

debug() {
  echo "DEBUG: $1"
}
error() {
  echo "ERROR: $1"
}