class_name HapticFeedbacker extends Node


@export var source: HapticsManager.Source = HapticsManager.Source.BUTTONS
@export var duration_ms: int = 100
@export var force: float = 1.0



func vibrate() -> void:
	HapticsManager.vibrate(source, duration_ms, force)
