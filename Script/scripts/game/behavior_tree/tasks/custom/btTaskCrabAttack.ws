class CBTTaskCrabAttack extends IBehTreeTask
{

	//TODO caching Damage action would be beneficial to performance
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var crab : CNewNPC = GetNPC();
		//FIXME should be an attack action
		var action : W3DamageAction = new W3DamageAction in theGame.damageMgr;
		
		if ( animEventName == 'AttackLight' && animEventType == AET_DurationStart)
		{
			if ( crab.GetTarget() && crab.InAttackRange( crab.GetTarget() ) )
			{
				action.Initialize( crab, crab.GetTarget(), NULL, "boid", EHRT_None, CPS_Undefined, true, false, false, false, theGame.params.LIGHT_HIT_FX, theGame.params.LIGHT_HIT_BACK_FX, theGame.params.LIGHT_HIT_PARRIED_FX, theGame.params.LIGHT_HIT_BACK_PARRIED_FX);
				action.SetHitAnimationPlayType(EAHA_Default);
				action.AddDamage('PhysicalDamage', 3);
				theGame.damageMgr.ProcessAction( action );
				delete action;
			}			
			return true;
		}
		return false;
	}
}

class CBTTaskCrabAttackDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskCrabAttack';
}