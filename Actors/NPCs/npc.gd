extends CharacterBody2D

@onready var state_timer: Timer = $StateTimer
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

enum State {
	IDLE,
	WANDER
}

const MAX_SPEED: int = 60
const ACCELERATION: int = 4
const FRICTION: int = 4

var state: State = State.IDLE
var tilemap_layer: TileMapLayer
var valid_tile_positions: Array[Vector2i] = []

func _ready():
	state_timer.timeout.connect(on_change_state)
	state_timer.one_shot = true
	state_timer.start(randf_range(1, 3))
	
	navigation_agent_2d.navigation_finished.connect(on_change_state)
	navigation_agent_2d.velocity_computed.connect(on_navigation_agent_velocity_computed)
	navigation_agent_2d.avoidance_enabled = true
	navigation_agent_2d.path_postprocessing = NavigationPathQueryParameters2D.PATH_POSTPROCESSING_EDGECENTERED
	#navigation_agent_2d.debug_enabled = true
	
	tilemap_layer = get_parent().get_node("TileMapLayer")
	setup_tile_positions()
	
func setup_tile_positions() -> void:
	var used_cells: Array[Vector2i] = tilemap_layer.get_used_cells()
	var tileset: TileSet = tilemap_layer.tile_set

	for cell in used_cells:
		var tile_data: TileData = tilemap_layer.get_cell_tile_data(cell)

		if tile_data and tile_data.get_custom_data("isNavigatable"):
			valid_tile_positions.append(cell)

func _physics_process(_delta) -> void:
	match (state):
		State.IDLE:
			idle_state()
		State.WANDER:
			wander_state()
	
	if velocity.x != 0:
		animation_tree.set("parameters/Idle/blend_position", velocity.x)
		animation_tree.set("parameters/Move/blend_position", velocity.x)
		animation_state.travel("Move")
	elif velocity.y != 0:
		animation_state.travel("Move")
	else:
		animation_state.travel("Idle")
	
	move_and_slide()

func idle_state() -> void:
	navigation_agent_2d.velocity = velocity.move_toward(Vector2.ZERO, FRICTION)

func wander_state() -> void:
	if navigation_agent_2d.is_navigation_finished():
		navigation_agent_2d.velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	
	var destination: Vector2 = navigation_agent_2d.get_next_path_position()
	var direction: Vector2 = global_position.direction_to(destination)
	navigation_agent_2d.velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION)

func randomize_state() -> State:
	var random_index: int = randi_range(0, State.size() - 1)
	return State.values()[random_index]

func pick_target_position() -> Vector2:
	if valid_tile_positions.size() > 0:
		var random_index: int = randi() % valid_tile_positions.size()
		var chosen_cell: Vector2i = valid_tile_positions[random_index]
		return tilemap_layer.map_to_local(chosen_cell)

	return Vector2.ZERO

func on_navigation_agent_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func on_change_state() -> void:
	state = randomize_state()
	
	match (state):
		State.IDLE:
			state_timer.start(randf_range(1, 3))
		State.WANDER:
			var wander_target: Vector2 = pick_target_position()
			navigation_agent_2d.target_position = wander_target
