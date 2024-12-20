extends Node2D

@export var source: Vector2
@export var target: Vector2

@onready var line = $Line2D
@onready var arrow_head = $Polygon2D

var from
var to

var arrow_size: float = 30.0  # Ukuran kepala panah
var arrow_offset: float = 10.0  # Offset kepala panah dari target

var weight: float = 0.0  # Menyimpan bobot yang diinput

func _ready() -> void:
	$InputPopup.position = (source + target) / 2
	update_arrow()

func _process(delta: float) -> void:
	update_arrow()

func update_arrow() -> void:
	# Periksa jika source dan target memiliki nilai yang valid
	if source == target:
		return

	# Menggambar garis antara source dan target
	line.clear_points()
	line.add_point(source)
	line.add_point(target)

	# Menggambar kepala panah
	var direction = (target - source).normalized()
	var arrow_size = 30.0
	var perpendicular = Vector2(-direction.y, direction.x)

	var arrow_tip = target
	var left_wing = arrow_tip - direction * arrow_size + perpendicular * (arrow_size * 0.5)
	var right_wing = arrow_tip - direction * arrow_size - perpendicular * (arrow_size * 0.5)

	# Offset kepala panah agar sesuai dengan posisi global
	arrow_head.position = target  # Atur posisi kepala panah ke target
	arrow_head.polygon = PackedVector2Array([
		Vector2.ZERO,  # Ujung panah di titik (0, 0) lokal
		left_wing - target,  # Offset terhadap target
		right_wing - target  # Offset terhadap target
	])

	# Menampilkan bobot di tengah garis
	var mid_point = (source + target) / 2 
	$Weight.position = mid_point


func _on_save_attribute_button_pressed() -> void:
	weight = float($InputPopup/WeightInput.text)
	$Weight.text = $InputPopup/WeightInput.text + " km"
	global.add_edge_to_graph(from, to, weight)
	$InputPopup.queue_free()
