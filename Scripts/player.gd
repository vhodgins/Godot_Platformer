extends KinematicBody2D

const GRAVITY = 1000.0
const WALK_SPEED = 10
const JUMP_SPEED = -650

var velocity = Vector2()
var acceleration = Vector2()
var jumping = false
var walljumping = false
var jump_key = "jump"

var gp_cooldown = 1
var gp_duration = .1


onready var platform_detector = $PlatformDetector
onready var platform_detector2 = $PlatformDetector2
onready var left_wall_detected = $LeftWall
onready var right_wall_detected = $RightWall
onready var player_stats = get_node("PlayerStats")
onready var healthbar = get_node("PlayerCanvas/Healthbar")


var damage =  0 setget set_damage ,get_damage
var max_health = 1 setget ,get_max_health
export var has_healthbar_  = true setget ,has_healthbar
var health  setget , get_health

var invincible = false setget can_take_damage
var can_grapple = false 
onready var statv = player_stats.stats()
onready var equipv = player_stats.equipped()
onready var inv = player_stats.inventory()
var _respawn_coords = Vector2(0,0)

func _ready():
	max_health = statv["health"]
	health = max_health
	healthbar.adjust_healthbar()
	can_grapple = equipv["grapple"]
	damage = equipv["weapon"][0]




func respawn_coords():
	_respawn_coords = position


func set_damage(arg):
	damage = arg

var total_grapples = 3
var grapple_counter = 0

func update_grapple():
	total_grapples += 1
	grapple_counter = total_grapples
	can_grapple=true
	

### GETTERS 
func has_healthbar():
	return has_healthbar_
	
func can_take_damage(val):
	invincible = not val

var taking_damage = .25
func damage_cooldown(delta):
	if taking_damage >=0:
		taking_damage -= delta

func grav_pulsing():
	return grav_pulse_active
	
func grav_repulsing():
	return grav_repulse_active

func get_max_health():
	return max_health

func get_health():
	return health

func get_damage():
	return damage

### DAMAGE 
func take_damage(dam, angle, room):
	velocity += Vector2(200,0).rotated(angle)*(.75+abs(cos(angle)))*.5 + Vector2(0,50).rotated(angle)*cos(angle)
	if (taking_damage <=0):
		health -= dam if not invincible else 0
		taking_damage = .25 if not invincible else 0.0
	if health<=0:
		get_tree().reload_current_scene()
#		get_node("../Levels").reload(room)
#		health = max_health
#		velocity = Vector2(0,0)
#		position = _respawn_coords
		

### Forces on player
## Attractive forces on the player
func player_attraction(delta):
	### Sum of attractive forces acting upon the player character
	var grav_forc = -GRAVITY*delta if is_on_floor() else 0
	return Vector2(0,grav_forc)

## Impulsive forces on the player (knockback)
func player_impulse(delta):
	### Sum of impulsive forces acting upon the player character
	var x_force_sum = 0
	var y_force_sum = 0	
	return Vector2(x_force_sum ,y_force_sum)
	
## Fricticious forces on the player
func player_friction():
	### Sum of fricticious forces acting upon the player character
	
	var surface_friction = Vector2(1,1)
	var air_friction = Vector2(1,1)
	
	if (platform_detector.is_colliding() or platform_detector2.is_colliding()) or is_on_floor():
		surface_friction.x *= .9 #* surface friction
	else:
		air_friction.x *= .95
		air_friction.y *= .99
		
	if is_on_wall() and _jump_state==Jump_state.FALLING:
		surface_friction.y *= .9

	return surface_friction * air_friction
	
## Sum of above three forces
func latent_forces(delta):
	var lat_forc = Vector2(0,0)
	lat_forc.y += GRAVITY*delta
	## Attraction
	lat_forc += player_attraction(delta)
	## Impact
	lat_forc += player_impulse(delta)
	
	return lat_forc
	
	
### MOVEMENT
## Function that outputs movement to velocity
func movement_generator():
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	
	return Vector2(int(right)-int(left), int(down)-int(up))
	
## Horizontal velocity limiter
func horizontal_movement(key_input):
	var horiz_vel = Vector2()
	var speed = 10 if Input.is_action_pressed("ui_control") else 70
	var limit = 50 if Input.is_action_pressed("ui_control") else 500
	if (abs(velocity.x)<limit):
		horiz_vel.x += key_input.x * speed
	
	return horiz_vel
	
## Mid-air Dash 
var dashing = false
func dash(delta):
	if (Input.is_action_just_pressed(jump_key) and not dashing) and (time_since_jumped>.1):
		dashing = true
		return velocity + Vector2(200,0).rotated(velocity.angle())
	if is_on_floor() or is_on_wall():
		dashing = false
	return Vector2(0,0)
	

## Jump FSM 
enum Jump_state {FALLING, GROUND, JUMP1, WALLJUMP}
var _jump_state : int = Jump_state.FALLING
var _jump_counter = 0
var _walljump = true
var time_since_jumped = 0
func jump_fsm(key_input, delta):
	## State Transition Variables
	var N_jumps = 5
	var a = platform_detector.is_colliding() or platform_detector2.is_colliding() or is_on_floor()
	var b = Input.is_action_pressed(jump_key) #key_input.y==-1
	var c = is_on_wall()
	var d = left_wall_detected.is_colliding()
	var e = false #is_on_ceiling() 
	var jump_vel = 0
	var side_vel = 0
	
	
	match _jump_state:
		Jump_state.FALLING:
			time_since_jumped += delta
			_jump_counter = N_jumps
			jump_vel = 0
			if e:
				_jump_state = Jump_state.FALLING
				jump_vel = -velocity.y
			elif a:
				_jump_state = Jump_state.GROUND
				jump_vel = -1 * velocity.y
			elif (c and Input.is_action_just_pressed(jump_key)) and _walljump:
				time_since_jumped = 0
				jump_vel = JUMP_SPEED
				side_vel = 1000 if d else -1000
				_walljump = false
			
		Jump_state.GROUND:
			time_since_jumped = 0
			_jump_counter = 0
			_walljump = true
			if e:
				_jump_state = Jump_state.FALLING
			elif b:
				_jump_state = Jump_state.JUMP1
			elif not a:
				_jump_state = Jump_state.FALLING
			
		Jump_state.JUMP1:
			time_since_jumped += delta
			_jump_counter += 1
			jump_vel = JUMP_SPEED/5 #-100
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
	
	
## Grapple Mechanics
onready var grapple_collision = $Grapple
var grappling = false
var grappling_point = Vector2()
enum Grapple_state {AIMING, GRAPPLING}
export var _grapple_state : int = Grapple_state.AIMING setget ,get_grapple_state

## Grapple State Getter
func get_grapple_state():
	return _grapple_state

## Grapple FSM
func grapple():
	var a = Input.is_action_pressed("z")
	var grapple_vector = Vector2(0,0)
	var angle
	var colliding = grapple_collision.is_colliding()
	var b = is_on_ceiling()
	match _grapple_state:
		Grapple_state.AIMING:
			grapple_vector = Vector2(0,0)
			grapple_collision.scale.x = 1
			if is_on_floor():
				grapple_counter=total_grapples
			if (a and colliding) and (grapple_counter>0):
				grappling_point = grapple_collision.get_collision_point()
				_grapple_state = Grapple_state.GRAPPLING
				grapple_counter-=1
				
			
		Grapple_state.GRAPPLING:
			if a:
				angle = position.angle_to_point(grappling_point)
				grapple_collision.rotation = position.angle_to_point(grappling_point)
				grapple_collision.scale.x = position.distance_to(grappling_point)/64
				if grapple_collision.scale.x>6:
					grapple_collision.scale.x=1
					_grapple_state = Grapple_state.AIMING
				grapple_vector = Vector2(-cos(angle), -sin(angle))
				if is_on_floor() and (grapple_collision.scale.x<=2) and sin(grapple_collision.rotation)<-.25:
					grapple_vector = Vector2(0,0)
			else:
				_grapple_state = Grapple_state.AIMING
				
	velocity += grapple_vector * 50


## Gravity Pulse Attack
var grav_pulse_cooldown = gp_cooldown
var grav_pulse_active = false setget ,grav_pulsing
func gravity_pulse(delta):
	grav_pulse_cooldown-=delta if grav_pulse_cooldown>0 else 0
	
	if grav_pulse_cooldown < gp_cooldown-gp_duration:
		grav_pulse_active = false
	
	if grav_pulse_cooldown <= 0:
		if Input.is_action_pressed("a"):
			grav_pulse_active = true
			grav_pulse_cooldown = gp_cooldown
				

var grav_repulse_cooldown = gp_cooldown
var grav_repulse_active = false setget ,grav_repulsing
func gravity_repulse(delta):
	grav_repulse_cooldown-=delta if grav_repulse_cooldown>0 else 0
	
	if grav_repulse_cooldown < gp_cooldown-gp_duration:
		grav_repulse_active = false
	
	if grav_repulse_cooldown <= 0:
		if Input.is_action_pressed("s"):
			grav_repulse_active = true
			grav_repulse_cooldown = gp_cooldown
				


func _physics_process(delta):
	## Damage Handling
	damage_cooldown(delta)
	
	### Latent Forces 
	velocity +=  latent_forces(delta)
	### Input
	
	## Walking
	var key_input = movement_generator()
	velocity += horizontal_movement(key_input)
	## Jumping
	if can_grapple:
		grapple()
	gravity_pulse(delta)
	gravity_repulse(delta)
	velocity += jump_fsm(key_input, delta)
	
	velocity += dash(delta)

	velocity *= player_friction()
	if is_on_ceiling():
		velocity.y = GRAVITY*delta
	move_and_slide(velocity, Vector2(0, -1))
