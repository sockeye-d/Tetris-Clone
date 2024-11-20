extends Node


@export var initial_scene: PackedScene = preload("res://scenes/main_menu/main_menu.tscn")


@onready var transition: SceneTransition = %Transition


var scene_stack: Array[Node]
var modal_transition_stack: Array[ModalTransition]
var current_scene: Node:
	get:
		return scene_stack[-1] if scene_stack else null
var current_modal_transition: ModalTransition:
	get:
		return modal_transition_stack[-1] if modal_transition_stack else null


func _ready() -> void:
	remove_child(transition)
	var bbc := BackBufferCopy.new()
	bbc.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	add_child(bbc, false, Node.INTERNAL_MODE_BACK)
	add_child(transition, false, Node.INTERNAL_MODE_BACK)
	for child in get_children():
		child.queue_free()
	
	switch_to_scene.call_deferred(initial_scene)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		switch_back()


func switch_to_scene(to_scene: PackedScene, modal: bool = false) -> void:
	if modal:
		current_scene.process_mode = Node.PROCESS_MODE_DISABLED
		
		var m := ModalTransition.new()
		modal_transition_stack.push_back(m)
		scene_stack.push_back(to_scene.instantiate())
		add_child(current_modal_transition)
		add_child(current_scene)
		(current_scene as Modal).transition_in()
		
		m.transition_begin()
	else:
		if current_scene:
			await transition.transition_begin()
			remove_child(current_scene)
		else:
			transition.transition_middle()
		
		if to_scene:
			scene_stack.push_back(to_scene.instantiate())
			modal_transition_stack.push_back(null)
		else:
			scene_stack.pop_back()

		add_child(current_scene)
		transition.transition_end()


func switch_back() -> void:
	if scene_stack.size() < 1:
		await transition.transition_begin()
		await get_tree().create_timer(0.1)
		get_tree().quit()
		return
	
	if last_was_modal():
		(current_scene as Modal).transition_out()
		await current_modal_transition.transition_end()
		remove_child(current_modal_transition)
		remove_child(current_scene)
		modal_transition_stack.pop_back()
		scene_stack.pop_back()
		current_scene.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		if current_scene:
			await transition.transition_begin()
			remove_child(current_scene)
		else:
			transition.transition_middle()
		
		scene_stack.pop_back()
		modal_transition_stack.pop_back()
		add_child(current_scene)
		transition.transition_end()


func switch_back_to_first() -> void:
	if scene_stack.size() <= 1:
		return
	await transition.transition_begin()
	while scene_stack.size() > 1:
		current_scene.queue_free()
		scene_stack.pop_back()
		if current_modal_transition:
			current_modal_transition.queue_free()
		modal_transition_stack.pop_back()
	add_child(current_scene)
	await transition.transition_end()


func last_was_modal() -> bool:
	return current_modal_transition != null
