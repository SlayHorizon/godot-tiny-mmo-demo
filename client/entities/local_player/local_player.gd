extends Player

var speed: float = 75.0

var input_direction: Vector2 = Vector2.ZERO
var last_input_direction: Vector2 = Vector2.ZERO
var action_input: bool = false
var interact_input: bool = false

var state: String = "idle"

@onready var cursor: Sprite2D = $Cursor

func _ready() -> void:
	animated_sprite.play(&"idle_down")
	
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.tween_property(cursor, ^"position:y", 1.5, 0.4).as_relative()
	tween.tween_property(cursor, ^"position:y", -1.5, 0.4).as_relative()

func _physics_process(_delta: float) -> void:
	check_inputs()
	move()
	update_animation()
	define_sync_state()

func move() -> void:
	velocity = input_direction * speed
	state = "walk" if velocity else "idle"
	move_and_slide()

func check_inputs() -> void:
	input_direction = Input.get_vector("left", "right", "up", "down")
	match input_direction:
		Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN:
			last_input_direction = input_direction
	action_input = Input.is_action_just_pressed("action")
	interact_input = Input.is_action_just_pressed("interact")

func update_animation() -> void:
	var sprite_direction: String = "_down"
	match last_input_direction:
		Vector2.RIGHT:
			sprite_direction = "_right"
		Vector2.LEFT:
			sprite_direction = "_left"
		Vector2.UP:
			sprite_direction = "_up"
		Vector2.DOWN:
			sprite_direction = "_down"
	#animated_sprite.play(state + sprite_direction)
	animation = state + sprite_direction

func define_sync_state() -> void:
	# Should convert to bytes for optimization ?
	sync_state = {
		"T": Time.get_unix_time_from_system(),
		"position": get_global_position(),
		#"AD": anim_vector, 
		"animation": animation,
	}
	# Should be differently ?
	(get_parent() as InstanceClient).fetch_player_state.rpc_id(1, sync_state)

func _set_sync_state(new_state) -> void:
	sync_state = new_state
