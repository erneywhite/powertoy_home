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

// Срезаем UTF-8 BOM, если он есть — иначе irm | iex видит его как первый
// символ и парсер падает на чём-нибудь вроде "The term '﻿#' is not recognized".
if (substr($script, 0, 3) === "\xEF\xBB\xBF") {
    $script = substr($script, 3);
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
    <title>Cool script by Erney White</title>
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
        .header {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 8px;
        }
        .header img {
            width: 48px;
            height: 48px;
            flex-shrink: 0;
        }
        h1 {
            color: #58a6ff;
            margin: 0;
            font-size: 28px;
        }
        .subtitle {
            margin: 0 0 16px;
            color: #8b949e;
            font-size: 14px;
        }
        .subtitle a { color: #58a6ff; text-decoration: none; }
        .subtitle a:hover { text-decoration: underline; }

        .hint {
            background: #161b22;
            border: 1px solid #30363d;
            border-radius: 6px;
            padding: 12px 16px;
            margin: 16px 0;
            font-size: 14px;
        }
        .copy-cmd {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #0d1117;
            padding: 6px 10px;
            border-radius: 4px;
            color: #f0f6fc;
            font-family: "Cascadia Code", Consolas, "Courier New", monospace;
            cursor: pointer;
            user-select: none;
            border: 1px solid transparent;
            transition: border-color 0.15s, background 0.15s;
        }
        .copy-cmd:hover {
            border-color: #58a6ff;
            background: #1f242c;
        }
        .copy-cmd.copied {
            border-color: #3fb950;
            color: #3fb950;
        }
        .copy-cmd .icon {
            opacity: 0.6;
            font-size: 12px;
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
    </style>
</head>
<body>
    <div class="header">
        <img src="favicon.ico" alt="logo">
        <h1>powertoy.ps1</h1>
    </div>
    <p class="subtitle">Made by ErneyWhite — <a href="https://github.com/erneywhite/powertoy_home">GitHub</a></p>

    <div class="hint">
        Запуск из PowerShell от имени администратора (клик — скопировать):<br>
        <span class="copy-cmd" id="copyCmd" data-cmd="irm https://powertoy.erney.monster | iex" title="Кликни, чтобы скопировать">
            <span class="cmd-text">irm https://powertoy.erney.monster | iex</span>
            <span class="icon">📋</span>
        </span>
    </div>

    <pre><code><?= $safe ?></code></pre>

    <script>
        (function () {
            const el = document.getElementById('copyCmd');
            if (!el) return;
            const textEl = el.querySelector('.cmd-text');
            const originalText = textEl.textContent;

            function setCopied(msg) {
                el.classList.add('copied');
                textEl.textContent = msg;
                setTimeout(function () {
                    el.classList.remove('copied');
                    textEl.textContent = originalText;
                }, 1500);
            }

            el.addEventListener('click', function () {
                const cmd = el.getAttribute('data-cmd');
                if (navigator.clipboard && navigator.clipboard.writeText) {
                    navigator.clipboard.writeText(cmd).then(
                        function () { setCopied('Скопировано!'); },
                        function () { fallbackCopy(cmd); }
                    );
                } else {
                    fallbackCopy(cmd);
                }
            });

            function fallbackCopy(cmd) {
                const ta = document.createElement('textarea');
                ta.value = cmd;
                ta.style.position = 'fixed';
                ta.style.opacity = '0';
                document.body.appendChild(ta);
                ta.select();
                try {
                    document.execCommand('copy');
                    setCopied('Скопировано!');
                } catch (e) {
                    setCopied('Не удалось :(');
                }
                document.body.removeChild(ta);
            }
        })();
    </script>
</body>
</html>
