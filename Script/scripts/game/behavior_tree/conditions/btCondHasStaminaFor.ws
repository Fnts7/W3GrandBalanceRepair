/***********************************************************************/
/** 
/***********************************************************************/

class BTCondHasStaminaFor extends IBehTreeTask
{
	var staminaAction : EStaminaActionType;
	
	function IsAvailable() : bool
	{
		if( GetActor().HasStaminaToUseAction( staminaAction ) )
		{
			return true;
		}
		
		return false;
	}
}

class BTCondHasStaminaForDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondHasStaminaFor';
	editable var staminaAction 	: EStaminaActionType;
	
	default staminaAction = ESAT_LightAttack;
}