extends SceneTree

func _init() -> void:
	print("=== ТЕСТ 3D-СЦЕН ===")
	
	# 1. Загрузить 3D-оверлей
	var overlay_packed: PackedScene = load("res://scenes/world/city3d_overlay.tscn")
	if not overlay_packed:
		print("FAIL: не загружен city3d_overlay.tscn")
		quit(1)
		return
	var overlay: Control = overlay_packed.instantiate()
	root.add_child(overlay)
	await process_frame
	await process_frame
	await process_frame
	
	print("Overlay OK: ", overlay.name)
	
	# Проверить unique-ноды оверлея
	var back_btn = overlay.get_node_or_null("%BackButton")
	var viewport = overlay.get_node_or_null("%CityViewport")
	var card = overlay.get_node_or_null("%EnterpriseCard")
	var hint = overlay.get_node_or_null("%HintLabel")
	print("BackButton: ", back_btn != null)
	print("CityViewport: ", viewport != null)
	print("EnterpriseCard: ", card != null)
	print("HintLabel: ", hint != null)
	
	# Проверить, что City3D построен внутри вьюпорта
	var city = viewport.get_node_or_null("City")
	print("City3D built: ", city != null)
	if city:
		print("  children: ", city.get_child_count())
		var builder = city.get_node_or_null("CityBuilder")
		print("  CityBuilder: ", builder != null, " (buildings: ", builder.get_child_count() if builder else 0, ")")
		var player = city.get_node_or_null("Player")
		print("  Player: ", player != null)
		var cam = city.get_node_or_null("CameraRig")
		print("  CameraRig: ", cam != null)
	
	# 2. Загрузить m9_map с 3D-кнопкой
	var m9_packed: PackedScene = load("res://scenes/screens/m9_map.tscn")
	var m9: Control = m9_packed.instantiate()
	root.add_child(m9)
	await process_frame
	print("M9 OK: ", m9.name)
	var btn3d = m9.get_node_or_null("%BtnEnter3D")
	print("  BtnEnter3D: ", btn3d != null)
	
	# 3. Протестировать открытие 3D-оверлея из M9
	if btn3d:
		btn3d.pressed.emit()
		await process_frame
		await process_frame
		var overlay2 = m9.get_parent().get_node_or_null("City3DOverlay")
		print("  Overlay открыт: ", overlay2 != null)
		if overlay2:
			var vp2 = overlay2.get_node_or_null("%CityViewport")
			var city2 = vp2.get_node_or_null("City") if vp2 else null
			print("  City в overlay: ", city2 != null)
			overlay2.queue_free()
			await process_frame
	
	print("=== ТЕСТ ЗАВЕРШЁН ===")
	quit(0)
