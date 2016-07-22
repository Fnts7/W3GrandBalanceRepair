/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Patryk Fiutowski
/***********************************************************************/

class CBTTaskTrollAttack extends CBTTaskAttack
{
	var getStats : bool;
	default getStats = true;

	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var actors : array<CActor>;
		var npc : CNewNPC = GetNPC();
		var processed : bool;
		
		processed = super.OnAnimEvent( animEventName, animEventType, animInfo );
		
		if ( animEventName == 'AttackSmash' )
		{	
			actors = npc.GetAttackableNPCsAndPlayersInCone(3, npc.GetHeading(), 110);

			return true;
		}
		
		return processed;
	}
}

class CBTTaskTrollAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskTrollAttack';
}
