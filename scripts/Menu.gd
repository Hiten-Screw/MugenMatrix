extends Control

enum Screen {
	TITLE,
	SELECT
}

const GAME_SCENE_PATH := "res://scenes/game.tscn"
const TITLE_MUSIC := preload("res://assets/ui/mugen/music/title.mp3")
const SELECT_MUSIC := preload("res://assets/ui/mugen/music/select.mp3")
const PLAYER_COLORS := [Color(1.0, 0.83, 0.1), Color(0.1, 0.91, 0.9)]
const CHARACTER_NAMES: Array[String] = ["GOKU", "SABER"]
const CHARACTER_PORTRAITS: Array[Texture2D] = [
	preload("res://assets/characters/goku/char/prof.jpeg"),
	preload("res://assets/characters/saber/char/prof.png")
]
const READY_ACTIONS: Array[StringName] = [
	&"punch_1",
	&"kick_1",
	&"punch_2",
	&"kick_2",
	&"special_1"
]

@onready var _title_layer: Control = $TitleLayer
@onready var _select_layer: Control = $CharacterSelect
@onready var _battle_button: Button = $TitleLayer/MenuButtons/BattleButton
@onready var _select_heading: AnimatedSprite2D = $CharacterSelect/SelectHeading
@onready var _ready_statuses: Array[Label] = [
	$CharacterSelect/PlayerOneCard/ReadyStatus,
	$CharacterSelect/PlayerTwoCard/ReadyStatus
]
@onready var _character_portraits: Array[TextureRect] = [
	$CharacterSelect/PlayerOneCard/Portrait,
	$CharacterSelect/PlayerTwoCard/Portrait
]
@onready var _character_names: Array[Label] = [
	$CharacterSelect/PlayerOneCard/CharacterName,
	$CharacterSelect/PlayerTwoCard/CharacterName
]

var _screen: Screen = Screen.TITLE
var _player_ready: Array[bool] = [false, false]
var _selected_character_indices: Array[int] = [0, 0]
var _music_player: AudioStreamPlayer

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	_select_layer.hide()
	_battle_button.grab_focus()
	_play_music(TITLE_MUSIC, false)

func _exit_tree() -> void:
	if is_instance_valid(_music_player):
		_music_player.stop()
		_music_player.stream = null

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return

	if _screen == Screen.TITLE:
		get_tree().quit()
	else:
		_show_title_screen()
	get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if _screen != Screen.SELECT:
		return

	for player_index in range(2):
		if _player_ready[player_index]:
			continue
		var selection_direction := _player_selection_direction(player_index + 1)
		if selection_direction != 0:
			_selected_character_indices[player_index] = posmod(
				_selected_character_indices[player_index] + selection_direction,
				CHARACTER_NAMES.size()
			)
			_update_character_card(player_index)
		if not _player_pressed_ready_action(player_index + 1):
			continue

		_player_ready[player_index] = true
		_ready_statuses[player_index].text = "READY"
		_ready_statuses[player_index].add_theme_color_override("font_color", PLAYER_COLORS[player_index])

	if _player_ready[0] and _player_ready[1]:
		_start_battle()

func _on_battle_pressed() -> void:
	_screen = Screen.SELECT
	_title_layer.hide()
	_select_layer.show()
	_player_ready = [false, false]
	_selected_character_indices = [0, 0]
	_update_character_card(0)
	_update_character_card(1)
	_select_heading.play("default")
	_select_heading.frame = 0
	_reset_ready_status()
	_play_music(SELECT_MUSIC, true)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _show_title_screen() -> void:
	_screen = Screen.TITLE
	_select_layer.hide()
	_title_layer.show()
	_player_ready = [false, false]
	_selected_character_indices = [0, 0]
	_update_character_card(0)
	_update_character_card(1)
	_reset_ready_status()
	_battle_button.grab_focus()
	_play_music(TITLE_MUSIC, false)

func _reset_ready_status() -> void:
	_ready_statuses[0].text = "PRESS ANY ATTACK KEY TO READY"
	_ready_statuses[1].text = "PRESS ANY ATTACK KEY TO READY"
	for status in _ready_statuses:
		status.add_theme_color_override("font_color", Color(0.6, 0.68, 0.78))

func _player_selection_direction(player_id: int) -> int:
	if Input.is_action_just_pressed("move_left_%d" % player_id):
		return -1
	if Input.is_action_just_pressed("move_right_%d" % player_id):
		return 1
	return 0

func _update_character_card(player_index: int) -> void:
	var character_index := _selected_character_indices[player_index]
	_character_portraits[player_index].texture = CHARACTER_PORTRAITS[character_index]
	_character_names[player_index].text = CHARACTER_NAMES[character_index]

func _player_pressed_ready_action(player_id: int) -> bool:
	for action in READY_ACTIONS:
		if Input.is_action_just_pressed(StringName("%s_%d" % [action, player_id])):
			return true
	return false

func _start_battle() -> void:
	MatchSetup.player_one_scene_path = _character_scene_path(_selected_character_indices[0])
	MatchSetup.player_two_scene_path = _character_scene_path(_selected_character_indices[1])
	var error := get_tree().change_scene_to_file(GAME_SCENE_PATH)
	if error != OK:
		push_error("Could not load the battle scene: %s" % error_string(error))

func _character_scene_path(character_index: int) -> String:
	match character_index:
		0:
			return "res://scenes/goku.tscn"
		1:
			return "res://scenes/saber.tscn"
		_:
			push_error("Invalid character selection index: %d" % character_index)
			return ""

func _play_music(stream: AudioStream, should_loop: bool) -> void:
	if stream is AudioStreamMP3:
		stream.loop = should_loop
	_music_player.stream = stream
	_music_player.play()
