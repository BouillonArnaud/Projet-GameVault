<?php
header('Content-Type: application/json');
session_start();

// Vérification de la session standard
if (!isset($_SESSION['user']) ) {
    echo json_encode(['error' => 'Accès non autorisé']);
    exit;
}

// Connexion à la base de données
$servername = "localhost";
$username = "root";
$password = "Arno_18022002";
$dbname = "bd_projet_gamevault";

try {
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $dateActuelle = date('Y-m-d');
    
    $stmt = $conn->prepare("
        SELECT * FROM Jeux 
        WHERE date_sortie > :date_actuelle
        ORDER BY date_sortie ASC
    ");
    
    $stmt->bindParam(':date_actuelle', $dateActuelle);
    $stmt->execute();
    
    $jeux = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode($jeux);
    
} catch(PDOException $e) {
    echo json_encode(['error' => 'Erreur de connexion à la base de données: ' . $e->getMessage()]);
}

$conn = null;
?>