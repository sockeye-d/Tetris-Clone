extends GPUParticles2D

var time_alive: float

# Called when the node enters the scene tree for the first time.
func _ready():
	time_alive = 0.0
	emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_alive += delta
	if time_alive > lifetime + 2.0:
		queue_free()
