<h1 align="center">Автоматический установщик программ для Windows</h1>

<hr>

## Для чего этот скрипт?
Скрипт облегчит поиск и установку основных программ для простого пользователя. Автоматически скачает и установит выбранную вами программу из списка (список будет пополнен).

---

## Как использовать?

### PowerShell (Windows 8 или позднее)

1.   Откройте PowerShell с правами администратора.
2.   Скопируйте и вставьте в открывшееся окно следующую команду:  
```
irm https://powertoy.erney.monster | iex
```
  Команда с альтернативной ссылкой с GitHub:
```
irm https://raw.githubusercontent.com/erneywhite/powertoy_home/refs/heads/main/powertoy.ps1 | iex
```

3.   Выберите программу, которую хотите установить (1-9) и нажмите Enter.
4.   Программа установлена.

---

### Список программ и возможностей
```
7-Zip (24.09)
Firefox (137.0)
Google Chrome (latest)
Steam (latest)
Epic Games Store (18.1.3)
Discord (latest)
AmneziaVPN (4.8.5.0)
Spotify (latest)
1Password (latest)
Windhawk (1.5.1)
qBittorrent (5.0.4)
Telegram (5.13.1)
NVIDIA App (11.0.3.218)
Synology Drive Client (3.5.2-16111)
CurseForge (latest)
WeMod (latest)
Virtual Desktop Streamer (latest)
MiniBin (archive 6.6.0.0)
ID-COOLING (archive 1.0.5)
Z-SYNC (archive 1.0.19)
LibreOffice (25.2.2)
WinDirStat (2.2.2)
```
---

> [!NOTE]
>
> - При первом запуске скрипта - выполняется проверка на наличие архиватора 7-Zip и при его отсутствии выполняется автоматическая установка.
> - Права администратора: Для установки программ скрипт требует запуска с правами администратора.
> - Сетевое соединение: Убедитесь, что у вас есть стабильное интернет-соединение для скачивания программ.
> - Безопасность: Убедитесь, что скрипт загружен из доверенного источника. Используйте только официальные ссылки и проверяйте целостность загруженного кода.

---

<p align="center">Made by ErneyWhite</p>
