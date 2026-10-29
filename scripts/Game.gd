extends Node2D

const PLAYER_START_DISTANCE: float = 150.0
const GROUND_Y: float = -50.0
const MATCH_DURATION: float = 90.0

var _time_remaining: float = MATCH_DURATION
var _match_over: bool = false
var _is_paused: bool = false
var _players: Array[Player] = []

@onready var _timer_label: Label = $MatchHUD/MatchTimer
@onready var _player_names: Array[Label] = [
	$MatchHUD/Player1Card/CharacterName,
	$MatchHUD/Player2Card/CharacterName
]
@onready var _player_portraits: Array[TextureRect] = [
	$MatchHUD/Player1Card/Portrait,
	$MatchHUD/Player2Card/Portrait
]
@onready var _hp_bars: Array[ProgressBar] = [
	$MatchHUD/Player1Card/HPBar,
	$MatchHUD/Player2Card/HPBar
]
@onready var _sp_bars: Array[ProgressBar] = [
	$MatchHUD/Player1Card/SPBar,
	$MatchHUD/Player2Card/SPBar
]
@onready var _mp_bars: Array[ProgressBar] = [
	$MatchHUD/Player1Card/MPBar,
	$MatchHUD/Player2Card/MPBar
]
@onready var _result_layer: CanvasLayer = $MatchResult
@onready var _result_overlay: ColorRect = $MatchResult/Overlay
@onready var _result_label: Label = $MatchResult/ResultLabel
@onready var _rematch_button: Button = $MatchResult/RematchButton
@onready var _main_menu_button: Button = $MatchResult/MainMenuButton
@onready var _pause_layer: CanvasLayer = $PauseMenu
@onready var _resume_button: Button = $PauseMenu/ResumeButton
@onready var _pause_main_menu_button: Button = $PauseMenu/MainMenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_result_layer.hide()
	_pause_layer.hide()
	_timer_label.text = _format_match_time(MATCH_DURATION)
	_rematch_button.pressed.connect(_on_rematch_pressed)
	_main_menu_button.pressed.connect(_on_main_menu_pressed)
	_resume_button.pressed.connect(_on_resume_pressed)
	_pause_main_menu_button.pressed.connect(_on_pause_main_menu_pressed)

	var player_one_scene := load(MatchSetup.player_one_scene_path) as PackedScene
	var player_two_scene := load(MatchSetup.player_two_scene_path) as PackedScene

	if not player_one_scene or not player_two_scene:
		push_error("Could not load the selected player scenes.")
		return

	var player_one := player_one_scene.instantiate() as Player
	var player_two := player_two_scene.instantiate() as Player
	if not player_one or not player_two:
		push_error("Selected character scenes must have a Player root script.")
		if player_one:
			player_one.free()
		if player_two:
			player_two.free()
		return

	player_one.name = "Player1"
	player_one.player_id = 1
	player_one.process_mode = Node.PROCESS_MODE_PAUSABLE
	player_one.position = Vector2(-PLAYER_START_DISTANCE, GROUND_Y)
	player_two.name = "Player2"
	player_two.player_id = 2
	player_two.process_mode = Node.PROCESS_MODE_PAUSABLE
	player_two.position = Vector2(PLAYER_START_DISTANCE, GROUND_Y)

	add_child(player_one)
	add_child(player_two)
	player_one.opponent = player_two
	player_two.opponent = player_one
	player_one.defeated.connect(_on_player_defeated)
	player_two.defeated.connect(_on_player_defeated)
	_players = [player_one, player_two]
	_setup_match_hud()

func _process(delta: float) -> void:
	if _match_over or _is_paused or _players.size() != 2:
		return

	_time_remaining = maxf(0.0, _time_remaining - delta)
	_timer_label.text = _format_match_time(_time_remaining)
	_update_player_meters()

	if _time_remaining <= 0.0:
		_finish_match(null)

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel") or _match_over:
		return

	if _is_paused:
		_resume_match()
	else:
		_pause_match()
	get_viewport().set_input_as_handled()

func _on_player_defeated(loser: Player) -> void:
	if _match_over:
		return
	_match_over = true
	_is_paused = false
	get_tree().paused = false
	_pause_layer.hide()
	for player in _players:
		player.freeze_for_match_end()
	loser.play_loss_animation()
	_show_match_result_after_loss(loser.opponent, loser)

func _finish_match(winner: Player) -> void:
	if _match_over:
		return
	_match_over = true
	for player in _players:
		player.freeze_for_match_end()

	_show_match_result(winner)

func _show_match_result_after_loss(winner: Player, loser: Player) -> void:
	await get_tree().create_timer(3.0).timeout
	loser.animated_sprite.pause()
	_show_match_result(winner)

func _show_match_result(winner: Player) -> void:
	_result_label.text = "DRAW\nTIME UP" if winner == null else "PLAYER %d WINS\nMATCH OVER" % winner.player_id
	_is_paused = false
	get_tree().paused = false
	_pause_layer.hide()
	_result_overlay.modulate.a = 0.0
	_result_label.modulate.a = 0.0
	_rematch_button.modulate.a = 0.0
	_main_menu_button.modulate.a = 0.0
	_result_layer.show()
	var fade_in := create_tween().set_parallel(true)
	fade_in.tween_property(_result_overlay, "modulate:a", 1.0, 1.5)
	fade_in.tween_property(_result_label, "modulate:a", 1.0, 1.5)
	fade_in.tween_property(_rematch_button, "modulate:a", 1.0, 1.5)
	fade_in.tween_property(_main_menu_button, "modulate:a", 1.0, 1.5)
	fade_in.chain().tween_callback(_rematch_button.grab_focus)

func _pause_match() -> void:
	_is_paused = true
	_pause_layer.show()
	get_tree().paused = true
	_resume_button.grab_focus()

func _resume_match() -> void:
	_is_paused = false
	get_tree().paused = false
	_pause_layer.hide()

func _on_rematch_pressed() -> void:
	var error := get_tree().reload_current_scene()
	if error != OK:
		push_error("Could not start the rematch: %s" % error_string(error))

func _on_main_menu_pressed() -> void:
	_change_to_main_menu()

func _on_resume_pressed() -> void:
	_resume_match()

func _on_pause_main_menu_pressed() -> void:
	_change_to_main_menu()

func _change_to_main_menu() -> void:
	get_tree().paused = false
	var error := get_tree().change_scene_to_file("res://scenes/menu.tscn")
	if error != OK:
		push_error("Could not return to the main menu: %s" % error_string(error))

func _setup_match_hud() -> void:
	for index in range(_players.size()):
		var player := _players[index]
		_player_names[index].text = player.character_name
		_player_portraits[index].texture = player.profile_portrait
		_hp_bars[index].max_value = player.combat_stats.max_hp
		_sp_bars[index].max_value = player.combat_stats.max_sp
		_mp_bars[index].max_value = player.combat_stats.max_mp
	_update_player_meters()

func _update_player_meters() -> void:
	for index in range(_players.size()):
		var player := _players[index]
		var hp_bar := _hp_bars[index]
		hp_bar.value = player.hp
		hp_bar.visible = hp_bar.max_value > 0.0 and player.hp > 0.0

		var sp_bar := _sp_bars[index]
		sp_bar.value = player.sp
		sp_bar.visible = _resource_cost_is(player, AttackDefinition.CostResource.SP) \
			and sp_bar.max_value > 0.0 and player.sp > 0.0

		var mp_bar := _mp_bars[index]
		mp_bar.value = player.mp
		mp_bar.visible = _resource_cost_is(player, AttackDefinition.CostResource.MP) \
			and mp_bar.max_value > 0.0 and player.mp > 0.0

func _resource_cost_is(player: Player, resource_type: AttackDefinition.CostResource) -> bool:
	return player.attack_set \
		and player.attack_set.projectile \
		and player.attack_set.projectile.cost_resource == resource_type

func _format_match_time(time_remaining: float) -> String:
	var total_seconds := ceili(time_remaining)
	var minutes := floori(float(total_seconds) / 60.0)
	return "%02d:%02d" % [minutes, total_seconds % 60]
