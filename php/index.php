<?php
declare(strict_types=1);

/**
 * Minimal landing page for the Zephyr project.
 * Serves static documentation links and a status badge.
 */

$version = trim((string)@file_get_contents(__DIR__ . '/../VERSION'));
if ($version === '') {
    $version = 'unknown';
}

$links = [
    'Repository' => 'https://github.com/yourname/zephyr-lang',
    'Issues'     => 'https://github.com/yourname/zephyr-lang/issues',
    'License'    => 'https://github.com/yourname/zephyr-lang/blob/main/LICENSE',
];
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Zephyr <?= htmlspecialchars($version, ENT_QUOTES) ?></title>
    <style>
        body { font-family: system-ui, sans-serif; margin: 4rem auto; max-width: 40rem; }
        code { background: #f2f2f2; padding: 0.1rem 0.3rem; }
    </style>
</head>
<body>
    <h1>Zephyr</h1>
    <p>Version: <code><?= htmlspecialchars($version, ENT_QUOTES) ?></code></p>
    <p>A statically typed systems language that transpiles to C++17.</p>
    <ul>
        <?php foreach ($links as $label => $href): ?>
            <li><a href="<?= htmlspecialchars($href, ENT_QUOTES) ?>"><?= htmlspecialchars($label, ENT_QUOTES) ?></a></li>
        <?php endforeach; ?>
    </ul>
</body>
</html>
