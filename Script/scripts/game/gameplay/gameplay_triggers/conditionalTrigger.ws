class W3ConditionalTrigger extends CEntity
{
	editable inlined var conditionClass : W3Condition;
	editable inlined var effectorClasses : array< IPerformableAction >;
	editable var affectsPlayer : bool;
	
	default affectsPlayer = true;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		if( activator.GetEntity() == thePlayer && !affectsPlayer )
			return false;
			
		actor = (CActor)activator.GetEntity();
		
		if( conditionClass.Test( actor ) )
		{
			TriggerPerformableEventArgNode( effectorClasses, this, actor );
		}
	}
}

// --------------------------------
// ---------- CONDITIONS ----------
// --------------------------------

abstract class W3Condition
{
	function Test( actor : CActor ) : bool;
}

class W3ConditionHasEffect extends W3Condition
{
	editable var effect : EEffectType;
	
	function Test( actor : CActor ) : bool
	{
		if( actor.HasBuff( effect ) )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}