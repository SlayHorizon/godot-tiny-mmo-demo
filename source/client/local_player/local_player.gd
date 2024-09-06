class_name LocalPlayer
extends Player

signal sync_state_defined(sync_state: Dictionary)

var speed: float = 75.0
var lookat_speed: float = 10.0

var input_direction: Vector2 = Vector2.ZERO
var last_input_direction: Vector2 = Vector2.ZERO
var action_input: bool = false
var interact_input: bool = false

var state: String = "idle"

func _physics_process(_delta: float) -> void:
	check_inputs()
	move()
	update_animation()
	define_sync_state()

func move() -> void:
	velocity = input_direction * speed
	state = "run" if velocity else "idle"
	move_and_slide()

func check_inputs() -> void:
	input_direction = Input.get_vector("left", "right", "up", "down")
	match input_direction:
		Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN:
			last_input_direction = input_direction
	action_input = Input.is_action_just_pressed("action")
	interact_input = Input.is_action_just_pressed("interact")

func update_animation() -> void:
	var mouse_position := get_global_mouse_position()
	flipped = (Mouse.mouse_position.x < global_position.x)
	animation = state
	
	if idle_hands:
		return
	
	# Hands look at mouse & flips code
	if Input.is_action_pressed("action"):
		var hands_rot_pos = hands_rotation_point.global_position
		var flips := -1 if flipped else 1
		var look_at_mouse := atan2(
			(Mouse.mouse_position.y - hands_rot_pos.y), 
			(Mouse.mouse_position.x - hands_rot_pos.x) * flips
			)
		hands_rotation = lerp_angle(hands_rotation, look_at_mouse, get_physics_process_delta_time() * lookat_speed)#look_at_mouse
		return
	
	hands_rotation = lerp_angle(hands_rotation, 0, get_physics_process_delta_time() * lookat_speed)

func define_sync_state() -> void:
	# Should convert sync_state to packedbytes for optimization ?
	sync_state = {
		"T": Time.get_unix_time_from_system(),
		"position": get_global_position(),
		"flipped": flipped,
		"animation": animation,
		"hands_rotation": hands_rotation,
	}

func _set_sync_state(new_state) -> void:
	sync_state = new_state
	sync_state_defined.emit(new_state)
