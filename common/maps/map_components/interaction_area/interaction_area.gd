@icon("res://assets/node_icons/blue/icon_grid.png")
class_name InteractionArea
extends Area2D

signal player_entered_interaction_area(player: Player, interaction_area: InteractionArea)

func _init() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered_interaction_area.emit(body as Player, self)
