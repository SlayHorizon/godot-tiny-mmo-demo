extends Node

var instance_collection: Array[InstanceResource]
var main_instance: InstanceResource

func _ready() -> void:
	build_instance_collection()
	main_instance = (get_node("MainInstance") as ServerInstance).instance_resource
	multiplayer.peer_connected.connect(func(peer_id: int):
		charge_new_instance.rpc_id(peer_id, {
			"instance_name": main_instance.instance_name,
			"map_path": main_instance.map.resource_path
			}
		)
	)
	Server.start_server()


@rpc("authority", "call_remote", "reliable", 0)
func charge_new_instance(_new_instance: Dictionary) -> void:
	pass

func _on_player_entered_warper(peer_id: int, current_instance: ServerInstance, target_instance_name: StringName) -> void:
	var target_instance: InstanceResource = get_instance_resource_from_name(target_instance_name)
	if not target_instance:
		return
	if current_instance.connected_peers.has(peer_id):
		current_instance.despawn_player(peer_id)
	charge_new_instance.rpc_id(peer_id, {
		"instance_name": target_instance.instance_name,
		"map_path": target_instance.map.resource_path
		}
	)

func build_instance_collection() -> void:
	for file_path in get_all_file_paths("res://common/resources/custom/instance_resources/instance_collection/"):
		instance_collection.append(ResourceLoader.load(file_path))
	for instance_resource: InstanceResource in instance_collection:
		var new_instance: ServerInstance = preload("res://server/instance_server/instance_server.tscn").instantiate()
		new_instance.name = instance_resource.instance_name
		new_instance.instance_resource = instance_resource
		add_child(new_instance)
		new_instance.player_entered_warper.connect(self._on_player_entered_warper)
		new_instance.load_map(instance_resource.map)

func get_instance_resource_from_name(instance_name) -> InstanceResource:
	for instance_resource in instance_collection:
		if instance_resource.instance_name == instance_name:
			return instance_resource
	return null

func get_all_file_paths(path: String) -> Array[String]:  
	var file_paths: Array[String] = []  
	var dir := DirAccess.open(path)  
	dir.list_dir_begin()  
	var file_name: String = dir.get_next()  
	while file_name != "":  
		var file_path = path + "/" + file_name  
		if dir.current_is_dir():  
			file_paths += get_all_file_paths(file_path)  
		else:  
			file_paths.append(file_path)  
		file_name = dir.get_next()  
	return file_paths
