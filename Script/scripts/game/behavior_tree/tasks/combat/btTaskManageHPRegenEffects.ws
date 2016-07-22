//>--------------------------------------------------------------------------
// BTTaskManageHPRegenEffects
//---------------------------------------------------------------------------
// Pauses or Resume HP Regenaration effects
//>--------------------------------------------------------------------------
// Copyright © 2015 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskManageHPRegenEffects extends BTTaskIrisTask
{
	//>----------------------------------------------------------------------
	// Variables
	//-----------------------------------------------------------------------
	public var ResumeEffect	: bool;
	public var OnDeactivate	: bool;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnActivate() : EBTNodeStatus
	{
		if( !OnDeactivate )
		{
			Execute();
		}
		
		return BTNS_Active;
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private function OnDeactivate()
	{
		if( OnDeactivate )
		{
			Execute();
		}
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function Execute()
	{
		if( ResumeEffect )
		{
			GetNPC().ResumeEffects(EET_AutoEssenceRegen, 'TaskManageHPRegenEffects');
		}
		else
		{
			GetNPC().PauseEffects(EET_AutoEssenceRegen, 'TaskManageHPRegenEffects', true);
		}
	}
}

//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTTaskManageHPRegenEffectsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskManageHPRegenEffects';
	
	private editable var ResumeEffect	: bool;
	private editable var OnDeactivate	: bool;	
	
}