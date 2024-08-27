class_name LocalPlayer
extends Player

signal sync_state_defined(sync_state: Dictionary)

var speed: float = 75.0

var input_direction: Vector2 = Vector2.ZERO
var last_input_direction: Vector2 = Vector2.ZERO
var action_input: bool = false
var interact_input: bool = false

var state: String = "idle"

func _ready() -> void:
	animated_sprite.play(&"idle")

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
	flipped = (mouse_position.x < global_position.x)
	animation = state

func define_sync_state() -> void:
	# Should convert sync_state to packedbytes for optimization ?
	sync_state = {
		"T": Time.get_unix_time_from_system(),
		"position": get_global_position(),
		"flipped": flipped,
		"animation": animation,
	}

func _set_sync_state(new_state) -> void:
	sync_state = new_state
	sync_state_defined.emit(new_state)
