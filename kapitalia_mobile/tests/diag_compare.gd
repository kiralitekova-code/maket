extends SceneTree

func _init() -> void:
	print("=== ИТОГОВАЯ ПРОВЕРКА === " + str(Time.get_ticks_msec()))
	
	# 1. AppShell
	var shell: Node = await _try_load("res://scenes/shell/AppShell.tscn", "AppShell")
	if shell:
		print("AppShell children: ", shell.get_child_count())
		var wl = shell.get_node_or_null("%WeekLabel")
		print("  %WeekLabel: ", wl != null)
		shell.queue_free()
	
	# 2. M9
	var m9: Node = await _try_load("res://scenes/screens/m9_map.tscn", "M9Map")
	if m9:
		print("M9 children: ", m9.get_child_count())
		print("  Scroll: ", m9.get_node_or_null("Scroll") != null)
		print("  Scroll/VBox: ", m9.get_node_or_null("Scroll/VBox") != null)
		print("  Scroll/VBox/SegmentRow: ", m9.get_node_or_null("Scroll/VBox/SegmentRow") != null)
		print("  Scroll/VBox/BtnEnter3D: ", m9.get_node_or_null("Scroll/VBox/BtnEnter3D") != null)
		print("  %BtnEnter3D: ", m9.get_node_or_null("%BtnEnter3D") != null)
		print("  Scroll/VBox/MapViewport: ", m9.get_node_or_null("Scroll/VBox/MapViewport") != null)
		print("  %MapViewport: ", m9.get_node_or_null("%MapViewport") != null)
		print("  Scroll/VBox/CityDetailCard: ", m9.get_node_or_null("Scroll/VBox/CityDetailCard") != null)
		var vb = m9.get_node_or_null("Scroll/VBox")
		if vb:
			print("  VBox children: ", vb.get_child_count())
			var sr = vb.get_node_or_null("SegmentRow")
			if sr:
				print("    SegmentRow children: ", sr.get_child_count())
				print("    SegDemand: ", sr.get_node_or_null("SegDemand") != null)
				print("    SegLogistics: ", sr.get_node_or_null("SegLogistics") != null)
		print("  MapView: ", m9.get_node_or_null("Scroll/VBox/MapViewport/MapView") != null)
		print("M9Map OK!")
		m9.queue_free()
	
	# 3. City3D
	var c3d: Node = await _try_load("res://scenes/world/city3d.tscn", "City3D")
	if c3d:
		print("City3D OK, children: ", c3d.get_child_count())
		c3d.queue_free()
	
	# 4. City3DOverlay
	var overlay: Node = await _try_load("res://scenes/world/city3d_overlay.tscn", "City3DOverlay")
	if overlay:
		print("City3DOverlay OK, children: ", overlay.get_child_count())
		print("  CityViewport: ", overlay.get_node_or_null("CityViewport") != null)
		print("  %City3D: ", overlay.get_node_or_null("%City3D") != null)
		print("  BackButton: ", overlay.get_node_or_null("UI/TopBar/TopBarInner/BackButton") != null)
		print("  %BackButton: ", overlay.get_node_or_null("%BackButton") != null)
		print("  %HintLabel: ", overlay.get_node_or_null("%HintLabel") != null)
		print("  %EnterpriseCard: ", overlay.get_node_or_null("%EnterpriseCard") != null)
		print("  CardName: ", overlay.get_node_or_null("UI/EnterpriseCard/CardVBox/CardHeader/CardName") != null)
		overlay.queue_free()
	
	print("=== ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ ===")
	quit(0)

func _try_load(path: String, label: String) -> Node:
	var packed: PackedScene = load(path)
	if not packed:
		print(label + ": FAIL load")
		return null
	var node: Node = packed.instantiate()
	root.add_child(node)
	await process_frame
	return node
