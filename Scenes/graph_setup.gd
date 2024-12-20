extends Node2D

@onready var newNodeDefPosition: Marker2D = $NewNodeDefPosition
var vertexId: int = 0


func _ready() -> void:
	$Result.hide()
	$ResultDetail.hide()
	$ResultOverlayShadow.hide()
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
	print("=======================================================================================")
	# Mulai pencarian rute dari node "A"
	global.dfs("A", ["A"], 0.0, 0.0, [])
	print("===================================FINISH========================================")
	
	# Cari rute dengan waktu tempuh tercepat
	var min_time = INF
	var best_route = null
	var best_checkpoint_details = null
	
	for i in range(global.route_times.size()):
		if global.route_times[i] < min_time:
			min_time = global.route_times[i]
			best_route = global.routes[i]
			best_checkpoint_details = global.route_checkpoints[i]
	
	print("MIN_TIME " + str(min_time))
	#print("ALL_ROUTE " + str(global.routes))
	print("BEST ROUTE " + str(best_route))
	#print("CHECKPOINT DETAILS: " + str(best_checkpoint_details))
	
	# Tampilkan hasil simulasi
	_display_result()
	$Result.show()
	
func _display_result():
	# Pastikan ada rute di global.routes
	if global.routes.size() == 0:
		print("No routes available.")
		return
	
	# Cari rute terbaik berdasarkan waktu total
	var best_route = global.routes[0]  # Mulai dengan rute pertama sebagai yang terbaik
	for route in global.routes:
		if route["total_time"] < best_route["total_time"]:  # Bandingkan waktu total
			best_route = route
			
	print(best_route)
	
	$Result/ColorRect/BestRoute.text = best_route["path"]
	$Result/ColorRect/BestDistanceAndDuration.text = "total jarak: " + str(best_route["total_distance_in_km"]) + " km\nTotal Durasi: " + str(best_route["total_time"]/3600) + " jam"
	$Result/ColorRect/BestRoute.text = best_route["path"]
	
	for route in global.routes:
		# Format jalur rute
		var route_str = route["path"]
		
		# Ambil data jarak total dalam km
		var total_distance = route.get("total_distance_in_km", 0)
		
		# Hitung waktu total dalam jam
		var total_time_in_hours = route.get("total_time", 0) / 3600.0  # Konversi detik ke jam
		
		# Format string dengan data lengkap
		var formatted_str = "%s | %.1f km | %.1f jam" % [route_str, total_distance, total_time_in_hours]
		
		# Tambahkan ke UI List
		$Result/RouteList.add_item(formatted_str)



func _on_start_over_button_pressed() -> void:
	global.routes.clear()
	$Result.hide()


func _on_speed_input_text_changed(new_text: String) -> void:
	global.speed_in_km_per_h = int(new_text)


func _on_route_list_item_selected(index: int) -> void:
	print(global.checkpoints_global)
	
	# Clear existing UI elements in ResultDetail before adding new ones
	for child in $ResultDetail.get_children():
		print(child.name)
		#child.queue_free()  # Removes previous elements
	
	# Dapatkan node awal dari rute yang dipilih (misalnya berdasarkan urutan index atau node yang dipilih)
	print("ASDAS" + str(global.routes))
	
		# Ambil rute berdasarkan index
	var selected_route = global.routes[index]

	# Pisahkan path menjadi node-node yang terpisah
	var path_nodes = selected_route["path"].split("-")

	# Ambil node pertama sebagai start_node
	var selected_start_node = path_nodes[0]

	
	# Cek apakah start_node ada dalam checkpoints_global
	if global.checkpoints_global.has(selected_start_node):
		var checkpoints = global.checkpoints_global[selected_start_node]  # Ambil daftar checkpoints untuk node ini
		
		# Filter dan tampilkan checkpoint untuk rute yang dipilih
		for checkpoint in checkpoints:
			# Membuat VBoxContainer untuk menampung label
			var vbox = VBoxContainer.new()

			# Menambahkan label ke VBoxContainer
			var current_node_label = Label.new()
			current_node_label.text = "Current Node: " + checkpoint["current_node"]
			vbox.add_child(current_node_label)

			var next_node_label = Label.new()
			next_node_label.text = "Next Node: " + checkpoint["next_node"]
			vbox.add_child(next_node_label)

			var arrival_time_label = Label.new()
			arrival_time_label.text = "Arrival Time: " + str(checkpoint["arrival_time"])
			vbox.add_child(arrival_time_label)

			var light_status_label = Label.new()
			light_status_label.text = "Light Status: " + checkpoint["light_status"]
			vbox.add_child(light_status_label)

			var additional_time_label = Label.new()
			additional_time_label.text = "Additional Time: " + str(checkpoint["additional_time"]) + " seconds"
			vbox.add_child(additional_time_label)

			var remaining_time_label = Label.new()
			remaining_time_label.text = "Remaining Time: " + str(checkpoint["remaining_time"]) + " seconds"
			vbox.add_child(remaining_time_label)

			# Menambahkan VBoxContainer ke ResultDetail
			$ResultDetail.add_child(vbox)

	
	# Display the ResultDetail and ResultOverlayShadow
	$ResultDetail.show()
	$ResultOverlayShadow.show()

func _on_back_detail():
	$ResultDetail.hide() 
	$ResultOverlayShadow.hide()
