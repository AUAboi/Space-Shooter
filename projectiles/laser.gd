extends Node2D

@onready var visible_on_screen_enabler_2d: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D
@onready var scale_component := $ScaleComponent as ScaleComponent 
@onready var flash_component := $FlashComponent as FlashComponent

func _ready() -> void:
	scale_component.tween_scale()
	flash_component.flash()
	visible_on_screen_enabler_2d.screen_exited.connect(queue_free)


func _on_hitbox_component_hit_hurtbox(hurtbox: Variant) -> void:
	queue_free()
