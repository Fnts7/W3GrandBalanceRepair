//>--------------------------------------------------------------------------
// BTTaskAddBuff
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Add buffs to the NPC
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 01-September-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskAddBuffs extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	public  var onDeactivate	: bool;
	public 	var buffs			: array<EEffectType>;
	public 	var duration		: float;
	public  var customValue		: SAbilityAttributeValue;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnActivate() : EBTNodeStatus
	{
		if( onDeactivate ) return BTNS_Active;
		AddBuffs();
		return BTNS_Active;
	}	
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private function OnDeactivate()
	{
		if( !onDeactivate ) return;
		AddBuffs();
	}
	
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private function AddBuffs()
	{
		var i			: int;
		var l_actor		: CActor;
		var l_params	: SCustomEffectParams;
		
		l_actor				= GetNPC();
		
		for( i = 0; i < buffs.Size(); i += 1 )
		{
			l_params.effectType = buffs[i];
			//l_params.creator 	= l_actor;
			
			if( buffs[i] == EET_VitalityDrain )
			{
				l_params.creator 	= GetCombatTarget();
				l_params.sourceName = GetCombatTarget().GetName();
			}
			else
			{
				l_params.sourceName = l_actor.GetName();
			}
			
			l_params.duration 	= duration;
			
			if( customValue.valueAdditive != 0 || customValue.valueBase != 0 || customValue.valueMultiplicative != 0 )
				l_params.effectValue = customValue;
			
			l_actor.AddEffectCustom( l_params );
		}
		
	}
}


//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTTaskAddBuffsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskAddBuffs';
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	private editable var onDeactivate	: bool;
	private editable var buffs			: array<EEffectType>;
	private editable var duration		: float;
	private editable var customValue	: SAbilityAttributeValue;
}
