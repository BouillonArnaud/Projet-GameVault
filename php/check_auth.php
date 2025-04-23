<?php
session_start();

// Définir le rôle guest par défaut si non connecté
if (!isset($_SESSION['user'])) {
    $_SESSION['user'] = ['role' => 'guest'];
}

function getCurrentRole() {
    return $_SESSION['user']['role'] ?? 'guest';
}

function isGuest() {
    return getCurrentRole() === 'guest';
}

function isUser() {
    return getCurrentRole() === 'standard';
}

function isAdmin() {
    return getCurrentRole() === 'admin';
}

function requireAuth() {
    if (isGuest()) {
        header('Location: connexion.html');
        exit;
    }
}

function requireAdmin() {
    if (!isAdmin()) {
        header('Location: index.html');
        exit;
    }
}
?>