#!/bin/bash
# install.sh:
# принимает один аргумент - строку из конфига 
# формат строки - "app_name app_link(необязательно)"

. ./logging.sh

wget_timeout=10
apt_flags=-y
download_package_wget() {
  if wget --spider --timeout=5 "$link" >/dev/null 2>&1; then
    debug "-> Загружаю $app_name..."
    wget --timeout=$wget_timeout "$link" -O "$app_name.deb"
    if [ $? -eq 0 ]; then
      debug "✅ $app_name: пакет успешно загружен"
    else
      error "$app_name: ошибка при загрузке пакета"
      return 1
    fi
  else
    error "$app_name: ссылка '$link' недоступна"
    return 1
  fi
}

install_with_apt() {
  # если ссылка не указана - пытаемся установить через apt напрямую
  if [ -z "$link" ]; then
    debug "ссылка не указана, установка через apt"
    sudo apt install "$apt_flags" "$app_name"
    if [ $? -eq 0 ]; then
      debug "✅ $app_name: пакет успешно загружен"
    else
      error "$app_name: ошибка при загрузке пакета"
      return 1
    fi
  # если ссылка есть - скачиваем файл и устанавливаем 
  else
    if download_package_wget; then
      sudo apt install "$apt_flags" "./$app_name.deb" && rm -f "$app_name.deb"
    else
      return 1
    fi
  fi
}

Проверка прав администратора
if [ "$EUID" -ne 0 ]; then
  error "Скрипт должен быть запущен с правами администратора (root)."
  exit 1
fi

if [ "$#" -ne 1 ]; then
  error "Использование: $0 '<app_name> [app_link]'"
  exit 1
fi

input="$1"

read -r app_name link <<< "$input"

if [ -z "$app_name" ]; then
  error "Не удалось определить имя приложения из строки: '$input'"
  exit 1
fi

if ! install_with_apt; then
  exit 1
fi