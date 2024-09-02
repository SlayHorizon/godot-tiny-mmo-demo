@tool
class_name Hand
extends Sprite2D

var x_id : int = 0
var y_id : int = 0

const width_and_height : int = 16

@export var side : hand_sides = hand_sides.left :
	set(new_side):
		side = new_side
		_update_sides()
	get:
		return side
		
@export var status : hand_status = hand_status.idle :
	set(new_status):
		status = new_status
		_update_hands()
	get:
		return status

func _update_sides() -> void:
	match (side):
		hand_sides.left:
			x_id = 0
		hand_sides.right:
			x_id = 1
	
	_update_hands()

func _update_hands() -> void:
	match (status):
		hand_status.idle:
			y_id = 0
		hand_status.grab:
			y_id = 1
	
	if status == hand_status.pull:
		region_rect = Rect2(2 * 16, 1 * 16, width_and_height, width_and_height)
		return
	
	region_rect = Rect2(x_id * 16, y_id * 16, width_and_height, width_and_height)

enum hand_status {
	idle,
	grab,
	pull
}

enum hand_sides {
	left,
	right
}

func _init() -> void:
	_update_sides()
	region_enabled = true
