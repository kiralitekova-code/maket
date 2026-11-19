extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/screens/m9_map.tscn")
	var m9: Node = packed.instantiate()
	root.add_child(m9)
	await process_frame
	print("DUMP_START")
	for c in m9.get_children():
		print("CHILD ", c.name, " cls=", c.get_class(), " kids=", c.get_child_count())
	print("DUMP_END")
	quit(0)
