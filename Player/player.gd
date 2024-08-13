extends CharacterBody2D

@export var max_speed: int = 80
@export var acceleration: int = 10
@export var friction: int = 10

func _physics_process(delta):
	var input_vector: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if input_vector:
		velocity = velocity.move_toward(input_vector * max_speed, acceleration)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction)
		
	move_and_slide()
