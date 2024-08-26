extends Node

static var dev_menu_instance : CanvasLayer

@onready var dev_menu : PackedScene = preload("res://client/ui/hud/dev_hud.tscn")

var place_holder_message : Label
var msg_container : VBoxContainer
var cmd_box : LineEdit

func _get_args(param : String) -> Array:
	var args : = []
	while param.length() > 0:
		var id : int = param.find(" ")
		if id != -1:
			var isarg : String = param.left(id)
			args.append(isarg)
			param = param.erase(0, isarg.length() + 1)
		else:
			args.append(param)
			param = param.erase(0, param.length() + 1)
			
	return args

@rpc("any_peer", "call_remote", "reliable", 0)
func filter_cmd(cmd : String, args : Array) -> void:
	pass

var cmds : Dictionary = {
	"tp" : func(param : String):
		var args : = _get_args(param)
		if args.size() < 2:
			return
		
		get_tree().root.get_node("Main").filter_cmd.rpc_id(1, "tp", args)
		pass,
	"warp" : func(param : String):
		var args : = _get_args(param)
		if args.size() < 1:
			return
		
		get_tree().root.get_node("Main").filter_cmd.rpc_id(1, "warp", args)
		pass;
}

func is_client() -> bool:
	return OS.has_feature("client")
	
func _ready() -> void:
	var new_menu = dev_menu.instantiate()
	add_child(new_menu)

	dev_menu_instance = new_menu
	
	place_holder_message = new_menu.get_node("placeholdermsg")
	msg_container = new_menu.get_node("DevHud/VBoxContainer")
	cmd_box = new_menu.get_node("DevHud/LineEdit")
	cmd_box.text_submitted.connect(_apply_cmd)

func _apply_cmd(cmd : String) -> void:
	_send_messages(cmd)
	
	var id : int = cmd.find(" ")
	if id != -1:
		var iscmd : String = cmd.left(id)
		if cmds.has(iscmd):
			cmds[iscmd].call( cmd.erase(0, iscmd.length() + 1) )
		
	cmd_box.text = ""

var messages := []
func _send_messages(msg : String = "") -> void:
	var new_msg : Label = place_holder_message.duplicate()
	new_msg.text = msg
	new_msg.visible = true
	
	messages.append(new_msg)
	msg_container.add_child(new_msg)
	
	if messages.size() > 13:
		messages[0].queue_free()
		messages.remove_at(0)

var key_debounce : bool = false
func _process(_delta : float) -> void:
	if cmd_box.has_focus():
		return
		
	if Input.is_key_pressed(KEY_0) and not key_debounce:
		dev_menu_instance.visible = !dev_menu_instance.visible 
		key_debounce = true
		
	if not Input.is_key_pressed(KEY_0):
		key_debounce = false
		
