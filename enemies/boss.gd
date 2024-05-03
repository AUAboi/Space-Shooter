extends Enemy

@onready var move_down_state: TimedStateComponent = %MoveDownState
@onready var states: Node = $States
@onready var projectile_phase_state: TimedStateComponent = %ProjectilePhaseState
@onready var bone_projectiles_spawner_component: SpawnerComponent = %BoneProjectilesSpawnerComponent
@onready var bone_spawn_timer: Timer = %BoneSpawnTimer
@onready var gaster_blaster_phase_state: StateComponent = %GasterBlasterPhaseState
@onready var blaster_spawner_component: SpawnerComponent = %BlasterSpawnerComponent
@onready var player = get_tree().get_first_node_in_group("player")
@onready var target_blaster_phase: TimedStateComponent = %TargetedBlasterPhase
@onready var targeted_blaster_spawner_component: SpawnerComponent = %TargetedBlasterSpawnerComponent
@onready var blaster_delay_timer: Timer = %BlasterDelayTimer

const PHASE_DELAY_TIMER: = 1.0

var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")

#Projectile Phase Routine variables
const PROJECTILE_MIN_Y_SPEED: = 125.0
const PROJECTILE_MAX_Y_SPEED: = 200.0

var projectile_start_vector: = Vector2(20, 25)
var projectile_end_vector: = Vector2(screen_width - 20, 25)

var projectile_current_vector := projectile_start_vector
var is_moving_forward := true
var move_amount := 20.0


#Gaster Blaster Phase Routine variables
const SCREEN_BLASTER_COUNT: = 4

const FULL_BLASTER_BEAM_DURATION: = 2.0
const FULL_BLASTER_BEAM_WAIT_TIME: = 1.25

var full_blasters_iteration_count: = 4

#Targeted Blaster Routine
const TARGETED_BEAM_DELAY: = 0.35
const TARGETED_BEAM_DURATION: = 1.0
const TARGETED_BEAM_WAIT_TIME: = 0.05

func _ready() -> void:
	super()
	
	for state: StateComponent in states.get_children():
		state.disable()

	move_down_state.state_finished.connect(func():
		var random_states: Array[StateComponent] = [projectile_phase_state, gaster_blaster_phase_state, target_blaster_phase]
		
		random_states.shuffle()
		for i in range(random_states.size()):
			var current_index = i
			var next_index = (i + 1) % random_states.size()  # Wrap around to the beginning if at the end
			random_states[current_index].disabled.connect(_on_state_state_finished.bind(random_states[next_index]))

		# Enable the first state component in the randomized order
		random_states[0].enable()
		)
	
	move_down_state.enable()

func projectile_phase_routine():
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
	
		shoot_projectile(projectile_current_vector, Vector2(0, randf_range(PROJECTILE_MIN_Y_SPEED, PROJECTILE_MAX_Y_SPEED)))
	)

func shoot_projectile(position_vector: Vector2, move_vector: Vector2 = Vector2(0, PROJECTILE_MIN_Y_SPEED)):
	var projectile = bone_projectiles_spawner_component.spawn(position_vector)
	projectile.move(move_vector)

func spawn_blasters_targeted():
	if player == null:
		return
	
	var blaster: GasterBlaster = targeted_blaster_spawner_component.spawn(Vector2(player.global_position.x, -16)) as GasterBlaster
	
	blaster.beam_wait_time = TARGETED_BEAM_WAIT_TIME
	blaster.beam_duration = TARGETED_BEAM_DURATION
	
	blaster.fire()
	
	var target_position := Vector2(player.global_position.x, 20)
	var tween_in = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween_in.tween_property(blaster, "global_position", target_position, 0.4).from_current()
	
	blaster_delay_timer.start(TARGETED_BEAM_DURATION + TARGETED_BEAM_DELAY)

func spawn_blasters_full():
	
	for i in range(full_blasters_iteration_count):
		var spawn_position: = Vector2(20, -16)
	
		var skip_iteration = randi() % SCREEN_BLASTER_COUNT  # Randomly select an iteration to skip
		
		for j in range(SCREEN_BLASTER_COUNT):
			if j == skip_iteration:
				spawn_position.x = spawn_position.x + 40
				continue
			
			var blaster: GasterBlaster = blaster_spawner_component.spawn(spawn_position) as GasterBlaster
			
			blaster.beam_duration = FULL_BLASTER_BEAM_DURATION
			blaster.beam_wait_time = FULL_BLASTER_BEAM_WAIT_TIME
			
			blaster.fire()
			
			var target_position := Vector2(spawn_position.x, 20)
				
			var tween_in = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			
			tween_in.tween_property(blaster, "global_position", target_position, 0.4).from_current()
			
			spawn_position.x = spawn_position.x + 40
		
		await get_tree().create_timer(FULL_BLASTER_BEAM_DURATION + FULL_BLASTER_BEAM_WAIT_TIME + 1.0).timeout
	
	gaster_blaster_phase_state.disable()

########
#RANDOMIZED STATE HANDLER
########
func _on_state_state_finished(next_state: StateComponent):
	await get_tree().create_timer(PHASE_DELAY_TIMER).timeout 
	next_state.enable()

########
#FOLLOWING SIGNALS ARE USED TO ORDER PHASES
#TODO: RANDOMIZE
####

func _on_target_blaster_phase_enabled() -> void:
	blaster_delay_timer.start(TARGETED_BEAM_DURATION + TARGETED_BEAM_DELAY)
	spawn_blasters_targeted()

func _on_projectile_phase_state_enabled() -> void:
	projectile_phase_routine()

func _on_blaster_delay_timer_timeout() -> void:
	spawn_blasters_targeted()

func _on_gaster_blaster_phase_state_enabled() -> void:
	spawn_blasters_full()
