extends Node2D

@onready var left_muzzle: Marker2D = $LeftMuzzle
@onready var right_muzzle: Marker2D = $RightMuzzle
@onready var spawner_component := $SpawnerComponent as SpawnerComponent
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var scale_component:= $ScaleComponent as ScaleComponent
@onready var move_component: MoveComponent = $MoveComponent
@onready var ship_animated_sprite: AnimatedSprite2D = $Anchor/AnimatedSprite2D
@onready var flame_animated_sprite: AnimatedSprite2D = %FlameAnimatedSprite
@onready var variable_pitch_audio_stream_player: VariablePitchAudioStreamPlayer = $VariablePitchAudioStreamPlayer

func _ready() -> void:
	fire_rate_timer.timeout.connect(fire_laser)

func fire_laser() -> void:
	variable_pitch_audio_stream_player.play_with_variance()
	spawner_component.spawn(left_muzzle.global_position)
	spawner_component.spawn(right_muzzle.global_position)
	scale_component.tween_scale()

func _process(_delta: float) -> void:
	animate_the_ship()

func animate_the_ship() -> void:
	if move_component.velocity.x < 0:
		ship_animated_sprite.play("bank_left")
		flame_animated_sprite.play("bank_left")
		
	elif move_component.velocity.x > 0:
		ship_animated_sprite.play("bank_right")
		flame_animated_sprite.play("bank_right")
	else:
		ship_animated_sprite.play("center")
		flame_animated_sprite.play("center")
