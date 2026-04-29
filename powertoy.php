<?php
// Отдаёт powertoy.ps1: сырой скрипт для PowerShell/curl, подсвеченный HTML — для браузера.
// Источник истины — соседний файл powertoy.ps1; этот PHP его НЕ дублирует.

$scriptPath = __DIR__ . '/powertoy.ps1';
$script = @file_get_contents($scriptPath);

if ($script === false) {
    http_response_code(500);
    header('Content-Type: text/plain; charset=utf-8');
    echo "powertoy.ps1 not found on server.";
    exit;
}

$userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
$isClient = (stripos($userAgent, 'PowerShell') !== false) || (stripos($userAgent, 'curl') !== false);

if ($isClient) {
    while (ob_get_level() > 0) { ob_end_clean(); }
    header('Content-Type: application/octet-stream; charset=utf-8');
    header('Content-Length: ' . strlen($script));
    echo $script;
    exit;
}

// Браузерная версия — подсвеченное превью.
header('Content-Type: text/html; charset=utf-8');
$safe = htmlspecialchars($script, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
?>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>powertoy.ps1 — Made by ErneyWhite</title>
    <link rel="icon" type="image/x-icon" href="favicon.ico">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Arial, sans-serif;
            background: #0d1117;
            color: #c9d1d9;
            margin: 0;
            padding: 24px;
        }
        h1 { color: #58a6ff; margin: 0 0 8px; }
        .hint {
            background: #161b22;
            border: 1px solid #30363d;
            border-radius: 6px;
            padding: 12px 16px;
            margin: 16px 0;
            font-size: 14px;
        }
        .hint code {
            background: #0d1117;
            padding: 2px 6px;
            border-radius: 4px;
            color: #f0f6fc;
        }
        pre {
            background: #161b22;
            border: 1px solid #30363d;
            border-radius: 6px;
            padding: 16px;
            overflow-x: auto;
            font-family: "Cascadia Code", Consolas, "Courier New", monospace;
            font-size: 13px;
            line-height: 1.5;
        }
        a { color: #58a6ff; }
    </style>
</head>
<body>
    <h1>powertoy.ps1</h1>
    <p>Made by ErneyWhite — <a href="https://github.com/erneywhite/powertoy_home">GitHub</a></p>
    <div class="hint">
        Запуск из PowerShell от имени администратора:<br>
        <code>irm https://powertoy.erney.monster | iex</code>
    </div>
    <pre><code><?= $safe ?></code></pre>
</body>
</html>
