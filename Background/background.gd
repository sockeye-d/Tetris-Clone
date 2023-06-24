extends SubViewport

@export var SPEED: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Camera3D.position += SPEED * delta
	$GPUParticles3D.position += SPEED * delta
	$GPUParticles3D2.position += SPEED * delta
