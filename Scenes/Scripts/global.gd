extends Node

var is_dragging = false
var speed_in_km_per_h: float = 10

var graph_data = {
  "nodes": [
	{ "id": "A", "cycle_duration": 0 },
	{ "id": "B", "cycle_duration": 200 },
	{ "id": "C", "cycle_duration": 110 },
	{ "id": "D", "cycle_duration": 75 },
	{ "id": "E", "cycle_duration": 90 },
	{ "id": "F", "cycle_duration": 0 }
  ],
  "edges": [
	{ "from": "A", "to": "C", "distance_in_km": 16 },
	{ "from": "A", "to": "B", "distance_in_km": 2.8 },
	{ "from": "B", "to": "D", "distance_in_km": 12 },
	{ "from": "D", "to": "E", "distance_in_km": 4.2 },
	{ "from": "D", "to": "F", "distance_in_km": 15.6 },
	{ "from": "C", "to": "F", "distance_in_km": 10 },
	{ "from": "E", "to": "F", "distance_in_km": 5.4 },
	{ "from": "D", "to": "C", "distance_in_km": 5 }
  ]
}

var routes = []  # Rute yang memungkinkan
var route_times = []  # Total waktu untuk setiap rute
var route_checkpoints = []
var checkpoints_global = {}

func add_node_to_graph(vertexName, cycleDuration):
	var node_data = {
		"id": vertexName,
		"cycle_duration": cycleDuration
	}
	graph_data["nodes"].append(node_data)
	
func add_edge_to_graph(from, to, distance):
	var edge_data = {
		"from": from,
		"to": to,
		"distance_in_km": distance
	}
	graph_data["edges"].append(edge_data)

func dfs(current_node, current_path, total_time, total_distance, checkpoints):
	var nodes = graph_data["nodes"]
	var edges = graph_data["edges"]
	
	# Membuat dictionary untuk akses cepat durasi siklus node
	var node_cycle_duration = {}
	for node in nodes:
		node_cycle_duration[node["id"]] = node["cycle_duration"]
	
	# Jika sampai di node tujuan (misalnya "F"), simpan rute, waktu, dan detail checkpoint
	if current_node == "F":
		print("LAST ROUTE")
		print("=======================================================================================")
		
		# Gunakan checkpoint terakhir untuk detail tambahan
		var last_checkpoint = checkpoints[-1] if checkpoints.size() > 0 else {}

		var total_additional_time = 0
		for checkpoint in checkpoints:
			total_additional_time += checkpoint["additional_time"]
		
		var total_distance_in_km = total_distance

		var path_str = ""
		for i in range(current_path.size()):
			path_str += current_path[i]
			if i < current_path.size() - 1:
				path_str += "-"  # Tambahkan "-" di antara node

		var route_data = {
			"path": path_str,
			"arrival_time": last_checkpoint.get("arrival_time", total_time),
			"light_status": last_checkpoint.get("light_status", "green"),
			"total_time": total_time + total_additional_time,
			"remaining_time": last_checkpoint.get("remaining_time", 0),
			"additional_time": total_additional_time,
			"total_distance_in_km": total_distance_in_km
		}
		
		# Simpan data ke dalam variabel global routes
		routes.append(route_data)
		return
	
	# Cari semua edge yang keluar dari current_node
	for edge in edges:
		if edge["from"] == current_node:
			# Hitung waktu tempuh dan jarak ke node berikutnya
			var distance = edge["distance_in_km"]
			var travel_time = distance / speed_in_km_per_h  # t = s/v
			var travel_time_in_seconds = travel_time * 3600
			
			# Hitung waktu tiba di node tujuan
			var next_node = edge["to"]
			var cycle_duration = node_cycle_duration.get(next_node, 0)  # Default 0 jika tidak ditemukan
			var time_at_next_node = total_time + travel_time_in_seconds
			
			var additional_time = 0.0
			var light_status = "green"
			var full_cycles = 0
			var remaining_time = 0
			
			# Jika node berikutnya bukan tujuan akhir, hitung siklus lampu
			if next_node != "F":
				full_cycles = int(time_at_next_node / cycle_duration)
				remaining_time = int(time_at_next_node) % cycle_duration
				
				# Tentukan status lampu saat tiba
				if full_cycles % 2 == 0:  # Lampu merah
					additional_time = cycle_duration - remaining_time
					light_status = "red"
			
			# Catat detail checkpoint
			var checkpoint = {
				"current_node": current_node,
				"next_node": next_node,
				"arrival_time": time_at_next_node,
				"light_status": light_status,
				"additional_time": additional_time,
				"remaining_time": remaining_time
			}
			
			# Menyimpan checkpoint berdasarkan node atau rute
			if not checkpoints_global.has(current_node):
				checkpoints_global[current_node] = []
			
			checkpoints_global[current_node].append(checkpoint)
			
			# Rekursi ke node berikutnya
			dfs(
				next_node,
				current_path + [next_node],
				time_at_next_node + additional_time,
				total_distance + distance,
				checkpoints + [checkpoint]
			)
