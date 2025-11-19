#!/bin/bash
# install.sh:
# принимает один аргумент - строку из конфига 
# формат строки - "app_name app_link(необязательно)"

. ./logging.sh

wget_timeout=10
apt_flags=-y

is_installed() {
  local name="$1"
  
  # проверка пакета через dpkg 
  if dpkg -s "$name" >/dev/null 2>&1; then
    return 0
  fi
  # проверка существования бинарника
  if command -v "$name" >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

download_package_wget() {
  if wget --spider --timeout=5 "$link" >/dev/null 2>&1; then
    debug "$app_name: загружаю пакет..."
    wget --timeout=$wget_timeout "$link" -O "$app_name.deb"
    if [ $? -eq 0 ]; then
      debug "$app_name: пакет успешно загружен"
    else
      debug "$app_name: ошибка при загрузке пакета"
      return 1
    fi
  else
    error "$app_name: ссылка '$link' недоступна"
    return 1
  fi
}

install_with_apt() {
  debug "$app_name: Проверка..."
  # если ссылка не указана - пытаемся установить через apt напрямую
  if [ -z "$link" ]; then
    debug "$app_name: ссылка не указана, установка через apt"
    sudo DEBIAN_FRONTEND=noninteractive apt install "$apt_flags" "$app_name"
    if [ $? -eq 0 ]; then
      debug "$app_name: пакет успешно установлен"
    else
      debug "$app_name: ошибка при установке пакета"
      return 1
    fi
  # если ссылка есть - скачиваем файл и устанавливаем 
  else
    if download_package_wget; then
      sudo DEBIAN_FRONTEND=noninteractive apt install "$apt_flags" "./$app_name.deb" && rm -f "$app_name.deb"
      if [ $? -eq 0 ]; then
      debug "$app_name: пакет успешно установлен"
      else
        debug "$app_name: ошибка при установке пакета"
        return 1
      fi
    else
      return 1
    fi
  fi
}

if [ "$EUID" -ne 0 ]; then
  debug "Скрипт должен быть запущен с правами администратора (root)."
  exit 1
fi

if [ "$#" -ne 1 ]; then
  debug "Использование: $0 '<app_name> [app_link]'"
  exit 1
fi

input="$1"

read -r app_name link <<< "$input"

if [ -z "$app_name" ]; then
  error "Не удалось определить имя приложения из строки: '$input'"
  exit 1
fi

if is_installed "$app_name"; then
  debug "$app_name: уже установлен, пропуск"
elif ! install_with_apt; then
  exit 1
fi