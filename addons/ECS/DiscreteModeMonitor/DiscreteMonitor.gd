extends CanvasLayer

@onready 
var systems_list = $Base/MarginContainer/VBoxContainer/SystemsList



func _ready():
	ECS.entered_discrete_mode.connect(_on_enter_dicrete_mode)
	ECS.exited_discrete_mode.connect(_on_exit_discrete_mode)
	ECS.process_pushed.connect(_on_process_pushed)


func _on_enter_dicrete_mode():
	visible = true
	systems_list.update_text()


func _on_exit_discrete_mode():
	visible = false


func _on_next_pressed():
	ECS.push_update()


func _on_exit_discrete_mode_pressed():
	ECS.exit_discrete_mode()


func _on_process_pushed():
	systems_list.update_text()



