# powertoy.ps1 — автоматический установщик программ для Windows
# Запуск: irm https://powertoy.erney.monster | iex

[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# TLS 1.2 для всех HTTPS-запросов (PS 5.1 по умолчанию использует SSL3/TLS1.0)
try {
    [System.Net.ServicePointManager]::SecurityProtocol = `
        [System.Net.ServicePointManager]::SecurityProtocol -bor `
        [System.Net.SecurityProtocolType]::Tls12
} catch {}

$ErrorActionPreference = 'Stop'
$logPath = Join-Path $env:TEMP 'powertoy.log'

# --- Лог -------------------------------------------------------------------

function Write-PtLog {
    param([string]$Message, [string]$Level = 'INFO')
    $line = "[{0}] [{1}] {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    try { Add-Content -Path $logPath -Value $line -Encoding UTF8 } catch {}
}

# --- Утилиты ---------------------------------------------------------------

function Read-YesNo {
    param([Parameter(Mandatory)] [string]$Prompt)
    while ($true) {
        $resp = Read-Host "$Prompt (y/н, n/т)"
        switch -Regex ($resp) {
            '^(y|н)$' { return $true }
            '^(n|т)$' { return $false }
            default   { Write-Host 'Неверный ответ. Введите y/н или n/т.' -ForegroundColor Yellow }
        }
    }
}

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    return ([Security.Principal.WindowsPrincipal]$id).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Start-Install {
    # Запускает установщик; если нужен админ, а мы не админ — поднимает права
    # точечно (отдельный UAC только на этот установщик).
    param(
        [Parameter(Mandatory)] [string]$FilePath,
        [string]$Arguments,
        [switch]$NeedsAdmin
    )
    $sp = @{ FilePath = $FilePath; Wait = $true; PassThru = $true; ErrorAction = 'Stop' }
    if ($Arguments) { $sp.ArgumentList = $Arguments }
    if ($NeedsAdmin -and -not $script:isAdmin) { $sp['Verb'] = 'RunAs' }
    return Start-Process @sp
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

function Resize-ConsoleWindow {
    # Подгоняем окно консоли под размер меню, чтобы не прокручивать.
    # 9 категорий + 31 программа + подсказки ≈ 60 строк.
    param(
        [int]$MinHeight = 60,
        [int]$MinWidth  = 100
    )

    try {
        $ui = (Get-Host).UI.RawUI
        if (-not $ui) { return }

        $maxSize = $ui.MaxWindowSize
        if (-not $maxSize) { return }

        $targetHeight = [math]::Min($MinHeight, [int]$maxSize.Height)
        $targetWidth  = [math]::Min($MinWidth,  [int]$maxSize.Width)

        # BufferSize должен быть >= WindowSize по обоим измерениям.
        $buffer = $ui.BufferSize
        $bufferChanged = $false
        if ($buffer.Width  -lt $targetWidth)          { $buffer.Width  = $targetWidth;       $bufferChanged = $true }
        if ($buffer.Height -lt ($targetHeight + 200)) { $buffer.Height = $targetHeight + 200; $bufferChanged = $true }
        if ($bufferChanged) { $ui.BufferSize = $buffer }

        $window = $ui.WindowSize
        $windowChanged = $false
        if ($window.Width  -lt $targetWidth)  { $window.Width  = $targetWidth;  $windowChanged = $true }
        if ($window.Height -lt $targetHeight) { $window.Height = $targetHeight; $windowChanged = $true }
        if ($windowChanged) { $ui.WindowSize = $window }
    } catch {
        # ISE/VSCode/Windows Terminal могут не позволять — игнорируем.
    }
}

function Get-SevenZipPath {
    $candidates = @(
        Join-Path $env:ProgramFiles      '7-Zip\7z.exe'
        Join-Path ${env:ProgramFiles(x86)} '7-Zip\7z.exe'
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }
    return $candidates | Select-Object -First 1
}

function Install-SevenZip {
    $url = 'https://www.7-zip.org/a/7z2601-x64.exe'
    $tmp = Join-Path $env:TEMP '7z2601-x64.exe'

    Write-Host 'Скачивание установщика 7-Zip...' -ForegroundColor Cyan
    Start-BitsTransfer -Source $url -Destination $tmp -ErrorAction Stop

    Write-Host 'Установка 7-Zip...' -ForegroundColor Cyan
    Start-Install -FilePath $tmp -Arguments '/S' -NeedsAdmin | Out-Null

    Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue

    $path = Get-SevenZipPath
    if (-not $path) { throw '7-Zip не установлен. Проверьте корректность установки.' }
    Write-Host '7-Zip успешно установлен!' -ForegroundColor Green
    return $path
}

# --- Прогресс-бар скачивания -----------------------------------------------

function Format-Duration {
    param([double]$Seconds)
    if ($Seconds -lt 0) { $Seconds = 0 }
    $s = [int][math]::Round($Seconds)
    if ($s -lt 60) { return "${s}с" }
    return ("{0}м{1:D2}с" -f [int]($s / 60), ($s % 60))
}

function Write-DownloadProgress {
    # Параметры без типизации: BITS отдаёт BytesTotal как [uint64] и когда
    # размер неизвестен — возвращает [uint64]::MaxValue (18446744073709551615),
    # что в Int64 не лезет. Работаем через [double].
    param(
        [Parameter(Mandatory)] $Received,
        [Parameter(Mandatory)] $Total,
        [double]$ElapsedSec = 0
    )

    $width = [Console]::WindowWidth - 1
    $rD = [double]$Received
    $tD = [double]$Total
    # BITS-сентинел «размер неизвестен» или невалидное значение
    $totalKnown = ($tD -gt 0) -and ($tD -lt [double][uint64]::MaxValue)

    # Средняя скорость и ETA за текущую попытку загрузки.
    $speedStr = ''
    $etaStr   = ''
    if ($ElapsedSec -gt 0.5 -and $rD -gt 0) {
        $bps = $rD / $ElapsedSec
        $speedStr = "  {0,5:N1} MB/s" -f ($bps / 1MB)
        if ($totalKnown -and $bps -gt 0) {
            $etaStr = "  ETA " + (Format-Duration (($tD - $rD) / $bps))
        }
    }

    if (-not $totalKnown) {
        $line = "  Скачано: {0:N1} MB{1}" -f ($rD / 1MB), $speedStr
    } else {
        $pct = [math]::Min(100, [int](($rD / $tD) * 100))
        $barWidth = 30
        $filled = [int]([math]::Floor($pct * $barWidth / 100))
        $bar = ('█' * $filled) + ('░' * ($barWidth - $filled))
        $line = "  [$bar] {0,3}%  {1,5:N1} / {2,5:N1} MB{3}{4}" -f $pct, ($rD / 1MB), ($tD / 1MB), $speedStr, $etaStr
    }

    if ($line.Length -lt $width) { $line = $line.PadRight($width) }
    [Console]::Write("`r$line")
}

function Invoke-DownloadWithProgress {
    param(
        [Parameter(Mandatory)] [string]$Url,
        [Parameter(Mandatory)] [string]$Destination,
        [Parameter(Mandatory)] [string]$DisplayName,
        [int]$MaxAttempts = 3
    )

    Write-Host "Скачивание $DisplayName..." -ForegroundColor Cyan
    Write-PtLog "Download start: $DisplayName ($Url)"

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        $job = $null
        $sw  = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            $job = Start-BitsTransfer -Source $Url -Destination $Destination `
                -Asynchronous -DisplayName $DisplayName -ErrorAction Stop

            while ($job.JobState -ne 'Transferred' -and $job.JobState -ne 'Error') {
                if ($job.BytesTotal -gt 0) {
                    Write-DownloadProgress -Received $job.BytesTransferred -Total $job.BytesTotal -ElapsedSec $sw.Elapsed.TotalSeconds
                }
                Start-Sleep -Milliseconds 200
            }

            if ($job.JobState -eq 'Transferred') {
                Write-DownloadProgress -Received $job.BytesTotal -Total $job.BytesTotal -ElapsedSec $sw.Elapsed.TotalSeconds
                [Console]::WriteLine()
                Complete-BitsTransfer -BitsJob $job
                Write-PtLog "Download done: $DisplayName ($($job.BytesTotal) bytes)"
                return
            }

            $errMsg = $job.ErrorDescription
            Remove-BitsTransfer -BitsJob $job -ErrorAction SilentlyContinue
            throw "Ошибка BITS: $errMsg"
        } catch {
            if ($job -and $job.JobState -ne 'Transferred') {
                Remove-BitsTransfer -BitsJob $job -ErrorAction SilentlyContinue
            }
            Remove-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
            if ($attempt -ge $MaxAttempts) {
                Write-PtLog "Download failed (попыток: $attempt): $DisplayName — $_" 'ERROR'
                throw
            }
            $wait = 2 * $attempt
            [Console]::WriteLine()
            Write-Host "Сбой загрузки (попытка $attempt из $MaxAttempts). Повтор через ${wait}с..." -ForegroundColor Yellow
            Write-PtLog "Download retry $attempt/${MaxAttempts}: $DisplayName — $_" 'WARN'
            Start-Sleep -Seconds $wait
        }
    }
}

function Get-CachedOrDownload {
    param(
        [Parameter(Mandatory)] [string]$Url,
        [Parameter(Mandatory)] [string]$Destination,
        [Parameter(Mandatory)] [string]$DisplayName
    )

    if (Test-Path -LiteralPath $Destination) {
        $size = (Get-Item -LiteralPath $Destination).Length
        if ($size -gt 0) {
            $sizeMb = [math]::Round($size / 1MB, 1)
            Write-Host "Используется кешированная версия $DisplayName ($sizeMb MB)" -ForegroundColor DarkGreen
            Write-PtLog "Cache hit: $DisplayName ($size bytes)"
            return
        }
        Remove-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    }

    Invoke-DownloadWithProgress -Url $Url -Destination $Destination -DisplayName $DisplayName
}

# --- Установленные программы (для отметки в меню) -------------------------

$script:installedNamesCache = $null

function Get-InstalledProgramNames {
    if ($null -ne $script:installedNamesCache) { return $script:installedNamesCache }

    $set = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)

    # 1. Реестр Uninstall (HKLM, HKLM\WOW6432Node, HKCU, HKCU\WOW6432Node)
    $paths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    Get-ItemProperty -Path $paths -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.DisplayName)  { [void]$set.Add($_.DisplayName) }
        # Имя ключа реестра тоже бывает информативным (например "1Password" или GUID)
        if ($_.PSChildName)  { [void]$set.Add($_.PSChildName) }
    }

    # 2. AppX-пакеты (Microsoft Store / Modern apps — например 1Password 8 ставится как AppX)
    try {
        Get-AppxPackage -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.Name)              { [void]$set.Add($_.Name) }
            if ($_.PackageFamilyName) { [void]$set.Add($_.PackageFamilyName) }
        }
    } catch {}

    $script:installedNamesCache = @($set)
    return $script:installedNamesCache
}

function Test-IsProgramInstalled {
    param([Parameter(Mandatory)] $Program)

    # Базовое имя — отрезаем версию и пометки в скобках.
    $base = ($Program.Name -replace '\s*\([^)]*\)\s*', ' ').Trim()

    # Подстроки для поиска: базовое имя + пользовательские DetectNames из JSON
    $needles = New-Object System.Collections.Generic.List[string]
    if ($base) { $needles.Add($base) }
    if ($Program.DetectNames) {
        foreach ($n in $Program.DetectNames) {
            if ($n) { $needles.Add($n) }
        }
    }
    if ($needles.Count -eq 0) { return $false }

    foreach ($name in (Get-InstalledProgramNames)) {
        foreach ($needle in $needles) {
            if ($name -like "*$needle*") { return $true }
        }
    }
    return $false
}

# --- Winget --------------------------------------------------------------

$script:wingetAvailable = $null

function Test-WingetAvailable {
    if ($null -ne $script:wingetAvailable) { return $script:wingetAvailable }
    $script:wingetAvailable = $null -ne (Get-Command winget -ErrorAction SilentlyContinue)
    return $script:wingetAvailable
}

function Install-WithWinget {
    param([Parameter(Mandatory)] [string]$WingetId, [Parameter(Mandatory)] [string]$DisplayName)

    Write-Host "Установка $DisplayName через winget ($WingetId)..." -ForegroundColor Cyan
    Write-PtLog "Winget install: $WingetId"

    $proc = Start-Process -FilePath 'winget' -ArgumentList @(
        'install', '--id', $WingetId,
        '--silent',
        '--accept-source-agreements',
        '--accept-package-agreements',
        '--disable-interactivity'
    ) -Wait -PassThru -NoNewWindow

    if ($proc.ExitCode -eq 0) {
        Write-PtLog "Winget success: $DisplayName"
        return $true
    }
    Write-PtLog "Winget failed (exit $($proc.ExitCode)): $DisplayName" 'WARN'
    return $false
}

function Install-Winget {
    # Ставит App Installer (winget) per-user через Add-AppxPackage — без админа.
    # Best-effort: при любой ошибке возвращаем $false и работаем на прямых ссылках.
    Write-Host 'Установка winget (App Installer)...' -ForegroundColor Cyan
    Write-PtLog 'Winget bootstrap: start'
    $tmp = Join-Path $env:TEMP 'winget-bootstrap'
    try {
        if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }
        New-Item -ItemType Directory -Path $tmp -Force | Out-Null

        # 1. Зависимость VCLibs
        $vclibs = Join-Path $tmp 'vclibs.appx'
        Start-BitsTransfer -Source 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -Destination $vclibs -ErrorAction Stop
        Add-AppxPackage -Path $vclibs -ErrorAction SilentlyContinue

        # 2. Зависимость Microsoft.UI.Xaml 2.8 (appx лежит внутри nupkg)
        $nupkg = Join-Path $tmp 'uixaml.zip'
        Start-BitsTransfer -Source 'https://api.nuget.org/v3-flatcontainer/microsoft.ui.xaml/2.8.7/microsoft.ui.xaml.2.8.7.nupkg' -Destination $nupkg -ErrorAction Stop
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::OpenRead($nupkg)
        try {
            $entry = $zip.Entries | Where-Object { $_.FullName -eq 'tools/AppX/x64/Release/Microsoft.UI.Xaml.2.8.appx' } | Select-Object -First 1
            if ($entry) {
                $uixaml = Join-Path $tmp 'uixaml.appx'
                [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $uixaml, $true)
                Add-AppxPackage -Path $uixaml -ErrorAction SilentlyContinue
            }
        } finally { $zip.Dispose() }

        # 3. App Installer (winget)
        $bundle = Join-Path $tmp 'AppInstaller.msixbundle'
        Start-BitsTransfer -Source 'https://aka.ms/getwinget' -Destination $bundle -ErrorAction Stop
        Add-AppxPackage -Path $bundle -ErrorAction Stop

        # winget только что поставлен — добавим WindowsApps в PATH текущей сессии
        $wa = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps'
        if ((Test-Path $wa) -and ($env:PATH -notlike "*$wa*")) { $env:PATH = "$env:PATH;$wa" }
        $script:wingetAvailable = $null

        if (Test-WingetAvailable) {
            Write-Host 'winget установлен.' -ForegroundColor Green
            Write-PtLog 'Winget bootstrap: success'
            return $true
        }
        throw 'winget недоступен после установки'
    } catch {
        Write-Host "Не удалось установить winget: $_" -ForegroundColor Yellow
        Write-Host 'Продолжаю с прямыми ссылками.' -ForegroundColor DarkGray
        Write-PtLog "Winget bootstrap failed: $_" 'WARN'
        return $false
    } finally {
        Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# --- Права администратора (не обязательны) ---------------------------------
# Скрипт работает и без админа. Программы для пользователя ставятся как есть;
# для тех, что требуют прав (MSI, драйверы, поле RequiresAdmin), UAC
# запрашивается точечно при установке именно этой программы.

$script:isAdmin = Test-IsAdmin
if (-not $script:isAdmin) {
    Write-Host 'Запущено без прав администратора.' -ForegroundColor Yellow
    Write-Host 'Это нормально — для программ, которым нужен админ, появится отдельный запрос UAC.' -ForegroundColor DarkGray
    Write-Host
}

Write-PtLog '=== Session start ==='

# Расширяем окно консоли, чтобы меню помещалось без прокрутки.
Resize-ConsoleWindow -MinHeight 60 -MinWidth 100

# --- Приветствие ----------------------------------------------------------

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

# --- 7-Zip -----------------------------------------------------------------

$sevenZipPath = Get-SevenZipPath
if (-not $sevenZipPath) {
    Write-Host '7-Zip не найден. Он рекомендуется для установки программ из архивов.' -ForegroundColor Yellow
    if (Read-YesNo 'Хотите установить 7-Zip?') {
        try { $sevenZipPath = Install-SevenZip }
        catch {
            Write-Host "Ошибка установки 7-Zip: $_" -ForegroundColor Red
            Read-Host 'Нажмите Enter для выхода'
            Exit
        }
    } else {
        Write-Host 'Установка 7-Zip пропущена. Программы типа archive не сработают.' -ForegroundColor Yellow
        if (-not (Read-YesNo 'Продолжить без 7-Zip?')) { Exit }
    }
}

# --- Winget (ставит программы последней версии) ---------------------------

if (-not (Test-WingetAvailable)) {
    Write-Host 'winget не найден — с ним программы ставятся последней версии.' -ForegroundColor Yellow
    if (Read-YesNo 'Установить winget (App Installer)?') {
        Install-Winget | Out-Null
    }
}

# --- Список программ ------------------------------------------------------

$programsUrl = 'https://powertoy.erney.monster/programs.json'

try {
    Write-Host 'Загрузка списка программ...' -ForegroundColor Cyan
    # Грузим сырыми байтами и руками декодируем как UTF-8 — иначе PS 5.1
    # без charset в Content-Type использует ISO-8859-1 и ломает кириллицу.
    $resp  = Invoke-WebRequest -Uri $programsUrl -UseBasicParsing
    $bytes = $resp.RawContentStream.ToArray()
    # Срезаем UTF-8 BOM, если он есть, чтобы ConvertFrom-Json в PS 5.1 не споткнулся.
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $jsonText = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
    } else {
        $jsonText = [System.Text.Encoding]::UTF8.GetString($bytes)
    }
    $programs = $jsonText | ConvertFrom-Json
} catch {
    Write-Host "Не удалось загрузить список программ с $programsUrl" -ForegroundColor Red
    Write-Host "Ошибка: $_" -ForegroundColor Red
    Write-PtLog "Failed to fetch programs.json: $_" 'ERROR'
    Read-Host 'Нажмите Enter для выхода'
    Exit
}

if (-not $programs -or $programs.Count -eq 0) {
    Write-Host 'Список программ пуст или повреждён.' -ForegroundColor Red
    Read-Host 'Нажмите Enter для выхода'
    Exit
}

Write-PtLog "Loaded $($programs.Count) programs from JSON"

# --- Установка ------------------------------------------------------------

$downloadPath = Join-Path $env:TEMP 'Installers'
if (-not (Test-Path -LiteralPath $downloadPath)) {
    New-Item -ItemType Directory -Path $downloadPath | Out-Null
}

function Expand-NestedArchive {
    param(
        [Parameter(Mandatory)] [string]$ArchivePath,
        [Parameter(Mandatory)] [string]$ExtractPath
    )

    if (-not $sevenZipPath) { throw '7-Zip не установлен — распаковка архива невозможна.' }

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

function Install-IsoProgram {
    param([Parameter(Mandatory)] $Program)

    $isoPath = Join-Path $downloadPath $Program.Installer
    Get-CachedOrDownload -Url $Program.Url -Destination $isoPath -DisplayName "ISO $($Program.Name)"

    if ($Program.LicenseKey) {
        Set-Clipboard -Value $Program.LicenseKey
        Write-Host 'Лицензионный ключ скопирован в буфер обмена.' -ForegroundColor Green
    }

    Write-Host 'Монтирование ISO-образа...' -ForegroundColor Cyan
    $mount = Mount-DiskImage -ImagePath $isoPath -PassThru
    $driveLetter = ($mount | Get-Volume).DriveLetter
    if ($driveLetter) {
        Write-Host "ISO-образ смонтирован на диске ${driveLetter}:" -ForegroundColor Green
    } else {
        Write-Host 'ISO-образ смонтирован (буква диска не определена).' -ForegroundColor Yellow
    }

    Read-Host 'Нажмите Enter для размонтирования ISO-образа'

    Write-Host 'Размонтирование ISO-образа...' -ForegroundColor Cyan
    Dismount-DiskImage -ImagePath $isoPath | Out-Null
    Write-Host 'ISO-образ размонтирован.' -ForegroundColor Green
}

function Install-ScriptProgram {
    param([Parameter(Mandatory)] $Program)

    $scriptPath = Join-Path $downloadPath $Program.Installer
    Get-CachedOrDownload -Url $Program.Url -Destination $scriptPath -DisplayName "скрипт $($Program.Name)"

    Write-Host "Выполнение скрипта $($Program.Name)..." -ForegroundColor Cyan
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $scriptPath

    Write-Host "$($Program.Name) выполнен." -ForegroundColor Green
}

function Install-SelectedProgram {
    param([Parameter(Mandatory)] [int]$Index)

    if ($Index -lt 1 -or $Index -gt $programs.Count) {
        Write-Host "Неверный выбор: $Index" -ForegroundColor Yellow
        return
    }
    $program = $programs[$Index - 1]

    Write-PtLog "Install start: [$Index] $($program.Name)"

    try {
        # Сначала пробуем winget, если поле задано и winget доступен
        if ($program.WingetId -and (Test-WingetAvailable)) {
            if (Install-WithWinget -WingetId $program.WingetId -DisplayName $program.Name) {
                Write-Host "$($program.Name) установлен через winget." -ForegroundColor Green
                return
            }
            Write-Host 'Winget не сработал, пробую прямую установку...' -ForegroundColor Yellow
        }

        switch ($program.Type) {
            'ISO'    { Install-IsoProgram    -Program $program; return }
            'Script' { Install-ScriptProgram -Program $program; return }
        }

        $downloadName = if ($program.Zip) { $program.Zip } else { $program.Installer }
        $downloadFile = Join-Path $downloadPath $downloadName
        $extractPath  = Join-Path $downloadPath ($program.Name -replace ' ', '_')

        Get-CachedOrDownload -Url $program.Url -Destination $downloadFile -DisplayName $program.Name

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

        $isMsi      = $installerPath -like '*.msi'
        # MSI /quiet сам UAC не вызывает → для него (и для помеченных RequiresAdmin)
        # поднимаем права точечно. Обычные exe с админ-манифестом всплывут UAC сами.
        $needsAdmin = $isMsi -or [bool]$program.RequiresAdmin
        if ($needsAdmin -and -not $script:isAdmin) {
            Write-Host 'Этой программе нужны права администратора — появится запрос UAC.' -ForegroundColor Yellow
        }

        if ($isMsi) {
            Write-Host "Установка MSI-пакета $($program.Name)..." -ForegroundColor Cyan
            $msiArgs = "/i `"$installerPath`""
            if ($program.Args) { $msiArgs += " $($program.Args)" }
            Start-Install -FilePath 'msiexec.exe' -Arguments $msiArgs -NeedsAdmin:$needsAdmin | Out-Null
        } else {
            Write-Host "Установка $($program.Name)..." -ForegroundColor Cyan
            Start-Install -FilePath $installerPath -Arguments $program.Args -NeedsAdmin:$needsAdmin | Out-Null
        }

        Write-Host "$($program.Name) успешно установлен." -ForegroundColor Green
        Write-PtLog "Install done: $($program.Name)"
    } catch {
        Write-Host "Ошибка при установке $($program.Name): $_" -ForegroundColor Red
        Write-PtLog "Install failed: $($program.Name) — $_" 'ERROR'
    }
}

# --- Меню ------------------------------------------------------------------

function Get-FilteredIndices {
    param([string]$Filter)

    if ([string]::IsNullOrWhiteSpace($Filter)) {
        return @(1..$programs.Count)
    }

    $result = @()
    for ($i = 0; $i -lt $programs.Count; $i++) {
        if ($programs[$i].Name -like "*$Filter*") { $result += ($i + 1) }
    }
    return $result
}

function Show-Menu {
    param([string]$Filter = '')

    Clear-Host

    if ($Filter) {
        Write-Host "Поиск: '$Filter'  (введите / чтобы сбросить)" -ForegroundColor Yellow
        Write-Host
    }

    $visible = Get-FilteredIndices -Filter $Filter

    if ($visible.Count -eq 0) {
        Write-Host 'Ничего не найдено.' -ForegroundColor Yellow
        Write-Host
        return
    }

    # Группируем по Category, сохраняя порядок появления категории в списке
    $groups = [ordered]@{}
    foreach ($idx in $visible) {
        $cat = $programs[$idx - 1].Category
        if (-not $cat) { $cat = 'Прочее' }
        if (-not $groups.Contains($cat)) { $groups[$cat] = @() }
        $groups[$cat] += $idx
    }

    foreach ($cat in $groups.Keys) {
        Write-Host "── $cat ──" -ForegroundColor Cyan
        foreach ($idx in $groups[$cat]) {
            $p = $programs[$idx - 1]
            $num = "[$idx]".PadLeft(5)
            $installed = Test-IsProgramInstalled -Program $p
            if ($installed) {
                Write-Host ("  {0}  {1}" -f $num, $p.Name) -NoNewline
                Write-Host '  ✓' -ForegroundColor Green
            } else {
                Write-Host ("  {0}  {1}" -f $num, $p.Name)
            }
        }
        Write-Host
    }
}

function Show-Hints {
    Write-Host '─────────────────────────────────────────────' -ForegroundColor DarkGray
    Write-Host '  Введите номер(а) через пробел: 1 5 17       ' -ForegroundColor DarkGray
    Write-Host '  Поиск: /текст     Сброс поиска: /           ' -ForegroundColor DarkGray
    Write-Host '  Выход: q                                    ' -ForegroundColor DarkGray
    Write-Host '─────────────────────────────────────────────' -ForegroundColor DarkGray
}

# --- Основной цикл ---------------------------------------------------------

$filter = ''

try {
    while ($true) {
        Show-Menu -Filter $filter
        Show-Hints
        $userInput = Read-Host 'Ваш выбор'
        $userInput = $userInput.Trim()

        if ([string]::IsNullOrWhiteSpace($userInput)) { continue }

        if ($userInput -match '^(q|й)$') {
            Write-Host 'Выход из программы.' -ForegroundColor Green
            break
        }

        if ($userInput.StartsWith('/')) {
            $filter = $userInput.Substring(1).Trim()
            if ($filter) { Write-PtLog "Search filter set: '$filter'" }
            else         { Write-PtLog 'Search filter cleared' }
            continue
        }

        # Парсинг множественного выбора через пробел
        $indices = @()
        $bad = $null
        foreach ($token in ($userInput -split '\s+')) {
            if ([string]::IsNullOrWhiteSpace($token)) { continue }
            $n = 0
            if ([int]::TryParse($token, [ref]$n) -and $n -ge 1 -and $n -le $programs.Count) {
                if ($indices -notcontains $n) { $indices += $n }
            } else {
                $bad = $token
                break
            }
        }

        if ($bad) {
            Write-Host "Неверный пункт: $bad" -ForegroundColor Red
            Read-Host 'Нажмите Enter'
            continue
        }
        if ($indices.Count -eq 0) { continue }

        if ($indices.Count -gt 1) {
            Write-Host "Выбрано программ: $($indices.Count)" -ForegroundColor Cyan
            foreach ($idx in $indices) {
                Write-Host ("  • {0}" -f $programs[$idx - 1].Name)
            }
            if (-not (Read-YesNo 'Установить выбранное?')) {
                Write-Host 'Отменено.' -ForegroundColor Yellow
                continue
            }
        }

        foreach ($idx in $indices) {
            Install-SelectedProgram -Index $idx
            Write-Host
        }

        # Сбрасываем кеш установленных, чтобы при возврате в меню обновились ✓
        $script:installedNamesCache = $null

        Read-Host 'Нажмите Enter для возврата в меню'
    }
}
finally {
    if (Test-Path -LiteralPath $downloadPath) {
        Remove-Item -LiteralPath $downloadPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-PtLog '=== Session end ==='
    Write-Host 'Все выбранные программы установлены.' -ForegroundColor Green
    Write-Host "Лог сессии: $logPath" -ForegroundColor DarkGray
}
