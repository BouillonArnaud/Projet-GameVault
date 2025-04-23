<?php
session_start();

// Réinitialiser la session en gardant le rôle guest
$_SESSION['user'] = [
    'role' => 'guest'
];

// Alternative: pour une vraie déconnexion
// $_SESSION = array();
// session_destroy();

header('Content-Type: application/json');
echo json_encode(['success' => true]);
?>