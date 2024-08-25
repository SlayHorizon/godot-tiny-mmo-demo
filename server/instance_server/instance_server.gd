class_name ServerInstance
extends SubViewport

const PLAYER = preload("res://common/entities/player/base_player/player.tscn")

var entity_collection: Dictionary = {}
var connected_peers: PackedInt64Array = []

var instance_resource: InstanceResource

func _ready() -> void:
	multiplayer.peer_disconnected.connect(
		func(peer_id: int):
			if connected_peers.has(peer_id):
				despawn_player(peer_id)
	)

func _physics_process(_delta: float) -> void:
	var state: Dictionary = {"EC" = {}}
	for entity_id: int in entity_collection:
		state["EC"][entity_id] = (entity_collection[entity_id] as Entity).sync_state
	state["T"] = Time.get_unix_time_from_system()
	for peer_id: int in connected_peers:
		fetch_instance_state.rpc_id(peer_id, state)

func load_map(map_scene: PackedScene) -> void:
	if not map_scene: return;
	var map = map_scene.instantiate()
	add_child(map)
	for child in map.get_children():
		if child is Warper:
			child.player_trying_to_exit.connect(self.change_instance)

@rpc("authority", "call_remote", "unreliable", 0)
func fetch_instance_state(_new_state: Dictionary):
	pass

@rpc("any_peer", "call_remote", "unreliable", 0)
func fetch_player_state(sync_state: Dictionary) -> void:
	var peer_id: int = multiplayer.get_remote_sender_id()
	if entity_collection.has(peer_id):
		var entity: Entity = entity_collection[peer_id] as Entity
		if entity.sync_state["T"] < sync_state["T"]:
			entity.sync_state = sync_state

@rpc("authority", "call_remote", "reliable", 0)
func spawn_player(player_id: int, spawn_state: Dictionary = {}) -> void:
	if spawn_state["spawn_id"] != null:
		for obj in get_child(0).get_children():
			if obj is spawn_point:
				if obj.id == spawn_state["spawn_id"]:
					spawn_state["position"] = obj.global_position
	
	spawn_state["sprite_frames"] = Server.player_list[player_id]["class"]
	
	var new_player: Player = PLAYER.instantiate() as Player
	new_player.name = str(player_id)
	new_player.spawn_state = spawn_state
	
	add_child(new_player, true)
	
	entity_collection[player_id] = new_player
	connected_peers.append(player_id)
	# Spawn the new player on all other client in the current instance
	# and spawn all other players on the new client.
	for peer_id: int in connected_peers:
		spawn_player.rpc_id(peer_id, player_id, new_player.spawn_state)
			
		if player_id != peer_id:
			spawn_player.rpc_id(player_id, peer_id, entity_collection[peer_id].spawn_state)

@rpc("authority", "call_remote", "reliable", 0)
func despawn_player(player_id: int) -> void:
	connected_peers.remove_at(connected_peers.find(player_id))
	if entity_collection.has(player_id):
		(entity_collection[player_id] as Entity).queue_free()
		entity_collection.erase(player_id)
	for peer_id: int in connected_peers:
		despawn_player.rpc_id(peer_id, player_id)

func enter_instance(peer_id: int, spawn_id: int = 0) -> void:
	var instance_data: Dictionary = {
		"instance_name": instance_resource.instance_name,
		"map_path": instance_resource.map.resource_path,
		"spawn_id": spawn_id
		}
	get_parent().request_change_instance.rpc_id(peer_id, instance_data)

func change_instance(player: Player, instance_name: StringName, spawn_id: int = 0) -> void:
	var player_id: int = player.name.to_int()
	if connected_peers.has(player_id):
		despawn_player(player_id)
		
	var target_instance: InstanceResource = Server.get_instance_resource_from_name(instance_name)
	if not target_instance: return;
	get_parent().request_change_instance.rpc_id(player_id, 
		{
		"instance_name": target_instance.instance_name,
		"map_path": target_instance.map.resource_path,
		"spawn_id": spawn_id
		}
	)

@rpc("any_peer", "call_remote", "reliable", 0)
func ready_to_enter_instance(spawn_id: int = 0) -> void:
	var peer_id: int = multiplayer.get_remote_sender_id()
	spawn_player(peer_id, {
		"spawn_id": spawn_id
	})
