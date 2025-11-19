# Robbo-testovoe

Принцип работы:

Конфиг файл содержит данные в формате:

```
"app_name app_link"
```
Пример:
```
cpuid
htop http://ftp.ru.debian.org/debian/pool/main/h/htop/htop_3.4.1-5_amd64.deb
code https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
vlc
git
```

Каждая строка относится к одному пакету.
**Ссылка не обязательна.**
Если ссылка указана - установщик скачает пакет через wget и установит через apt.
Если только имя - попытается напрямую через apt.

Инструкции по запуску:

```
sudo ./auto_install.sh config.conf
```

Скрипт выведет список программ для установки (содержимое конфига)
и будет ждать ввода - y/n
```
Список пакетов для установки:
     1	cpuid
     2	htop http://ftp.ru.debian.org/debian/pool/main/h/htop/htop_3.4.1-5_amd64.deb
     3	code https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
     4	vlc
     5	git


Продолжить установку? (y/N):
```

После подтверждения начнется установка!
```
Начинаем установку...
DEBUG: cpuid: ссылка на пакет не указана, установка через apt
DEBUG: cpuid: пакет успешно установлен
DEBUG: htop: уже установлен, пропуск
DEBUG: code: уже установлен, пропуск
DEBUG: vlc: уже установлен, пропуск
DEBUG: git: уже установлен, пропуск
```

Все ошибки записываются в ```log_file.log```


---

Утилита собрана в .deb пакет и готова к использованию

Пример вывода: (установлена через dpkg)
```
sudo auto_install.sh Robbo-testovoe/config.conf 
Список пакетов для установки:
     1	cpuid
     2	htop http://ftp.ru.debian.org/debian/pool/main/h/htop/htop_3.4.1-5_amd64.deb
     3	code https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
     4	vlc
     5	git

Продолжить установку? (y/N):
y
Начинаем установку...
DEBUG: cpuid: уже установлен, пропуск
DEBUG: htop: уже установлен, пропуск
DEBUG: code: уже установлен, пропуск
DEBUG: vlc: уже установлен, пропуск
DEBUG: git: уже установлен, пропуск
```

инструкции для установки:

```
sudo dpkg -i auto-install-1.0.deb
```

---

Примечания:
Лог файл сохраняется в папке откуда вызывается скрипт - название `log_file.log`

---


Тестировал на Ubuntu server 24.04