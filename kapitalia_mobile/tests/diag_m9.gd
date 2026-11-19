extends SceneTree

func _init() -> void:
	print("=== ДИАГНОСТИКА M9 ===")
	var packed: PackedScene = load("res://scenes/screens/m9_map.tscn")
	if not packed:
		print("FAIL: не загружен m9_map.tscn")
		quit(1)
		return
	
	var m9: Node = packed.instantiate()
	root.add_child(m9)
	await process_frame
	
	# Пройти всё дерево и вывести реальные пути
	_dump_tree(m9, 0)
	
	# Проверить ключевые ноды
	print("--- Проверка ключевых нод ---")
	var seg_row = m9.get_node_or_null("Scroll/VBox/SegmentRow")
	print("SegmentRow: ", seg_row != null)
	if seg_row:
		print("  children: ", seg_row.get_child_count())
		print("  SegDemand: ", seg_row.get_node_or_null("SegDemand") != null)
		print("  SegLogistics: ", seg_row.get_node_or_null("SegLogistics") != null)
	var btn3d = m9.get_node_or_null("%BtnEnter3D")
	print("BtnEnter3D (%): ", btn3d != null)
	print("BtnEnter3D (path): ", m9.get_node_or_null("Scroll/VBox/BtnEnter3D") != null)
	var mapvp = m9.get_node_or_null("Scroll/VBox/MapViewport")
	print("MapViewport: ", mapvp != null)
	if mapvp:
		print("  children: ", mapvp.get_child_count())
	var mapview = m9.get_node_or_null("Scroll/VBox/MapViewport/MapView")
	print("MapView: ", mapview != null)
	if mapview:
		print("  MapView children: ", mapview.get_child_count())
	var detail = m9.get_node_or_null("Scroll/VBox/CityDetailCard")
	print("CityDetailCard: ", detail != null)
	if detail:
		print("  children: ", detail.get_child_count())
		var detailvbox = detail.get_node_or_null("CityDetailVBox")
		print("  CityDetailVBox: ", detailvbox != null)
		if detailvbox:
			print("    CityDetailVBox children: ", detailvbox.get_child_count())
	
	quit(0)

func _dump_tree(node: Node, depth: int) -> void:
	var indent := ""
	for i in range(depth):
		indent += "  "
	print(indent + node.name + " (" + node.get_class() + ")")
	for c in node.get_children():
		_dump_tree(c, depth + 1)
