extends Node

const BOSS_MUSIC = preload("res://sounds/boss_music.ogg")

@export var game_stats: GameStats
@export var level_duration:= 20.00

@onready var enemy_generator: Node2D = $EnemyGenerator
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var level_timer: Timer = $LevelTimer
@onready var boss_spawner_component: SpawnerComponent = $BossSpawnerComponent

var progress_increment_per_second := 0.0
var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")

func _ready() -> void:
	level_timer.start(level_duration)
	progress_increment_per_second = 100.0 / level_duration
	

func _process(delta: float) -> void:
	progress_bar.value = min(progress_bar.value + (progress_increment_per_second * delta), 100.0)
	
func _on_level_timer_timeout() -> void:
	enemy_generator.process_mode = Node.PROCESS_MODE_DISABLED
	
	boss_spawner_component.spawn(
		Vector2(screen_width/2, -16)
	)
	
	level_timer.stop()
	
	Music.stream = BOSS_MUSIC
	Music.play()

