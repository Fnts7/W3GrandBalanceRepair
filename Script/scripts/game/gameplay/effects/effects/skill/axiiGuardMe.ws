/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Patryk Fiutowski, Tomek Kozera
/***********************************************************************/

class W3Effect_AxiiGuardMe extends CBaseGameplayEffect
{
	private var drainStaminaOnExit : bool;

	default effectType = EET_AxiiGuardMe;
	default resistStat = CDS_WillRes;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default drainStaminaOnExit = false;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var npc : CNewNPC;
		var bonusAbilityName : name;
		var skillLevel, i : int;
		
		super.OnEffectAdded(customParams);
		
		npc = (CNewNPC)target;
		
		((CAIStorageReactionData)npc.GetScriptStorageObject('ReactionData')).ResetAttitudes(npc);
		
		// if npc is hostile towards player directly -> the attitude needs to be reset
		if ( npc.HasAttitudeTowards( thePlayer ) && npc.GetAttitude( thePlayer ) == AIA_Hostile )
		{
			npc.ResetAttitude( thePlayer );
		}
		
		if ( npc.HasTag('animal') || npc.IsHorse() )
		{
			npc.SetTemporaryAttitudeGroup('animals_charmed', AGP_Axii);
		}
		else
		{
			npc.SetTemporaryAttitudeGroup('npc_charmed', AGP_Axii);
		}
		
		npc.SignalGameplayEvent('AxiiGuardMeAdded');
		npc.SignalGameplayEvent('NoticedObjectReevaluation');
		
		//damage bonus
		skillLevel = GetWitcherPlayer().GetSkillLevel(S_Magic_s05);
		bonusAbilityName = thePlayer.GetSkillAbilityName(S_Magic_s05);
		for(i=0; i<skillLevel; i+=1)
			target.AddAbility(bonusAbilityName, true);
			
		if (npc.IsHorse())
			npc.GetHorseComponent().ResetPanic();
	}
	
	event OnEffectRemoved()
	{
		var npc : CNewNPC;
		var bonusAbilityName : name;
		
		super.OnEffectRemoved();
		
		npc = (CNewNPC)target;		
		if(npc)
		{
			npc.ResetTemporaryAttitudeGroup(AGP_Axii);
			npc.SignalGameplayEvent('NoticedObjectReevaluation');
			((CAIStorageReactionData)npc.GetScriptStorageObject('ReactionData')).ResetAttitudes(npc);
		}
		
		if(drainStaminaOnExit)
		{
			target.DrainStamina(ESAT_FixedValue, target.GetStat(BCS_Stamina));
		}
		
		//remove attack bonus ability
		bonusAbilityName = thePlayer.GetSkillAbilityName(S_Magic_s05);		
		while(target.HasAbility(bonusAbilityName))
			target.RemoveAbility(bonusAbilityName);
	}
	
	public function SetDrainStaminaOnExit()
	{
		drainStaminaOnExit = true;
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		super.CalculateDuration(setInitialDuration);
		
		if ( duration > 0 )
			duration = MaxF(8.f,duration);
	}
}