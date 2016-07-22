/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTTaskSirenAttack extends CBTTaskAttack
{
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var actors : array<CActor>;
		var i : int;
		var npc : CNewNPC = GetNPC();
		
		
		//FIXME
		//HACK
		// This is some old code and it's broken. I checked it but to me it seems that this never gets called... In case it does it needs to get fixed:
		//  * this never gets called - the event doesn't come,
		//  * the stamina is already spent during attack
		//  * the buff should be set in attack instead of hacking it like this
		//  * especially that the code for applying the buff does not take into cosideration attitudes and attack range		
		//  * also if you hypnotize a siren it won't be able to stagger other sirens
		if ( animEventName == 'AttackScream' )
		{
			actors = npc.GetAttackableNPCsAndPlayersInRange(12);
			for ( i = 0 ; i < actors.Size(); i+=1)
			{
				if ( !actors[i].HasAbility( 'mon_siren' ))
				{
					actors[i].AddEffectDefault(EET_Stagger, npc, 'siren_attack' );
				}
			}
			return true;
		}
		return super.OnAnimEvent( animEventName, animEventType, animInfo);
	}
}

class CBTTaskSirenAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskSirenAttack';
}
