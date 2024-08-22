class_name Player
extends Entity

var player_resource: PlayerResource
var equiped_item: ItemResource

var display_name: String = "Player":
	set = _set_display_name

var animation: String = "idle":
	set = _set_animation

var is_in_pvp_zone: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _init() -> void:
	sync_state = {"T" = 0.0}
	group = Group.PLAYER

func _set_display_name(_new_name: String) -> void:
	pass

func _set_animation(new_animation: String) -> void:
	animation = new_animation
	animated_sprite.play(new_animation)

func _set_sync_state(new_state) -> void:
	sync_state = new_state
	for property: String in new_state:
		set(property, new_state[property])

func _set_spawn_state(new_state) -> void:
	spawn_state = new_state
	for property: String in new_state:
		set(property, new_state[property])
