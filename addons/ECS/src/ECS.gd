extends Node


## Autoload to made all ecs things work[br][br]
## Handles [i]registered[/i] entities and filters[br][br]
## Provides methods to activate and use [i]discrete mode[/i][br]
## [i]discrete mode[/i] allows you to process systems step-by-step



const COMPONENT_TYPE_PROPERTY = "COMPONENT_TYPE"
const COMPONENT_READONLY_META_NAME = "READONLY_COMPONENT"

## Emmited after ECS entered discrete mode
signal entered_discrete_mode
## Emmited after ECS exited discrete mode
signal exited_discrete_mode
## Only in discrete mode[br]
## Emmited after next system processed
signal process_pushed

## Array of all registered entities 
var entities : Array[Entity] = []
## Array of all registered filters
var filters : Array[EntityFilter] = []
## If true, discrete mode is active
var in_discrete_mode : bool = false

var _systems_queue : Array[System] = []
var _first_system : System


func _enter_tree():
	get_tree().node_added.connect(_on_node_added)


## Allow [code]filter[/code] to get valid registered entities
func register_filter(filter:EntityFilter) -> void:
	if filter.registered:
		return
	
	filters.append(filter)
	
	for ent in entities:
		if EntitySignature.match_entity(filter.entity_signature, ent):
			filter.add_entity(ent)
	
	filter.registered = true
	filter.was_registered.emit()


## [code]filter[/code] stops to get valid entities and clears [code]valid_entities[/code]
func unregister_filter(filter:EntityFilter) -> void:
	if not filter.registered:
		return
	
	filter.pre_unregister.emit()
	
	filters.erase(filter)
	filter.valid_entities = []
	filter.registered = false



## Allow [code]entity[/code] being passed into registered filters
func register_entity(entity:Entity) -> void:
	if entity.inside_ecs:
		return
	
	entities.append(entity)
	
	entity.enter_ecs.emit()
	entity.inside_ecs = true
	
	revise_entity(entity)


## [code]entitity[/code] stops being passed into filters
func unregister_entity(entity:Entity) -> void:
	if not entity.inside_ecs:
		return
	
	entities.erase(entity)
	
	for filter in filters:
		if entity in filter.valid_entities:
			filter.remove_entity(entity)
	
	entity.exit_ecs.emit()
	entity.inside_ecs = false


## Frees all regsitered entities
func clear_entities() -> void:
	for ent in entities.duplicate():
		ent.free()


## Usually called when [code]entity[/code] changed it's components set[br]
## Adds [code]entity[/code] into filters it fits[br]
## Removes an [code]entity[/code] from filters it doesn't fit, if [code]entity[/code] in it
func revise_entity(entity:Entity) -> void:
	if not entity.inside_ecs:
		return
	
	for filter in filters:
		if EntitySignature.match_entity(filter.entity_signature, entity):
			if not entity in filter.valid_entities:
				filter.add_entity(entity)
		
		elif entity in filter.valid_entities:
				filter.remove_entity(entity)


## Only in discrete mode[br]
## Processes next system
func push_update() -> void:
	if not _has_systems_in_queue():
		push_warning("Has no systems to push update")
		return
	
	_process_next_system()
	
	process_pushed.emit()


## Only in discrete mode[br]
## Processes systems before a system which is processed first in one frame in queue
func complete_systems_cycle() -> void:
	if not in_discrete_mode:
		push_warning("Attempted complete systems cycle when discrete mode isn't active")
		return
	
	if not _has_systems_in_queue():
		push_warning("Has no systems to complete cycle")
		return
	
	while _systems_queue[0] != _first_system:
		_process_next_system()
		process_pushed.emit()


## Activates step-by-step system processing[br]
## Shows discrete mode control panel
func enter_discrete_mode() -> void:
	if in_discrete_mode:
		push_warning("Attempted to enter discrete mode when it's active")
		return
		
	await get_tree().process_frame
	
	_fill_system_queue(get_tree().root)
	
	for s in _systems_queue:
		s.in_discrete_mode = true
	
	in_discrete_mode = true
	
	if not _systems_queue.is_empty():
		_first_system = _systems_queue[0]
	
	entered_discrete_mode.emit()


## Diactivates step-by-step system processing[br]
## Hides discrete mode control panel
func exit_discrete_mode() -> void:
	await get_tree().process_frame
	
	if not in_discrete_mode:
		return # warning
	
	for s in _systems_queue:
		s.in_discrete_mode = false
	
	_systems_queue = []
	in_discrete_mode = false
	
	exited_discrete_mode.emit()


## True if [code]instance[/code] can be interpreted as component
func is_instance_component(instance:Object) -> bool:
	return COMPONENT_TYPE_PROPERTY in instance


## True if [code]instance[/code] can be interpreted as component and was set as readonly
func is_component_readonly(instance:Object) -> bool:
	if not is_instance_component(instance):
		return false
	
	return instance.has_meta(COMPONENT_READONLY_META_NAME)


## Sets component as readonly[br]
## Creates instance's meta with name specified in [code]COMPONENT_READONLY_META_NAME[/code]
func set_component_readonly(instance:Object) -> void:
	if not is_instance_component(instance):
		return
	
	instance.set_meta(COMPONENT_READONLY_META_NAME, 0)


func _fill_system_queue(node:Node) -> void:
	if node is System:
		_systems_queue.append(node)
	
	for i in node.get_children():
		_fill_system_queue(i)


func _process_next_system() -> void:
	var system : System = _systems_queue.pop_front()
	
	system.push_process()
	
	_systems_queue.append(system)


func _has_systems_in_queue() -> bool:
	return not _systems_queue.is_empty()


func _on_node_added(node:Node) -> void:
	if node is System and in_discrete_mode:
		push_warning("Adding new System while discrete mode active")
