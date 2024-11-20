extends Node


enum Source {
	BUTTONS,
	GAMEPLAY,
}


var haptic_feedback_strengths: Dictionary[Source, float] = {
	Source.BUTTONS: 0.5,
	Source.GAMEPLAY: 1.0,
}


func vibrate(source: Source, duration_ms: int, amplitude_mul: float = 1.0) -> void:
	#print(Source.find_key(source), " ", duration_ms, " ", amplitude_mul)
	Input.vibrate_handheld(duration_ms, haptic_feedback_strengths[source] * amplitude_mul)
