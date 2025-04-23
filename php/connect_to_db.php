<?php

    function connect_to_db($serv,$db_name,$user_name,$password){
        try {
            $bddPDO = new PDO('mysql:host=' . $serv .';dbname=' . $db_name . ';charset=utf8', $user_name, $password);
        }
        catch(Exception $e){
            die('Erreur : '.$e->getMessage());
        }
        return $bddPDO;
    }

?>