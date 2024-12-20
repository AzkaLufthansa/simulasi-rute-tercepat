extends Node

var is_dragging = false
var speed: int = 0

var graph_data = {
	"nodes": [],
	"edges": []
}

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

func save_to_json():
	pass
	#var file = File.new()
	#if file.open("user://graph_data.json", File.WRITE) == OK:
		#file.store_string(to_json(graph_data))
		#file.close()
