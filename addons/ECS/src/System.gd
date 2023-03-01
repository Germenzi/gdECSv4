extends Node

class_name System

@export
var active : bool = true

@export
var autoregister : bool = true


var registered : bool = false
var entity_filter : EntityFilter
var in_descrete_mode : bool = false

var _push_allowed : bool = false


func push_process_entity(): # only for using in descrete mode
	_push_allowed = true


func _enter_tree():
	entity_filter = EntityFilter.new(
		EntitySignature.create_signature(
			get_necessary_components(),
			get_banned_components()
		)
	)
	
	ECS.register_filter(entity_filter)


func _exit_tree():
	ECS.unregister_filter(entity_filter)


func _process(delta:float):
	if in_descrete_mode and not _push_allowed:
		return
	
	_process_entities(delta)
	_push_allowed = false


func _process_entities(delta:float):
	if not active:
		return
	
	for i in entity_filter.valid_entities:
		on_entity_process(i, delta)


# virtual
func on_entity_process(entity:Entity, delta:float):
	pass

# virtual
func get_necessary_components() -> Array:
	return []

# virtual
func get_banned_components() -> Array:
	return []
