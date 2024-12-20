extends Node2D

@onready var newNodeDefPosition: Marker2D = $NewNodeDefPosition
var vertexId: int = 0


func _ready() -> void:
	$Result.hide()
	SignalManager.connect("vertex_selected", _on_vertex_selecterd)

# Fungsi untuk menambahkan node
func _on_add_node_button_pressed() -> void:
	var vertexScene = load("res://Scenes/vertex.tscn")
	var vertexInstance = vertexScene.instantiate()

	vertexInstance.position = newNodeDefPosition.position
	vertexInstance.id = vertexId
	vertexInstance.name = "Vertex" + String(char(65 + vertexInstance.id))
	get_parent().add_child(vertexInstance)

	vertexId = vertexId + 1


# Fungsi untuk menghapus semua vertex
func _on_button_pressed() -> void:
	for node in get_parent().get_children():
		if node.name.begins_with("Vertex"):
			node.queue_free()  # Hapus node dari scene
			
	vertexId = 0


# Fungsi untuk membuat panah
func _on_vertex_selecterd(sourceVertex: Node2D, targetVertex: Node2D):
	var arrow = preload("res://Scenes/arrow.tscn").instantiate()

	# Hitung arah garis dari source ke target
	var direction = (targetVertex.global_position - sourceVertex.global_position).normalized()
	
	# Tentukan jarak untuk memendekkan garis (sesuaikan dengan ukuran vertex)
	var offset_distance = 20.0  # Jarak yang dipendekkan di setiap sisi
	
	# Hitung posisi source dan target baru
	arrow.source = sourceVertex.global_position + direction * offset_distance
	arrow.target = targetVertex.global_position - direction * offset_distance
	
	arrow.from = sourceVertex.vertexName
	arrow.to = targetVertex.vertexName

	get_parent().add_child(arrow)


func _on_start_simulation_button_pressed() -> void:
	print(global.graph_data)
	$Result.show()


func _on_start_over_button_pressed() -> void:
	$Result.hide()
