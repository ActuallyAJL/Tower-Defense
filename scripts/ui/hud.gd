extends CanvasLayer
class_name HUD

## HUD: top bar (lives / wave / gold), bottom tower shop, game-over/win overlay.
## The tower shop is built dynamically from RunSeed.tower_roster each run.

## Index into RunSeed.tower_roster of the currently selected tower; -1 = none.
var selected_index: int = -1

signal start_wave_pressed
signal tower_selected(index: int)

const PANEL_BG   := Color(0.05, 0.05, 0.08, 0.88)
const TEXT_WHITE := Color(1.0, 1.0, 1.0, 1.0)
const TEXT_GOLD  := Color(1.0, 0.82, 0.20, 1.0)
const TEXT_RED   := Color(1.0, 0.28, 0.28, 1.0)
const SEL_BORDER := Color(1.0, 0.90, 0.20, 1.0)
const DIM_ALPHA  := 0.45

# Minimum button width; shrinks if the roster is large.
const BTN_MIN_W  : int = 100
const BTN_HEIGHT : int = 70

var _lives_label : Label
var _wave_label  : Label
var _gold_label  : Label
var _start_btn   : Button
var _shop_btns   : Array[Button] = []
var _overlay     : Panel
var _overlay_lbl : Label


func _ready() -> void:
	layer = 1
	_build_top_bar()
	_build_bottom_bar()
	_build_overlay()
	_connect_game_state()
	_refresh_labels()


# ---------------------------------------------------------------------------
# Layout builders
# ---------------------------------------------------------------------------

func _build_top_bar() -> void:
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	panel.custom_minimum_size = Vector2(0, 52)
	_style_panel(panel)
	add_child(panel)

	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 0)
	panel.add_child(hbox)

	_lives_label = _make_label("♥ 20", TEXT_RED, 20)
	_lives_label.custom_minimum_size = Vector2(180, 0)
	_lives_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	hbox.add_child(_lives_label)

	_wave_label = _make_label("Wave 0 / ?", TEXT_WHITE, 20)
	_wave_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(_wave_label)

	_gold_label = _make_label("⬡ 150g", TEXT_GOLD, 20)
	_gold_label.custom_minimum_size = Vector2(180, 0)
	_gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hbox.add_child(_gold_label)


func _build_bottom_bar() -> void:
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.custom_minimum_size = Vector2(0, 88)
	_style_panel(panel)
	add_child(panel)

	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 4)
	panel.add_child(hbox)

	# Dynamically build one button per tower in the run's roster.
	var roster: Array[TowerData] = RunSeed.tower_roster
	for i: int in roster.size():
		var td: TowerData = roster[i]
		var btn := Button.new()
		btn.text = "%s\n$%d" % [td.tower_name, td.cost]
		btn.custom_minimum_size = Vector2(BTN_MIN_W, BTN_HEIGHT)
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		# Color the button text to match the element.
		if td.element != null:
			btn.add_theme_color_override("font_color", td.element.color.lightened(0.25))

		var idx := i
		btn.pressed.connect(func(): _on_shop_btn(idx))
		hbox.add_child(btn)
		_shop_btns.append(btn)

	# Spacer pushes Start Wave button to the right.
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	# Start Wave button
	_start_btn = Button.new()
	_start_btn.text = "▶  Start Wave"
	_start_btn.custom_minimum_size = Vector2(160, BTN_HEIGHT)
	_start_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_start_btn.pressed.connect(_on_start_wave)
	hbox.add_child(_start_btn)


func _build_overlay() -> void:
	_overlay = Panel.new()
	_overlay.set_anchors_preset(Control.PRESET_CENTER)
	_overlay.custom_minimum_size = Vector2(400, 200)
	_overlay.offset_left   = -200
	_overlay.offset_top    = -100
	_overlay.offset_right  =  200
	_overlay.offset_bottom =  100
	_style_panel(_overlay)
	_overlay.visible = false
	add_child(_overlay)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	_overlay.add_child(vbox)

	_overlay_lbl = _make_label("", TEXT_WHITE, 28)
	_overlay_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_overlay_lbl)

	var restart := Button.new()
	restart.text = "Restart"
	restart.custom_minimum_size = Vector2(140, 48)
	restart.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	restart.pressed.connect(func(): get_tree().reload_current_scene())
	vbox.add_child(restart)


# ---------------------------------------------------------------------------
# Signal connections
# ---------------------------------------------------------------------------

func _connect_game_state() -> void:
	GameState.lives_changed.connect(_on_lives_changed)
	GameState.gold_changed.connect(_on_gold_changed)
	GameState.wave_changed.connect(_on_wave_changed)
	GameState.game_over.connect(_on_game_over)
	GameState.game_won.connect(_on_game_won)


func _refresh_labels() -> void:
	_on_lives_changed(GameState.lives)
	_on_gold_changed(GameState.gold)
	_on_wave_changed(GameState.wave)


# ---------------------------------------------------------------------------
# Public API used by main.gd
# ---------------------------------------------------------------------------

func on_wave_completed(_wave_num: int) -> void:
	_start_btn.disabled = false


func deselect_tower() -> void:
	selected_index = -1
	_update_shop_visuals()


# ---------------------------------------------------------------------------
# Event handlers
# ---------------------------------------------------------------------------

func _on_shop_btn(index: int) -> void:
	if selected_index == index:
		selected_index = -1   # toggle off
	else:
		selected_index = index
	_update_shop_visuals()
	tower_selected.emit(selected_index)


func _on_start_wave() -> void:
	_start_btn.disabled = true
	start_wave_pressed.emit()


func _on_lives_changed(current: int) -> void:
	_lives_label.text = "♥ %d" % current


func _on_gold_changed(current: int) -> void:
	_gold_label.text = "⬡ %dg" % current
	_update_shop_visuals()


func _on_wave_changed(current: int) -> void:
	_wave_label.text = "Wave %d / %d" % [current, RunSeed.waves.size()]


func _on_game_over() -> void:
	_overlay_lbl.text = "GAME OVER"
	_overlay_lbl.add_theme_color_override("font_color", TEXT_RED)
	_overlay.visible = true
	_start_btn.disabled = true


func _on_game_won() -> void:
	_overlay_lbl.text = "YOU WIN!"
	_overlay_lbl.add_theme_color_override("font_color", TEXT_GOLD)
	_overlay.visible = true
	_start_btn.disabled = true


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _update_shop_visuals() -> void:
	var roster: Array[TowerData] = RunSeed.tower_roster
	for i: int in _shop_btns.size():
		var btn    : Button    = _shop_btns[i]
		if i >= roster.size():
			break
		var td     : TowerData = roster[i]
		var can_afford         := GameState.gold >= td.cost
		var is_selected        := selected_index == i
		btn.modulate.a = 1.0 if can_afford else DIM_ALPHA
		if is_selected:
			btn.add_theme_color_override("font_color", SEL_BORDER)
		elif td.element != null:
			btn.add_theme_color_override("font_color", td.element.color.lightened(0.25))
		else:
			btn.remove_theme_color_override("font_color")


func _make_label(txt: String, col: Color, size: int) -> Label:
	var lbl := Label.new()
	lbl.text = txt
	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_constant_override("outline_size", 2)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return lbl


func _style_panel(panel: Panel) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_BG
	panel.add_theme_stylebox_override("panel", style)
