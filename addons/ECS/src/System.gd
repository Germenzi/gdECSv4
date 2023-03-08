extends Node

class_name System

## System implementation as [Node][br]
## You can activate and diactivate it using [code]active[/code] exported variable.[br]
## Define entities processing behaviour in [code]on_entity_process(entity:Entity, delta:float)[/code]
## virtual method.[br]
## Specify necessary and banned components as a return value of [code]get_necessary_components[/code] 
## and [code]get_banned_components[/code] methods.

## If system active, it processes entities in the normal way.[br]
## If system deactivated ([code]active = false[/code]), it processes no entities until
## will be activated.
@export
var active : bool = true:
	set(v):
		active = v
		set_process(active)


## Filter to get valid entities.[br]
## Usually no reason to change.
var entity_filter : EntityFilter
## Systems in discrete mode doesn't process entities automatically.[br]
## Call [code]push_process()[/code] to process, but usually there is no reason
## to do it. [code]ECS[/code] manage discrete mode by itself.
var in_discrete_mode : bool = false

var _allow_push : bool = false


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


func _ready():
	set_process(active)


func _process(delta:float):
	if in_discrete_mode and not _allow_push:
		return
	
	_process_entities(delta)
	
	if in_discrete_mode:
		_allow_push = false


## Only in discrete mode.[br]
## Usually there is no reason to call it manually.[br]
## Makes the system processing entities
func push_process() -> void:
	if in_discrete_mode:
		_allow_push = true


func _process_entities(delta:float):
	for i in entity_filter.valid_entities:
		on_entity_process(i, delta)


## Vurtual[br][br]
## Define in this method behaviour of processing entity
## [code]delta[/code] is the same as [code]delta[/code] in [method Node._process] method
func on_entity_process(entity:Entity, delta:float) -> void:
	pass

## Virtual[br][br]
## Override this to return an array of necessary components' names
func get_necessary_components() -> Array[String]:
	return []


## Virtual[br][br]
## Override this to return an array of banned components' names
func get_banned_components() -> Array[String]:
	return []
