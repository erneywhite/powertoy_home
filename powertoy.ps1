# Устанавливаем кодировку UTF-8 для входных и выходных данных
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-Response {
    $response = Read-Host "Хотите запустить скрипт от имени администратора? (y/н, n/т)"
    if ($response -eq "y" -or $response -eq "н") {
        return $true
    } elseif ($response -eq "n" -or $response -eq "т") {
        return $false
    } else {
        Write-Host "Неверный ответ. Пожалуйста, введите y/н для согласия или n/т для отказа." -ForegroundColor Yellow
        return Get-Response
    }
}

# Проверка прав администратора
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Скрипт требует запуска от имени администратора." -ForegroundColor Red
    $response = Get-Response
    if ($response) {
        # Запускаем скрипт от имени администратора
        Start-Process -FilePath PowerShell -ArgumentList "-Command", "irm https://powertoy.erney.monster | iex" -Verb RunAs
        # Выходим из текущего процесса
        Exit
    } else {
        Write-Host "Скрипт требует запуска от имени администратора для корректной работы." -ForegroundColor Red
        Pause
        Exit
    }
}

# Функция для центрированного вывода сообщения с цветами
function Write-CenteredMessage {
    param (
        [string]$message,
        [int]$lineNumber,
        [string]$foregroundColor = $null,
        [string]$backgroundColor = $null
    )

    $originalForeground = [console]::ForegroundColor
    $originalBackground = [console]::BackgroundColor

    if ($foregroundColor) {
        [console]::ForegroundColor = $foregroundColor
    }

    if ($backgroundColor) {
        [console]::BackgroundColor = $backgroundColor
    }

    $windowWidth = [console]::WindowWidth
    $padding = " " * [math]::Floor(($windowWidth - $message.Length) / 2)
    [console]::SetCursorPosition(0, $lineNumber)
    [console]::WriteLine("$padding$message")

    # Возвращаем цвета назад
    [console]::ForegroundColor = $originalForeground
    [console]::BackgroundColor = $originalBackground
}

# Очистка экрана
Clear-Host

# Получение размеров консоли
$windowWidth = [console]::WindowWidth
$windowHeight = [console]::WindowHeight

# Вычисляем центральное положение сообщения
$centerLine = [math]::Floor($windowHeight / 2)

# Вывод приветственного сообщения
Write-CenteredMessage "Автоматический установщик программ для Windows" -lineNumber ($centerLine - 10) -ForegroundColor DarkRed

# Мордочка енота
$enot = @(
    "░░░░░░░░░░░░░░░▄▄▄▄▄▄▄▄░░░░░░░░░░░░░░",
    "░▄█▀███▄▄████████████████████▄▄███▀█░",
    "░█░░▀████████████████████████████░░█░",
    "░░█▄░░▀████████████████████████░░░▄▀░",
    "░░░▀█▄▄████▀▀▀░░░░██░░░▀▀▀█████▄▄█▀░░",
    "░░░▄███▀▀░░░░░░░░░██░░░░░░░░░▀███▄░░░",
    "░░▄██▀░░░░░▄▄▄██▄▄██░▄██▄▄▄░░░░░▀██▄░",
    "▄██▀░░░▄▄▄███▄██████████▄███▄▄▄░░░▀█▄",
    "▀██▄▄██████████▀░███▀▀▀█████████▄▄▄█▀",
    "░░▀██████████▀░░░███░░░▀███████████▀░",
    "░░░░▀▀▀██████░░░█████▄░░▀██████▀▀░░░░",
    "░░░░░░░░░▀▀▀▀▄░░█████▀░▄█▀▀▀░░░░░░░░░",
    "░░░░░░░░░░░░░░▀▀▄▄▄▄▄▀▀░░░░░░░░░░░░░░"
)

$enotHeight = $enot.Length
$enotStartLine = $centerLine - [math]::Floor($enotHeight / 2)

for ($i = 0; $i -lt $enotHeight; $i++) {
    $bottomLine = $enotStartLine + $i
    [console]::SetCursorPosition(0, $bottomLine)
    $padding = " " * [math]::Floor(($windowWidth - $enot[$i].Length) / 2)
    [console]::WriteLine("$padding" + $enot[$i])
}

# Вывод строки "made by ErneyWhite" в самом низу консоли
$bottomLine = $windowHeight - 1
[console]::SetCursorPosition(0, $bottomLine)
# Цвет текста — например, Cyan (можно изменить)
$originalColor = [console]::ForegroundColor
[console]::ForegroundColor = "DarkRed"
# Вывод надписи по центру
$padding = " " * [math]::Floor(($windowWidth - "made by ErneyWhite".Length) / 2)
[console]::WriteLine("$padding" + "made by ErneyWhite")
# Возврат к исходному цвету
[console]::ForegroundColor = $originalColor

# Пауза на 3 секунды
Start-Sleep -Seconds 3

# Очистка экрана после приветственного сообщения
Clear-Host

# Функция для центрированного вывода сообщения
function Write-CenteredMessage {
    param (
        [string]$message,
        [int]$lineNumber
    )

    $padding = " " * [math]::Floor(($windowWidth - $message.Length) / 2)
    [console]::SetCursorPosition(0, $lineNumber)
    [console]::WriteLine("$padding$message")
}

$sevenZipPaths = @(
    Join-Path $env:ProgramFiles "7-Zip\\7z.exe"
    Join-Path ${env:ProgramFiles(x86)} "7-Zip\\7z.exe"
)

$sevenZipPath = $sevenZipPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

# Проверка наличия 7-Zip
if (-Not (Test-Path -Path $sevenZipPath)) {
    Write-Host "7-Zip не найден по пути $sevenZipPath. Рекомендуется установить его для корректной работы некоторых программ." -ForegroundColor Yellow
    
    $response = Read-Host "Хотите установить 7-Zip? (y/н, n/т)"
    if ($response -eq "y" -or $response -eq "н") {
        $sevenZipInstallerUrl = "https://www.7-zip.org/a/7z2409-x64.exe"
        $sevenZipInstallerPath = "$env:TEMP\7z2409-x64.exe"

        try {
            Write-Host "Скачивание установщика 7-Zip..." -ForegroundColor Cyan
            Start-BitsTransfer -Source $sevenZipInstallerUrl -Destination $sevenZipInstallerPath -ErrorAction Stop

            Write-Host "Установка 7-Zip..." -ForegroundColor Cyan
            Start-Process -FilePath $sevenZipInstallerPath -ArgumentList "/S" -Wait -ErrorAction Stop

            if (Test-Path -Path $sevenZipPath) {
                Write-Host "7-Zip успешно установлен!" -ForegroundColor Green
                Remove-Item -Path $sevenZipInstallerPath -Force -ErrorAction SilentlyContinue
            } else {
                throw "7-Zip не установлен. Убедитесь, что установка прошла корректно."
            }
        }
        catch {
            Write-Host "Произошла ошибка во время установки 7-Zip: $_" -ForegroundColor Red
            Pause
            Exit
        }
    } elseif ($response -eq "n" -or $response -eq "т") {
        Write-Host "Установка 7-Zip пропущена. Некоторые программы могут не работать корректно." -ForegroundColor Yellow
    } else {
        Write-Host "Неверный ответ. Установка 7-Zip пропущена." -ForegroundColor Yellow
    }
}

# Если 7-Zip не установлен, предупреждаем пользователя и продолжаем выполнение
if (-Not (Test-Path -Path $sevenZipPath)) {
    Write-Host "7-Zip не установлен. Некоторые программы могут не работать корректно. Продолжить? (y/н, n/т)" -ForegroundColor Yellow
    $response = Read-Host
    if ($response -eq "y" -or $response -eq "н") {
        Write-Host "Продолжаем выполнение без 7-Zip." -ForegroundColor Yellow
    } elseif ($response -eq "n" -or $response -eq "т") {
        Write-Host "Выход из программы." -ForegroundColor Green
        Exit
    } else {
        Write-Host "Неверный ответ. Выход из программы." -ForegroundColor Red
        Exit
    }
}

# Список программ с их URL, аргументами установки, именами установщиков и (опционально) архивами
$programs = @(
    @{
        Name       = "7-Zip (24.09)"
        Url        = "https://www.7-zip.org/a/7z2409-x64.exe"
        Args       = "/S"
        Installer  = "7z2409-x64.exe"
    },
    @{
        Name       = "WinRAR (7.00)"
        Url        = "https://powertoy.erney.monster/packs/WinRAR.v7.00.exe"
        Args       = "/S /IRU"
        Installer  = "WinRAR.v7.00.exe"
    },
    @{
        Name       = "Firefox (137.0)"
        Url        = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/137.0/win64/ru/Firefox%20Setup%20137.0.msi"
        Args       = "/quiet /norestart"
        Installer  = "Firefox%20Setup%20137.0.msi"
    },
    @{
        Name       = "Google Chrome (latest)"
        Url        = "https://powertoy.erney.monster/packs/ChromeSetup.exe"
        Args       = "/S"
        Installer  = "ChromeSetup.exe"
    },
    @{
        Name       = "Notepad++ (8.7.9)"
        Url        = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.7.9/npp.8.7.9.Installer.x64.exe"
        Args       = "/S"
        Installer  = "npp.8.7.9.Installer.x64.exe"
    },
    @{
        Name       = "Steam (latest)"
        Url        = "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe"
        Args       = "/S"
        Installer  = "SteamSetup.exe"
    },
    @{
        Name       = "Epic Games Store (18.1.3)"
        Url        = "https://epicgames-download1.akamaized.net/Builds/UnrealEngineLauncher/Installers/Win32/EpicInstaller-18.1.3.msi?launcherfilename=EpicInstaller-18.1.3.msi"
        Args       = "/quiet /norestart"
        Installer  = "EpicInstaller-18.1.3.msi"
    },
    @{
        Name       = "Discord (latest)"
        Url        = "https://stable.dl2.discordapp.net/distro/app/stable/win/x64/1.0.9188/DiscordSetup.exe"
        Args       = "/S"
        Installer  = "DiscordSetup.exe"
    },
    @{
        Name       = "AmneziaVPN (4.8.5.0)"
        Url        = "https://github.com/amnezia-vpn/amnezia-client/releases/download/4.8.5.0/AmneziaVPN_4.8.5.0_x64.exe"
        Args       = "/S"
        Installer  = "AmneziaVPN_4.8.5.0_x64.exe"
    },
    @{
        Name       = "Spotify (latest)"
        Url        = "https://download.scdn.co/SpotifySetup.exe"
        Args       = "/S"
        Installer  = "SpotifySetup.exe"
    },
    @{
        Name       = "1Password (latest)"
        Url        = "https://downloads.1password.com/win/1PasswordSetup-latest.exe"
        Args       = ""
        Installer  = "1PasswordSetup-latest.exe"
    },
    @{
        Name       = "Windhawk (1.5.1)"
        Url        = "https://github.com/ramensoftware/windhawk/releases/download/v1.5.1/windhawk_setup.exe"
        Args       = "/S"
        Installer  = "windhawk_setup.exe"
    },
    @{
        Name       = "qBittorrent (5.0.4)"
        Url        = "https://netix.dl.sourceforge.net/project/qbittorrent/qbittorrent-win32/qbittorrent-5.0.4/qbittorrent_5.0.4_x64_setup.exe?viasf=1"
        Args       = "/S"
        Installer  = "qbittorrent_5.0.4_x64_setup.exe"
    },
    @{
        Name       = "Telegram (5.13.1)"
        Url        = "https://td.telegram.org/tx64/tsetup-x64.5.13.1.exe"
        Args       = "/S"
        Installer  = "tsetup-x64.5.13.1.exe"
    },
        @{
        Name       = "NVIDIA App (11.0.3.218)"
        Url        = "https://us.download.nvidia.com/nvapp/client/11.0.3.218/NVIDIA_app_v11.0.3.218.exe"
        Args       = "/S"
        Installer  = "NVIDIA_app_v11.0.3.218.exe"
    },
    @{
        Name       = "Synology Drive Client (3.5.2-16111)"
        Url        = "https://global.synologydownload.com/download/Utility/SynologyDriveClient/3.5.2-16111/Windows/Installer/i686/Synology%20Drive%20Client-3.5.2-16111-x86.exe"
        Args       = "/S"
        Installer  = "Synology%20Drive%20Client-3.5.2-16111-x86.exe"
    },
    @{
        Name       = "CurseForge (latest)"
        Url        = "https://download.overwolf.com/installer/prod/3106bf0c5fb76010ca49405b08867f60/CurseForge%20Windows%20-%20Installer.exe"
        Args       = "/S"
        Installer  = "CurseForge%20Windows%20-%20Installer.exe"
    },
    @{
        Name       = "WeMod (latest)"
        Url        = "https://www.wemod.com/download/direct"
        Args       = "/S"
        Installer  = "WeMod-Setup.exe"
    },
    @{
        Name       = "WeMod PRO Unlocker (archive)"
        Url        = "https://powertoy.erney.monster/packs/WeMod_Pro_Unlocker.zip"
        Args       = ""
        Installer  = "WeMod Pro - Unlocker {mul0}[v2.1].exe"
        Zip        = "WeMod_Pro_Unlocker.zip"
    },
    @{
        Name       = "WeMod PRO W3M0dP4tch32 (archive)"
        Url        = "https://powertoy.erney.monster/packs/v1.2.5.EXE.zip"
        Args       = ""
        Installer  = "WeModPatcher.exe"
        Zip        = "v1.2.5.EXE.zip"
    },
    @{
        Name       = "Virtual Desktop Streamer (latest)"
        Url        = "https://download.vrdesktop.net/files/VirtualDesktop.Streamer.Setup.exe"
        Args       = ""
        Installer  = "VirtualDesktop.Streamer.Setup.exe"
    },
    @{
        Name       = "SideQuest (0.10.42)"
        Url        = "https://powertoy.erney.monster/packs/SideQuest-Setup-0.10.42-x64-win.exe"
        Args       = ""
        Installer  = "SideQuest-Setup-0.10.42-x64-win.exe"
    },
    @{
        Name       = "MiniBin (archive 6.6.0.0)"
        Url        = "https://1uost4.soft-load.eu/b3/0/6/7b5b2b5b4e1e55d6e73d51076d64a22e/minibin.zip"
        Args       = "/S"
        Installer  = "MiniBin-6.6.0.0-Setup.exe"
        Zip        = "minibin.zip"
    },
    @{
        Name       = "ID-COOLING (1.0.5)"
        Url        = "https://powertoy.erney.monster/packs/ID-COOLING2.1V1.0.5.msi"
        Args       = "/quiet /norestart"
        Installer  = "ID-COOLING2.1V1.0.5.msi"
    },
    @{
        Name       = "Z-SYNC (archive 1.0.19)"
        Url        = "https://powertoy.erney.monster/packs/Z-SYNC%20Software%20Ver+1.0.19.zip_210216.zip"
        Args       = "/quiet /norestart"
        Installer  = "Setup1.msi"
        Zip        = "Z-SYNC Software Ver+1.0.19.zip_210216.zip"
    },
    @{
        Name       = "Stream Dock (latest)"
        Url        = "https://download1979.mediafire.com/83pu8n5j5ejgntt4Fs0jTIZUJSz-7GhIgIL5rFp1rMCvlqPiTMipD_7v70aj5NpkbKy-gVFRha8eZoM12-i26JA49Ji-YCP-InlPTKUHfwkOI5OxkyUsVMly3X64sEla7Rb_3GsnnCjkHEex9OyC65-nXV7XUk_EbKCaapw4JqKQ/bo00bunrx3nwqbc/Stream-Dock-Installer_Windows.exe"
        Args       = ""
        Installer  = "Stream-Dock-Installer_Windows.exe"
    },
    @{
        Name       = "Logitech G HUB (latest)"
        Url        = "https://download01.logi.com/web/ftp/pub/techsupport/gaming/lghub_installer.exe"
        Args       = ""
        Installer  = "lghub_installer.exe"
    },
    @{
        Name       = "LibreOffice (25.2.2)"
        Url        = "https://ftp.byfly.by/pub/tdf/libreoffice/stable/25.2.2/win/x86_64/LibreOffice_25.2.2_Win_x86-64.msi"
        Args       = "/quiet /norestart"
        Installer  = "LibreOffice_25.2.2_Win_x86-64.msi"
    },
    @{
        Name       = "WinDirStat (2.2.2)"
        Url        = "https://github.com/windirstat/windirstat/releases/download/release/v2.2.2/WinDirStat-x64.msi"
        Args       = "/quiet /norestart"
        Installer  = "WinDirStat-x64.msi"
    }
    # Добавьте больше программ по аналогии
)

# Путь для временного хранения загруженных установщиков
$downloadPath = "$env:TEMP\Installers"

# Создаем папку для загруженных установщиков, если она не существует
if (-Not (Test-Path -Path $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath
}

# Функция для отображения меню
function Show-Menu {
    Clear-Host
    Write-host "Выберите программу для установки (для пунктов с archive необходимо наличие 7-Zip) или q для выхода:"  -ForegroundColor Green
    for ($i = 0; $i -lt $programs.Count; $i++) {
        Write-host "[$($i + 1)] $($programs[$i].Name)"
    }
    Write-host "[q] Выход" -ForegroundColor Green
}

# Функция для рекурсивного разархивирования
function Extract-Archive {
    param (
        [string]$archivePath,
        [string]$extractPath
    )

    Write-host "Разархивирование $($archivePath)..." -ForegroundColor Cyan
    Start-Process -FilePath $sevenZipPath -ArgumentList "x -o`"$extractPath`" `"$archivePath`" -y" -Wait

    # Поиск вложенных архивов
    $nestedArchives = Get-ChildItem -Path $extractPath -Recurse -Include *.zip, *.rar
    foreach ($nestedArchive in $nestedArchives) {
        $nestedExtractPath = Join-Path -Path $nestedArchive.DirectoryName -ChildPath ($nestedArchive.BaseName -replace " ", "_")
        if (Test-Path -Path $nestedExtractPath) {
            Remove-Item -Path $nestedExtractPath -Recurse -Force
        }
        New-Item -ItemType Directory -Path $nestedExtractPath
        Extract-Archive -archivePath $nestedArchive.FullName -extractPath $nestedExtractPath
    }
}

# Функция установки выбранной программы
function Install-SelectedProgram {
    param (
        [int]$index
    )

    if ($index -ge 1 -and $index -le $programs.Count) {
        $program = $programs[$index - 1]

        if ($program.Type -eq "ISO") {
            # Обработка монтирования ISO-образа
            $isoFilePath = Join-Path -Path $downloadPath -ChildPath $program.Installer

            # Скачивание ISO-образа
            Write-host "Скачивание ISO-образа $($program.Name)..." -ForegroundColor Cyan
            Start-BitsTransfer -Source $program.Url -Destination $isoFilePath

            # Монтирование ISO-образа
            Write-host "Монтирование ISO-образа $($program.Name)..." -ForegroundColor Cyan
            $mountResult = Mount-DiskImage -ImagePath $isoFilePath -PassThru
            $driveLetter = ($mountResult | Get-Volume).DriveLetter + ":"

            Write-host "ISO-образ успешно смонтирован на диске $driveLetter." -ForegroundColor Green

            # Ожидание нажатия клавиши для размонтирования
            Read-Host "Нажмите Enter для размонтирования ISO-образа..." -ForegroundColor Cyan

            # Размонтирование ISO-образа
            Write-host "Размонтирование ISO-образа..." -ForegroundColor Cyan
            Dismount-DiskImage -ImagePath $isoFilePath

            Write-host "ISO-образ успешно размонтирован." -ForegroundColor Green
            return
        }

        if ($program.Type -eq "Script") {
            # Обработка специальных случаев для скриптов
            
        }

        $downloadFilePath = Join-Path -Path $downloadPath -ChildPath $program.Installer
        if ($program.Zip) {
            $downloadFilePath = Join-Path -Path $downloadPath -ChildPath $program.Zip
        }

        $extractPath = Join-Path -Path $downloadPath -ChildPath ($program.Name -replace " ", "_")

        if ($program.Zip) {
            # Скачивание архива
            Write-host "Скачивание архива $($program.Name)..." -ForegroundColor Cyan
            Start-BitsTransfer -Source $program.Url -Destination $downloadFilePath

            # Разархивирование архива
            if (Test-Path -Path $extractPath) {
                Remove-Item -Path $extractPath -Recurse -Force
            }
            New-Item -ItemType Directory -Path $extractPath
            Extract-Archive -archivePath $downloadFilePath -extractPath $extractPath

            # Поиск установного файла внутри разархивированных файлов
            $installerPath = Get-ChildItem -Path $extractPath -Recurse -Include *.msi, *.exe | Select-Object -First 1 -ExpandProperty FullName
            if (-Not $installerPath) {
                Write-host "Установочный файл не найден в разархивированных файлах." -ForegroundColor Red
                return
            }
        } else {
            # Скачивание установочного файла
            Write-host "Скачивание $($program.Name)..." -ForegroundColor Cyan
            Start-BitsTransfer -Source $program.Url -Destination $downloadFilePath
            $installerPath = $downloadFilePath
        }

        # Определение типа установочного файла
        if ($program.Type -eq "Script") {
            # Выполнение PowerShell-скрипта
            Write-host "Выполнение скрипта $($program.Name)..." -ForegroundColor Cyan
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installerPath
        } elseif ($installerPath -like "*.msi") {
            # Установка MSI-пакета
            Write-host "Установка MSI-пакета $($program.Name)..." -ForegroundColor Cyan
            $msiArgs = "/i `"$installerPath`""
            if ($program.Args) {
                $msiArgs += " $($program.Args)"
            }
            Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait
        } else {
            # Установка обычного установщика
            Write-host "Установка $($program.Name)..." -ForegroundColor Cyan
            $exeArgs = $program.Args
            if ($program.Args) {
                Start-Process -FilePath $installerPath -ArgumentList $exeArgs -Wait
            } else {
                Start-Process -FilePath $installerPath -Wait
            }
        }

        Write-host "$($program.Name) успешно установлен и настроен." -ForegroundColor Green
    } else {
        Write-host "Неверный выбор: $index" -ForegroundColor Yellow
    }
}

# Основной цикл программы
do {
    Show-Menu
    $input = Read-Host "Введите номер программы для установки или q/й для выхода"

    if ($input -eq "q" -or $input -eq "й") {
        Write-host "Выход из программы." -ForegroundColor Green
        break
    }

    # Объявляем переменную $selectedIndex
    $selectedIndex = 0
    if ([int]::TryParse($input, [ref]$selectedIndex) -and $selectedIndex -ge 1 -and $selectedIndex -le $programs.Count) {
        Install-SelectedProgram -index $selectedIndex
    } else {
        Write-host "Неверный выбор: $input" -ForegroundColor Red
    }

    Read-Host "Нажмите Enter для возврата в меню..."
} while ($true)

# Удаляем папку с загруженными установщиками
Remove-Item -Path $downloadPath -Recurse -Force

Write-host "Все выбранные программы установлены." -ForegroundColor Green
