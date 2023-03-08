extends Object

class_name EntitySignature

## Static class which provides you to create signature and match entity by signature

const NECESSARY_STRING = "NECESSARY_COMPONENTS"
const BANNED_STRING = "BANNED_COMPONENTS"

## Returns true if [code]entity[/code] has all components specified in
## [code]signature[NECESSARY_STRING][/code] and has no one of components specified
## in [code]signature[BANNED_STRING][/code]
static func match_entity(signature:Dictionary, entity:Entity) -> bool:
	if Entity.is_dirty(entity):
		return false
	
	for ncc in signature.get(NECESSARY_STRING, []):
		if not entity.has_component(ncc):
			return false
	
	for bnc in signature.get(BANNED_STRING, []):
		if entity.has_component(bnc):
			return false
	
	return true


## Creates a [Dictionary] with the same strucrure:
## [codeblock]
## {
##     NECESSARY_STRING : necessary.duplicate(),
##     BANNED_STRING : banned.duplicate()
## }
## [/codeblock]
static func create_signature(necessary:Array, banned:Array=[]) -> Dictionary:
	return {
		NECESSARY_STRING : necessary.duplicate(),
		BANNED_STRING : banned.duplicate()
	}
