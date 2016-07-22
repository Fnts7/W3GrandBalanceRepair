// CBTTaskStopEffectIfActive
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Stops an effect on actor if it's active
//---------------------------------------------------------------------------
class CBTTaskStopEffectIfActive extends IBehTreeTask
{
	var entity				: CEntity;
	var effectName			: name;
	var onActivate			: bool;
	var onDeactivate		: bool;
	var allEffects			: bool;
	var findActorByTag		: bool;
	var tagToFind			: name;
	
	function IsAvailable() : bool
	{
		if( findActorByTag )
		{
			entity = theGame.GetEntityByTag( tagToFind );
		}
		else
		{
			entity = GetNPC();
		}
		
		if( !entity )
		{
			return false;
		}
		else return true;
	}
	function OnActivate() : EBTNodeStatus
	{	
		if( onActivate )
		{
			
			if( allEffects )
			{
				entity.StopAllEffects();
			}
			else
			{
				entity.StopEffectIfActive( effectName );
			}
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( onDeactivate )
		{
			if( allEffects )
			{
				entity.StopAllEffects();
			}
			else
			{
				entity.StopEffectIfActive(	effectName );
			}
			
		}
	}
}

class CBTTaskStopEffectIfActiveDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskStopEffectIfActive';
	
			 var entity 			: CEntity;
	editable var effectName			: name;
	editable var onActivate			: bool;
	editable var onDeactivate		: bool;
	editable var allEffects			: bool;
	editable var findActorByTag		: bool;
	editable var tagToFind			: name;
	
	default findActorByTag = false;
}


class CBTTaskIsEffectActive extends IBehTreeTask
{
	var target				: CNewNPC;
	var effectName			: name;
	
	function IsAvailable() : bool
	{	
		target = GetNPC();

		return target.IsEffectActive( effectName );
	}
}

class CBTTaskIsEffectActiveDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskIsEffectActive';
	
	var target						: CNewNPC;
	editable var effectName			: name;
}