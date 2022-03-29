extends KinematicBody2D

const GRAVITY = 1000.0
const WALK_SPEED = 10
const JUMP_SPEED = -500

var velocity = Vector2()
var acceleration = Vector2()
var jumping = false
var walljumping = false
var jump_key = "ui_accept"
var entity_mass = 1
onready var max_health = self.get_node("../").health() setget ,get_max_health
onready var damage_output = self.get_node("../").damage() setget ,get_damage_output
onready var global_pos = (self.get_parent().position+position)
onready var physics_enabled = (self.get_parent().is_physics_enabled())
export var has_healthbar_  = true setget ,has_healthbar
export var is_affected_by_forces_ = true setget ,is_affected_by_forces
var health setget ,get_health
var damage_ready = false

onready var platform_detector = $PlatformDetector
onready var platform_detector2 = $PlatformDetector2
onready var left_wall_detected = $LeftWall
onready var right_wall_detected = $RightWall

onready var player = get_node("/root/Node2D/player")
onready var event_handler = get_node("../../../EventHandler")
onready var player_melee = get_node("/root/Node2D/player/Melee")
onready var player_melee_ray = get_node("/root/Node2D/player/Melee/Node2D/MeleeRay")
onready var movegen = get_node("../MovementGenerator")

onready var enemylist = get_node("../../../EnemyInstances")
onready var grandparent = get_parent().get_parent()
onready var active_en =  get_node("../../../Enemies") 


func _ready():
#	if grandparent == active_en:
#		#print("Adding Enemy: " + self.name + " to list")
#		enemylist.add_child(get_parent())
#	elif grandparent == enemylist:
#		physics_enabled = false
#		position.y += 900000
#		awake = false
	health = max_health
	
	
## Getters 

func alter_pos():
	position.y -=900000
	physics_enabled = true
	awake = true

	
## Getters 

func is_affected_by_forces():
	return is_affected_by_forces_

func has_healthbar():
	return has_healthbar_

func get_max_health():
	return max_health 


func get_health():
	return health

func get_damage_output():
	return self.get_node("../").damage()
	
	
var awake = false
func wakeup():
	awake = true

func player_attraction(delta):
	### Sum of attractive forces acting upon the player character
	var sum = Vector2(0,0)
	#var grav_forc =Vector2(0,(-GRAVITY*delta if is_on_floor() else 0)) ## Could be problematic
	sum = grav_pulse() #grav_forc + grav_pulse()
	if sum:
		pass
	return sum



func grav_pulse():
	var gp_force = Vector2(0,0)
	var angle = global_pos.angle_to_point(player.position)
	var pulse_distance = global_pos.distance_to(player.position)
	
	if player.grav_pulsing():
		health -= 5/(pow(1+round(pulse_distance/96),2))
		gp_force += 500*Vector2(-cos(angle), -sin(angle)) +2000*Vector2(
			-cos(angle)/(pow(2+round(pulse_distance/48),2)), 
			-sin(angle)/(pow(2+round(pulse_distance/48),2))
			)
		
		#print(self, "\ngp_force:", gp_force, "\nangle: ", angle, "\npulse_distance: ", pulse_distance,"\n")
	
	if player.grav_repulsing():
		gp_force -= 2500*Vector2(
			-cos(angle)/(pow(2+round(pulse_distance/96),2)), 
			-sin(angle)/(pow(2+round(pulse_distance/96),2))
			)
			
	return gp_force

func player_impulse(delta):
	### Sum of impulsive forces acting upon the player character
	var total = Vector2()
	total += melee_impulse(delta)
	
	return total
	
var is_dying = false
var death_counter = 1
func die():
	scale = Vector2(1,1) / death_counter
	death_counter +=.3
	if death_counter > 5:
		grandparent.remove_child(get_parent())
		if (event_handler.enemy_count()==0):
			event_handler.enemies_defeated()
	
	
	
var damage_cooldown = .25
func melee_impulse(delta):
	#Player's melee attack 
	damage_cooldown -= delta if damage_cooldown>=0 else 0
	if player_melee.is_striking():
		if player_melee_ray.get_collider()==self and damage_cooldown<=0: 
			health -= player.get_damage()
			damage_cooldown = .25
			if health<0:
				is_dying=true
			return ((player.velocity * 0) 
			+ Vector2(1000,0).rotated(player_melee.rotation-PI)
			+ (Vector2(0,-50) if (player_melee.rotation==PI or player_melee.rotation==0) else Vector2(0,0))
			/ entity_mass)
		else:
			return Vector2(0,0)
	else:
		return Vector2(0,0)
		
		
func player_friction():
	### Sum of fricticious forces acting upon the player character
	
	var surface_friction = Vector2(1,1)
	var air_friction = Vector2(1,1)
	
	if (platform_detector.is_colliding() or platform_detector2.is_colliding()) or is_on_floor():
		surface_friction.x *= .8 + (.1 if player.grav_pulsing() else 0) #* surface friction
	else:
		air_friction.x *= .8
		air_friction.y *= .8
		
	if is_on_wall():
		surface_friction.y *= .9
		
		
	return surface_friction * air_friction
	
func latent_forces(delta):
	var lat_forc = Vector2(0,0)
	lat_forc.y += GRAVITY*delta
	## Attraction
	lat_forc += player_attraction(delta)
	## Impact
	lat_forc += player_impulse(delta)
	
	return lat_forc
	
var _enemy_jumping = false
onready var move_speed = get_parent().get_speed()

var time = 0
var time_2 = 0
func movement_generator(delta):
	var on_right = ((not platform_detector.is_colliding()) and platform_detector2.is_colliding())
	var on_left  = ((not platform_detector2.is_colliding()) and platform_detector.is_colliding())
	on_right = on_right or right_wall_detected.is_colliding()
	on_left = on_left or left_wall_detected.is_colliding()
	var angle = global_pos.angle_to_point(player.position)
	var pulse_distance = global_pos.distance_to(player.position)
	
	if time_2 >3:
		velocity += 300*Vector2(-cos(angle), -sin(angle)) 
		if time_2>3.15:
			time_2 = 0
	time_2 += delta
	## New Approach : Copy whole script but change movegen func for each enemy 
	time += delta
	if physics_enabled:
		velocity.y -= GRAVITY*delta
		velocity.y += 30*sin(time*10)
	
	velocity += 2500*Vector2(
			-cos(angle)/(pow(10+round(pulse_distance/96),2)), 
			-sin(angle)/(pow(10+round(pulse_distance/96),2))
			)
		
		
#	

	return Vector2(0,0)
	
	
func horizontal_movement(key_input):
	var horiz_vel = Vector2()
	var speed = 20 if Input.is_action_pressed("ui_control") else 70
	var limit = 100 if Input.is_action_pressed("ui_control") else 600
	if (abs(velocity.x)<limit):
		horiz_vel.x += key_input.x * speed
	
	return horiz_vel
	
	
	

## Rebuild Jump FSM but set velocity.y = 0 when on ground
enum Jump_state {FALLING, GROUND, JUMP1, WALLJUMP}
var _jump_state : int = Jump_state.FALLING
var _jump_counter = 0
var _walljump = true

func jump_fsm(key_input, delta):
	## State Transition Variables
	var N_jumps = 5
	var a = is_on_floor()
	var b = _enemy_jumping#
	var c = is_on_wall()
	var d = left_wall_detected.is_colliding()
	var e = is_on_ceiling()
	var jump_vel = 0
	var side_vel = 0
	
	match _jump_state:
		Jump_state.FALLING:
			_jump_counter = N_jumps
			jump_vel = 0
			if e:
				_jump_state = Jump_state.FALLING
				jump_vel = -velocity.y
			elif a:
				_jump_state = Jump_state.GROUND
				jump_vel = -1 * velocity.y
			elif c and b and _walljump:
				jump_vel = -500
				side_vel = 1000 if d else -1000
				_walljump = false
			
		Jump_state.GROUND:
			_jump_counter = 0
			if velocity.y > 0 :
				velocity.y = 0 
			_walljump = true
			if e:
				_jump_state = Jump_state.FALLING
			elif b:
				_jump_state = Jump_state.JUMP1
			elif not a:
				_jump_state = Jump_state.FALLING
			
		Jump_state.JUMP1:
			_jump_counter += 1
			jump_vel = -100
			if e:
				_jump_state = Jump_state.FALLING
				jump_vel = -velocity.y
			elif _jump_counter==N_jumps:
				_jump_state = Jump_state.FALLING
			elif a:
				_jump_state = Jump_state.GROUND
			elif b:
				_jump_counter+=1
			else:
				_jump_state = Jump_state.FALLING
				
	return Vector2(side_vel, jump_vel)
	


func _physics_process(delta):
	if awake:
		global_pos = self.global_position #(self.get_parent().position+position)
		### Latent Forces 
		if not is_dying and physics_enabled:
			velocity +=  latent_forces(delta)
		### Input
		
		## Walking
		var key_input = movement_generator(delta)
		velocity += horizontal_movement(key_input)
		## Jumping
		velocity += jump_fsm(key_input, delta)
		
		#velocity += dash(delta)
		velocity *= player_friction()
		if is_on_ceiling():
			velocity.y = GRAVITY*delta
		
		move_and_slide(velocity, Vector2(0, -1))
		if is_dying:
			die()
