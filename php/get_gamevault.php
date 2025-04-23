<?php
// Connexion à la base de données
try {
    $bdd = new PDO('mysql:host=localhost;dbname=bd_projet_gamevault;charset=utf8', 'root', 'Arno_18022002');
} catch (Exception $e) {
    die('Erreur : ' . $e->getMessage());
}

// Récupérer les données des jeux vidéo
$reponse = $bdd->query('SELECT * FROM jeux');

// Tableau pour stocker les résultats
$games = [];

while ($donnees = $reponse->fetch()) {
    $games[] = [
        'id_jeu' => $donnees['id_jeu'],
        'nom_jeu' => $donnees['nom_jeu'],
        'plateforme' => $donnees['plateforme'],
        'edition_jeu' => $donnees['edition_jeu'],
        'nom_editeur' => $donnees['nom_editeur'],
        'IMG_jeux' => $donnees['IMG_jeux'],
        'Lien_jeux' => $donnees['Lien'],
        'date_sortie' => $donnees['date_sortie']
    ];
}

echo json_encode($games);

// Fermer la connexion
$reponse->closeCursor();
?>
