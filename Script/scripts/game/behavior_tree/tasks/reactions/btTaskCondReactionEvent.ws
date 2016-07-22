/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2013 CD Projekt RED
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

// Reaction event name list
/*
PlayerAttack
PlayerCastSign
PlayerThrowItem
PlayerEvade
PlayerSpecialAttack
PlayerSprint
*/

class CBTTaskCondReactionEvent extends IBehTreeTask
{
	var reactionEventName	: name;
	var eventReceived		: bool;
	
	
	function IsAvailable() : bool
	{
		if ( eventReceived )
		{
			return true;
		}
		return false;
	}
	
	function OnDeactivate()
	{
		eventReceived = false;
	}
	
	function OnListenedGameplayEvent( _EventName : name ) : bool
	{
		eventReceived = true;
		return true;
	}
};

class CBTTaskCondReactionEventDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskCondReactionEvent';

	editable var reactionEventName	: name;
	
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var task : CBTTaskCondReactionEvent;
		task = (CBTTaskCondReactionEvent) taskGen;
		if ( IsNameValid( task.reactionEventName ) )
		{
			ListenToGameplayEvent( task.reactionEventName );
		}
	}
};
