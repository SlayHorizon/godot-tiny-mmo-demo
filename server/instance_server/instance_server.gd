class_name ServerInstance
extends SubViewport

signal player_entered_warper(peer_id: int, current_instance: ServerInstance, target_instance: StringName)

const PLAYER = preload("res://common/entities/player/base_player/player.tscn")

var entity_collection: Dictionary = {}
var connected_peers: PackedInt64Array = []

var map: Map
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
	if map:
		map.queue_free()
	map = map_scene.instantiate()
	add_child(map)
	for child in map.get_children():
		if child is InteractionArea:
			child.player_entered_interaction_area.connect(_on_player_entered_interaction_area)

func _on_player_entered_interaction_area(player: Player, interaction_area: InteractionArea) -> void:
	if player.just_teleported:
		return
	if interaction_area is Warper:
		interaction_area = interaction_area as Warper
		player_entered_warper.emit(player.name.to_int(), self, interaction_area.target_instance_name)
	if interaction_area is Teleporter:
		if not player.just_teleported:
			player.just_teleported = true
			update_entity(player, {"position": interaction_area.target.global_position})
			await get_tree().create_timer(0.6).timeout
			player.just_teleported = false

@rpc("authority", "call_remote", "reliable", 1)
func update_entity(entity, to_update: Dictionary) -> void:
	for thing: String in to_update:
		entity.set_indexed(thing, to_update[thing])
	for peer_id: int in connected_peers:
		update_entity.rpc_id(peer_id, entity.name.to_int(), to_update)

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
	var new_player: Player = PLAYER.instantiate() as Player
	var spawn_position := map.get_spawn_position()
	spawn_state = {
		"position": spawn_position,
		"sprite_frames": Server.player_list[player_id]["class"]
	}
	new_player.name = str(player_id)
	new_player.spawn_state = spawn_state
	new_player.just_teleported = true
	add_child(new_player, true)
	entity_collection[player_id] = new_player
	connected_peers.append(player_id)
	# Spawn the new player on all other client in the current instance
	# and spawn all other players on the new client.
	for peer_id: int in connected_peers:
		spawn_player.rpc_id(peer_id, player_id, new_player.spawn_state)
		if player_id != peer_id:
			spawn_player.rpc_id(player_id, peer_id, entity_collection[peer_id].spawn_state)
	await get_tree().create_timer(0.6).timeout
	new_player.just_teleported = false

@rpc("authority", "call_remote", "reliable", 0)
func despawn_player(player_id: int) -> void:
	connected_peers.remove_at(connected_peers.find(player_id))
	if entity_collection.has(player_id):
		(entity_collection[player_id] as Entity).queue_free()
		entity_collection.erase(player_id)
	for peer_id: int in connected_peers:
		despawn_player.rpc_id(peer_id, player_id)

@rpc("any_peer", "call_remote", "reliable", 0)
func ready_to_enter_instance() -> void:
	var peer_id: int = multiplayer.get_remote_sender_id()
	spawn_player(peer_id)
