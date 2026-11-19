extends SceneTree

func _init() -> void:
	var p: PackedScene = load("res://tests/test_vbox_bug.tscn")
	var root: Node = p.instantiate()
	get_node("/root").add_child(root)
	await process_frame
	print("Root children: ", root.get_child_count())
	var scroll = root.get_node_or_null("Scroll")
	print("Scroll: ", scroll != null)
	if scroll:
		print("  Scroll kids: ", scroll.get_child_count())
		var vb = scroll.get_node_or_null("VBox")
		print("  VBox: ", vb != null)
		if vb:
			print("    VBox kids: ", vb.get_child_count())
			var sr = vb.get_node_or_null("SegmentRow")
			print("    SegmentRow: ", sr != null)
			var ob = vb.get_node_or_null("OtherBtn")
			print("    OtherBtn: ", ob != null)
	print("DONE")
	quit(0)
