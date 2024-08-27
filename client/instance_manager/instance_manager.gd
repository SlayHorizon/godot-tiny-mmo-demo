extends Node

var current_instance: InstanceClient

@rpc("authority", "call_remote", "reliable", 0)
func charge_new_instance(new_instance: Dictionary) -> void:
	if current_instance:
		current_instance.queue_free()
	current_instance = InstanceClient.new()
	add_child(current_instance)
	current_instance.name = new_instance["instance_name"]
	print("Loading new map: %s." % new_instance["map_path"])
	var map: Node2D = load(new_instance["map_path"]).instantiate()
	map.ready.connect(current_instance.ready_to_enter_instance)
	current_instance.add_child(map)
