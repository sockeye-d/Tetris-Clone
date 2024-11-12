extends Node


@export var initial_scene: PackedScene = preload("res://scenes/main_menu/main_menu.tscn")


@onready var transition: Transition = %Transition


var scene_stack: Array[Node]


func _ready() -> void:
	remove_child(transition)
	add_child(transition, false, Node.INTERNAL_MODE_BACK)
	
	GlobalSignals.please_switch_to_scene.connect(switch_to_scene)
	
	switch_to_scene.call_deferred(initial_scene)


## if to_scene is null, then it will go back a scene in the stack
func switch_to_scene(to_scene: PackedScene) -> void:
	if scene_stack.back() == null and to_scene == null:
		# can't go back if no scene is loaded
		return
	
	if scene_stack.back():
		await transition.transition_begin()
		remove_child(scene_stack.back())
	else:
		transition.transition_middle()
	
	if to_scene:
		scene_stack.push_back(to_scene.instantiate())
	else:
		scene_stack.pop_back()
	
	add_child(scene_stack.back())
	transition.transition_end()


func switch_back() -> void:
	switch_to_scene(null)
