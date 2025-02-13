<?php
namespace App\Services;

use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
use Ratchet\Server\IoServer;
use Ratchet\Http\HttpServer;
use Ratchet\WebSocket\WsServer;

class SocketService implements MessageComponentInterface {
    protected $clients;
    protected $rooms = [];

    public function __construct() {
        $this->clients = new \SplObjectStorage;
    }

    public function onOpen(ConnectionInterface $conn) {
        $this->clients->attach($conn);
        echo "New connection! ({$conn->resourceId})\n";
    }

    public function onMessage(ConnectionInterface $from, $msg) {
        $data = json_decode($msg, true);
        
        switch($data['event']) {
            case 'join_room':
                $this->joinRoom($from, $data['room']);
                break;
            case 'leave_room':
                $this->leaveRoom($from, $data['room']);
                break;
            case 'room_message':
                $this->broadcastToRoom($data['room'], $data['event'], $data['data']);
                break;
            default:
                $this->broadcast($data['event'], $data['data']);
        }
    }

    public function onClose(ConnectionInterface $conn) {
        $this->clients->detach($conn);
    }

    public function onError(ConnectionInterface $conn, \Exception $e) {
        echo "An error has occurred: {$e->getMessage()}\n";
        $conn->close();
    }

    protected function broadcast($event, $data) {
        foreach ($this->clients as $client) {
            $client->send(json_encode([
                'event' => $event,
                'data' => $data
            ]));
        }
    }

    protected function joinRoom($client, $room) {
        if (!isset($this->rooms[$room])) {
            $this->rooms[$room] = new \SplObjectStorage;
        }
        $this->rooms[$room]->attach($client);
    }

    protected function leaveRoom($client, $room) {
        if (isset($this->rooms[$room])) {
            $this->rooms[$room]->detach($client);
        }
    }

    protected function broadcastToRoom($room, $event, $data) {
        if (isset($this->rooms[$room])) {
            foreach ($this->rooms[$room] as $client) {
                $client->send(json_encode([
                    'event' => $event,
                    'data' => $data
                ]));
            }
        }
    }
} 