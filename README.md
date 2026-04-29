<h1 align="center">Powertoy Home</h1>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-GPL%20v3-blue.svg" alt="GPL v3"></a>
  <img src="https://img.shields.io/badge/Platform-Windows%208%2B-0078D6?logo=windows&logoColor=white" alt="Windows 8+">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white" alt="PowerShell">
  <img src="https://img.shields.io/badge/Программ-31-brightgreen" alt="31 programs">
</p>

<p align="center">Автоматический установщик программ для Windows в одну команду. Запусти — выбери программу из меню — готово.</p>

---

## Содержание

- [Быстрый старт](#быстрый-старт)
- [Как это работает](#как-это-работает)
- [Список программ](#список-программ)
- [Структура репозитория](#структура-репозитория)
- [Добавление программы](#добавление-программы)
- [Нюансы](#нюансы)

---

## Быстрый старт

Откройте **PowerShell от имени администратора** и запустите одну из команд:

```powershell
irm https://powertoy.erney.monster | iex
```

Альтернативная ссылка (напрямую с GitHub):

```powershell
irm https://raw.githubusercontent.com/erneywhite/powertoy_home/refs/heads/main/powertoy.ps1 | iex
```

> ⚠️ Если скрипт запущен без прав администратора — автоматически предложит перезапуститься с повышением привилегий.

---

## Как это работает

```
1. Проверка прав администратора
   └─ Если нет → предложит перезапуститься (Start-Process RunAs)
2. Приветственный экран с ASCII-енотом на 3 секунды
3. Проверка наличия 7-Zip → автоустановка при необходимости
4. Загрузка списка программ из programs.json
5. Меню по категориям с отметкой ✓ для уже установленных
6. Выбор и установка
   ├─ Множественный выбор: «1 5 17» — установит все три по очереди
   ├─ Поиск: «/firefox» — отфильтрует список
   ├─ Сброс поиска: «/»
   └─ Выход: q
7. Установка по типу
   ├─ Если в JSON задан WingetId и доступен winget → пробует через winget
   ├─ exe/msi → скачать (BITS + кастомный прогресс) → Start-Process
   ├─ archive (.zip) → 7-Zip распаковка → поиск .exe/.msi внутри
   ├─ ISO → скачать → Mount-DiskImage → ждать Enter → Dismount
   └─ Script → скачать .ps1 → выполнить через powershell.exe
8. Удаление %TEMP%\Installers после завершения сессии
```

Кеш установщиков работает в пределах сессии: при повторном выборе той же
программы файл не качается заново. После выхода из скрипта `%TEMP%\Installers`
удаляется. Лог сессии сохраняется в `%TEMP%\powertoy.log`.

---

## Список программ

### Архиваторы и утилиты

| # | Программа | Тип | Источник |
|---|---------|------|--------|
| 1 | 7-Zip (26.01) | .exe | 7-zip.org |
| 2 | WinRAR (7.00) | .exe | powertoy.erney.monster |
| 28 | LibreOffice (26.2.2) | .msi | documentfoundation.org |
| 29 | HiBitUninstaller (4.0.10) | .exe | powertoy.erney.monster |
| 30 | WinDirStat (2.5.0) | .msi | github.com |
| 31 | Paragon HDM Ru (17.20.9) | archive | powertoy.erney.monster |

### Браузеры

| # | Программа | Тип | Источник |
|---|---------|------|--------|
| 3 | Firefox (150.0.1) | .msi | mozilla.net |
| 4 | Google Chrome (latest) | .exe | powertoy.erney.monster |

### Мессенджеры и соцсети

| # | Программа | Тип | Источник |
|---|---------|------|--------|
| 8 | Discord (latest) | .exe | discord.com |
| 14 | Telegram (6.7.8) | .exe | td.telegram.org |

### Игры и гейминг

| # | Программа | Тип | Источник |
|---|---------|------|--------|
| 6 | Steam (latest) | .exe | steamstatic.com |
| 7 | Epic Games Store (19.2.3) | .msi | epicgames |
| 17 | CurseForge (latest) | .exe | overwolf.com |
| 18 | WeMod (latest) | .exe | wemod.com |
| 19 | WeMod PRO Unlocker | .exe | powertoy.erney.monster |
| 20 | Virtual Desktop Streamer (latest) | .exe | vrdesktop.net |
| 21 | SideQuest (0.10.42) | .exe | powertoy.erney.monster |

### VPN и безопасность

| # | Программа | Тип | Источник |
|---|---------|------|--------|
| 9 | AmneziaVPN (4.8.14.5) | .exe | github.com |
| 11 | 1Password (latest) | .exe | 1password.com |

### Музыка и медиа

| # | Программа | Тип | Источник |
|---|---------|------|--------|
| 10 | Spotify (latest) | .exe | scdn.co |

### Системные утилиты Windows

| # | Программа | Тип | Источник |
|---|---------|------|--------|
| 5 | Notepad++ (8.9.4) | .exe | github.com |
| 12 | Windhawk (1.7.3) | .exe | github.com |
| 22 | MiniBin (6.6.0.0) | .exe | powertoy.erney.monster |

### Торрент и облако

| # | Программа | Тип | Источник |
|---|---------|------|--------|
| 13 | qBittorrent (5.1.4) | .exe | sourceforge.net |
| 16 | Synology Drive Client (4.0.2) | .exe | synologydownload.com |

### Драйверы и периферия

| # | Программа | Тип | Источник |
|---|---------|------|--------|
| 15 | NVIDIA App (11.0.7.247) | .exe | nvidia.com |
| 23 | ID-COOLING (1.0.5) | .msi | powertoy.erney.monster |
| 24 | Z-SYNC (archive 1.0.19) | .zip | powertoy.erney.monster |
| 25 | Stream Dock (latest) | .exe | powertoy.erney.monster |
| 26 | Logitech G HUB (latest) | .exe | logi.com |
| 27 | RK Keyboard (latest) | .exe | s3.amazonaws.com |

---

## Структура репозитория

```
powertoy_home/
├── powertoy.ps1    # Основной PowerShell-скрипт установщика (логика)
├── programs.json   # Список программ (URL, аргументы установки)
├── powertoy.php    # Отдаёт powertoy.ps1 для PowerShell или HTML-превью для браузера
├── favicon.ico     # Иконка сайта
└── .gitignore
```

`powertoy.php` читает `powertoy.ps1` с диска и отдаёт его сырьём при запросе от PowerShell (`irm`) или подсвеченным превью в браузере.

`powertoy.ps1` при запуске загружает `programs.json` с сервера через `Invoke-RestMethod` — добавление/обновление программ не требует правки самого скрипта.

---

## Добавление программы

Добавьте объект в массив в `programs.json`:

**Обычный .exe / .msi:**
```json
{
    "Name": "MyApp (1.0.0)",
    "Url": "https://example.com/myapp-setup.exe",
    "Args": "/S",
    "Installer": "myapp-setup.exe"
}
```

**Файл в архиве (archive)** — необходим 7-Zip:
```json
{
    "Name": "MyApp (archive)",
    "Url": "https://example.com/myapp.zip",
    "Args": "/quiet",
    "Installer": "setup.msi",
    "Zip": "myapp.zip"
}
```

**ISO-образ** — скачивается, монтируется в систему как виртуальный диск. Опционально кладёт лицензионный ключ в буфер обмена. После установки нужно нажать Enter — скрипт размонтирует ISO:
```json
{
    "Name": "MyApp (ISO)",
    "Url": "https://example.com/myapp.iso",
    "Installer": "myapp.iso",
    "Type": "ISO",
    "LicenseKey": "ABCDE-12345-FGHIJ"
}
```

**PowerShell-скрипт** — скачивает `.ps1` и запускает через `powershell.exe -NoProfile -ExecutionPolicy Bypass`:
```json
{
    "Name": "MyApp (script)",
    "Url": "https://example.com/install.ps1",
    "Installer": "install.ps1",
    "Type": "Script"
}
```

Поля:
- `Name` — отображается в меню.
- `Category` — заголовок группы в меню (например `"Браузеры"`, `"Игры и гейминг"`). Программы с одинаковой категорией будут показаны вместе. Если поле отсутствует — попадёт в группу `Прочее`.
- `Url` — прямая ссылка на установщик (или ZIP/ISO/PS1).
- `Args` — аргументы тихой установки. Для `.exe` обычно `/S` или `/silent`, для `.msi` — `/quiet /norestart`. Пустая строка `""` запустит установщик без аргументов (графический мастер). Игнорируется для типов ISO и Script.
- `Installer` — имя файла, под которым установщик будет сохранён в `%TEMP%\Installers`. Для archive-типа — имя установочного файла **внутри** архива (`*.exe` или `*.msi`).
- `Zip` (опционально) — имя ZIP-файла, под которым он будет сохранён локально перед распаковкой. Указание этого поля переключает программу в режим archive.
- `Type` (опционально) — переопределяет тип установки:
  - `"ISO"` — монтирует ISO, ждёт Enter, размонтирует.
  - `"Script"` — запускает `.ps1`.
- `LicenseKey` (опционально, только для ISO) — копируется в буфер обмена перед монтированием.
- `WingetId` (опционально) — идентификатор пакета в [winget](https://learn.microsoft.com/windows/package-manager/winget/), например `"Mozilla.Firefox"`. Если поле задано и `winget` доступен, скрипт попробует установку через него — это даёт автообновления и проверенные хеши. При ошибке winget — фолбэк на `Url`.

После правки `programs.json` достаточно загрузить новую версию на сервер — изменения подхватятся при следующем запуске `irm https://powertoy.erney.monster | iex` без правки самого скрипта.

---

## Нюансы

> [!NOTE]
>
> - **Права администратора**: скрипт проверяет права сразу при запуске. Если недостаточно — предложит авто-перезапуск через `Start-Process RunAs`.
> - **7-Zip**: необходим для установки программ с пометкой `archive`. При отсутствии скрипт предложит его установить.
> - **BITS**: загрузка выполняется через `Start-BitsTransfer -Asynchronous` с кастомным прогресс-баром в консоли — надёжно для больших файлов.
> - **Кеш в сессии**: повторный выбор той же программы не перекачивает файл — берётся из `%TEMP%\Installers`. После выхода из скрипта папка удаляется.
> - **Лог сессии**: `%TEMP%\powertoy.log` — что качалось, когда, успех/ошибка. Полезно для дебага.
> - **Отметка ✓**: скрипт сканирует реестр Uninstall (HKLM + HKCU + WOW6432Node) и помечает уже установленные программы. Сопоставление по подстроке имени, возможны ложные срабатывания.
> - **Winget**: если в `programs.json` задано поле `WingetId` и команда `winget` доступна — скрипт сначала пробует установку через winget, при ошибке переходит на прямую загрузку.
> - **WeMod PRO Unlocker**: неофициальный патчер. Используйте на свой страх и риск.
> - **Безопасность**: запускайте скрипты `irm | iex` только из доверенных источников. При желании можно предварительно скачать `powertoy.ps1` и прочитать код вручную.

---

## Лицензия

GPL-3.0 — см. файл [LICENSE](LICENSE).

---

<p align="center">Made by ErneyWhite</p>
