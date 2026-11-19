@tool
extends Node

# ==============================================================================
# KAPITALIA Mobile — Связующий скрипт оболочки (AppShell Wiring)
# Подключает TickManager и MarketData к UI-элементам оболочки:
# — %WeekLabel, %TickTimeLabel (тик-стрип)
# — Стакан в M5 (Ask/Bid цены, объёмы, тоталы)
# — Алерты в M8
# — Баланс в M0 (через GameState)
# ==============================================================================

var _tick_manager: TickManager = null
var _market_data: MarketData = null
var _game_state: GameState = null

# UI-ноды оболочки
@onready var week_label: Label = %WeekLabel
@onready var tick_time_label: Label = %TickTimeLabel

# Стакан M5 (нужно искать в текущем экране)
var _m5_orderbook_nodes: Dictionary = {}

# Флаг инициализации
var _initialized: bool = false


func _ready() -> void:
	# В редакторе — только сбор метаданных
	if Engine.is_editor_hint():
		return
	
	# Найти GameCore ноды
	await get_tree().process_frame
	_find_game_core_nodes()
	_connect_signals()
	_initialized = true
	
	# Первичное обновление UI
	_update_time_labels()


func _find_game_core_nodes() -> void:
	# ShellWiring находится внутри GameCore, поэтому:
	# get_parent() → GameCore
	# get_parent().get_parent() → AppShell (NavigationController)
	var game_core: Node = get_parent()
	if not game_core:
		return
	
	_tick_manager = game_core.get_node_or_null("TickManager") as TickManager
	_market_data = game_core.get_node_or_null("MarketData") as MarketData
	
	# GameState создаётся внутри TickManager._ready()
	if _tick_manager:
		_game_state = _tick_manager.get_node_or_null("GameState") as GameState


func _connect_signals() -> void:
	if _tick_manager:
		_tick_manager.tick_started.connect(_on_tick_started)
		_tick_manager.economy_updated.connect(_on_economy_updated)
	
	if _market_data:
		_market_data.quotes_updated.connect(_on_quotes_updated)
	
	if _game_state:
		_game_state.balance_changed.connect(_on_balance_changed)
		_game_state.tick_changed.connect(_on_tick_changed)


# ── Обработчики сигналов ──

func _on_tick_started(week: int, day: int, tick: int) -> void:
	_update_time_labels()
	_generate_alerts_if_needed()


func _on_economy_updated() -> void:
	_update_time_labels()
	_refresh_current_screen()


func _on_quotes_updated() -> void:
	_update_orderbook_display()


func _on_balance_changed(new_balance: int) -> void:
	# Обновить баланс в M0, если он отображается
	_update_m0_balance_display(new_balance)


func _on_tick_changed(week: int, day: int, tick: int) -> void:
	_update_time_labels()


# ── Обновление UI ──

func _update_time_labels() -> void:
	if not week_label or not tick_time_label:
		return
	
	if _game_state:
		week_label.text = _game_state.get_time_string()
		tick_time_label.text = _game_state.get_tick_countdown()
	else:
		week_label.text = "Week -- · --"
		tick_time_label.text = "Next tick --:--:--"


func _update_orderbook_display() -> void:
	if not _market_data:
		return
	
	# Найти текущий экран M5
	var current_screen: Control = _get_current_screen()
	if not current_screen or current_screen.name != "M5Market":
		return
	
	# Обновить стакан для первого товара (демо: flour_premium)
	_update_commodity_orderbook(current_screen, "flour_premium")


func _update_commodity_orderbook(screen: Control, commodity_id: String) -> void:
	var book: MarketData.OrderBook = _market_data.get_orderbook(commodity_id)
	if not book:
		return
	
	var commodity: MarketData.Commodity = _market_data.get_commodity(commodity_id)
	
	# Обновить Ask (продавцы) — сверху вниз: Ask3, Ask2, Ask1
	for i in range(3):
		var level: MarketData.OrderBookLevel = book.asks[i] if i < book.asks.size() else null
		var idx: int = 3 - i  # 3, 2, 1
		
		var price_label: Label = screen.get_node_or_null("Scroll/VBox/ItemFlour/ItemFlourInner/Ask%dPrice" % idx) as Label
		var vol_label: Label = screen.get_node_or_null("Scroll/VBox/ItemFlour/ItemFlourInner/Ask%dVol" % idx) as Label
		var total_label: Label = screen.get_node_or_null("Scroll/VBox/ItemFlour/ItemFlourInner/Ask%dTotal" % idx) as Label
		
		if level and price_label:
			price_label.text = "%s CR" % MarketData.format_price(level.price)
		if level and vol_label:
			vol_label.text = "%.0f т" % level.volume
		if level and total_label:
			var total: float = level.price * level.volume
			total_label.text = _format_total(total)
	
	# Обновить Bid (покупатели) — сверху вниз: Bid1, Bid2, Bid3
	for i in range(3):
		var level: MarketData.OrderBookLevel = book.bids[i] if i < book.bids.size() else null
		var idx: int = i + 1  # 1, 2, 3
		
		var price_label: Label = screen.get_node_or_null("Scroll/VBox/ItemFlour/ItemFlourInner/OrderBookBids/Bid%dPrice" % idx) as Label
		var vol_label: Label = screen.get_node_or_null("Scroll/VBox/ItemFlour/ItemFlourInner/OrderBookBids/Bid%dVol" % idx) as Label
		var total_label: Label = screen.get_node_or_null("Scroll/VBox/ItemFlour/ItemFlourInner/OrderBookBids/Bid%dTotal" % idx) as Label
		
		if level and price_label:
			price_label.text = "%s CR" % MarketData.format_price(level.price)
		if level and vol_label:
			vol_label.text = "%.0f т" % level.volume
		if level and total_label:
			var total: float = level.price * level.volume
			total_label.text = _format_total(total)
	
	# Обновить спред
	if commodity:
		var spread_label: Label = screen.get_node_or_null("Scroll/VBox/ItemFlour/ItemFlourInner/SpreadRow") as Label
		if spread_label and book.asks.size() > 0 and book.bids.size() > 0:
			var spread: float = book.asks[0].price - book.bids[0].price
			var spread_pct: float = (spread / book.bids[0].price) * 100.0
			spread_label.text = "Спред: %.0f CR (%.2f%%)" % [spread, spread_pct]


func _format_total(total: float) -> String:
	if total >= 1_000_000.0:
		return "%.2fM CR" % (total / 1_000_000.0)
	elif total >= 1_000.0:
		return "%.1fk CR" % (total / 1_000.0)
	else:
		return "%.0f CR" % total


func _update_m0_balance_display(new_balance: int) -> void:
	# Найти M0 экран и обновить баланс
	var current_screen: Control = _get_current_screen()
	if not current_screen or current_screen.name != "M0Home":
		return
	
	# Найти ноду баланса в M0 (если есть)
	var balance_label: Label = current_screen.get_node_or_null("BalanceLabel") as Label
	if balance_label and _game_state:
		balance_label.text = GameState.format_money(new_balance)


func _generate_alerts_if_needed() -> void:
	# Логика генерации алертов уже в TickManager
	# Здесь можно добавить UI-обновление для M8
	pass


func _refresh_current_screen() -> void:
	# Перерисовать текущий экран при обновлении экономики
	var current_screen: Control = _get_current_screen()
	if current_screen:
		match current_screen.name:
			"M0Home":
				_update_m0_display(current_screen)
			"M5Market":
				_update_orderbook_display()
			"M8Alerts":
				_update_m8_alerts(current_screen)


func _update_m0_display(screen: Control) -> void:
	# Обновить KPI, баланс, алерты на главной
	if _game_state:
		# Найти ноды KPI и обновить
		var kpi_label: Label = screen.get_node_or_null("KPI_Section") as Label
		if kpi_label:
			kpi_label.text = "📊 KPI Карусель:\n• Выручка: %s\n• Расходы: %s\n• Прибыль: %s" % [
				GameState.format_money(_game_state.total_revenue),
				GameState.format_money(_game_state.total_expenses),
				GameState.format_money(_game_state.net_profit)
			]


func _update_m8_alerts(screen: Control) -> void:
	# Обновить список алертов на экране M8
	if not _game_state:
		return
	
	# Найти контейнер алертов и пересоздать карточки
	var alerts_container: VBoxContainer = screen.get_node_or_null("Scroll/VBox/AlertsContainer") as VBoxContainer
	if not alerts_container:
		return
	
	# Очистить старые алерты
	for child in alerts_container.get_children():
		child.queue_free()
	
	# Создать новые карточки
	for alert in _game_state.alerts:
		var card := _create_alert_card(alert)
		alerts_container.add_child(card)


func _create_alert_card(alert: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 120)
	
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	card.add_child(vbox)
	
	var title := Label.new()
	title.text = alert.get("title", "Алерт")
	title.add_theme_font_size_override("font_size", 14)
	vbox.add_child(title)
	
	var desc := Label.new()
	desc.text = alert.get("description", "")
	desc.add_theme_font_size_override("font_size", 12)
	desc.add_theme_color_override("font_color", Color("#93A1B0"))
	vbox.add_child(desc)
	
	return card


func _get_current_screen() -> Control:
	# AppShell (NavigationController) — бабка: GameCore → AppShell
	var app_shell: NavigationController = get_parent().get_parent() as NavigationController
	if app_shell:
		var viewport: Control = app_shell.get_node_or_null("ContentViewport")
		if viewport and viewport.get_child_count() > 0:
			return viewport.get_child(0) as Control
	return null
