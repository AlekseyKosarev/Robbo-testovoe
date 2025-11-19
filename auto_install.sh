#!/bin/bash
. ./logging.sh

pids=()
tmp_files=()
app_names=()
cleanup() {
  echo "Прерывание: завершаем дочерние процессы..."
  kill "${pids[@]}" 2>/dev/null
  rm -f "${tmp_files[@]}"
  exit 1
}
trap cleanup INT TERM

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

echo "Список пакетов для установки:"
idx=0
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]] && continue
  read -r app_name _ <<< "$line"
  app_names[idx]="$app_name"   # явная индексация
  echo " --- Запуск: $app_name --- "
  
  tmp=$(mktemp) || { error "mktemp failed"; exit 1; }
  ./install.sh "$line" >"$tmp" 2>&1 &
  pids[idx]=$!
  tmp_files[idx]="$tmp"
  ((idx++))
done < "$config"

if [ "${#app_names[@]}" -eq 0 ]; then
  error "Нет пакетов для установки в '$config'"
  exit 1
fi

# подтверждение установки y/n
printf '\n Продолжить установку %d пакет(ов)? (y/N): ' "${#app_names[@]}"
read -r confirm
case "${confirm,,}" in
  y|yes) echo "🚀 Начинаем установку...";;
  *) echo "⏹ Установка отменена."; exit 0;;
esac
#

# построчно читает файл - вызывает install.sh
# передает строку из конфига
while IFS= read -r line; do
  [[ "$line" =~ ^[[:space:]]*# ]] && continue  # пропускаем комментарии
  [[ -z "$line" ]] && continue                # пропускаем пустые строки

  echo " --- Запуск установки: $line --- "
  
  tmp=$(mktemp) || { error "Не удалось создать временный файл"; exit 1; }
  ./install.sh "$line" >"$tmp" 2>&1 &
  pids+=($!)
  tmp_files+=("$tmp")
done < "$config"

# ждем завершения процессов, а также перехватываем обычый вывод и ошибки в лог файл! 
for i in "${!pids[@]}"; do
  echo " --- Ожидание установки: ${app_names[i]} --- "
  pid=${pids[i]}
  tmp=${tmp_files[i]}

  wait "$pid"
  status=$?
  output=$(cat "$tmp")

  if [ $status -ne 0 ]; then
    echo " --- Произошла ошибка, подробности в $log_file! --- "
    filtered=$(printf '%s\n' "$output" | grep -v '^DEBUG:' || true)
    log "$filtered"
  else
    echo " --- Пакет успешно установлен! --- "
    printf '%s\n' "$output" | grep '^DEBUG:'
  fi

  rm -f "$tmp"
done
