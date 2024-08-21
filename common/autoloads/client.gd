extends Node

## Server's adress. Use "127.0.0.1" or "localhost" to test locally.
const ADDRESS: String = "127.0.0.1" 
## Server's port.
const PORT: int = 8087

var peer: WebSocketMultiplayerPeer
var peer_id: int
var connection_status: bool = false

## For autocomplention & quick search (cmd + click)
@onready var scene_multiplayer := multiplayer as SceneMultiplayer

func connect_to_server():
	print("Starting connection to the server.")
	peer = WebSocketMultiplayerPeer.new()
	
	multiplayer.connected_to_server.connect(_on_connection_succeeded)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	scene_multiplayer.peer_authenticating.connect(self._on_peer_authenticating)
	scene_multiplayer.peer_authentication_failed.connect(self._on_peer_authentication_failed)
	scene_multiplayer.set_auth_callback(authentification_call)
	
	var certificate = load("res://common/server_certificate.crt")
	peer.create_client("wss://" + ADDRESS + ":" + str(PORT), TLSOptions.client_unsafe(certificate))
	multiplayer.set_multiplayer_peer(peer)

func close_connection():
	multiplayer.connected_to_server.disconnect(self._on_connection_succeeded)
	multiplayer.connection_failed.disconnect(self._on_connection_failed)
	multiplayer.server_disconnected.disconnect(self._on_server_disconnected)
	scene_multiplayer.peer_authenticating.disconnect(self._on_peer_authenticating)
	scene_multiplayer.peer_authentication_failed.disconnect(self._on_peer_authentication_failed)
	multiplayer.set_multiplayer_peer(null)
	peer.close()
	connection_status = false

func _on_connection_succeeded() -> void:
	print("Succesfuly connected to the server as %d!" % multiplayer.get_unique_id())
	peer_id = multiplayer.get_unique_id()
	DisplayServer.window_set_title("Client - %d" % peer_id)
	connection_status = true

func _on_connection_failed() -> void:
	print("Failed to connect to the server.")
	close_connection()

func _on_server_disconnected() -> void:
	print("Server disconnected.")
	close_connection()
	get_tree().paused = true

func _on_peer_authenticating(_peer_id: int) -> void:
	print("Trying to authenticate to the server.")

func _on_peer_authentication_failed(_peer_id: int) -> void:
	print("Authentification to the server failed.")
	close_connection()

func authentification_call(_peer_id: int, data: PackedByteArray):
	print("Authentification call from server with data: \"%s\"." % data.get_string_from_ascii())
	scene_multiplayer.send_auth(1, PackedByteArray("test_data_from_client".to_utf8_buffer()))
	scene_multiplayer.complete_auth(1)
