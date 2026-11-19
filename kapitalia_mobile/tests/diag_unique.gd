extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/shell/AppShell.tscn")
	var shell: Node = packed.instantiate()
	root.add_child(shell)
	await process_frame
	await process_frame
	
	print("=== ДИАГНОСТИКА UNIQUE-НОД ===")
	print("Shell: ", shell.name)
	
	# Проверить unique-ноды от корня
	for n in shell.find_children("*", "", true, false):
		if n.get("unique_name_in_tree"):
			print("UNIQUE: ", n.get_path(), " → owner=", n.owner)
	
	# Проверить навигационный контроллер
	var nav: Node = shell
	var week_label = shell.get_node_or_null("%WeekLabel")
	print("WeekLabel от корня: ", week_label)
	
	var wiring: Node = shell.get_node_or_null("GameCore/ShellWiring")
	print("ShellWiring: ", wiring, " owner=", wiring.owner if wiring else null)
	
	# Проверить доступ к unique от wiring
	if wiring:
		var wl = wiring.get_node_or_null("%WeekLabel")
		print("WeekLabel от wiring: ", wl)
		var app = wiring.get_node_or_null("%TopBar")
		print("TopBar от wiring: ", app)
	
	quit()
