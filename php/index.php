<?php
declare(strict_types=1);

$version = trim((string)@file_get_contents(__DIR__ . '/../VERSION')) ?: 'unknown';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Zephyr <?= htmlspecialchars($version) ?></title>
    <style>body{font-family:system-ui,sans-serif;margin:4rem auto;max-width:40rem}code{background:#f2f2f2;padding:.1rem .3rem}</style>
</head>
<body>
    <h1>Zephyr</h1>
    <p>Version: <code><?= htmlspecialchars($version) ?></code></p>
    <p>A statically typed systems language that transpiles to C++17.</p>
    <ul>
        <li><a href="https://github.com/Strengthnaxy/zephyr-lang">Repository</a></li>
        <li><a href="https://github.com/Strengthnaxy/zephyr-lang/blob/main/SYNTAX.md">Syntax</a></li>
        <li><a href="https://github.com/Strengthnaxy/zephyr-lang/blob/main/LICENSE">License</a></li>
    </ul>
</body>
</html>
