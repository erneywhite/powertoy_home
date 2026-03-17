<h1 align="center">Автоматический установщик программ для Windows</h1>

<p align="center">PowerShell-скрипт для быстрой установки популярных программ в одно действие.</p>

<hr>

## Для чего этот скрипт?

Скрипт облегчит поиск и установку основных программ для простого пользователя. Автоматически скачает и установит выбранную программу из списка. При первом запуске проверяет наличие 7-Zip и при необходимости устанавливает его автоматически.

---

## Как использовать?

### PowerShell (Windows 8 или позднее)

1. Откройте PowerShell с правами администратора.
2. Скопируйте и вставьте одну из команд:

```powershell
irm https://powertoy.erney.monster | iex
```

Альтернативная ссылка (GitHub):

```powershell
irm https://raw.githubusercontent.com/erneywhite/powertoy_home/refs/heads/main/powertoy.ps1 | iex
```

3. Выберите программу из меню по номеру и нажмите Enter.
4. Программа будет загружена и установлена автоматически.

---

## Список программ

```
7-Zip (24.09)
WinRAR (7.00)
Firefox (147.0.2)
Google Chrome (latest)
Notepad++ (8.9.1)
Steam (latest)
Epic Games Store (19.1.5)
Discord (latest)
AmneziaVPN (4.8.12.9)
Spotify (latest)
1Password (latest)
Windhawk (1.7.3)
qBittorrent (5.0.4)
Telegram (6.4.2)
NVIDIA App (11.0.6.383)
Synology Drive Client (4.0.1-17885)
CurseForge (latest)
WeMod (latest)
WeMod PRO Unlocker (archive)
Virtual Desktop Streamer (latest)
SideQuest (0.10.42)
MiniBin (6.6.0.0)
ID-COOLING (1.0.5)
Z-SYNC (archive 1.0.19)
Stream Dock (latest)
Logitech G HUB (latest)
RK Keyboard (latest)
LibreOffice (25.8.4)
HiBitUninstaller (4.0.10)
WinDirStat (2.2.2)
Paragon Hard Disk Manager Ru (archive & portable 17.20.9)
```

---

## Структура репозитория

```
powertoy_home/
├── powertoy.ps1   # Основной PowerShell-скрипт установщика
├── powertoy.php   # Веб-страница / редирект (powertoy.erney.monster)
├── favicon.ico    # Иконка сайта
└── .gitignore
```

---

> [!NOTE]
>
> - **7-Zip**: при первом запуске автоматически проверяется и при отсутствии предлагается установка.
> - **Права администратора**: скрипт требует запуска от имени администратора. Если запущен без прав — предложит перезапуститься автоматически.
> - **Архивные программы**: пункты с пометкой `archive` требуют наличия 7-Zip для распаковки.
> - **Сеть**: убедитесь в наличии стабильного интернет-соединения.
> - **Безопасность**: используйте только официальные ссылки выше. Проверяйте целостность загружаемого кода.

---

## Лицензия

GPL-3.0 — см. файл [LICENSE](LICENSE).

---

<p align="center">Made by ErneyWhite</p>
