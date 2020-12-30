extends Node2D

var player_scene = preload("res://Player.tscn")
# The URL we will connect to
export var websocket_url = "ws://127.0.0.1:3001/ws"
# Our WebSocketClient instance
var _client = WebSocketClient.new()

var players = {}

var player = {
	"player_id": randi() % 100,
	"position": null
}

var message = {
	"action": "publish",
	"topic": "join/room/1",
	"message": "Ola mundo."
}
func _ready():
	randomize()
	player["player_id"] = randi() % 100
	
	var ps = {
		"x" : $Player.position.x,
		"y" : $Player.position.y
	}
	player["position"] = ps
	EventBus.connect("update_position", self, "on_update_position")
	connect_ws()

func on_update_position(position):
	print("publish position")
	player["position"] = position
	publish("position/room/1", player)
	
func connect_ws():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	print("Connected with protocol: ", proto)
	subscribe("position/room/1")
	publish("join/room/1", player)
	subscribe("join/room/1")

func _on_data():
	var result = JSON.parse(_client.get_peer(1).get_packet().get_string_from_utf8())
	var data = result.result
	handle_topic(data["topic"], JSON.parse(data["message"]).result)

func handle_topic(topic, m):
	if topic == "join/room/1":
		var new_player = player_scene.instance()
		add_child(new_player)
		new_player.is_controled = false
		new_player.position.x = 220
		new_player.position.y = 220
		players["1"] = new_player
	if topic == "position/room/1":
		var p = JSON.parse(m["position"]).result
		print(p)
		var vel = Vector2(p["velocity"]["x"],p["velocity"]["y"])
		var dir = Vector2(p["direction"]["x"],p["direction"]["y"])
		var punch = p["is_punch"]
		players["1"].Move(vel, dir, punch)

		
func _process(_delta):
	_client.poll()

func subscribe(topic):
	message["action"] = "subscribe"
	message["topic"] = topic
	var msg = JSON.print(message)
	_client.get_peer(1).put_packet(msg.to_utf8())

func publish(topic, m):
	message["action"] = "publish"
	message["topic"] = topic
	message["message"] = JSON.print(m)
	var msg = JSON.print(message)
	_client.get_peer(1).put_packet(msg.to_utf8())
