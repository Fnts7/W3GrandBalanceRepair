/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Tomek Kozera
/***********************************************************************/

/*
	Effect that regenerates particular character stat.
*/
abstract class W3RegenEffect extends CBaseGameplayEffect
{
	protected var regenStat : ECharacterRegenStats;			//regenstat (checked from xml) based on which we set the stat to regenerate - it's set in child classes
	protected saved var stat : EBaseCharacterStats;			//stat to regenerate
	private var isOnMonster : bool;							//if false then buff is on human
		
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnUpdate(dt : float)
	{
		var regenPoints : float;
		var canRegen : bool;
		var hpRegenPauseBuff : W3Effect_DoTHPRegenReduce;
		var pauseRegenVal, armorModVal : SAbilityAttributeValue;
		var baseStaminaRegenVal : float;
		
		super.OnUpdate(dt);
		
		//regen only if stat not maxed or
		if(stat == BCS_Vitality && isOnPlayer && target == GetWitcherPlayer() && GetWitcherPlayer().HasRunewordActive('Runeword 4 _Stats'))
		{
			canRegen = true;
		}
		else
		{
			canRegen = (target.GetStatPercents(stat) < 1);
		}
		
		if(canRegen)
		{
			//max must be read all the time (cannot be cached) because it might change as a result of some other buff
			regenPoints = effectValue.valueAdditive + effectValue.valueMultiplicative * target.GetStatMax(stat);
			
			if (isOnPlayer && regenStat == CRS_Stamina && attributeName == RegenStatEnumToName(regenStat) && GetWitcherPlayer())
			{
				baseStaminaRegenVal = GetWitcherPlayer().CalculatedArmorStaminaRegenBonus();
				//regenPoints *= 1 + armorModVal.valueMultiplicative;
				regenPoints *= 1 + baseStaminaRegenVal;
			}
			//reduced if monster and hp regen lowered due to DOT damage
			else if(regenStat == CRS_Vitality || regenStat == CRS_Essence)
			{
				hpRegenPauseBuff = (W3Effect_DoTHPRegenReduce)target.GetBuff(EET_DoTHPRegenReduce);
				if(hpRegenPauseBuff)
				{
					pauseRegenVal = hpRegenPauseBuff.GetEffectValue();
					regenPoints = MaxF(0, regenPoints * (1 - pauseRegenVal.valueMultiplicative) - pauseRegenVal.valueAdditive);
				}
			}
			
			if( regenPoints > 0 )
				effectManager.CacheStatUpdate(stat, regenPoints * dt);
		}
	}	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var null : SAbilityAttributeValue;
		
		super.OnEffectAdded(customParams);
	
		//deactivate this buff if regen value is undefined
		if(effectValue == null)
		{
			isActive = false;
		}
		else if(target.GetStatMax(stat) <= 0)
		{
			isActive = false;
		}
		CheckMonsterTarget();
	}
	
	private function CheckMonsterTarget()
	{
		var monsterCategory : EMonsterCategory;
		var temp_n : name;
		var temp_b : bool;
		
		theGame.GetMonsterParamsForActor(target, monsterCategory, temp_n, temp_b, temp_b, temp_b);
		isOnMonster = (monsterCategory != MC_Human);
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		CheckMonsterTarget();
	}
	
	public function CacheSettings()
	{
		var i,size : int;
		var att : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var atts : array<name>;
							
		super.CacheSettings();
		
		//find which stat we're regenerating - regenstat set in child classes but let's make sure
		if(regenStat == CRS_Undefined)
		{
			dm = theGame.GetDefinitionsManager();
			dm.GetAbilityAttributes(abilityName, att);
			size = att.Size();
			
			for(i=0; i<size; i+=1)
			{
				regenStat = RegenStatNameToEnum(att[i]);
				if(regenStat != CRS_Undefined)
					break;
			}
		}
		stat = GetStatForRegenStat(regenStat);
		attributeName = RegenStatEnumToName(regenStat);
	}
	
	public function GetRegenStat() : ECharacterRegenStats
	{
		return regenStat;
	}
	
	public function UpdateEffectValue()
	{
		SetEffectValue();
	}
}