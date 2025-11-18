#!/bin/bash
# install.sh:
# принимает один аргумент - строку из конфига 
# формат строки - "app_name app_link(необязательно)"
# далее проверяет, если ссылка есть - идет путем установки через dpkg
# если только имя - идет через apt

# Проверка прав администратора
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

install_with_apt() {
  debug "ссылка не указана, установка через apt"
  debug "✅ $app_name: успешно установлен через apt (тест)"
}

install_with_dpkg() {
  debug "→ Проверяю ссылку: $link"
  if curl -I --connect-timeout 3 --max-time 5 -sf "$link" >/dev/null 2>&1; then
    debug "✅ $app_name: ссылка доступна"
  else
    error "$app_name: ссылка '$link' недоступна"
    exit 1
  fi
}
if [ -z "$link" ]; then
  install_with_apt
else
  install_with_dpkg
fi