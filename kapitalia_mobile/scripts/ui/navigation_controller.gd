class_name NavigationController
extends Control

# ==============================================================================
# KAPITALIA Mobile — Навигационный контроллер экранов и модальных окон
# Управляет переключением табов (M0, M1, M5, M7, M8), стеком экранов деталей (M2, M3, M9)
# и модальными листами (BottomSheet M4, M6).
# ==============================================================================

signal screen_changed(screen_name: String)
signal tick_updated(week: int, day: String, time_left: String)

enum TabIndex {
	HOME = 0,        # M0 — Главная
	ENTERPRISES = 1, # M1 — Список предприятий
	MARKET = 2,      # M5 — Биржа и стакан
	REPORTS = 3,     # M7 — P&L отчёты
	MORE = 4         # M8 / M9 / Настройки
}

# Маппинг предзагружаемых сцен экранов
const SCREENS: Dictionary = {
	"M0_home": "res://scenes/screens/m0_home.tscn",
	"M1_enterprises": "res://scenes/screens/m1_enterprises.tscn",
	"M2_enterprise_detail": "res://scenes/screens/m2_enterprise_detail.tscn",
	"M3_supply_autopilot": "res://scenes/screens/m3_supply_autopilot.tscn",
	"M5_market": "res://scenes/screens/m5_market.tscn",
	"M7_reports": "res://scenes/screens/m7_reports.tscn",
	"M8_alerts": "res://scenes/screens/m8_alerts.tscn",
	"M9_map": "res://scenes/screens/m9_map.tscn",
}

# Маппинг контента для модальных BottomSheet
const SHEETS: Dictionary = {
	"M4_new_contract": "res://scenes/sheets/m4_new_contract_sheet.tscn",
	"M6_order_ticket": "res://scenes/sheets/m6_order_ticket_sheet.tscn",
}

@onready var top_bar: PanelContainer = %TopBar
@onready var tick_strip: PanelContainer = %TickStrip
@onready var content_viewport: Control = %ContentViewport
@onready var bottom_tab_bar: PanelContainer = %BottomTabBar
@onready var bottom_sheet_host: BottomSheet = %ModalBottomSheet

# Элементы статус-бара
@onready var tick_label: Label = %TickTimeLabel
@onready var week_label: Label = %WeekLabel

var current_screen_node: Control = null
var current_screen_id: String = ""
var navigation_stack: Array[String] = []

func _ready() -> void:
	_connect_tab_buttons()
	# Старт с главного экрана
	navigate_to("M0_home", false)

func _connect_tab_buttons() -> void:
	var tab_home: Button = %TabHome
	var tab_enterprises: Button = %TabEnterprises
	var tab_market: Button = %TabMarket
	var tab_reports: Button = %TabReports
	var tab_more: Button = %TabMore

	if tab_home: tab_home.pressed.connect(func(): switch_tab(TabIndex.HOME))
	if tab_enterprises: tab_enterprises.pressed.connect(func(): switch_tab(TabIndex.ENTERPRISES))
	if tab_market: tab_market.pressed.connect(func(): switch_tab(TabIndex.MARKET))
	if tab_reports: tab_reports.pressed.connect(func(): switch_tab(TabIndex.REPORTS))
	if tab_more: tab_more.pressed.connect(func(): switch_tab(TabIndex.MORE))

func switch_tab(index: TabIndex) -> void:
	navigation_stack.clear()
	match index:
		TabIndex.HOME:
			navigate_to("M0_home")
		TabIndex.ENTERPRISES:
			navigate_to("M1_enterprises")
		TabIndex.MARKET:
			navigate_to("M5_market")
		TabIndex.REPORTS:
			navigate_to("M7_reports")
		TabIndex.MORE:
			navigate_to("M8_alerts")

## Переход на новый экран
func navigate_to(screen_id: String, push_history: bool = true) -> void:
	if not SCREENS.has(screen_id):
		push_error("Экран не найден в реестре: %s" % screen_id)
		return

	if push_history and not current_screen_id.is_empty():
		navigation_stack.append(current_screen_id)

	_load_screen_node(screen_id)

## Возврат назад по стеку навигации
func go_back() -> void:
	if navigation_stack.size() > 0:
		var previous_screen: String = navigation_stack.pop_back()
		_load_screen_node(previous_screen)
	else:
		switch_tab(TabIndex.HOME)

func _load_screen_node(screen_id: String) -> void:
	if current_screen_node:
		current_screen_node.queue_free()

	current_screen_id = screen_id
	var scene_path: String = SCREENS[screen_id]
	if ResourceLoader.exists(scene_path):
		var packed: PackedScene = load(scene_path)
		current_screen_node = packed.instantiate() as Control
		content_viewport.add_child(current_screen_node)
	else:
		# Заглушка, если сцена ещё не сохранена на диск
		var fallback := PanelContainer.new()
		fallback.set_anchors_preset(Control.PRESET_FULL_RECT)
		var lbl := Label.new()
		lbl.text = "Экран: %s\n(Готов к инъекции сцены)" % screen_id
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		fallback.add_child(lbl)
		current_screen_node = fallback
		content_viewport.add_child(current_screen_node)

	screen_changed.emit(screen_id)
	_update_shell_state(screen_id)

## Открытие модального BottomSheet поверх текущего экрана
func open_sheet(sheet_id: String, sheet_title: String, action_text: String = "Подтвердить") -> void:
	if not bottom_sheet_host:
		return
	
	bottom_sheet_host.set_title(sheet_title)
	bottom_sheet_host.set_action_text(action_text)
	
	# Очистка старого контента листа
	var container: VBoxContainer = bottom_sheet_host.get_node("%ContentContainer")
	for child in container.get_children():
		child.queue_free()

	if SHEETS.has(sheet_id) and ResourceLoader.exists(SHEETS[sheet_id]):
		var sheet_scene: PackedScene = load(SHEETS[sheet_id])
		container.add_child(sheet_scene.instantiate())

	bottom_sheet_host.open(BottomSheet.SheetState.EXPANDED if sheet_id == "M6_order_ticket" else BottomSheet.SheetState.HALF)

func _update_shell_state(screen_id: String) -> void:
	# Скрытие/показ нижнего таббара на экранах глубокой детализации
	var hide_tabs: bool = screen_id in ["M2_enterprise_detail", "M3_supply_autopilot"]
	bottom_tab_bar.visible = not hide_tabs
	
	# Обновление заголовка экрана в TopBar
	var screen_title: Label = top_bar.get_node_or_null("TopBarInner/TitleRow/ScreenTitle") as Label
	if screen_title:
		screen_title.text = _get_screen_title(screen_id)


func _get_screen_title(screen_id: String) -> String:
	match screen_id:
		"M0_home":
			return "Главная"
		"M1_enterprises":
			return "Предприятия"
		"M2_enterprise_detail":
			return "Детали предприятия"
		"M3_supply_autopilot":
			return "Автопилот снабжения"
		"M5_market":
			return "Биржа"
		"M7_reports":
			return "Отчёты P&L"
		"M8_alerts":
			return "События"
		"M9_map":
			return "Карта и логистика"
		_:
			return "Экран"
