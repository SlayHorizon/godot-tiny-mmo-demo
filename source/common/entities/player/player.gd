class_name Player
extends Entity

# Incomplete
var player_resource: PlayerResource
var equiped_item: ItemResource

var display_name: String = "Player":
	set = _set_display_name

var animation: String = "idle":
	set = _set_animation

var flipped: bool = false:
	set = _set_flip

var sprite_frames: String = "knight":
	set = _set_sprite_frames
	
var hands_rotation: float = 0 :
	set = _set_hands_rotation

var is_in_pvp_zone: bool = false
var just_teleported: bool = false:
	set(value):
		just_teleported = value
		if not is_node_ready():
			await ready
		if not is_inside_tree():
			await tree_entered
		if just_teleported:
			await get_tree().create_timer(0.5).timeout
			just_teleported = false

var idle_hands: bool = false # stops hands from looking at the cursor

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hands_offset_node: Node2D = $hands_offset
@onready var hands_rotation_point: Node2D = $hands_offset/hands_rotation_point

func _init() -> void:
	sync_state = {"T" = 0.0}
	group = Group.PLAYER


func _set_hands_rotation(_new_rot: float) -> void:
	hands_rotation = _new_rot
	hands_rotation_point.rotation = hands_rotation

func _set_display_name(_new_name: String) -> void:
	pass

func _set_animation(new_animation: String) -> void:
	animation = new_animation
	animation_player.play("knight_" + new_animation) # sprite_frames + "_" + new_animation for later unique animations
	#animated_sprite.play(new_animation)

func _set_flip(new_flip: bool) -> void:
	flipped = new_flip
	animated_sprite.flip_h = flipped
	
	var flips : int = -1 if flipped else 1
	hands_offset_node.scale = Vector2(flips, 1)

func _set_sprite_frames(new_sprite_frames: String) -> void:
	# Bad design, not scalable and optimized.
	match new_sprite_frames:
		"knight":
			animated_sprite.sprite_frames = load("res://source/common/resources/builtin/sprite_frames/knight.tres")
		"rogue":
			animated_sprite.sprite_frames = load("res://source/common/resources/builtin/sprite_frames/rogue.tres")
		"wizard":
			animated_sprite.sprite_frames = load("res://source/common/resources/builtin/sprite_frames/wizard.tres")

func _set_sync_state(new_state) -> void:
	sync_state = new_state
	for property: String in new_state:
		set(property, new_state[property])

func _set_spawn_state(new_state) -> void:
	spawn_state = new_state
	if not is_node_ready():
		await ready
	for property: String in new_state:
		set(property, new_state[property])
