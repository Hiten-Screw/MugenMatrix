extends Control

enum Screen {
	TITLE,
	SELECT
}

const GAME_SCENE_PATH := "res://scenes/game.tscn"
const TITLE_MUSIC := preload("res://assets/ui/mugen/music/title.mp3")
const SELECT_MUSIC := preload("res://assets/ui/mugen/music/select.mp3")
const PLAYER_COLORS := [Color(1.0, 0.83, 0.1), Color(0.1, 0.91, 0.9)]

@onready var _title_layer: Control = $TitleLayer
@onready var _select_layer: Control = $CharacterSelect
@onready var _battle_button: Button = $TitleLayer/MenuButtons/BattleButton
@onready var _select_heading: AnimatedSprite2D = $CharacterSelect/SelectHeading
@onready var _ready_statuses: Array[Label] = [
	$CharacterSelect/PlayerOneCard/ReadyStatus,
	$CharacterSelect/PlayerTwoCard/ReadyStatus
]

var _screen: Screen = Screen.TITLE
var _player_ready: Array[bool] = [false, false]
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
		if not Input.is_action_just_pressed("punch_1_%d" % (player_index + 1)):
			continue

		_player_ready[player_index] = true
		_ready_statuses[player_index].text = "READY!"
		_ready_statuses[player_index].add_theme_color_override("font_color", PLAYER_COLORS[player_index])

	if _player_ready[0] and _player_ready[1]:
		_start_battle()

func _on_battle_pressed() -> void:
	_screen = Screen.SELECT
	_title_layer.hide()
	_select_layer.show()
	_player_ready = [false, false]
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
	_reset_ready_status()
	_battle_button.grab_focus()
	_play_music(TITLE_MUSIC, false)

func _reset_ready_status() -> void:
	_ready_statuses[0].text = "PRESS U TO READY"
	_ready_statuses[1].text = "PRESS 1 TO READY"
	for status in _ready_statuses:
		status.add_theme_color_override("font_color", Color(0.6, 0.68, 0.78))

func _start_battle() -> void:
	var error := get_tree().change_scene_to_file(GAME_SCENE_PATH)
	if error != OK:
		push_error("Could not load the battle scene: %s" % error_string(error))

func _play_music(stream: AudioStream, should_loop: bool) -> void:
	if stream is AudioStreamMP3:
		stream.loop = should_loop
	_music_player.stream = stream
	_music_player.play()
