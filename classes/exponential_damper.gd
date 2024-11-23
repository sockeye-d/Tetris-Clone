@tool
class_name ExponentialDamper extends Node


const ALLOWED_TYPES = [
	TYPE_INT,
	TYPE_FLOAT,
	TYPE_VECTOR2,
	TYPE_VECTOR3,
	TYPE_VECTOR4,
	TYPE_COLOR,
	TYPE_QUATERNION,
	TYPE_BASIS,
	TYPE_TRANSFORM2D,
	TYPE_TRANSFORM3D,
]


enum ProcessFrame {
	## Disable processing
	NONE,
	## Same as [code]Node._process(float)[/code]
	IDLE,
	## Same as [code]Node._physics_process(float)[/code]
	PHYSICS,
}


var value: Variant
var target_value: Variant


@export var decay: float = 5.0
@export var process_frame: ProcessFrame = ProcessFrame.IDLE
@export var source_property: PathChain
@export var target_property: PathChain


func _process(delta: float) -> void:
	if process_frame != ProcessFrame.IDLE:
		return
	process(delta)


func _physics_process(delta: float) -> void:
	if process_frame != ProcessFrame.PHYSICS:
		return
	process(delta)


func process(delta: float) -> void:
	if not source_property:
		return
	
	var source_value = source_property.get_value(self)
	if not source_value or typeof(source_value) not in ALLOWED_TYPES:
		return
	
	target_value = target_property.get_value(self)
	
	if not target_value or typeof(target_value) not in ALLOWED_TYPES or typeof(target_value) != typeof(source_value):
		return
	
	value = lerp(target_value, source_value, exp(-decay * delta))
	source_property.set_value(self, value)
