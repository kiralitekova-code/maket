@tool
extends Node

# ==============================================================================
# KAPITALIA Mobile — Godot 4 Theme Generator (build_theme.gd)
# Generates a production-ready Godot 4 Theme resource from DESIGN.mobile.md
# Run as @tool in Editor or attach to scene to export / apply kapitalia_theme.tres
# ==============================================================================

const FONT_REGULAR_PATH := "res://assets/fonts/Inter-Regular.ttf"
const FONT_MEDIUM_PATH  := "res://assets/fonts/Inter-Medium.ttf"
const FONT_BOLD_PATH    := "res://assets/fonts/Inter-SemiBold.ttf"
const FONT_MONO_PATH    := "res://assets/fonts/IBMPlexMono-Medium.ttf"

# --- KAPITALIA Palette Tokens ---
const COLOR_SURFACE            := Color("#151A21")
const COLOR_SURFACE_DIM        := Color("#111319")
const COLOR_SURFACE_BRIGHT     := Color("#36393f")
const COLOR_SURFACE_LOWEST     := Color("#0b0e13")
const COLOR_SURFACE_LOW        := Color("#191c21")
const COLOR_SURFACE_HIGH       := Color("#262a32")
const COLOR_SURFACE_HIGHEST    := Color("#31353e")

const COLOR_TEXT_PRIMARY       := Color("#E2E8F0")
const COLOR_TEXT_SECONDARY     := Color("#94A3B8")
const COLOR_TEXT_MUTED         := Color("#64748B")

const COLOR_PRIMARY_AMBER      := Color("#F2A93B")
const COLOR_PRIMARY_CONTAINER  := Color("#F6B543")
const COLOR_ON_PRIMARY         := Color("#1A1204")

const COLOR_TEAL_BUY           := Color("#2DD4BF")
const COLOR_RED_SELL           := Color("#F87171")
const COLOR_BORDER             := Color("#232936")
const COLOR_BORDER_SUBTLE      := Color("#1c222d")

func _ready() -> void:
    if Engine.is_editor_hint():
        var theme := generate_kapitalia_theme()
        var save_err := ResourceSaver.save(theme, "res://themes/kapitalia_theme.tres")
        if save_err == OK:
            print("✅ KAPITALIA Mobile Godot 4 Theme successfully generated at res://themes/kapitalia_theme.tres")
        else:
            push_warning("Could not auto-save theme, status code: %d" % save_err)

static func generate_kapitalia_theme() -> Theme:
    var theme := Theme.new()

    # 1. Base fonts & fallbacks
    var font_regular : Font = _load_or_fallback_font(FONT_REGULAR_PATH)
    var font_bold : Font = _load_or_fallback_font(FONT_BOLD_PATH)

    theme.default_font = font_regular
    theme.default_font_size = 14

    # 2. Button styling
    _setup_buttons(theme, font_bold)

    # 3. PanelContainer & Cards
    _setup_panels(theme)

    # 4. TabBar & TabContainer
    _setup_tabs(theme, font_bold)

    # 5. LineEdit & Keypad input
    _setup_inputs(theme)

    # 6. ScrollBars & Sliders
    _setup_sliders_and_scrollbars(theme)

    # 7. Labels
    _setup_labels(theme)

    return theme

static func _setup_buttons(theme: Theme, font_bold: Font) -> void:
    # Primary Button (Amber Action 48px touch target)
    var btn_normal := StyleBoxFlat.new()
    btn_normal.bg_color = COLOR_PRIMARY_AMBER
    btn_normal.set_corner_radius_all(10)
    btn_normal.content_margin_top = 14
    btn_normal.content_margin_bottom = 14
    btn_normal.content_margin_left = 16
    btn_normal.content_margin_right = 16

    var btn_pressed := btn_normal.duplicate() as StyleBoxFlat
    btn_pressed.bg_color = COLOR_PRIMARY_AMBER.darkened(0.15)

    var btn_hover := btn_normal.duplicate() as StyleBoxFlat
    btn_hover.bg_color = COLOR_PRIMARY_CONTAINER

    var btn_disabled := btn_normal.duplicate() as StyleBoxFlat
    btn_disabled.bg_color = COLOR_SURFACE_HIGH
    
    theme.set_stylebox("normal", "Button", btn_normal)
    theme.set_stylebox("pressed", "Button", btn_pressed)
    theme.set_stylebox("hover", "Button", btn_hover)
    theme.set_stylebox("disabled", "Button", btn_disabled)
    theme.set_color("font_color", "Button", COLOR_ON_PRIMARY)
    theme.set_color("font_pressed_color", "Button", COLOR_ON_PRIMARY)
    theme.set_color("font_hover_color", "Button", COLOR_ON_PRIMARY)
    theme.set_color("font_disabled_color", "Button", COLOR_TEXT_MUTED)
    theme.set_font("font", "Button", font_bold)
    theme.set_font_size("font_size", "Button", 15)

    # Secondary Ghost / Card Button
    var btn_secondary_normal := StyleBoxFlat.new()
    btn_secondary_normal.bg_color = COLOR_SURFACE_HIGH
    btn_secondary_normal.border_color = COLOR_BORDER
    btn_secondary_normal.set_border_width_all(1)
    btn_secondary_normal.set_corner_radius_all(8)
    btn_secondary_normal.content_margin_top = 10
    btn_secondary_normal.content_margin_bottom = 10
    btn_secondary_normal.content_margin_left = 14
    btn_secondary_normal.content_margin_right = 14

    var btn_secondary_pressed := btn_secondary_normal.duplicate() as StyleBoxFlat
    btn_secondary_pressed.bg_color = COLOR_SURFACE_HIGHEST

    theme.set_stylebox("normal", "ButtonSecondary", btn_secondary_normal)
    theme.set_stylebox("pressed", "ButtonSecondary", btn_secondary_pressed)
    theme.set_color("font_color", "ButtonSecondary", COLOR_TEXT_PRIMARY)

    # Trade Action Buttons (Teal Buy & Red Sell)
    var btn_buy := btn_normal.duplicate() as StyleBoxFlat
    btn_buy.bg_color = COLOR_TEAL_BUY
    theme.set_stylebox("normal", "ButtonBuy", btn_buy)
    theme.set_color("font_color", "ButtonBuy", Color("#06201B"))

    var btn_sell := btn_normal.duplicate() as StyleBoxFlat
    btn_sell.bg_color = COLOR_RED_SELL
    theme.set_stylebox("normal", "ButtonSell", btn_sell)
    theme.set_color("font_color", "ButtonSell", Color("#260808"))

static func _setup_panels(theme: Theme) -> void:
    # Card / Container Panel
    var card_box := StyleBoxFlat.new()
    card_box.bg_color = COLOR_SURFACE_DIM
    card_box.border_color = COLOR_BORDER
    card_box.set_border_width_all(1)
    card_box.set_corner_radius_all(12)
    card_box.content_margin_left = 14
    card_box.content_margin_right = 14
    card_box.content_margin_top = 12
    card_box.content_margin_bottom = 12

    theme.set_stylebox("panel", "PanelContainer", card_box)

    # BottomSheet Modal Panel
    var sheet_box := StyleBoxFlat.new()
    sheet_box.bg_color = COLOR_SURFACE
    sheet_box.border_color = COLOR_BORDER
    sheet_box.border_width_top = 1
    sheet_box.corner_radius_top_left = 18
    sheet_box.corner_radius_top_right = 18
    sheet_box.content_margin_left = 16
    sheet_box.content_margin_right = 16
    sheet_box.content_margin_top = 12
    sheet_box.content_margin_bottom = 24

    theme.set_stylebox("panel", "BottomSheetPanel", sheet_box)

static func _setup_tabs(theme: Theme, font_bold: Font) -> void:
    var tab_unselected := StyleBoxFlat.new()
    tab_unselected.bg_color = Color(0, 0, 0, 0)
    tab_unselected.content_margin_left = 12
    tab_unselected.content_margin_right = 12
    tab_unselected.content_margin_top = 8
    tab_unselected.content_margin_bottom = 8

    var tab_selected := StyleBoxFlat.new()
    tab_selected.bg_color = COLOR_SURFACE_HIGH
    tab_selected.border_color = COLOR_PRIMARY_AMBER
    tab_selected.border_width_bottom = 2
    tab_selected.set_corner_radius_all(6)
    tab_selected.content_margin_left = 12
    tab_selected.content_margin_right = 12
    tab_selected.content_margin_top = 8
    tab_selected.content_margin_bottom = 8

    theme.set_stylebox("tab_unselected", "TabBar", tab_unselected)
    theme.set_stylebox("tab_selected", "TabBar", tab_selected)
    theme.set_color("font_selected_color", "TabBar", COLOR_PRIMARY_AMBER)
    theme.set_color("font_unselected_color", "TabBar", COLOR_TEXT_SECONDARY)
    theme.set_font("font", "TabBar", font_bold)

static func _setup_inputs(theme: Theme) -> void:
    var input_box := StyleBoxFlat.new()
    input_box.bg_color = COLOR_SURFACE_LOWEST
    input_box.border_color = COLOR_BORDER
    input_box.set_border_width_all(1)
    input_box.set_corner_radius_all(8)
    input_box.content_margin_left = 14
    input_box.content_margin_right = 14
    input_box.content_margin_top = 12
    input_box.content_margin_bottom = 12

    var input_box_focus := input_box.duplicate() as StyleBoxFlat
    input_box_focus.border_color = COLOR_PRIMARY_AMBER

    theme.set_stylebox("normal", "LineEdit", input_box)
    theme.set_stylebox("focus", "LineEdit", input_box_focus)
    theme.set_color("font_color", "LineEdit", COLOR_TEXT_PRIMARY)
    theme.set_color("font_placeholder_color", "LineEdit", COLOR_TEXT_MUTED)

static func _setup_sliders_and_scrollbars(theme: Theme) -> void:
    var grabber := StyleBoxFlat.new()
    grabber.bg_color = COLOR_PRIMARY_AMBER
    grabber.set_corner_radius_all(10)

    var slider_line := StyleBoxFlat.new()
    slider_line.bg_color = COLOR_SURFACE_HIGHEST
    slider_line.set_corner_radius_all(3)
    slider_line.content_margin_top = 4
    slider_line.content_margin_bottom = 4

    theme.set_stylebox("slider", "HSlider", slider_line)
    theme.set_stylebox("grabber_area", "HSlider", grabber)

static func _setup_labels(theme: Theme) -> void:
    theme.set_color("font_color", "Label", COLOR_TEXT_PRIMARY)

static func _load_or_fallback_font(path: String) -> Font:
    # Если путь не существует или файл пустой (0-байтовый плейсхолдер)
    if not ResourceLoader.exists(path):
        return _get_safe_fallback_font()
    
    var font: Font = load(path) as Font
    if not font:
        return _get_safe_fallback_font()
    
    # Проверка: 0-байтовый файл (плейсхолдер без данных)
    if font.get_data().size() == 0:
        return _get_safe_fallback_font()
    
    return font


static func _get_safe_fallback_font() -> Font:
    # ThemeDB.fallback_font может быть null в рантайме
    var fallback: Font = ThemeDB.fallback_font
    if not fallback:
        var bf := FontFile.new()
        push_warning("⚠ Шрифт не найден, используется пустой FontFile. Добавьте реальные .ttf в assets/fonts/")
        return bf
    return fallback
