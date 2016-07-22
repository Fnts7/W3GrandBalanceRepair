/***********************************************************************/
/** Copyright © 2013-2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3BlindnessEffect extends W3CriticalEffect
{
	default criticalStateType 	= ECST_Blindness;
	default effectType 			= EET_Blindness;
	default resistStat 			= CDS_WillRes;
	default attachedHandling 	= ECH_Abort;
	default onHorseHandling 	= ECH_Abort;
	
	public function CacheSettings()
	{
		super.CacheSettings();
		blockedActions.PushBack(EIAB_Fists);
		blockedActions.PushBack(EIAB_Jump);
		blockedActions.PushBack(EIAB_RunAndSprint);
		blockedActions.PushBack(EIAB_ThrowBomb);
		blockedActions.PushBack(EIAB_Crossbow);
		blockedActions.PushBack(EIAB_UsableItem);
		blockedActions.PushBack(EIAB_Parry);
		blockedActions.PushBack(EIAB_Sprint);
		blockedActions.PushBack(EIAB_Explorations);
		blockedActions.PushBack(EIAB_Counter);
		blockedActions.PushBack(EIAB_QuickSlots);
		
		// disabled on request from review #91534
		//blockedActions.PushBack(EIAB_SwordAttack);
		//blockedActions.PushBack(EIAB_LightAttacks);
		//blockedActions.PushBack(EIAB_SpecialAttackLight);
		//blockedActions.PushBack(EIAB_HeavyAttacks);
		//blockedActions.PushBack(EIAB_SpecialAttackHeavy);
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if(isOnPlayer)
		{
			thePlayer.HardLockToTarget( false );
		}
	}
}