extends Node

## Main.

func _ready() -> void:
	if OS.has_feature("client"):
		await get_tree().create_timer(1.0).timeout
		add_child(
			load("res://client/instance_client/instance_client.tscn").instantiate()
		)
		Client.connect_to_server()
	elif OS.has_feature("server"):
		setup_server()


func setup_server() -> void:
	DisplayServer.window_set_title("Server")
	get_window().position = Vector2(0, 0)
	var instance_resources: Array[InstanceResource]
	for file_path in get_all_file_paths("res://common/resources/instance_resources/instance_collection/"):
		instance_resources.append(ResourceLoader.load(file_path))
	Server.instance_collection.append_array(instance_resources)
	for instance_resource in instance_resources:
		var new_instance: ServerInstance = preload("res://server/instance_server/instance_server.tscn").instantiate()
		new_instance.name = instance_resource.instance_name
		new_instance.instance_resource = instance_resource
		add_child(new_instance)
		new_instance.load_map(instance_resource.map)
	Server.start_server()

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

@rpc("authority", "call_remote", "reliable", 0)
func request_change_instance(new_instance: Dictionary) -> void:
	var instance = get_child(0) # Bad
	instance.queue_free()
	instance = InstanceClient.new()
	add_child(instance)
	instance.name = new_instance["instance_name"]
	print("loading new map = ", new_instance["map_path"])
	var map: Node2D = load(new_instance["map_path"]).instantiate()
	map.ready.connect(instance.ready_to_enter_instance)
	instance.add_child(map)
