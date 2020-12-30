extends KinematicBody2D

const SPEED = 1000
const UP = Vector2(0,-1)
var direction = Vector2()
var velocity = Vector2(0, 0)
var is_punch = false
var is_left = false	
export var is_controled = true

var player_position = {
	"x": 0,
	"y": 0
}

var player_state = {
	"player_id": "",
	"direction": {
		"x": 0,
		"y": 0
	},
	"velocity" : {
		"x": 0,
		"y": 0
	},
	"is_punch": false
}


onready var animated_sprite = $AnimatedSprite
onready var initialPos = $CollisionShape2D.position
onready var PunchAreaPosition = $PunchArea.position


func _ready():
	pass

func set_velocity(vel):
	velocity = vel

# warning-ignore:unused_argument
func _physics_process(delta):
		
		$PunchArea/CollisionShape2D.disabled = true
		is_punch = false
		velocity.y += 40
			
		if is_controled:
			if Input.is_action_pressed("ui_right"):
				velocity.x = SPEED
				direction = Vector2(1, 0)
			
			if Input.is_action_pressed("ui_left"):
				velocity.x = -SPEED
				direction = Vector2(-1, 0)

			if is_on_floor() and Input.is_action_just_pressed("ui_up"):
				velocity.y = -900
			if Input.is_action_pressed("punch"):
				$PunchArea/CollisionShape2D.disabled = false
				is_punch = true

		velocity = move_and_slide(velocity, UP)
		
		check_animation(velocity, direction, is_punch)
		
		if (velocity.x == SPEED or velocity.x == -SPEED or velocity.y == -900 or is_punch) and is_controled:
			player_state["velocity"]["x"] = velocity.x
			player_state["velocity"]["y"] = velocity.y
			player_state["direction"]["x"] = direction.x
			player_state["direction"]["y"] = direction.y
			player_state["is_punch"] = is_punch
			EventBus.emit_signal("update_position", JSON.print(player_state))
			
		velocity.x = lerp(velocity.x, 0, 0.2)
		
func play_animation(anim_name, flip):
		animated_sprite.flip_h = flip
		animated_sprite.play(anim_name)


func check_animation(vel, facing_dir, punch):
	animated_sprite.speed_scale = 1
	if vel.x == SPEED:
		is_left = false
		play_animation("walk_right", false)
		$CollisionShape2D.position = initialPos
		$PunchArea.position = PunchAreaPosition
	elif vel.x == -SPEED:
		is_left = true
		play_animation("walk_right", true)
		var x = initialPos.x * 2
		$CollisionShape2D.position.x = -x
		var punchX = PunchAreaPosition.x * 3.2
		$PunchArea.position.x = -punchX
				
	elif facing_dir.x == 1:
		is_left = false
		$CollisionShape2D.position = initialPos
		play_animation("idle_right", false)
	elif facing_dir.x == -1:
		is_left = true
		var x = initialPos.x * 2
		$CollisionShape2D.position.x = -x
		var punchX = PunchAreaPosition.x * 3.2
		$PunchArea.position.x = -punchX
		play_animation("idle_right", true)
	elif facing_dir.x == 0 or facing_dir.y == 0:
		is_left = false
		$CollisionShape2D.position = initialPos
		play_animation("idle_right", false)
	if punch == true: 
		animated_sprite.speed_scale = 100
		play_animation("punch_right", is_left)


func _on_PunchArea_body_entered(body):
	$AudioPunch.play()
	if body.name != "Player":
		if is_left:
			velocity.x += 2
		else: 
			velocity.x -= 2
		#move_and_slide(velocity * SPEED, UP)

func Move(vel, dir, punch):
	direction = dir
	velocity = move_and_slide(vel, UP)
	check_animation(vel, dir, punch)	
	#velocity.x = lerp(velocity.x, 0, 0.2)
