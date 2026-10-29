class_name Player
extends CharacterBody2D

signal defeated(player: Player)

const ATTACK_INPUT_ACTIONS: Array[StringName] = [
	&"punch_1",
	&"kick_1",
	&"punch_2",
	&"kick_2",
	&"special_1"
]
const ATTACK_SLOTS: Array[StringName] = [
	&"light_punch",
	&"light_kick",
	&"heavy_punch",
	&"heavy_kick",
	&"projectile"
]

@export_range(1, 2, 1) var player_id: int = 1

@export var character_name: String = "Fighter"
@export var profile_portrait: Texture2D
@export var speed: float = 61.0
@export var jump_velocity: float = -490.0
@export var gravity_scale: float = 1.0
@export var attack_set: CharacterAttackSet
@export var combat_stats: CharacterCombatStats

@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var opponent: Player = null
var hp: float = 100.0
var sp: float = 0.0
var mp: float = 0.0
var active_attack_id: StringName
var _attack_ready_at: Dictionary = {}
var _is_defeated: bool = false
var _consecutive_hit_count: int = 0
var _last_hit_attack_id: StringName
var _facing_locked: bool = false
var _locked_facing_left: bool = false

func _ready() -> void:
	for sibling in get_parent().get_children():
		if sibling is Player and sibling != self and sibling.player_id != player_id:
			opponent = sibling
			break

	if gravity == 0.0:
		gravity = 980.0
	gravity *= gravity_scale
	if not combat_stats:
		push_error("%s has no combat stats resource assigned." % character_name)
		return
	hp = clampf(combat_stats.starting_hp, 0.0, combat_stats.max_hp)
	sp = clampf(combat_stats.starting_sp, 0.0, combat_stats.max_sp)
	mp = clampf(combat_stats.starting_mp, 0.0, combat_stats.max_mp)
	
	var initial_ball = get_node_or_null("HandMarker/Area2D")
	if initial_ball:
		initial_ball.visible = false
		initial_ball.process_mode = Node.PROCESS_MODE_DISABLED

	var hurtbox = get_node_or_null("HurtBox") as Area2D
	var hitbox = get_node_or_null("HitBox") as Area2D
	if hitbox:
		hitbox.end_attack()
	var hitbox_shape := get_node_or_null("HitBox/CollisionShape2D") as CollisionShape2D
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)

	# Players use separate hitbox and hurtbox layers.
	if player_id == 2:
		if hurtbox:
			hurtbox.collision_layer = 16
			hurtbox.collision_mask = 2
		if hitbox:
			hitbox.collision_layer = 8
			hitbox.collision_mask = 4
	else:
		if hurtbox:
			hurtbox.collision_layer = 4
			hurtbox.collision_mask = 8
		if hitbox:
			hitbox.collision_layer = 2
			hitbox.collision_mask = 16

	state_machine.init(self)

func input_action(action: StringName) -> StringName:
	return StringName("%s_%d" % [action, player_id])

func try_start_attack() -> bool:
	for index in range(ATTACK_INPUT_ACTIONS.size()):
		if not Input.is_action_just_pressed(input_action(ATTACK_INPUT_ACTIONS[index])):
			continue

		if not attack_set:
			push_error("%s has no character attack set assigned." % character_name)
			return true

		start_attack(ATTACK_SLOTS[index])
		return true
	return false

func start_attack(slot: StringName) -> bool:
	var attack_state := state_machine.states.get("attack") as Attack
	if not attack_state:
		push_error("The player state machine has no Attack state.")
		return false
	if not attack_state.setup_attack(slot):
		return false
	if state_machine.current_state != attack_state:
		state_machine.change_state("attack")
	return true

func try_pay_attack_cost(definition: AttackDefinition) -> bool:
	var now := Time.get_ticks_msec() / 1000.0
	var ready_at: float = _attack_ready_at.get(definition.move_id, 0.0)
	if now < ready_at:
		return false

	var available_resource := _get_attack_resource(definition.cost_resource)
	if available_resource < definition.cost:
		return false

	_set_attack_resource(definition.cost_resource, available_resource - definition.cost)
	if definition.cooldown > 0.0:
		_attack_ready_at[definition.move_id] = now + definition.cooldown
	return true

func _get_attack_resource(resource_type: AttackDefinition.CostResource) -> float:
	match resource_type:
		AttackDefinition.CostResource.HP:
			return hp
		AttackDefinition.CostResource.SP:
			return sp
		AttackDefinition.CostResource.MP:
			return mp
		_:
			return INF

func _set_attack_resource(resource_type: AttackDefinition.CostResource, value: float) -> void:
	match resource_type:
		AttackDefinition.CostResource.HP:
			hp = maxf(0.0, value)
			if hp <= 0.0 and not _is_defeated:
				_is_defeated = true
				defeated.emit(self)
		AttackDefinition.CostResource.SP:
			sp = clampf(value, 0.0, combat_stats.max_sp)
		AttackDefinition.CostResource.MP:
			mp = clampf(value, 0.0, combat_stats.max_mp)

func gain_sp_for_landing_hit() -> void:
	if combat_stats:
		sp = minf(combat_stats.max_sp, sp + combat_stats.sp_on_hit_dealt)

func on_character_attack_started(_definition: AttackDefinition) -> void:
	pass

func spawn_character_projectile(_definition: AttackDefinition) -> void:
	pass

func on_character_attack_finished(_definition: AttackDefinition) -> void:
	pass

func begin_attack_dash() -> float:
	_facing_locked = true
	_locked_facing_left = animated_sprite.flip_h
	return -1.0 if _locked_facing_left else 1.0

func end_attack_dash() -> void:
	_facing_locked = false

func _unhandled_input(event: InputEvent) -> void:
	state_machine.handle_input(event)

func take_hit(
	damage: float,
	attack_type: String,
	attacker: Player = null,
	attack_id: StringName = &""
) -> void:
	if _is_defeated or damage <= 0.0:
		return

	var final_damage := damage
	var current_state = state_machine.current_state
	var is_blocking := current_state is Block and attack_type != "special"
	var block_state := state_machine.states.get("block") as Block
	if current_state is Block:
		final_damage = current_state.evaluate_incoming_attack(attack_type, damage, attack_id)
	elif block_state:
		block_state.reset_block_sequence()
	if is_blocking:
		_reset_hit_sequence()

	var actual_damage := minf(hp, maxf(0.0, final_damage))
	hp -= actual_damage
	if actual_damage > 0.0:
		sp = minf(combat_stats.max_sp, sp + combat_stats.sp_on_hit_received)
		if attacker and attacker != self:
			attacker.gain_sp_for_landing_hit()

	if hp <= 0.0:
		_is_defeated = true
		defeated.emit(self)
		return

	if actual_damage <= 0.0:
		return
	if is_blocking:
		return

	if attack_id == _last_hit_attack_id:
		_consecutive_hit_count = 1
	else:
		_consecutive_hit_count += 1
	_last_hit_attack_id = attack_id
	if _consecutive_hit_count >= 4:
		apply_hitstun()

func apply_hitstun() -> void:
	_reset_hit_sequence()
	var hitstun_state := state_machine.states.get("hitstun") as HitStun
	if hitstun_state:
		state_machine.change_state("hitstun")

func freeze_for_match_end() -> void:
	if state_machine.current_state:
		state_machine.current_state.exit()
	velocity = Vector2.ZERO
	animated_sprite.pause()
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_input(false)

func play_loss_animation() -> void:
	if not animated_sprite.sprite_frames.has_animation(&"loss"):
		push_error("%s has no loss animation configured." % character_name)
		return
	animated_sprite.sprite_frames.set_animation_loop(&"loss", false)
	animated_sprite.play(&"loss")

func _reset_hit_sequence() -> void:
	_consecutive_hit_count = 0
	_last_hit_attack_id = &""

func _process(delta: float) -> void:
	if combat_stats:
		mp = minf(combat_stats.max_mp, mp + combat_stats.mp_regen_per_second * delta)
	state_machine.update(delta)

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)

	var facing_left := animated_sprite.flip_h
	if _facing_locked:
		facing_left = _locked_facing_left
	elif opponent:
		facing_left = opponent.global_position.x < global_position.x
	elif velocity.x != 0:
		facing_left = velocity.x < 0

	animated_sprite.flip_h = facing_left
	var hand_marker = get_node_or_null("HandMarker") as Node2D
	if hand_marker:
		hand_marker.position.x = -abs(hand_marker.position.x) if facing_left else abs(hand_marker.position.x)
