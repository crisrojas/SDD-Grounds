<?php

class AuthCommand {
    public $grantType;
    public $clientId;
    public $clientSecret;
    public $username;
    public $password;
    
    public function __construct($username, $password) {
        $this->grantType = 'password';
        $this->clientId = 'tuClientId'; // Reemplazar con tu clientId
        $this->clientSecret = 'tuClientSecret'; // Reemplazar con tu clientSecret
        $this->username = $username;
        $this->password = $password;
    }
}

?>
