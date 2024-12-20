extends Node2D

var selectedVertexName

@onready var itemList = $InputPopup/ItemList

func _ready() -> void:
	var nodes = get_tree().get_root().get_children()
	
	for node in nodes:
		if node is Node2D and node.name.begins_with("Vertex"):
			if "vertexName" in node:  # Periksa apakah node memiliki properti vertexName
				if node.vertexName != selectedVertexName:
					itemList.add_item(node.vertexName)


func _on_item_list_item_selected(index: int) -> void:
	var node_name = itemList.get_item_text(index)  # Nama lengkap node seperti "VertexA"
	var selected_node = null
	var source_node = null

	# Cari node berdasarkan nama
	for node in get_parent().get_children():
		if node.name == ("Vertex" + node_name):
			selected_node = node
			break
			
	# Cari node sumber
	for node in get_parent().get_children():
		if node.name == ("Vertex" + selectedVertexName):
			source_node = node
			break

	if selected_node:
		SignalManager.vertex_selected.emit(source_node, selected_node)
		
	queue_free()  # Hapus popup ini
