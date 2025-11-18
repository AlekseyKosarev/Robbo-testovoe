#!/bin/bash
log_file="log_file.log" 

# args - error_message(уже имеет в форматированный вывод)
log() {
  if [ "$#" -eq 0 ]; then
    echo "Ошибка в функции log: Необходимо передать хотя бы 1 аргумент."
    return 1
  fi

  local error_message="$2"
  local current_time=$(date +"%Y-%m-%d %H:%M:%S")

  {
    echo "--- $current_time ---"
    echo "$error_message"
    echo "--- ^^^^^^^^^^^^^^^^^ ---"
    echo
  } >> "$log_file"
}

debug() {
  if [ "$#" -eq 0 ]; then
    echo "Ошибка в функции debug: Необходимо передать хотя бы 1 аргумент."
    return 1
  fi
  echo $1
}

error() {
  if [ "$#" -eq 0 ]; then
    echo "Ошибка в функции error: Необходимо передать хотя бы 1 аргумент."
    return 1
  fi
  echo $1
}