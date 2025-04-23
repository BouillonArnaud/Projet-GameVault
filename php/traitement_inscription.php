<?php
header('Content-Type: application/json');

// Configuration BDD
$db_host = 'localhost';
$db_name = 'bd_projet_gamevault';
$db_user = 'root';
$db_pass = 'Arno_18022002';

$response = [
    'success' => false,
    'message' => '',
    'errors' => []
];

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    $response['message'] = "Erreur de connexion à la base de données";
    echo json_encode($response);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Nettoyage des données
    $nom_utilisateur = trim($_POST['nom_utilisateur'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $mot_de_passe = $_POST['mot_de_passe'] ?? '';
    $date_naissance = $_POST['date_naissance'] ?? '';

    // Validation
    if (empty($nom_utilisateur)) {
        $response['errors']['nom_utilisateur'] = "Nom d'utilisateur requis";
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $response['errors']['email'] = "Email invalide";
    }

    if (strlen($mot_de_passe) < 8) {
        $response['errors']['mot_de_passe'] = "8 caractères minimum";
    }

    if (empty($date_naissance)) {
        $response['errors']['date_naissance'] = "Date de naissance requise";
    }

    if (empty($response['errors'])) {
        try {
            // Vérification des doublons
            $stmt = $pdo->prepare("SELECT id_utilisateur FROM Utilisateur WHERE email = ? OR nom_utilisateur = ?");
            $stmt->execute([$email, $nom_utilisateur]);
            
            if ($stmt->rowCount() > 0) {
                $response['message'] = "Cet email ou nom d'utilisateur existe déjà";
            } else {
                // Insertion
                $hash = password_hash($mot_de_passe, PASSWORD_DEFAULT);
                $stmt = $pdo->prepare("INSERT INTO Utilisateur (nom_utilisateur, email, hash_mot_de_passe, date_naissance, type_utilisateur) 
                                      VALUES (?, ?, ?, ?, 'standard')");
                $stmt->execute([$nom_utilisateur, $email, $hash, $date_naissance]);
                
                $response['success'] = true;
                $response['message'] = "Inscription réussie !";
            }
        } catch (PDOException $e) {
            $response['message'] = "Erreur lors de l'inscription : " . $e->getMessage();
        }
    } else {
        $response['message'] = "Veuillez corriger les erreurs";
    }
} else {
    $response['message'] = "Méthode non autorisée";
}

echo json_encode($response);
?>