extends Node

var current_instance: InstanceClient

@rpc("authority", "call_remote", "reliable", 0)
func charge_new_instance(new_instance_data: Dictionary) -> void:
	var new_instance := InstanceClient.new()
	new_instance.name = new_instance_data["instance_name"]
	add_child(new_instance, true)
	print("Loading new map: %s." % new_instance_data["map_path"])
	var map: Node2D = load(new_instance_data["map_path"]).instantiate()
	map.ready.connect(new_instance.ready_to_enter_instance)
	new_instance.add_child(map)
	if current_instance:
		if current_instance.local_player:
			current_instance.local_player.reparent(new_instance, false)
		current_instance.queue_free()
	current_instance = new_instance
