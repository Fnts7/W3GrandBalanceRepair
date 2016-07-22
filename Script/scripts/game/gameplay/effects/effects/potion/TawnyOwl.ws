/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Tomek Kozera
/***********************************************************************/

// increases stamina regen
class W3Potion_TawnyOwl extends W3RegenEffect
{
	default effectType = EET_TawnyOwl;
	
	public function OnTimeUpdated(deltaTime : float)
	{
		var currentHour, level : int;
		var toxicityThreshold : float;
		
		if( isActive && pauseCounters.Size() == 0)
		{
			timeActive += deltaTime;	
			if( duration != -1 )
			{
				//tick time only if it's not night
				level = GetBuffLevel();				
				currentHour = GameTimeHours(theGame.GetGameTime());
				if(level < 3 || (currentHour > GetHourForDayPart(EDP_Dawn) && currentHour < GetHourForDayPart(EDP_Dusk)) )
					timeLeft -= deltaTime;
					
				if( timeLeft <= 0 )
				{
					if ( thePlayer.CanUseSkill(S_Alchemy_s03) )
					{
						toxicityThreshold = thePlayer.GetStatMax(BCS_Toxicity);
						toxicityThreshold *= 1 - CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Alchemy_s03, 'toxicity_threshold', false, true) ) * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s03);
					}
					if(isPotionEffect && target == thePlayer && thePlayer.CanUseSkill(S_Alchemy_s03) && thePlayer.GetStat(BCS_Toxicity, true) > toxicityThreshold)
					{
						//keep it going for as long as there is some toxicity left
					}
					else
					{
						isActive = false;		//this will be the last call
					}
				}
			}
			OnUpdate(deltaTime);	
		}
	}
}