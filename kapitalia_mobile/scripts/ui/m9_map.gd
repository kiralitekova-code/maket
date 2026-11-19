extends Control

# ==============================================================================
# KAPITALIA — Экран M9 «Карта и логистика»
# Добавляет: кнопку запуска 3D-города (полноценный 3D-режим)
# ==============================================================================

var _overlay: Control = null

@onready var _btn_3d: Button = %BtnEnter3D
@onready var _map_viewport: SubViewportContainer = %MapViewport


func _ready() -> void:
	if _btn_3d:
		_btn_3d.pressed.connect(_open_3d_city)
	
	# Заполнить реальные данные городов из MarketData (если доступен)
	_fill_city_data()


## Открыть полноэкранный 3D-режим города
func _open_3d_city() -> void:
	if _overlay:
		return
	
	var packed: PackedScene = load("res://scenes/world/city3d_overlay.tscn")
	_overlay = packed.instantiate() as Control
	_overlay.name = "City3DOverlay"
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Добавить на самый верх (поверх TabBar) — как сиблинг в AppShell
	var app_shell: Control = get_parent() as Control
	if app_shell:
		app_shell.add_child(_overlay)
		_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		_overlay.move_to_front()
	
	# Кнопка возврата
	var overlay_script: Node = _overlay
	if overlay_script.has_signal("close_requested"):
		overlay_script.close_requested.connect(_close_3d_city)


## Закрыть 3D-режим
func _close_3d_city() -> void:
	if _overlay:
		_overlay.queue_free()
		_overlay = null


## Заполнить карту реальными данными из MarketData
func _fill_city_data() -> void:
	# Ищем MarketData через GameCore
	var app_shell := get_tree().current_scene
	if not app_shell:
		return
	var game_core: Node = app_shell.get_node_or_null("GameCore")
	if not game_core:
		return
	var market: Node = game_core.get_node_or_null("MarketData")
	if not market:
		return
	
	# Обновить торговые индексы городов в карточке
	var nordheim_idx: float = market.get_trade_index(0)
	var wallen_idx: float = market.get_trade_index(1)
	var kron_idx: float = market.get_trade_index(2)
	var oster_idx: float = market.get_trade_index(3)
	
	# Обновить подписи (если есть ноды)
	var idx_label: Label = get_node_or_null("Scroll/VBox/CityDetailCard/CityDetailVBox/CityIdentity/CityTradeIndex/TradeIndexValue") as Label
	if idx_label:
		idx_label.text = "%.2fx ▲" % nordheim_idx
