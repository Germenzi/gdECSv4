extends Window

@onready 
var systems_list = $Base/MarginContainer/VBoxContainer/SystemsList



func _ready():
	ECS.entered_discrete_mode.connect(_on_enter_dicrete_mode)
	ECS.exited_discrete_mode.connect(_on_exit_discrete_mode)
	ECS.process_pushed.connect(_on_process_pushed)


func _on_enter_dicrete_mode():
	show()
	systems_list.update_text()


func _on_exit_discrete_mode():
	hide()


func _on_next_pressed():
	ECS.push_update()


func _on_exit_discrete_mode_pressed():
	_exit_discr_mode()


func _on_process_pushed():
	systems_list.update_text()


func _on_close_requested():
	_exit_discr_mode()


func _on_complete_cycle_pressed():
	ECS.complete_systems_cycle()


func _exit_discr_mode():
	if ECS._systems_queue.is_empty():
		return
	
	if ECS._systems_queue[0] != ECS._first_system:
		$ConfirmationDialog.position = position
		$ConfirmationDialog.show()
	else:
		ECS.exit_discrete_mode()


func _on_confirmation_dialog_confirmed():
	ECS.exit_discrete_mode()
