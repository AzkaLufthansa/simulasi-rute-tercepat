extends Node2D

var draggable = false
var offset: Vector2
var is_dragging = false
@export var id: int
@export var vertexName: String

var cycle_duration = 50
var label_text = ""  # Menyimpan teks label untuk setiap node

@onready var input_popup = $InputPopup
@onready var label = $VertexName  # Label yang ada di dalam node

# Variabel untuk menyimpan waktu klik pertama
var first_click_time = -1.0
var double_click_threshold = 0.5  # Batas waktu antara klik pertama dan kedua

static var currently_dragged_node: Node2D = null


func _ready() -> void:
	input_popup.visible = false
	label.text = label_text  # Set teks label ketika node siap  # 
	
	# Mengatur id untuk node berdasarkan urutan
	label_text = String(char(65 + id))  # 'A' untuk id 0, 'B' untuk id 1, dll.
	label.text = label_text
	vertexName = label_text


func _process(delta: float) -> void:
	if (Time.get_ticks_msec() / 1000.0) - first_click_time >= double_click_threshold:
		first_click_time = -1.0
		
	if draggable:
		if Input.is_action_just_pressed("click"):
			offset = get_global_mouse_position() - global_position
			is_dragging = true

			# Jika klik pertama, simpan waktu
			if first_click_time == -1.0:
				first_click_time = Time.get_ticks_msec() / 1000.0  # Waktu dalam detik
				#print("1x DIKLIK -> " + str(first_click_time))
			else:
				# Jika sudah ada klik pertama, cek apakah klik kedua terjadi dalam interval yang ditentukan
				var second_click_time = Time.get_ticks_msec() / 1000.0

				#print("2x DIKLIK -> " + str(second_click_time))
				#print("SELISIH -> " + str(second_click_time - first_click_time))
				#print("=================================================")

				if second_click_time - first_click_time <= double_click_threshold:
					_on_double_click()  # Panggil fungsi untuk menangani klik ganda
					first_click_time = -1.0  # Reset setelah klik ganda
				else:
					# Jika selisih terlalu lama (misalnya lebih dari threshold), reset waktu pertama
					first_click_time = -1.0


		if is_dragging and Input.is_action_pressed("click"):
			global_position = get_global_mouse_position() - offset

		elif Input.is_action_just_released("click"):
			is_dragging = false
			currently_dragged_node = null


# Fungsi untuk menangani klik ganda
func _on_double_click() -> void:
	if !input_popup.visible:
		input_popup.visible = true
		input_popup.get_node("CycleDurationInput").text = str(cycle_duration)	
	else:
		input_popup.visible = false



# Fungsi ketika user mengkonfirmasi input durasi siklus
func _on_save_attribute_button_pressed() -> void:
	var input_text = input_popup.get_node("CycleDurationInput").text
	cycle_duration = int(input_text)
	global.add_node_to_graph(vertexName, cycle_duration)  # Menyimpan data node yang sudah diperbarui
	input_popup.hide()


# Fungsi ketika mouse masuk ke Area2D
func _on_area_2d_mouse_entered() -> void:
	if not is_dragging:
		draggable = true
		$Sprite2D.scale = Vector2(0.11, 0.11)


# Fungsi ketika mouse keluar dari Area2D
func _on_area_2d_mouse_exited() -> void:
	if not is_dragging:
		draggable = false
		$Sprite2D.scale = Vector2(0.098, 0.099)

# Fungsi tombol connect, memunculkan list node
func _on_texture_button_pressed() -> void:
	var node_selection_popup = load("res://Scenes/node_selection_popup.tscn").instantiate()
	node_selection_popup.position = input_popup.position
	node_selection_popup.selectedVertexName = vertexName
	#node_selection_popup.connect("node_selected", self, "_on_node_selected")
	get_tree().root.add_child(node_selection_popup)
	input_popup.hide()
