class_name NodeUtil


static func get_leaf_nodes(base: Node, include_internal: bool = false) -> Array[Node]:
	var child_nodes := base.get_children(include_internal)
	
	var nodes: Array[Node]
	if child_nodes:
		for n in child_nodes:
			nodes.append_array(get_leaf_nodes(n, include_internal))
	else:
		nodes = [base]
	return nodes


static func get_nodes(base: Node, include_internal: bool = false) -> Array[Node]:
	var child_nodes := base.get_children(include_internal)
	
	var nodes: Array[Node] = [base]
	for n in child_nodes:
		nodes.append_array(get_nodes(n, include_internal))
	return nodes
