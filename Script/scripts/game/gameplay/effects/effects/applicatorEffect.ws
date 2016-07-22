/***********************************************************************/
/** Copyright © 2013
/** Author : Tomasz Kozera
/***********************************************************************/

/*
	Base class for applicator type buffs. Applicators are buffs which only purpose 
	is to apply other buffs (called spawns) when certain conditions are met.
	Different conditions are defined for different subclasses of the ApplicatorEffect.
	
	As a brief example if we have an aura that sets all enemies in 5m range on fire then
	we define an aura buff (ApplicatorEffect) which constantly applies the burning
	effect (SpawnEffect) to targets within range.
*/
abstract class W3ApplicatorEffect extends CBaseGameplayEffect
{
	protected saved var spawns : array<SApplicatorSpawnEffect>;		//stats of the 'spawn effects' to use
	
		default isPositive = true;
	
	/*
		Applies spawn effects on given target. Effects won't be applied if attitude between 
		this buff's owner and victim are not proper (e.g. hostile for negative buff or non-hotile for positive buff).
		
		Since non-actor gameplay entities have no possibility of having buffs they are ignored. We might think about
		adding Executors here as well and then applying them to gameplay entities. This way e.g. fire damage aura would
		damage debris, doors etc.
	*/
	protected function ApplySpawnsOn(victimGE : CGameplayEntity)
	{
		var i : int;
		var victim : CActor;
		var params : SCustomEffectParams;
	
		victim = (CActor)victimGE;
		if(!victim)
			return;
	
		for(i=0; i<spawns.Size(); i+=1)
		{
			//if buff is negative then don't apply it on the entity that has the aura - makes no sense, performance upgrade
			if(victim == GetCreator() && theGame.effectMgr.IsBuffNegative(spawns[i].spawnType))
				continue;
					
			if( IsRequiredAttitudeBetween(victim, GetCreator(), spawns[i].spawnFlagsHostile, spawns[i].spawnFlagsNeutral, spawns[i].spawnFlagsFriendly) )
			{
				params.effectType = spawns[i].spawnType;
				params.creator = GetCreator();
				params.sourceName = spawns[i].spawnSourceName;
				params.customAbilityName = spawns[i].spawnAbilityName;
				
				victim.AddEffectCustom(params);
			}
		}
	}	

	// Returns true if at least one of the spawns targets neutrals
	protected function HasNeutralSpawn() : bool
	{
		var i : int;
		
		for(i=0; i<spawns.Size(); i+=1)
			if(spawns[i].spawnFlagsNeutral)
				return true;
		
		return false;
	}
	
	/*
		Call to update params of this applicator. You might need to call this if e.g. the params influence
		the strength of spawn effects.
		
		Let's say that you have a permanent healing aura. Then whenever you level up or increase your 
		spell power you need to call this function so that spawn effects created from now on would use
		the new (increased) stats.
	*/
	public function UpdateParams()
	{
		var actor : CActor;
	
		actor = (CActor)GetCreator();
		if(!actor)
			return;
	
		actor.GetApplicatorParamsFor(this, creatorPowerStat);
	}
	
	public function CacheSettings()
	{
		var appliedEffects : array<SCustomNode>;
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var tmpName, effectName, tmpApplicatorName : name;
		var i,j : int;
		var tmpFloat : float;
		var tmpBool : bool;
		var tmpSpawn : SApplicatorSpawnEffect;
		var type : EEffectType;
	
		super.CacheSettings();
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('effects');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpApplicatorName);
			EffectNameToType(tmpApplicatorName, type, tmpName);
			if(effectType == type)
			{			
				//applied effects' stats
				appliedEffects = main.subNodes[i].subNodes;
				
				for(j=0; j<appliedEffects.Size(); j+=1)
				{
					if(dm.GetCustomNodeAttributeValueName(appliedEffects[j], 'name_name', effectName))
					{						
						EffectNameToType(effectName, type, effectName);
						tmpSpawn.spawnType = type;
						if(tmpSpawn.spawnType == EET_Undefined)
						{
							LogAssert(false, "W3ApplicatorEffect.CacheSettings: spawn effect <<" + tmpName +">> of applicator <<" + tmpApplicatorName + ">> is not defined! Skipping!");
							continue;
						}
					}
					
					if(dm.GetCustomNodeAttributeValueName(appliedEffects[j], 'customAbilityName_name', tmpName))
						tmpSpawn.spawnAbilityName = tmpName;
									
					if(dm.GetCustomNodeAttributeValueBool(appliedEffects[j], 'affectsHostile', tmpBool))
						tmpSpawn.spawnFlagsHostile = tmpBool;
					if(dm.GetCustomNodeAttributeValueBool(appliedEffects[j], 'affectsNeutral', tmpBool))
						tmpSpawn.spawnFlagsNeutral = tmpBool;
					if(dm.GetCustomNodeAttributeValueBool(appliedEffects[j], 'affectsFriendly', tmpBool))					
						tmpSpawn.spawnFlagsFriendly = tmpBool;
					
					if(!tmpSpawn.spawnFlagsHostile && !tmpSpawn.spawnFlagsNeutral && !tmpSpawn.spawnFlagsFriendly)
					{
						LogAssert(false, "W3ApplicatorEffect.CacheSettings: effect <<" + effectName +">> of applicator <<" + tmpApplicatorName + ">> has no hostility flags set! Aborting!");
						continue;
					}
					
					spawns.PushBack(tmpSpawn);
					
					//clear temp for further use
					tmpSpawn.spawnType = EET_Undefined;
					tmpSpawn.spawnAbilityName = '';
					tmpSpawn.spawnFlagsHostile = false;
					tmpSpawn.spawnFlagsNeutral = false;
					tmpSpawn.spawnFlagsFriendly = false;
					tmpSpawn.spawnSourceName = "";
				}
				break;
			}
		}
	}	
}