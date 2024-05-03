class_name BoneProjectile

extends Node2D

@onready var move_component: MoveComponent = $MoveComponent
@onready var visible_on_screen_enabler_2d: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D

func move(move_vector: Vector2):
	move_component.velocity = move_vector

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()

func _on_hitbox_component_hit_hurtbox(hurtbox: Variant) -> void:
	queue_free()
