extends Node2D

@onready var scale_component: ScaleComponent = $ScaleComponent
@onready var hitbox_component: HitboxComponent = $Anchor/HitboxComponent
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	scale_component.tween_scale()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_hitbox_component_hit_hurtbox(hurtbox: Variant) -> void:
	queue_free()
