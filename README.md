# powertoy_home
Автоматический установщик программ для Windows

Описание:

Этот скрипт на PowerShell позволяет автоматически скачивать и устанавливать различные программы на компьютер под управлением Windows.
Скрипт поддерживает как установку напрямую из установочных файлов (.exe, .msi), так и из архивов (.zip, .rar), требующих предварительного разархивирования.

Особенности:

Автоматическая установка 7-Zip: Если на компьютере не установлен 7-Zip, скрипт автоматически скачивает и устанавливает его.
Поддержка множества программ: Включена поддержка более 20 популярных программ, таких как Firefox, Google Chrome, Steam, Discord, 1Password и многие другие.
Разархивирование вложенных архивов: Скрипт рекурсивно разархивирует вложенные архивы и ищет внутри них установочные файлы.
Командная строка и веб-интерфейс: Скрипт может быть запущен как из командной строки (PowerShell, curl), так и через веб-браузер.

Как использовать:

<img width="1114" alt="изображение" src="https://github.com/user-attachments/assets/743f0131-661c-4ee4-9464-96ea2a8db131" />

PowerShell
```
irm https://powertoy.erney.monster | iex
```

Список доступных программ

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

Важно:

Права администратора: Для установки программ скрипт требует запуска с правами администратора.
Сетевое соединение: Убедитесь, что у вас есть стабильное интернет-соединение для скачивания программ.
