// copyrajt orajt
// W. Żerek

class CBTTaskIceGiantFallingIcicles extends CBTTaskAttack
{
	var icicles : array<CGameplayEntity>;
	var rangeForIcyclesActivation : float;
	var npc : CNewNPC;
	
	function IsAvailable() : bool
	{
		npc = GetNPC();
		
		// search for existing icicles
		FindGameplayEntitiesInRange( icicles, npc, rangeForIcyclesActivation, 10, 'icicle' );
		
		if( icicles.Size() )
		{	
			return true;
		}
		
		return false;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var i : int;
		
		if( animEventName == 'AttackSuperHeavy' )
		{
			for( i = 0; i < icicles.Size(); i += 1 )
			{
				// DO STUFF WITH ICICLES HERE
				// pick random
				//LogChannel('ICICLES', "destroyed icicle no.: " + i );
			}
			
			return true;
		}
		
		return false;
	}
	
	function OnDeactivate()
	{
		super.OnDeactivate();
		
		icicles.Clear();		
	}
}

class CBTTaskIceGiantFallingIciclesDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskIceGiantFallingIcicles';

	editable var rangeForIcyclesActivation : float;

	default rangeForIcyclesActivation = 10;
}