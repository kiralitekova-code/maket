class_name BottomSheet
extends Control

signal state_changed(new_state: SheetState)
signal closed()
signal confirmed()

enum SheetState {
	HIDDEN,
	PEEK,      # ~25% экрана
	HALF,      # ~50% экрана
	EXPANDED   # ~85% экрана
}

@export var current_state: SheetState = SheetState.HIDDEN
@export var snap_threshold: float = 60.0
@export var transition_duration: float = 0.24

@onready var scrim: Panel = %Scrim
@onready var sheet_container: PanelContainer = %SheetContainer
@onready var drag_area: Control = $SheetContainer/VBox/DragArea
@onready var close_button: Button = %CloseButton
@onready var sheet_title: Label = %SheetTitle
@onready var primary_action: Button = %PrimaryAction

var is_dragging: bool = false
var drag_start_y: float = 0.0
var initial_offset_top: float = 0.0
var tween: Tween

func _ready() -> void:
	close_button.pressed.connect(close)
	primary_action.pressed.connect(func(): confirmed.emit())
	scrim.gui_input.connect(_on_scrim_gui_input)
	drag_area.gui_input.connect(_on_drag_area_gui_input)
	# Не вызывать set_state в _ready — лист должен остаться скрытым

func set_title(title_text: String) -> void:
	sheet_title.text = title_text

func set_action_text(button_text: String) -> void:
	primary_action.text = button_text

func set_state(target_state: SheetState, animated: bool = true) -> void:
	current_state = target_state
	var screen_h: float = get_viewport_rect().size.y
	var target_y: float = 0.0

	match current_state:
		SheetState.HIDDEN:
			target_y = 0.0
		SheetState.PEEK:
			target_y = -screen_h * 0.28
		SheetState.HALF:
			target_y = -screen_h * 0.58
		SheetState.EXPANDED:
			target_y = -screen_h * 0.88

	if tween and tween.is_running():
		tween.kill()

	if animated:
		tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(sheet_container, "position:y", screen_h + target_y, transition_duration)
		var scrim_alpha: float = 0.0 if current_state == SheetState.HIDDEN else 1.0
		tween.tween_property(scrim, "modulate:a", scrim_alpha, transition_duration)
		if current_state == SheetState.HIDDEN:
			tween.chain().tween_callback(func(): visible = false; closed.emit())
		else:
			visible = true
	else:
		sheet_container.position.y = screen_h + target_y
		scrim.modulate.a = 0.0 if current_state == SheetState.HIDDEN else 1.0
		visible = (current_state != SheetState.HIDDEN)

	state_changed.emit(current_state)

func open(target_state: SheetState = SheetState.HALF) -> void:
	visible = true
	set_state(target_state, true)

func close() -> void:
	set_state(SheetState.HIDDEN, true)

func _on_scrim_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		close()
	elif event is InputEventScreenTouch and event.pressed:
		close()

func _on_drag_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drag(event.position.y)
		else:
			_end_drag()
	elif event is InputEventMouseMotion and is_dragging:
		_process_drag(event.relative.y)
	elif event is InputEventScreenTouch:
		if event.pressed:
			_start_drag(event.position.y)
		else:
			_end_drag()
	elif event is InputEventScreenDrag and is_dragging:
		_process_drag(event.relative.y)

func _start_drag(y: float) -> void:
	is_dragging = true
	drag_start_y = y
	if tween and tween.is_running():
		tween.kill()

func _process_drag(rel_y: float) -> void:
	sheet_container.position.y = clampf(sheet_container.position.y + rel_y, get_viewport_rect().size.y * 0.12, get_viewport_rect().size.y)

func _end_drag() -> void:
	is_dragging = false
	var screen_h: float = get_viewport_rect().size.y
	var current_y: float = sheet_container.position.y
	var ratio: float = 1.0 - (current_y / screen_h)

	if ratio < 0.18:
		close()
	elif ratio < 0.40:
		set_state(SheetState.PEEK)
	elif ratio < 0.70:
		set_state(SheetState.HALF)
	else:
		set_state(SheetState.EXPANDED)
