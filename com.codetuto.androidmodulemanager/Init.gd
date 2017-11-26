tool
extends EditorPlugin

var button 
var window

func _enter_tree():
	button = Button.new()
	button.set_text("AETC")
	add_control_to_container(CONTAINER_TOOLBAR,button)
	button.connect("pressed",self,"_on_button")
	pass

func _on_button():
	window = preload("scenes/main.tscn").instance()
	add_child(window)
	window.show_modal()
	window.popup_centered()

func _exit_tree():
	if(window != null):
		window.queue_free()
	if(button != null):
		button.queue_free()
	pass
