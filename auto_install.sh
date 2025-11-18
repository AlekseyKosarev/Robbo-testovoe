#!/bin/bash
. ./logging.sh

# Проверка прав администратора
if [ "$EUID" -ne 0 ]; then
  error "Скрипт должен быть запущен с правами администратора (root)."
  exit 1
fi

if [ "$#" -eq 0 ]; then
  error "Пожалуйста передайте config файл как аргумент!"
  exit 1
fi

config=$1
if [ ! -r "$config" ]; then
  error "Файл '$config' недоступен или не существует"
  exit 1
fi

pids=()
tmp_files=()

cleanup() {
  echo "Прерывание: завершаем дочерние процессы..."
  kill "${pids[@]}" 2>/dev/null
  wait "${pids[@]}" 2>/dev/null
  exit 1
}
trap cleanup INT TERM

# построчно читает файл - вызывает install.sh
# передает строку из конфига
while IFS= read -r line; do
  tmp=$(mktemp)
  ./install.sh "$line" >"$tmp" 2>&1 &
  pids+=($!)
  tmp_files+=("$tmp")
done < "$config"

# ждем завершения процессов
for i in "${!pids[@]}"; do
  pid=${pids[i]}
  tmp=${tmp_files[i]}

  wait "$pid"
  status=$?
  output=$(cat "$tmp")

  if [ $status -ne 0 ]; then
    log "$output"
  else
    debug "$output"
  fi

  rm -f "$tmp"
done
