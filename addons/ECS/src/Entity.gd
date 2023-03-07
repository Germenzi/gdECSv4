extends Object

class_name Entity


## Entity, or just components set


## Emmited after registration in ECS
signal enter_ecs
## Emmited after unregistration in ECS
signal exit_ecs

## True if registered in ES[br]
## Change it on your risk
var inside_ecs:bool = false # only for use from ECS singleton!

var _components : Dictionary = {} # component type : component instance
var _binded_scene : Node


## True if [code]entity[/code] valid [Entity]
static func is_dirty(entity:Entity) -> bool:
	return entity == null or \
			not is_instance_valid(entity)


func _init(_components:Array=[], autoregister:bool=true):
	if autoregister:
		ECS.register_entity(self)
	
	for i in _components:
		add_component(i)


## Binds component instance with it's name
## ([code]comp_instance.COMPONENT_TYPE[/code] by default) in this entity.
## [br][br]
## [code]comp_instance[/code] is instance of a component. Can be any [Object].
## It's allowed to pass as [code]comp_instance[/code] any Object-type with 
## assigned [code]COMPONENT_TYPE[/code] (by default). If [code]readonly[/code] is true,
## keep in mind that Object-type will be readonly everywhere, including
## other entities it was passed as non-readonly
## [br][br]
## [code]readonly[/code], if [code]true[/code], sets component as readonly using [code]
## ECS.set_component_readonly(comp_instance)[/code]
## [br][br]
## If [code]overwrite[/code] is true, it allowed to overwrite existing component's instance
## with the same name as [code]comp_instance[/code]'s name, if existing wasn't
## set as readonly
func add_component(comp_instance:Object, readonly:bool=false, overwrite:bool=false) -> void:
	if not ECS.is_instance_component(comp_instance):
		push_warning("Trying to add non-component instance as a component to the entity")
		return
	
	var existing : Object = get_component(comp_instance.COMPONENT_TYPE)
	
	if overwrite or existing == null:
		if existing != null and ECS.is_component_readonly(existing):
			push_warning("Cannot overwrite readonly component <{0}> in entity {1}".format([comp_instance.COMPONENT_TYPE, self]))
			return
		
		_components[comp_instance.COMPONENT_TYPE] = comp_instance
		
		if readonly:
			ECS.set_component_readonly(comp_instance)
		
		ECS.revise_entity(self)


## True if the entity has component with name [code]comp_type[/code]
func has_component(comp_type:String) -> bool:
	return _components.has(comp_type)


## Removes component with name [code]comp_type[/code] if
## it exists and wasn't set as readonly
func remove_component(comp_type:String) -> void:
	if not has_component(comp_type):
		push_warning("Entity <{0}> has no <{1}> component to remove".format([self, comp_type]))
		return
	
	if ECS.is_component_readonly(_components[comp_type]):
		push_warning("Cannot remove readonly component <{0}> from entity {1}".format([comp_type, self]))
		return
	
	_components.erase(comp_type)
	
	ECS.revise_entity(self)


## Returns component's instance with name [code]comp_type[/code] if exists.
## Otherwise returns [code]null[/code]
func get_component(comp_type:String) -> Object:
	if not has_component(comp_type):
		return null
	
	return _components[comp_type]


## Returns an array of all entity's components names
func get_components_names() -> Array[String]:
	return _components.keys()


## Returns an array of all entity's components instances
func get_components_instances() -> Array[Object]:
	return _components.values()


## [code]node[/code] binded with the entity will be freed at the same time
## entity will be freed. You can bind only one node with the entity. If
## called again, binds new node, while the old one unbinds with the entity.
func bind_node(node:Node) -> void:
	_binded_scene = node



func _free_binded_scene():
	if _binded_scene != null and is_instance_valid(_binded_scene):
		_binded_scene.queue_free()


func _notification(what):
	match what:
		NOTIFICATION_PREDELETE:
			ECS.unregister_entity(self)
			_free_binded_scene()
