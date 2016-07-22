/***********************************************************************/
/** Copyright © 2013
/** Author : Tomasz Kozera
/***********************************************************************/

class W3Effect_BattleTrance extends CBaseGameplayEffect
{
	private saved var currentFocusLevel : int;
	
	default effectType = EET_BattleTrance;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;

	// check if character's focus points have changed and if so apply a level change
	event OnUpdate(deltaTime : float)
	{
		var focus : float;
		var newLevel, delta : int;
	
		super.OnUpdate(deltaTime);
		
		//check current focus level
		focus = target.GetStat(BCS_Focus);
		newLevel = FloorF(focus);
		delta = newLevel - currentFocusLevel;
		
		//if changed then add/remove 1 level of bonus
		if(delta != 0)
		{
			if(delta < 0)
			{
				if(GetWitcherPlayer().CanUseSkill(S_Perk_19))
					target.RemoveAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_19), Abs(delta));
				else
					target.RemoveAbilityMultiple(thePlayer.GetSkillAbilityName(S_Sword_5), Abs(delta));
				
				if(thePlayer.CanUseSkill(S_Magic_s07))
					thePlayer.RemoveAbilityMultiple(thePlayer.GetSkillAbilityName(S_Magic_s07), Abs(delta));
				
				if(thePlayer.CanUseSkill(S_Perk_11))
					thePlayer.RemoveAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_11), Abs(delta));
			}
			else
			{
				if(GetWitcherPlayer().CanUseSkill(S_Perk_19))
					target.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_19), delta);
				else
					target.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Sword_5), delta);
				
				if(thePlayer.CanUseSkill(S_Magic_s07))
					thePlayer.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Magic_s07), delta);
				
				if(thePlayer.CanUseSkill(S_Perk_11))
					thePlayer.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_11), delta);
			}
			
			//shut down if no focus left
			if(newLevel == 0)
			{
				isActive = false;
				return true;
			}
			
			currentFocusLevel = newLevel;
		}
	}
	
	// also add trance aura dreadfull if hero has this skill
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var player : CR4Player;
	
		player = (CR4Player)target;
		if(!player)
		{
			LogEffects("W3Effect_BattleTrance.OnEffectAdded: effect added on non-CR4Player object - aborting!");
			return false;
		}
			
		super.OnEffectAdded(customParams);
		
		currentFocusLevel = FloorF(target.GetStat(BCS_Focus));
		
		if(player.CanUseSkill(S_Perk_19))
			target.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_19), currentFocusLevel);
		else
			target.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Sword_5), currentFocusLevel);
		
		if( player.CanUseSkill(S_Magic_s07) )
			player.AddAbilityMultiple( player.GetSkillAbilityName(S_Magic_s07), currentFocusLevel);
			
		if(player.CanUseSkill(S_Perk_11))
			player.AddAbilityMultiple(player.GetSkillAbilityName(S_Perk_11), currentFocusLevel);
	}
	
	event OnEffectRemoved()
	{
		var player : CR4Player;
		
		super.OnEffectRemoved();
		
		player = (CR4Player)target;
		player.RemoveAbilityAll( player.GetSkillAbilityName(S_Magic_s07) );
		player.RemoveAbilityAll( player.GetSkillAbilityName(S_Perk_11) );
		player.RemoveAbilityAll( player.GetSkillAbilityName(S_Sword_5) );
		player.RemoveAbilityAll( player.GetSkillAbilityName(S_Perk_19) );
	}
	
	public function OnPerk11Equipped()
	{
		thePlayer.AddAbilityMultiple(thePlayer.GetSkillAbilityName(S_Perk_11), FloorF(thePlayer.GetStat(BCS_Focus)));
	}
	
	public function OnPerk11Unequipped()
	{
		thePlayer.RemoveAbilityAll(thePlayer.GetSkillAbilityName(S_Perk_11) );
	}
	
	protected function SetEffectValue()
	{
		if(GetWitcherPlayer().CanUseSkill(S_Perk_19))
			effectValue = GetWitcherPlayer().GetSkillAttributeValue(S_Perk_19, theGame.params.CRITICAL_HIT_CHANCE, false, true);
		else
			effectValue = GetWitcherPlayer().GetSkillAttributeValue(S_Sword_5, PowerStatEnumToName(CPS_AttackPower), false, true);
	}
}