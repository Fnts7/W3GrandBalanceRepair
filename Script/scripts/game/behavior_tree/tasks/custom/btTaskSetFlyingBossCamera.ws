class BTTaskSetFlyingBossCamera extends IBehTreeTask
{
	private var val : bool;
	private var onActivate : bool;

	function OnActivate() : EBTNodeStatus
	{
		if( onActivate )
		{
			thePlayer.SetFlyingBossCamera( val );
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( !onActivate )
		{
			thePlayer.SetFlyingBossCamera( val );
		}
	}
}

//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------

class BTTaskSetFlyingBossCameraDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetFlyingBossCamera';
	
	editable var val : bool;
	editable var onActivate : bool;
	
	default onActivate = true;
}