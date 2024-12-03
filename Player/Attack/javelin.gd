extends Area2D

#Attack details
var level = 1
var hp = 9999
var speed = 200.0
var damage = 10
var knockback_amount = 100
var paths = 1
var attack_size = 1.0
var attack_speed = 4.0

#Target
var target = Vector2.ZERO
var target_array = []

#Position
var angle = Vector2.ZERO
var reset_pos = Vector2.ZERO

#Sprite
var spr_jav_reg = preload("res://Textures/Items/Weapons/javelin_3_new.png")
var spr_jav_atk = preload("res://Textures/Items/Weapons/javelin_3_new_attack.png")

#Onready variables
@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var attackTimer = get_node("%AttackTimer")
@onready var changeDirectionTimer = get_node("%ChangeDirection")
@onready var resetPosTimer = get_node("%ResetPosTimer")
@onready var soundAttack = $snd_attack

#Signal
signal remove_from_array(object)

#Ready function to update javelin
func _ready():
	update_javelin()
	
#Update javelin function
func update_javelin():
	level = player.javelin_level
	
	match level:
		1:
			hp = 9999
			speed = 200.0
			damage = 10
			knockback_amount = 100
			paths = 1
			attack_size = 1.0
			attack_speed = 4.0
			
	scale = Vector2(1.0, 1.0) * attack_size
	attackTimer.wait_time = attack_speed
	
func _physics_process(delta):
	if target_array.size() > 0:
		position += angle * speed * delta
		
func add_paths():
	soundAttack.play()
	emit_signal("remove_from_array", self)
	target_array.clear()
	
	var counter = 0
	
	while counter < paths:
		var new_path = player.get_random_target()
		
		target_array.append(new_path)
		counter += 1
	
	target = target_array[0]
	process_path()
	
func process_path():
	angle = global_position.direction_to(target)
	changeDirectionTimer.start()

func _on_attack_timer_timeout():
	add_paths()
