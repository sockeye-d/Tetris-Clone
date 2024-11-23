class_name Modal extends Control


#var t: Tween


func _ready() -> void:
	var leaf_nodes := NodeUtil.get_leaf_nodes(self)
	for leaf_node in leaf_nodes:
		leaf_node.self_modulate.a = 0.0


func transition_in():
	await get_tree().process_frame
	var leaf_nodes: Array[Node] = NodeUtil.get_nodes(self).filter(func(node): return node is not Container or node is PanelContainer)
	leaf_nodes.remove_at(leaf_nodes.find(self))
	leaf_nodes.sort_custom(_sort_node)
	for leaf_node_i in leaf_nodes.size():
		var leaf_node := leaf_nodes[leaf_node_i]
		var t := leaf_node.create_tween()
		leaf_node.position.y += 30.0
		t.tween_interval(leaf_node_i * 0.01)
		
		t.tween_property(leaf_node, ^"position:y", -30.0, 0.5).as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		t.set_parallel()
		t.tween_property(leaf_node, ^"self_modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


func transition_out():
	await get_tree().process_frame
	var leaf_nodes: Array[Node] = NodeUtil.get_nodes(self).filter(func(node): return node is not Container or node is PanelContainer)
	leaf_nodes.remove_at(leaf_nodes.find(self))
	leaf_nodes.sort_custom(_sort_node)
	for leaf_node_i in leaf_nodes.size():
		var leaf_node := leaf_nodes[leaf_node_i]
		var t := leaf_node.create_tween()
		t.tween_interval(leaf_node_i * 0.01)
		
		t.tween_property(leaf_node, ^"position:y", -30.0, 0.5).as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		t.set_parallel()
		t.tween_property(leaf_node, ^"self_modulate:a", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


func _sort_node(node_a: Node, node_b: Node) -> bool:
	if node_a is Control and node_b is Control:
		return node_a.position.y < node_b.position.y
	return String(node_a.name) < String(node_b.name)
