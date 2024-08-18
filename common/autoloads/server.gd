extends Node

const PORT: int = 8087

var peer: WebSocketMultiplayerPeer
var instance_collection: Array[InstanceResource]

func start_server() -> void:
	print("Starting server...")
	peer = WebSocketMultiplayerPeer.new()
	multiplayer.peer_connected.connect(self._peer_connected)
	multiplayer.peer_disconnected.connect(self._peer_disconnected)
	var server_certificate = load("res://common/server_certificate.crt")
	var server_key = load("res://server/server_key.key")
	peer.create_server(PORT, "*", TLSOptions.server(server_key, server_certificate))
	multiplayer.set_multiplayer_peer(peer)

func _peer_connected(peer_id) -> void:
	print("Peer: %d is connected." % peer_id)
	get_node("/root/Main/MainInstance").enter_instance(peer_id)

func _peer_disconnected(peer_id) -> void:
	print("Peer: %d is disconnected." % peer_id)

func get_instance_resource_from_name(instance_name) -> InstanceResource:
	for instance_resource in instance_collection:
		if instance_resource.instance_name == instance_name:
			return instance_resource
	return null

## Example of how to create a crypto key with its self signed certificate.
## The private shouldn't be exported on the client machine.
static func generate_key_n_cert() -> void:
	var crypto = Crypto.new()
	var key = CryptoKey.new()
	var cert = X509Certificate.new()
	key = crypto.generate_rsa(4096)
	cert = crypto.generate_self_signed_certificate(key, "CN=example.com,O=A Game Company,C=IT")
	key.save("res://server/server_key.key")
	cert.save("res://common/server_certificate.crt")
