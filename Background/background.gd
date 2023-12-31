extends SubViewport

@export var SPEED: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Camera3D.position += SPEED * delta
	$GPUParticles3D.position += SPEED * delta
	$GPUParticles3D2.position += SPEED * delta
	$GPUParticles3D.material_override.set_shader_parameter("point_size", 25.0 * get_visible_rect().size.x / 1920.0)
