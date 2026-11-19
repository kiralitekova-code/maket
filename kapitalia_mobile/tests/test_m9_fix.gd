extends SceneTree

func _init() -> void:
	var p: PackedScene = load("res://scenes/screens/m9_map.tscn")
	var m9: Node = p.instantiate()
	root.add_child(m9)
	await process_frame
	print("M9 children: ", m9.get_child_count())
	var scroll = m9.get_node_or_null("Scroll")
	print("Scroll: ", scroll != null)
	if scroll:
		print("  Scroll kids: ", scroll.get_child_count())
		var vb = scroll.get_node_or_null("VBox")
		print("  VBox: ", vb != null)
		if vb:
			print("    VBox kids: ", vb.get_child_count())
			print("    SegmentRow: ", vb.get_node_or_null("SegmentRow") != null)
			print("    BtnEnter3D: ", vb.get_node_or_null("BtnEnter3D") != null)
			print("    %%BtnEnter3D: ", m9.get_node_or_null("%BtnEnter3D") != null)
			print("    MapViewport: ", vb.get_node_or_null("MapViewport") != null)
			print("    %%MapViewport: ", m9.get_node_or_null("%MapViewport") != null)
			print("    CityDetailCard: ", vb.get_node_or_null("CityDetailCard") != null)
			var sr = vb.get_node_or_null("SegmentRow")
			if sr:
				print("      SegmentRow kids: ", sr.get_child_count())
	var md = m9.get_node_or_null("Scroll/VBox/MapViewport/MapView")
	print("MapView: ", md != null)
	if md:
		print("  MapView kids: ", md.get_child_count())
	print("OK")
	quit(0)
