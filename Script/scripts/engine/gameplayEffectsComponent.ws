/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2013 CDProjektRed
/** Author : Tim Green
/***********************************************************************/

//
// EEntityGameplayEffectFlags:
//		EGEF_FocusModeHighlight		- Highlight applied to objects when focus mode is active.
//		EGEF_CatViewHiglight		- Highlight of objects that need to be visible throught walls when using CatEffect
//
import class CGameplayEffectsComponent extends CComponent
{
	// Set effect flags on all components in this entity, and child entities (weapons and such).
	import final function SetGameplayEffectFlag( flag : EEntityGameplayEffectFlags, value : bool );
	
	// Get current value of effect flag. If that flag has not been set on this GEC, or it has since been
	// reset (with ResetGameplayEffectFlag), will return false.
	import final function GetGameplayEffectFlag( flag : EEntityGameplayEffectFlags ) : bool;
	
	// Reset effect flags back to the values defined per-component in the entity editor.
	import final function ResetGameplayEffectFlag( flag : EEntityGameplayEffectFlags ) : bool;
}


// Get a CGameplayEffectsComponent in a given entity, or NULL if it doesn't have one.
function GetGameplayEffectsComponent( entity : CEntity ) : CGameplayEffectsComponent
{
	if(entity)
		return ( CGameplayEffectsComponent )entity.GetComponentByClassName( 'CGameplayEffectsComponent' );
		
	return NULL;
}
