@tool
class_name PathNode extends Path


@export var node_path: NodePath


func get_value(from) -> Variant:
	if from == null:
		printerr("from was null")
		return null
	
	var base_node := from as Node
	if not base_node:
		printerr("from wasn't a node")
		return null
	
	var target_node := base_node.get_node(node_path)
	
	return target_node
