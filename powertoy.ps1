# powertoy.ps1 — автоматический установщик программ для Windows
# Запуск: irm https://powertoy.erney.monster | iex

[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = 'Stop'

# --- Утилиты ----------------------------------------------------------------

function Read-YesNo {
    param(
        [Parameter(Mandatory)] [string]$Prompt
    )
    while ($true) {
        $resp = Read-Host "$Prompt (y/н, n/т)"
        switch -Regex ($resp) {
            '^(y|н)$' { return $true }
            '^(n|т)$' { return $false }
            default   { Write-Host "Неверный ответ. Введите y/н или n/т." -ForegroundColor Yellow }
        }
    }
}

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    return ([Security.Principal.WindowsPrincipal]$id).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Write-CenteredMessage {
    param(
        [Parameter(Mandatory)] [string]$Message,
        [Parameter(Mandatory)] [int]$LineNumber,
        [string]$ForegroundColor
    )
    $origFg = [console]::ForegroundColor
    if ($ForegroundColor) { [console]::ForegroundColor = $ForegroundColor }

    $width   = [console]::WindowWidth
    $padding = ' ' * [math]::Max(0, [math]::Floor(($width - $Message.Length) / 2))
    [console]::SetCursorPosition(0, $LineNumber)
    [console]::WriteLine("$padding$Message")

    [console]::ForegroundColor = $origFg
}

function Get-SevenZipPath {
    $candidates = @(
        Join-Path $env:ProgramFiles      '7-Zip\7z.exe'
        Join-Path ${env:ProgramFiles(x86)} '7-Zip\7z.exe'
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }
    return $candidates | Select-Object -First 1
}

function Install-SevenZip {
    $url     = 'https://www.7-zip.org/a/7z2409-x64.exe'
    $tmp     = Join-Path $env:TEMP '7z2409-x64.exe'

    Write-Host 'Скачивание установщика 7-Zip...' -ForegroundColor Cyan
    Start-BitsTransfer -Source $url -Destination $tmp -ErrorAction Stop

    Write-Host 'Установка 7-Zip...' -ForegroundColor Cyan
    Start-Process -FilePath $tmp -ArgumentList '/S' -Wait -ErrorAction Stop

    Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue

    $path = Get-SevenZipPath
    if (-not $path) {
        throw '7-Zip не установлен. Проверьте корректность установки.'
    }
    Write-Host '7-Zip успешно установлен!' -ForegroundColor Green
    return $path
}

# --- Проверка прав администратора -------------------------------------------

if (-not (Test-IsAdmin)) {
    Write-Host 'Скрипт требует запуска от имени администратора.' -ForegroundColor Red
    if (Read-YesNo 'Хотите запустить скрипт от имени администратора?') {
        Start-Process -FilePath PowerShell `
            -ArgumentList '-Command', 'irm https://powertoy.erney.monster | iex' `
            -Verb RunAs
        Exit
    } else {
        Write-Host 'Скрипт требует прав администратора для корректной работы.' -ForegroundColor Red
        Read-Host 'Нажмите Enter для выхода'
        Exit
    }
}

# --- Приветствие ------------------------------------------------------------

Clear-Host
$windowWidth  = [console]::WindowWidth
$windowHeight = [console]::WindowHeight
$centerLine   = [math]::Floor($windowHeight / 2)

Write-CenteredMessage -Message 'Автоматический установщик программ для Windows' `
    -LineNumber ($centerLine - 10) -ForegroundColor DarkRed

$enot = @(
    '░░░░░░░░░░░░░░░▄▄▄▄▄▄▄▄░░░░░░░░░░░░░░',
    '░▄█▀███▄▄████████████████████▄▄███▀█░',
    '░█░░▀████████████████████████████░░█░',
    '░░█▄░░▀████████████████████████░░░▄▀░',
    '░░░▀█▄▄████▀▀▀░░░░██░░░▀▀▀█████▄▄█▀░░',
    '░░░▄███▀▀░░░░░░░░░██░░░░░░░░░▀███▄░░░',
    '░░▄██▀░░░░░▄▄▄██▄▄██░▄██▄▄▄░░░░░▀██▄░',
    '▄██▀░░░▄▄▄███▄██████████▄███▄▄▄░░░▀█▄',
    '▀██▄▄██████████▀░███▀▀▀█████████▄▄▄█▀',
    '░░▀██████████▀░░░███░░░▀███████████▀░',
    '░░░░▀▀▀██████░░░█████▄░░▀██████▀▀░░░░',
    '░░░░░░░░░▀▀▀▀▄░░█████▀░▄█▀▀▀░░░░░░░░░',
    '░░░░░░░░░░░░░░▀▀▄▄▄▄▄▀▀░░░░░░░░░░░░░░'
)
$enotStartLine = $centerLine - [math]::Floor($enot.Length / 2)
for ($i = 0; $i -lt $enot.Length; $i++) {
    [console]::SetCursorPosition(0, $enotStartLine + $i)
    $padding = ' ' * [math]::Max(0, [math]::Floor(($windowWidth - $enot[$i].Length) / 2))
    [console]::WriteLine("$padding$($enot[$i])")
}

$origFg = [console]::ForegroundColor
[console]::ForegroundColor = 'DarkRed'
$signature = 'made by ErneyWhite'
$padding = ' ' * [math]::Max(0, [math]::Floor(($windowWidth - $signature.Length) / 2))
[console]::SetCursorPosition(0, $windowHeight - 1)
[console]::WriteLine("$padding$signature")
[console]::ForegroundColor = $origFg

Start-Sleep -Seconds 3
Clear-Host

# --- 7-Zip ------------------------------------------------------------------

$sevenZipPath = Get-SevenZipPath
if (-not $sevenZipPath) {
    Write-Host '7-Zip не найден. Он рекомендуется для установки программ из архивов.' -ForegroundColor Yellow
    if (Read-YesNo 'Хотите установить 7-Zip?') {
        try {
            $sevenZipPath = Install-SevenZip
        } catch {
            Write-Host "Ошибка установки 7-Zip: $_" -ForegroundColor Red
            Read-Host 'Нажмите Enter для выхода'
            Exit
        }
    } else {
        Write-Host 'Установка 7-Zip пропущена. Программы типа archive не сработают.' -ForegroundColor Yellow
        if (-not (Read-YesNo 'Продолжить без 7-Zip?')) {
            Exit
        }
    }
}

# --- Список программ -------------------------------------------------------
# Список загружается из programs.json рядом со скриптом на сервере.
# Чтобы добавить/обновить программу — правь programs.json, не этот файл.

$programsUrl = 'https://powertoy.erney.monster/programs.json'

try {
    Write-Host 'Загрузка списка программ...' -ForegroundColor Cyan
    $programs = Invoke-RestMethod -Uri $programsUrl -UseBasicParsing
} catch {
    Write-Host "Не удалось загрузить список программ с $programsUrl" -ForegroundColor Red
    Write-Host "Ошибка: $_" -ForegroundColor Red
    Read-Host 'Нажмите Enter для выхода'
    Exit
}

if (-not $programs -or $programs.Count -eq 0) {
    Write-Host 'Список программ пуст или повреждён.' -ForegroundColor Red
    Read-Host 'Нажмите Enter для выхода'
    Exit
}

# --- Установка -------------------------------------------------------------

$downloadPath = Join-Path $env:TEMP 'Installers'
if (-not (Test-Path -LiteralPath $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath | Out-Null
}

function Show-Menu {
    Clear-Host
    Write-Host 'Выберите программу для установки (для archive нужен 7-Zip) или q/й для выхода:' -ForegroundColor Green
    for ($i = 0; $i -lt $programs.Count; $i++) {
        Write-Host "[$($i + 1)] $($programs[$i].Name)"
    }
    Write-Host '[q] Выход' -ForegroundColor Green
}

function Expand-NestedArchive {
    param(
        [Parameter(Mandatory)] [string]$ArchivePath,
        [Parameter(Mandatory)] [string]$ExtractPath
    )

    if (-not $sevenZipPath) {
        throw '7-Zip не установлен — распаковка архива невозможна.'
    }

    Write-Host "Разархивирование $ArchivePath..." -ForegroundColor Cyan
    Start-Process -FilePath $sevenZipPath `
        -ArgumentList "x -o`"$ExtractPath`" `"$ArchivePath`" -y" -Wait

    $nested = Get-ChildItem -LiteralPath $ExtractPath -Recurse -Include *.zip, *.rar -File
    foreach ($n in $nested) {
        $nestedExtract = Join-Path $n.DirectoryName ($n.BaseName -replace ' ', '_')
        if (Test-Path -LiteralPath $nestedExtract) {
            Remove-Item -LiteralPath $nestedExtract -Recurse -Force
        }
        New-Item -ItemType Directory -Path $nestedExtract | Out-Null
        Expand-NestedArchive -ArchivePath $n.FullName -ExtractPath $nestedExtract
    }
}

function Install-SelectedProgram {
    param([Parameter(Mandatory)] [int]$Index)

    if ($Index -lt 1 -or $Index -gt $programs.Count) {
        Write-Host "Неверный выбор: $Index" -ForegroundColor Yellow
        return
    }
    $program = $programs[$Index - 1]

    try {
        $downloadName = if ($program.Zip) { $program.Zip } else { $program.Installer }
        $downloadFile = Join-Path $downloadPath $downloadName
        $extractPath  = Join-Path $downloadPath ($program.Name -replace ' ', '_')

        Write-Host "Скачивание $($program.Name)..." -ForegroundColor Cyan
        Start-BitsTransfer -Source $program.Url -Destination $downloadFile

        if ($program.Zip) {
            if (Test-Path -LiteralPath $extractPath) {
                Remove-Item -LiteralPath $extractPath -Recurse -Force
            }
            New-Item -ItemType Directory -Path $extractPath | Out-Null
            Expand-NestedArchive -ArchivePath $downloadFile -ExtractPath $extractPath

            $installerPath = Get-ChildItem -LiteralPath $extractPath -Recurse -Include *.msi, *.exe -File |
                Select-Object -First 1 -ExpandProperty FullName
            if (-not $installerPath) {
                Write-Host 'Установочный файл не найден в архиве.' -ForegroundColor Red
                return
            }
        } else {
            $installerPath = $downloadFile
        }

        if ($installerPath -like '*.msi') {
            Write-Host "Установка MSI-пакета $($program.Name)..." -ForegroundColor Cyan
            $msiArgs = "/i `"$installerPath`""
            if ($program.Args) { $msiArgs += " $($program.Args)" }
            Start-Process -FilePath 'msiexec.exe' -ArgumentList $msiArgs -Wait
        } else {
            Write-Host "Установка $($program.Name)..." -ForegroundColor Cyan
            if ($program.Args) {
                Start-Process -FilePath $installerPath -ArgumentList $program.Args -Wait
            } else {
                Start-Process -FilePath $installerPath -Wait
            }
        }

        Write-Host "$($program.Name) успешно установлен." -ForegroundColor Green
    } catch {
        Write-Host "Ошибка при установке $($program.Name): $_" -ForegroundColor Red
    }
}

# --- Основной цикл ---------------------------------------------------------

try {
    do {
        Show-Menu
        $choice = Read-Host 'Введите номер программы или q/й для выхода'

        if ($choice -match '^(q|й)$') {
            Write-Host 'Выход из программы.' -ForegroundColor Green
            break
        }

        $selectedIndex = 0
        if ([int]::TryParse($choice, [ref]$selectedIndex) -and
            $selectedIndex -ge 1 -and $selectedIndex -le $programs.Count) {
            Install-SelectedProgram -Index $selectedIndex
        } else {
            Write-Host "Неверный выбор: $choice" -ForegroundColor Red
        }

        Read-Host 'Нажмите Enter для возврата в меню'
    } while ($true)
}
finally {
    if (Test-Path -LiteralPath $downloadPath) {
        Remove-Item -LiteralPath $downloadPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host 'Все выбранные программы установлены.' -ForegroundColor Green
}
