<?php

require_once 'AuthCommand.php';

function jsonResponse($data, $statusCode = 200) {
    header('Content-Type: application/json');
    http_response_code($statusCode);
    echo json_encode($data);
}

// login (POST)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $_SERVER['REQUEST_URI'] === '/login') {
    
    $requestData = json_decode(file_get_contents('php://input'), true);

    // Verify credentials
    if ($requestData['username'] === 'john@doe.fr' && $requestData['password'] === '123456' && 
        $requestData['clientId'] === 'local_clientId' &&
        $requestData['clientSecret'] === 'local_clientSecret') {
        
        // if Success
        jsonResponse([
            'accessToken' => 'some accessToken',
            'refreshToken' => 'some refreshToken'
        ]);
    } else {
        jsonResponse(['error' => 'Wrong credentials'], 401);
    }
} else if ($_SERVER['REQUEST_METHOD'] === 'GET' && $_SERVER['REQUEST_URI'] === '/address') {
    $authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
    if (strpos($authHeader, 'Bearer some accessToken') !== false) {
        jsonResponse([
            'firstName' => 'John',
            'lastName' => 'Doe',
            'line1' => '123 Main St',
            'city' => 'New York',
            'zipCode' => '10001',
            'phoneNumber' => '555-123-4567'
        ]);
    } else {
        jsonResponse(['error' => $authHeader], 401);
        echo $authHeader;
    }
} else if ($_SERVER['REQUEST_METHOD'] === 'PUT' && $_SERVER['REQUEST_URI'] === '/token') {
    
    $requestData = json_decode(file_get_contents('php://input'), true);
    
    if ($requestData['refreshToken'] === 'some refreshToken' &&
        $requestData['clientId'] === 'local_clientId' &&
        $requestData['clientSecret'] === 'local_clientSecret') {
        jsonResponse([
            'accessToken' => 'some accessToken',
            'refreshToken' => 'some refreshToken'
        ]);
    } else {
        jsonResponse(['error' => 'Wrong credentials'], 401);
    }
    
} else {
    http_response_code(404);
    echo 'Ruta no encontrada';
}
?>
