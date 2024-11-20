@tool
extends GPUParticles2D


func explode() -> void:
	emitting = true
	await get_tree().create_timer(lifetime + 2.0).timeout
	#queue_free()
