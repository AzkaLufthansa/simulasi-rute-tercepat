extends Node2D


# Mulai atur graf
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/graph_setup.tscn")
