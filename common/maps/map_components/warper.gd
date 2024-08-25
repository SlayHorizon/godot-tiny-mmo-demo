class_name Warper
extends Area2D

signal player_trying_to_exit(player: Player, target_instance_name)

@export var target_instance_name: StringName
@export var target_spawn_id: int

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_trying_to_exit.emit(body as Player, target_instance_name, target_spawn_id)
