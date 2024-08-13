extends CharacterBody2D

@export var max_speed: int = 80
@export var acceleration: int = 10
@export var friction: int = 10

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

func _physics_process(delta):
	var input_vector: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if input_vector.x:
		animation_tree.set("parameters/Idle/blend_position", input_vector.x)
		animation_tree.set("parameters/Move/blend_position", input_vector.x)
		move(input_vector)
	elif input_vector.y:
		move(input_vector)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, friction)
		
	move_and_slide()

func move(input_vector: Vector2):
	animation_state.travel("Move")
	velocity = velocity.move_toward(input_vector * max_speed, acceleration)
