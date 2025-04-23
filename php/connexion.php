<?php
header('Content-Type: application/json');
session_start();

// Configuration BDD
$db_host = 'localhost';
$db_name = 'bd_projet_gamevault';
$db_user = 'root';
$db_pass = 'Arno_18022002';

$response = [
    'success' => false,
    'message' => 'Erreur lors de la connexion',
    'role' => 'guest' // Par défaut
];

// Si l'utilisateur n'est pas connecté, définir le rôle guest
if (!isset($_SESSION['user'])) {
    $_SESSION['user'] = [
        'role' => 'guest'
    ];
}

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    $response['message'] = "Erreur de connexion à la base de données";
    echo json_encode($response);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $identifiant = trim($_POST['identifiant'] ?? '');
    $mot_de_passe = $_POST['mot_de_passe'] ?? '';

    if (empty($identifiant)) {
        $response['message'] = "L'identifiant est requis";
        echo json_encode($response);
        exit;
    }

    if (empty($mot_de_passe)) {
        $response['message'] = "Le mot de passe est requis";
        echo json_encode($response);
        exit;
    }

    try {
        $stmt = $pdo->prepare("SELECT * FROM Utilisateur WHERE email = ? OR nom_utilisateur = ?");
        $stmt->execute([$identifiant, $identifiant]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user && password_verify($mot_de_passe, $user['hash_mot_de_passe'])) {
            // Mise à jour de la session
            $_SESSION['user'] = [
                'id' => $user['id_utilisateur'],
                'nom' => $user['nom_utilisateur'],
                'email' => $user['email'],
                'role' => $user['type_utilisateur'] // 'user' ou 'admin'
            ];

            // Mise à jour dernière connexion
            $update = $pdo->prepare("UPDATE Utilisateur SET derniere_connexion = NOW() WHERE id_utilisateur = ?");
            $update->execute([$user['id_utilisateur']]);

            $response['success'] = true;
            $response['message'] = "Connexion réussie";
            $response['role'] = $_SESSION['user']['role'];
        } else {
            $response['message'] = "Identifiant ou mot de passe incorrect";
        }
    } catch (PDOException $e) {
        $response['message'] = "Erreur lors de la vérification des identifiants";
    }
}

echo json_encode($response);
?>