class_name weapon
extends Node2D

const attack_damage : float = 15.0
const attack_speed : float = 1

@export var left_hand : Hand
@export var right_hand : Hand

@export var status : weapon_status

enum weapon_status {
	idle,
	charging,
	attacking
}
