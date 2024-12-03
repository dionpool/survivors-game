extends CharacterBody2D

#Character variables
var movement_speed = 40.0
var hp = 80
var last_movement = Vector2.UP

#Attack variables
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javelin.tscn")

#Attack nodes onready variables
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%JavelinBase")

#Ice spear variables
var icespear_ammo = 0
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 1 #TODO: Temporarily disabled

#Tornado variables
var tornado_ammo = 0
var tornado_baseammo = 1
var tornado_attackspeed = 3
var tornado_level = 1 #TODO: Temporarily disabled

#Javelin variables
var javelin_ammo = 0
var javelin_level = 1

#Enemy related
var enemy_close = []

#Ready function to start attack
func _ready():
	attack()

#Sprite onready variables
@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

#Physics function to trigger movement
func _physics_process(_delta):
	movement()
	
#Movement function
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	
	if mov.x > 0:
		sprite.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false
		
	if mov != Vector2.ZERO:
		last_movement = mov
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()
	
	velocity = mov.normalized() * movement_speed
	move_and_slide()

#Attack function
func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
	if javelin_level > 0:
		spawn_javelin()

#Hurt function
func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= damage
	print(hp)

#Ice spear timer function
func _on_ice_spear_timer_timeout():
	icespear_ammo += icespear_baseammo
	iceSpearAttackTimer.start()

#Ice spear attack timer function
func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var iceSpear_attack = iceSpear.instantiate()
		
		iceSpear_attack.position = position
		iceSpear_attack.target = get_random_target()
		iceSpear_attack.level = icespear_level
		
		add_child(iceSpear_attack)
		
		icespear_ammo -= 1
		
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()

#Torando timer
func _on_tornado_timer_timeout():
	tornado_ammo += tornado_baseammo
	tornadoAttackTimer.start()

#Tornado attack timer
func _on_tornado_attack_timer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		
		add_child(tornado_attack)
		
		tornado_ammo -= 1
		
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()

#Spawn javelin function
func spawn_javelin():
	var get_javelin_total = javelinBase.get_child_count()
	var calc_spawns = javelin_ammo - get_javelin_total
	
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1

#Pick random target for attacks
func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP

#Detect enemy body entered
func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

#Detect enemy body exited
func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)
