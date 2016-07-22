/////////////////////////////////////////////////////
// CBTTaskSetCanBeFollowed
class CBTTaskSetCanBeFollowed extends IBehTreeTask
{
	var setCanBeFollowed : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		if( setCanBeFollowed )
		{
			GetNPC().SetCanBeFollowed( true );
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( setCanBeFollowed )
		{
			GetNPC().SetCanBeFollowed( false );
			thePlayer.SignalGameplayEvent( 'StopPlayerAction' );
			thePlayer.SetCanFollowNpc( false, NULL );
		}
	}
}

class CBTTaskSetCanBeFollowedDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSetCanBeFollowed';

	editable var setCanBeFollowed : CBehTreeValBool;
	default setCanBeFollowed =  false;
}