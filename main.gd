extends Node2D

onready var mqtt = $mqtt
var player_scene = preload("res://Player.tscn")

var player = {
	"player_id": randi() % 100,
}

func _ready():
	randomize()
	player["player_id"] = randi() % 100
	EventBus.connect("update_position", self, "on_update_position")
	connect_server()

func connect_server():
	mqtt.server = "127.0.0.1"
	mqtt.port = 1883
	#mqtt.user = "mqtt"
	#mqtt.pswd = "decafbad00"
	mqtt.connect("received_message", self, "_on_received_message")
	mqtt.connect_to_server()
	mqtt.ping()
	mqtt.subscribe("VR/#")
	mqtt.subscribe("JOIN/#")
	mqtt.publish("JOIN/ROOM", JSON.print(player))

 
func _on_received_message(topic, message):
	if topic == "JOIN/ROOM1":
		print("New player")
		var new_player = player_scene.instance()
		add_child(new_player)
		new_player.position.x =  randi() % 200
		new_player.position.y = randi() % 200
		new_player.is_controled = false

func on_update_position(pos):
	mqtt.publish("VR/position", pos)
