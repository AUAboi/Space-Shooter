class_name Enemy

extends Node2D

@onready var move_component: MoveComponent = $MoveComponent
@onready var stats_component: StatsComponent = $StatsComponent
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var scale_component: ScaleComponent = $ScaleComponent
@onready var shake_component: ShakeComponent = $ShakeComponent
@onready var flash_component: FlashComponent = $FlashComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var destroyed_component: DestroyedComponent = $DestroyedComponent
@onready var score_component: ScoreComponent = $ScoreComponent
@onready var variable_pitch_audio_stream_player: VariablePitchAudioStreamPlayer = $VariablePitchAudioStreamPlayer

func _ready() -> void:
	visible_on_screen_notifier_2d.screen_exited.connect(queue_free)
	hurtbox_component.hurt.connect(func(_hit_box: HitboxComponent):
		scale_component.tween_scale()
		flash_component.flash()
		shake_component.tween_shake()
		variable_pitch_audio_stream_player.play_with_variance()
	)

func _on_hitbox_component_hit_hurtbox(_hurtbox: Variant) -> void:
	destroyed_component.destroy()

func _on_stats_component_no_health() -> void:
	score_component.adjust_score()
