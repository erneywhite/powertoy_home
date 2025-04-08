<?php
// Ваш PowerShell скрипт
$powershellScript = '
# Устанавливаем кодировку UTF-8 для входных и выходных данных
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Устанавливаем кодировку UTF-8 для входных и выходных данных
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"

# Проверка наличия 7-Zip
if (-Not (Test-Path -Path $sevenZipPath)) {
    Write-Output "7-Zip не найден по пути $sevenZipPath. Установка 7-Zip (24.09)..."

    $sevenZipInstallerUrl = "https://www.7-zip.org/a/7z2409-x64.exe"
    $sevenZipInstallerPath = "$env:TEMP\7z2409-x64.exe"

    # Скачивание установщика 7-Zip (24.09)
    Write-Output "Скачивание установщика 7-Zip (24.09)..."
    Start-BitsTransfer -Source $sevenZipInstallerUrl -Destination $sevenZipInstallerPath

    # Установка 7-Zip (24.09)
    Write-Output "Установка 7-Zip (24.09)..."
    Start-Process -FilePath $sevenZipInstallerPath -ArgumentList "/S" -Wait

    # Проверка успешности установки
    if (-Not (Test-Path -Path $sevenZipPath)) {
        Write-Output "Не удалось установить 7-Zip. Пожалуйста, установите 7-Zip вручную и укажите правильный путь."
        exit
    }
    Write-Output "7-Zip успешно установлен."
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
        Name       = "Firefox (137.0)"
        Url        = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/137.0/win64/ru/Firefox%20Setup%20137.0.msi"
        Args       = "/quiet /norestart"
        Installer  = "Firefox%20Setup%20137.0.msi"
    },
    @{
        Name       = "Google Chrome (latest)"
        Url        = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B1830306B-1820-A51E-E12C-105AF0F1DDE7%7D%26lang%3Dru%26browser%3D3%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3Dx64-statsdef_1%26installdataindex%3Dempty/update2/installers/ChromeSetup.exe"
        Args       = "/S"
        Installer  = "ChromeSetup.exe"
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
        Name       = "Virtual Desktop (latest)"
        Url        = "https://download.vrdesktop.net/files/VirtualDesktop.Streamer.Setup.exe"
        Args       = "/S"
        Installer  = "VirtualDesktop.Streamer.Setup.exe"
    },
    @{
        Name       = "MiniBin (archive 6.1.1.1)"
        Url        = "https://dw.uptodown.net/dwn/-NFx0g5JJ48-7ndGQIXpSfAY4STck01JnW-TJoZ8Cx6YZP9wsJvUsL9tEAwp210nVTJHVcgfFxi9Qk-QJDLCWvRHT0aUWYRgA4X6vnPLVTi3OSKJnEdOkPRvmYqaZ815/g_yCNJh0nM9H8yc8qLYDlb0xDXvDfYMk629VbuLjRIEHkTC7mXRmImYAObWN82gueYJaM1dJL4RoYo0WMeWPn_dqxAMf2WYWexh7SCBQfIELHHuHNi8agujrRIyVcS5e/jbsQqu-il7YI6RU2S1B2bnDC-fos1tzKUaG1yPCVIODKZKhse_D8u5HDLNwN28KENrb7DLW05jcbcN7wMd_Gag==/minibin-6-1-1-1.zip"
        Args       = "/S"
        Installer  = "MiniBin-6.1.1.1-Setup.exe"
        Zip        = "minibin-6-1-1-1.zip"
    },
    @{
        Name       = "ID-COOLING (archive 1.0.5)"
        Url        = "https://drive.usercontent.google.com/download?id=1UapYowSOkg_LUKP14mhaqmh0Gtj8wuSM&export=download&authuser=0&confirm=t&uuid=e8204f52-1f77-4c56-81f6-e8cb1970f4df&at=APcmpoxFN0LPH6HQZH_2D0GT2T7_%3A1744056809000"
        Args       = "/quiet /norestart"
        Installer  = "ID-COOLING2.1V1.0.5.msi"
        Zip        = "ID-COOLING2.1V1.0.5-SetupFiles.rar"
    },
    @{
        Name       = "Z-SYNC (archive 1.0.19)"
        Url        = "https://www.zalman.com/cmm/fms/FileDownAll.do?atchFileId=FILE_000000000014397"
        Args       = "/quiet /norestart"
        Installer  = "Setup1.msi"
        Zip        = "Z-SYNC Software Ver+1.0.19.zip_210216.zip"
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
    Write-Output "Выберите программу для установки (для пунктов с archive необходимо наличие 7-Zip) или q для выхода:"
    for ($i = 0; $i -lt $programs.Count; $i++) {
        Write-Output "[$($i + 1)] $($programs[$i].Name)"
    }
    Write-Output "[q] Выход"
}

# Функция для рекурсивного разархивирования
function Extract-Archive {
    param (
        [string]$archivePath,
        [string]$extractPath
    )

    Write-Output "Разархивирование $($archivePath)..."
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

        $downloadFilePath = Join-Path -Path $downloadPath -ChildPath $program.Installer
        if ($program.Zip) {
            $downloadFilePath = Join-Path -Path $downloadPath -ChildPath $program.Zip
        }

        $extractPath = Join-Path -Path $downloadPath -ChildPath ($program.Name -replace " ", "_")

        if ($program.Zip) {
            # Скачивание архива
            Write-Output "Скачивание архива $($program.Name)..."
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
                Write-Output "Установочный файл не найден в разархивированных файлах."
                return
            }
        } else {
            # Скачивание установочного файла
            Write-Output "Скачивание $($program.Name)..."
            Start-BitsTransfer -Source $program.Url -Destination $downloadFilePath
            $installerPath = $downloadFilePath
        }

        # Определение типа установочного файла
        if ($installerPath -like "*.msi") {
            # Установка MSI-пакета
            Write-Output "Установка MSI-пакета $($program.Name)..."
            $msiArgs = "/i `"$installerPath`""
            if ($program.Args) {
                $msiArgs += " $($program.Args)"
            }
            Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait
        } else {
            # Установка обычного установщика
            Write-Output "Установка $($program.Name)..."
            $exeArgs = $program.Args
            if ($program.Args) {
                Start-Process -FilePath $installerPath -ArgumentList $exeArgs -Wait
            } else {
                Start-Process -FilePath $installerPath -Wait
            }
        }

        Write-Output "$($program.Name) успешно установлен."
    } else {
        Write-Output "Неверный выбор: $index"
    }
}

# Основной цикл программы
do {
    Show-Menu
    $input = Read-Host "Введите номер программы для установки или q/й для выхода"

    if ($input -eq "q" -or $input -eq "й") {
        Write-Output "Выход из программы."
        break
    }

    # Объявляем переменную $selectedIndex
    $selectedIndex = 0
    if ([int]::TryParse($input, [ref]$selectedIndex) -and $selectedIndex -ge 1 -and $selectedIndex -le $programs.Count) {
        Install-SelectedProgram -index $selectedIndex
    } else {
        Write-Output "Неверный выбор: $input"
    }

    Read-Host "Нажмите Enter для возврата в меню..."
} while ($true)

# Удаляем папку с загруженными установщиками
Remove-Item -Path $downloadPath -Recurse -Force

Write-Output "Все выбранные программы установлены."
';

// Добавляем BOM для UTF-8
$powershellScriptWithBOM = "\xEF\xBB\xBF" . $powershellScript;

// Форматированный скрипт для отображения в браузере
$formattedScript = '<pre><code><strong>Script for home usage</strong><br><span style="color: blue;"># Устанавливаем кодировку UTF-8 для входных и выходных данных
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"

# Проверка наличия 7-Zip
if (-Not (Test-Path -Path $sevenZipPath)) {
    Write-Output "7-Zip не найден по пути $sevenZipPath. Установка 7-Zip (24.09)..."

    $sevenZipInstallerUrl = "https://www.7-zip.org/a/7z2409-x64.exe"
    $sevenZipInstallerPath = "$env:TEMP\7z2409-x64.exe"

    # Скачивание установщика 7-Zip (24.09)
    Write-Output "Скачивание установщика 7-Zip (24.09)..."
    Start-BitsTransfer -Source $sevenZipInstallerUrl -Destination $sevenZipInstallerPath

    # Установка 7-Zip (24.09)
    Write-Output "Установка 7-Zip (24.09)..."
    Start-Process -FilePath $sevenZipInstallerPath -ArgumentList "/S" -Wait

    # Проверка успешности установки
    if (-Not (Test-Path -Path $sevenZipPath)) {
        Write-Output "Не удалось установить 7-Zip. Пожалуйста, установите 7-Zip вручную и укажите правильный путь."
        exit
    }
    Write-Output "7-Zip успешно установлен."
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
        Name       = "Firefox (137.0)"
        Url        = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/137.0/win64/ru/Firefox%20Setup%20137.0.msi"
        Args       = "/quiet /norestart"
        Installer  = "Firefox%20Setup%20137.0.msi"
    },
    @{
        Name       = "Google Chrome (latest)"
        Url        = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B1830306B-1820-A51E-E12C-105AF0F1DDE7%7D%26lang%3Dru%26browser%3D3%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3Dx64-statsdef_1%26installdataindex%3Dempty/update2/installers/ChromeSetup.exe"
        Args       = "/S"
        Installer  = "ChromeSetup.exe"
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
        Name       = "Virtual Desktop (latest)"
        Url        = "https://download.vrdesktop.net/files/VirtualDesktop.Streamer.Setup.exe"
        Args       = "/S"
        Installer  = "VirtualDesktop.Streamer.Setup.exe"
    },
    @{
        Name       = "MiniBin (archive 6.1.1.1)"
        Url        = "https://dw.uptodown.net/dwn/-NFx0g5JJ48-7ndGQIXpSfAY4STck01JnW-TJoZ8Cx6YZP9wsJvUsL9tEAwp210nVTJHVcgfFxi9Qk-QJDLCWvRHT0aUWYRgA4X6vnPLVTi3OSKJnEdOkPRvmYqaZ815/g_yCNJh0nM9H8yc8qLYDlb0xDXvDfYMk629VbuLjRIEHkTC7mXRmImYAObWN82gueYJaM1dJL4RoYo0WMeWPn_dqxAMf2WYWexh7SCBQfIELHHuHNi8agujrRIyVcS5e/jbsQqu-il7YI6RU2S1B2bnDC-fos1tzKUaG1yPCVIODKZKhse_D8u5HDLNwN28KENrb7DLW05jcbcN7wMd_Gag==/minibin-6-1-1-1.zip"
        Args       = "/S"
        Installer  = "MiniBin-6.1.1.1-Setup.exe"
        Zip        = "minibin-6-1-1-1.zip"
    },
    @{
        Name       = "ID-COOLING (archive 1.0.5)"
        Url        = "https://drive.usercontent.google.com/download?id=1UapYowSOkg_LUKP14mhaqmh0Gtj8wuSM&export=download&authuser=0&confirm=t&uuid=e8204f52-1f77-4c56-81f6-e8cb1970f4df&at=APcmpoxFN0LPH6HQZH_2D0GT2T7_%3A1744056809000"
        Args       = "/quiet /norestart"
        Installer  = "ID-COOLING2.1V1.0.5.msi"
        Zip        = "ID-COOLING2.1V1.0.5-SetupFiles.rar"
    },
    @{
        Name       = "Z-SYNC (archive 1.0.19)"
        Url        = "https://www.zalman.com/cmm/fms/FileDownAll.do?atchFileId=FILE_000000000014397"
        Args       = "/quiet /norestart"
        Installer  = "Setup1.msi"
        Zip        = "Z-SYNC Software Ver+1.0.19.zip_210216.zip"
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
    Write-Output "Выберите программу для установки (для пунктов с archive необходимо наличие 7-Zip) или q для выхода:"
    for ($i = 0; $i -lt $programs.Count; $i++) {
        Write-Output "[$($i + 1)] $($programs[$i].Name)"
    }
    Write-Output "[q] Выход"
}

# Функция для рекурсивного разархивирования
function Extract-Archive {
    param (
        [string]$archivePath,
        [string]$extractPath
    )

    Write-Output "Разархивирование $($archivePath)..."
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

        $downloadFilePath = Join-Path -Path $downloadPath -ChildPath $program.Installer
        if ($program.Zip) {
            $downloadFilePath = Join-Path -Path $downloadPath -ChildPath $program.Zip
        }

        $extractPath = Join-Path -Path $downloadPath -ChildPath ($program.Name -replace " ", "_")

        if ($program.Zip) {
            # Скачивание архива
            Write-Output "Скачивание архива $($program.Name)..."
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
                Write-Output "Установочный файл не найден в разархивированных файлах."
                return
            }
        } else {
            # Скачивание установочного файла
            Write-Output "Скачивание $($program.Name)..."
            Start-BitsTransfer -Source $program.Url -Destination $downloadFilePath
            $installerPath = $downloadFilePath
        }

        # Определение типа установочного файла
        if ($installerPath -like "*.msi") {
            # Установка MSI-пакета
            Write-Output "Установка MSI-пакета $($program.Name)..."
            $msiArgs = "/i `"$installerPath`""
            if ($program.Args) {
                $msiArgs += " $($program.Args)"
            }
            Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait
        } else {
            # Установка обычного установщика
            Write-Output "Установка $($program.Name)..."
            $exeArgs = $program.Args
            if ($program.Args) {
                Start-Process -FilePath $installerPath -ArgumentList $exeArgs -Wait
            } else {
                Start-Process -FilePath $installerPath -Wait
            }
        }

        Write-Output "$($program.Name) успешно установлен."
    } else {
        Write-Output "Неверный выбор: $index"
    }
}

# Основной цикл программы
do {
    Show-Menu
    $input = Read-Host "Введите номер программы для установки или q/й для выхода"

    if ($input -eq "q" -or $input -eq "й") {
        Write-Output "Выход из программы."
        break
    }

    # Объявляем переменную $selectedIndex
    $selectedIndex = 0
    if ([int]::TryParse($input, [ref]$selectedIndex) -and $selectedIndex -ge 1 -and $selectedIndex -le $programs.Count) {
        Install-SelectedProgram -index $selectedIndex
    } else {
        Write-Output "Неверный выбор: $input"
    }

    Read-Host "Нажмите Enter для возврата в меню..."
} while ($true)

# Удаляем папку с загруженными установщиками
Remove-Item -Path $downloadPath -Recurse -Force

Write-Output "Все выбранные программы установлены."</span></code></pre>';

// Получаем User-Agent из заголовков запроса
$userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';

// Проверяем, является ли запрос от PowerShell или curl
if (strpos($userAgent, 'PowerShell') !== false || strpos($userAgent, 'curl') !== false) {
    // Возвращаем чистый PowerShell скрипт с правильной кодировкой и BOM
    header('Content-Type: application/octet-stream; charset=utf-8');
    echo $powershellScriptWithBOM;
} else {
    // Возвращаем форматированный HTML
    header('Content-Type: text/html; charset=utf-8');
    echo '
    <!DOCTYPE html>
    <html>
    <head>
        <title>Cool script by Erney White</title>
        <link rel="icon" type="image/x-icon" href="favicon.ico">
        <meta charset="UTF-8">
        <style>
            pre {
                background-color: #f4f4f4;
                padding: 10px;
                border-radius: 5px;
                font-family: Consolas, monospace;
            }
            code {
                white-space: pre;
            }
            strong {
                color: green;
            }
            span {
                color: blue;
            }
        </style>
    </head>
    <body>
        <h1>Made by Erney White</h1>
        ' . $formattedScript . '
    </body>
    </html>
    ';
}
?>
