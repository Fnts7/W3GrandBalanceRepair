/***********************************************************************/
/** Copyright © 2015
/** Author : Tomek Kozera
/***********************************************************************/

abstract class W3Mutagen_Effect extends CBaseGameplayEffect
{
	private saved var toxicityOffset : float;
	
	default isPositive = true;
	default isNegative = false;
	default isNeutral = false;
	default isPotionEffect = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var mutParams : W3MutagenBuffCustomParams;
		var witcher : W3PlayerWitcher;
		
		//only works for Geralt
		witcher = GetWitcherPlayer();
		if(target != witcher)
		{
			isActive = false;
			return false;
		}
		
		super.OnEffectAdded(customParams);
		
		mutParams = (W3MutagenBuffCustomParams)customParams;
		toxicityOffset = mutParams.toxicityOffset;
		witcher.AddToxicityOffset(toxicityOffset);
		
		if(witcher.CanUseSkill(S_Alchemy_s13))
		{
			witcher.AddAbilityMultiple(witcher.GetSkillAbilityName(S_Alchemy_s13), witcher.GetSkillLevel(S_Alchemy_s13));
		}
		
		//override icon with item icon
		OverrideIcon( mutParams.potionItemName );		
	}
	
	//override icon with item icon
	public function OverrideIcon( itemName : name )
	{
		iconPath = theGame.GetDefinitionsManager().GetItemIconPath( itemName );
	}
	
	event OnEffectRemoved()
	{
		var witcher : W3PlayerWitcher;
		
		witcher = GetWitcherPlayer();
		witcher.RemoveToxicityOffset(toxicityOffset);
		
		if(witcher.CanUseSkill(S_Alchemy_s13))
		{
			witcher.RemoveAbilityMultiple(witcher.GetSkillAbilityName(S_Alchemy_s13), witcher.GetSkillLevel(S_Alchemy_s13));
		}
		
		target.RemoveAbilityAll( abilityName );

		if( target.HasBuff( EET_Mutation10 ) && target.GetStat( BCS_Toxicity ) == 0.f )
		{
			target.RemoveBuff( EET_Mutation10 );
		}
		
		super.OnEffectRemoved();
	}
	
	public final function GetToxicityOffset() : float
	{
		return toxicityOffset;
	}
}

class W3MutagenBuffCustomParams extends W3PotionParams
{
	var toxicityOffset : float;
}