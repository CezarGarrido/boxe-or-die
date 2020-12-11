tool
extends EditorPlugin


func _enter_tree():
	 add_custom_type("mqtt", "Node", preload("mqtt.gd"), null)

func _exit_tree():
	 remove_custom_type("mqtt")
