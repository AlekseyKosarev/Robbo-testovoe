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
cat -bs "$config"
echo 

# подтверждение установки y/n
echo 'Продолжить установку? (y/N):'
read -r confirm
case "${confirm,,}" in
  y|yes) echo "Начинаем установку...";;
  *) echo "Установка отменена."; exit 0;;
esac
#

# удаление логов перед стартом
rm -f "$log_file"

# построчно читает файл - вызывает install.sh
# передает строку из конфига
while IFS= read -r line; do
  [[ "$line" =~ ^[[:space:]]*# ]] && continue  # пропускаем комментарии
  [[ -z "$line" ]] && continue                # пропускаем пустые строки

  tmp=$(mktemp) || { error "Не удалось создать временный файл (mktemp failed)"; exit 1; }
  ./install.sh "$line" >"$tmp" 2>&1 &
  pids+=($!)
  tmp_files+=("$tmp")
done < "$config"

# ждем завершения процессов, а также перехватываем обычый вывод и ошибки в лог файл! 
for i in "${!pids[@]}"; do
  tmp=${tmp_files[i]}
  wait "${pids[i]}"
  status=$?
  output=$(cat "$tmp")

  if [ $status -ne 0 ]; then
    echo " -> Произошла ошибка, подробности в $log_file!"
    filtered=$(printf '%s\n' "$output" | grep -v '^DEBUG:' || true)
    log "$filtered"
  else
    printf '%s\n' "$output" | grep '^DEBUG:'
  fi

  rm -f "$tmp"
done
