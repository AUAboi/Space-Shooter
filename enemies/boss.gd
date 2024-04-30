extends Enemy



@onready var move_down_state: TimedStateComponent = %MoveDownState
@onready var states: Node = $States
@onready var projectile_phase_state: StateComponent = %ProjectilePhaseState
@onready var bone_projectiles_spawner_component: SpawnerComponent = %BoneProjectilesSpawnerComponent
@onready var bone_spawn_timer: Timer = %BoneSpawnTimer
@onready var gaster_blaster_phase_state: StateComponent = %GasterBlasterPhaseState
@onready var blaster_spawner_component: SpawnerComponent = %BlasterSpawnerComponent

var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")

#Projectile Phase Routine variables

var projectile_start_vector: = Vector2(20, 25)
var projectile_end_vector: = Vector2(screen_width - 20, 25)

var projectile_current_vector := projectile_start_vector
var is_moving_forward := true
var move_amount := 20.0


#Gaster Blaster Phase Routine variables
var waves: Array[Array] = [
	[
		Vector2(20, -16),
		Vector2(screen_width - 20, -16)
	],
	[
		Vector2(screen_width / 2, -16),
		Vector2(screen_width / 2 - 20, -16),
		Vector2(screen_width / 2 + 20, -16)
	],
]


func _ready() -> void:
	super()
	
	for state: StateComponent in states.get_children():
		state.disable()

	move_down_state.state_finished.connect(gaster_blaster_phase_routine)
	
	move_down_state.enable()

func projectile_phase_routine():
	projectile_phase_state.enable()
	shoot_projectile(projectile_start_vector)
	bone_spawn_timer.start()
	bone_spawn_timer.timeout.connect(func(): 
		move_amount = randf_range(20, 40)
		if is_moving_forward:
			projectile_current_vector.x += move_amount
			if projectile_current_vector.x >= projectile_end_vector.x:
				is_moving_forward = false
		else:
			projectile_current_vector.x -= move_amount
			if projectile_current_vector.x <= projectile_start_vector.x:
				is_moving_forward = true
	
		shoot_projectile(projectile_current_vector)
	)

func shoot_projectile(position_vector: Vector2, move_vector: Vector2 = Vector2(0, 200)):
	var projectile = bone_projectiles_spawner_component.spawn(position_vector)
	projectile.move_vector = move_vector

func gaster_blaster_phase_routine():
	gaster_blaster_phase_state.enable()
	waves.shuffle()
	
	spawn_blasters()

func spawn_blasters():
	while true:
		# Spawn blasters based on the shuffled wave configurations
		for positions in waves:
			await get_tree().create_timer(2).timeout
			
			for position in positions:
				var blaster = blaster_spawner_component.spawn(position)
			
				var target_position = Vector2(position.x, 20) # Move towards y=20
			
				var tween_in = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
				tween_in.tween_property(blaster, "global_position", target_position, 0.4).from_current()
