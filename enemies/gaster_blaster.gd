class_name GasterBlaster

extends Node2D

@onready var blaster_beam: Node2D = $BlasterBeam
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $BlasterBeam/HitboxComponent/CollisionShape2D
@onready var fire_audio_stream_player: VariablePitchAudioStreamPlayer = $FireAudioStreamPlayer

@export var beam_wait_time:= 0.25
@export var beam_duration:= 1.0

var fired := false

func fire() -> void:
	await get_tree().create_timer(beam_wait_time).timeout
	animated_sprite_2d.play("fire")

func _on_animated_sprite_2d_animation_finished() -> void:
	if fired:
		if animated_sprite_2d.animation == "fire":
			animated_sprite_2d.play("default")
			animated_sprite_2d.animation_looped.connect(queue_free)
	else:
		fire_audio_stream_player.play_with_variance()
		var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tween.tween_property(blaster_beam, "scale", Vector2(1, 1), 0.4).from_current()
		collision_shape_2d.set_deferred("disabled", false)
		
		await get_tree().create_timer(beam_duration).timeout
		
		var tween_back = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_parallel(true)
		tween_back.tween_property(blaster_beam, "scale", Vector2(0, 1), 0.6 ).from_current()
		tween_back.tween_property(blaster_beam, "modulate:a", 0, 0.4).from_current()
		collision_shape_2d.set_deferred("disabled", true)
		fired = true
		
		animated_sprite_2d.play_backwards()
