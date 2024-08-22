extends Node

const PORT: int = 8087

var peer: WebSocketMultiplayerPeer
var instance_collection: Array[InstanceResource]

@onready var scene_multiplayer := multiplayer as SceneMultiplayer

func start_server() -> void:
	print("Starting server.")
	peer = WebSocketMultiplayerPeer.new()
	
	multiplayer.peer_connected.connect(self._peer_connected)
	multiplayer.peer_disconnected.connect(self._peer_disconnected)
	
	scene_multiplayer.peer_authenticating.connect(self._peer_authenticating)
	scene_multiplayer.peer_authentication_failed.connect(self._peer_authentication_failed)
	scene_multiplayer.set_auth_callback(self._on_peer_auth)
	
	var server_certificate = load("res://common/server_certificate.crt")
	var server_key = load("res://server/server_key.key")
	
	peer.create_server(PORT, "*", TLSOptions.server(server_key, server_certificate))
	multiplayer.set_multiplayer_peer(peer)

func _peer_connected(peer_id) -> void:
	print("Peer: %d is connected." % peer_id)
	get_node("/root/Main/MainInstance").enter_instance(peer_id)

func _peer_disconnected(peer_id) -> void:
	print("Peer: %d is disconnected." % peer_id)

func _peer_authenticating(peer_id: int) -> void:
	print("Peer: %d is trying to authenticate." % peer_id)
	scene_multiplayer.send_auth(peer_id, "data_from_server".to_ascii_buffer())

func _peer_authentication_failed(peer_id: int) -> void:
	print("Peer: %d failed to authenticate." % peer_id)

# Quick and dirty. It needs serious rework.
func _on_peer_auth(peer_id: int, data: PackedByteArray) -> void:
	var dict := bytes_to_var(data) as Dictionary
	print("Peer: %d is trying to connect with data: \"%s\"." % [peer_id, dict])
	if is_valid_authentication_data(dict):
		scene_multiplayer.complete_auth(peer_id)
	else:
		peer.disconnect_peer(peer_id)

func is_valid_authentication_data(data: Dictionary) -> bool:
	var player_name: String
	var player_class: String
	if data.has("username") and data.has("class"):
		player_name = data["username"] as String
		player_class = data["class"] as String
	else:
		return false
	if not player_name.is_valid_identifier() or not player_name.length() < 10:
		return false
	elif not player_class in ["knight", "rogue", "mage"]:
		return false
	return true

func get_instance_resource_from_name(instance_name) -> InstanceResource:
	for instance_resource in instance_collection:
		if instance_resource.instance_name == instance_name:
			return instance_resource
	return null
