DROP DATABASE IF EXISTS bd_projet_gamevault;
CREATE DATABASE bd_projet_gamevault;
USE bd_projet_gamevault;

CREATE TABLE IF NOT EXISTS Utilisateur (
    id_utilisateur INT AUTO_INCREMENT,
    nom_utilisateur VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    hash_mot_de_passe VARCHAR(255) NOT NULL,
    date_creation_compte DATETIME DEFAULT CURRENT_TIMESTAMP,
    derniere_connexion DATETIME,
    date_naissance DATE NOT NULL,
    type_utilisateur ENUM('standard','admin') NOT NULL,
    PRIMARY KEY (id_utilisateur),
    UNIQUE (email),
    UNIQUE (nom_utilisateur)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Editeur (
    id_editeur INT AUTO_INCREMENT NOT NULL,
    nom VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_editeur),
    UNIQUE (nom)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Jeux (
    id_jeu INT AUTO_INCREMENT NOT NULL,
    nom_jeu VARCHAR(50) NOT NULL,
    plateforme VARCHAR(50) NOT NULL,
    edition_jeu VARCHAR(50) NOT NULL,
    id_editeur INT NOT NULL,
    PRIMARY KEY (id_jeu),
    CONSTRAINT fk_jeux_editeur
        FOREIGN KEY (id_editeur) 
        REFERENCES Editeur(id_editeur)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Genre (
    id_genre INT AUTO_INCREMENT NOT NULL,
    intitule_genre VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_genre),
    UNIQUE (intitule_genre)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Collection_jeu (
    id_utilisateur INT NOT NULL,
    id_jeu INT NOT NULL,
    date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_achat DATE NOT NULL,
    prix_achat NUMERIC(7,2) DEFAULT 0,
    PRIMARY KEY (id_utilisateur, id_jeu),
    CONSTRAINT fk_collection_utilisateur
        FOREIGN KEY (id_utilisateur) 
        REFERENCES Utilisateur(id_utilisateur)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_collection_jeux
        FOREIGN KEY (id_jeu) 
        REFERENCES Jeux(id_jeu)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Liste_souhait (
    id_liste INT AUTO_INCREMENT,
    date_ajout DATE NOT NULL,
    id_utilisateur INT NOT NULL,
    id_jeu INT NOT NULL,
    PRIMARY KEY (id_liste),
    CONSTRAINT fk_liste_utilisateur
        FOREIGN KEY (id_utilisateur) 
        REFERENCES Utilisateur(id_utilisateur)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_liste_jeux
        FOREIGN KEY (id_jeu) 
        REFERENCES Jeux(id_jeu)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE (id_utilisateur, id_jeu)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Avis (
    id_avis INT AUTO_INCREMENT NOT NULL,
    note TINYINT NOT NULL CHECK (note BETWEEN 1 AND 5),
    date_avis DATE NOT NULL,
    id_utilisateur INT NOT NULL,
    id_jeu INT NOT NULL,
    PRIMARY KEY (id_avis),
    CONSTRAINT fk_avis_utilisateur
        FOREIGN KEY (id_utilisateur) 
        REFERENCES Utilisateur(id_utilisateur)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_avis_jeux
        FOREIGN KEY (id_jeu) 
        REFERENCES Jeux(id_jeu)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE (id_utilisateur, id_jeu)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Genre_jeu (
    id_jeu INT NOT NULL,
    id_genre INT NOT NULL,
    PRIMARY KEY (id_jeu, id_genre),
    CONSTRAINT fk_genrejeu_jeux
        FOREIGN KEY (id_jeu) 
        REFERENCES Jeux(id_jeu)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_genrejeu_genre
        FOREIGN KEY (id_genre) 
        REFERENCES Genre(id_genre)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB;

-- Insertion des données corrigées pour correspondre aux résultats attendus
INSERT INTO Editeur (nom) VALUES 
('Electronic Arts'), ('Ubisoft'), ('Nintendo'), 
('Sony Interactive Entertainment'), ('Activision Blizzard');

INSERT INTO Genre (intitule_genre) VALUES 
('Action'), ('Aventure'), ('RPG'), ('FPS'), 
('Stratégie'), ('Sport'), ('Monde ouvert');

INSERT INTO Utilisateur (nom_utilisateur, email, hash_mot_de_passe, date_naissance, type_utilisateur) VALUES
('admin_gv', 'admin@gamevault.com', '$2a$10$x4D9ruWeJ4oR7kF6itqYBe5J5dZ7CYXZmW1pT7VdLTEvLd2Q3qR0K', '1985-01-15', 'admin'),
('jdupont', 'jean.dupont@mail.com', '$2a$10$yH9zCgZaKVBXUO6WZ7Q1UeR9XQY9JkZf8XoLz5d3YvJ3kLm1Xo9ZC', '1992-07-22', 'standard'),
('mgamer', 'marie.gamer@mail.com', '$2a$10$zT8wEhZrNXBVpO7Xa6r2UuS9vWX5KlYg9YoP3q4sRtJ2lL5uBv1Cd', '1998-11-03', 'standard');

INSERT INTO Jeux (nom_jeu, plateforme, edition_jeu, id_editeur) VALUES
('Assassin''s Creed Valhalla', 'PS5', 'Édition Standard', 2),
('The Legend of Zelda: Tears of the Kingdom', 'Switch', 'Édition Standard', 3),
('FIFA 23', 'Xbox Series X', 'Édition Ultimate', 1),
('God of War Ragnarök', 'PS5', 'Édition Collector', 4),
('Call of Duty: Modern Warfare II', 'PC', 'Édition Vault', 5);

INSERT INTO Genre_jeu (id_jeu, id_genre) VALUES
(1, 1), (1, 2), (1, 7),
(2, 1), (2, 2), (2, 3),
(3, 6),
(4, 1), (4, 2),
(5, 1), (5, 4);

-- Correction des données pour correspondre aux résultats
INSERT INTO Collection_jeu (id_utilisateur, id_jeu, date_achat, prix_achat) VALUES
(2, 1, '2023-05-10', 49.99),
(2, 3, '2023-06-15', 89.99),
(3, 2, '2023-05-20', 59.99),
(3, 4, '2023-04-05', 99.99);

-- Ajout du jeu dans la collection via la procédure pour déclencher la suppression de la liste de souhaits
DELIMITER //
CREATE PROCEDURE ajouter_jeu_collection(
    IN p_user_id INT,
    IN p_jeu_id INT,
    IN p_date_achat DATE,
    IN p_prix DECIMAL(7,2)
)
BEGIN
    DECLARE user_exists INT;
    DECLARE game_exists INT;
    
    SELECT COUNT(*) INTO user_exists FROM Utilisateur WHERE id_utilisateur = p_user_id;
    SELECT COUNT(*) INTO game_exists FROM Jeux WHERE id_jeu = p_jeu_id;
    
    IF user_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Utilisateur inexistant';
    ELSEIF game_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Jeu inexistant';
    ELSE
        INSERT INTO Collection_jeu (id_utilisateur, id_jeu, date_achat, prix_achat)
        VALUES (p_user_id, p_jeu_id, p_date_achat, p_prix);
        
        DELETE FROM Liste_souhait 
        WHERE id_utilisateur = p_user_id AND id_jeu = p_jeu_id;
    END IF;
END //
DELIMITER ;

-- Insertion initiale dans la liste de souhaits
INSERT INTO Liste_souhait (id_utilisateur, id_jeu, date_ajout) VALUES
(2, 4, '2023-07-01'),
(3, 1, '2023-06-28'),
(3, 5, '2023-07-10');

-- Ajout de God of War à la collection de jdupont (ce qui doit le supprimer de sa liste de souhaits)
CALL ajouter_jeu_collection(2, 4, '2023-07-18', 69.99);

INSERT INTO Avis (note, date_avis, id_utilisateur, id_jeu) VALUES
(5, '2023-05-12', 2, 1),
(4, '2023-06-20', 2, 3),
(5, '2023-05-22', 3, 2),
(3, '2023-04-10', 3, 4);