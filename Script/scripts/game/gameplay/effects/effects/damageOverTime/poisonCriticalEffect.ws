/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3Effect_PoisonCritical extends W3CriticalDOTEffect
{
	default criticalStateType 	= ECST_PoisonCritical;
	default effectType 			= EET_PoisonCritical;
	default powerStatType 		= CPS_SpellPower;
	default resistStat 			= CDS_PoisonRes;
	default postponeHandling 	= ECH_Postpone;
	default airHandling 		= ECH_Postpone;
	default attachedHandling 	= ECH_Postpone;
	default onHorseHandling	 	= ECH_Postpone;
	
	public function CacheSettings()
	{
		super.CacheSettings();
	
		blockedActions.PushBack(EIAB_Jump);
		blockedActions.PushBack(EIAB_RunAndSprint);
		blockedActions.PushBack(EIAB_Parry);
		blockedActions.PushBack(EIAB_Sprint);
		blockedActions.PushBack(EIAB_Counter);
	}
}