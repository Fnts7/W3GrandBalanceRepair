/***********************************************************************/
/** Copyright © 2013
/** Author : Tomasz Kozera
/***********************************************************************/

/*
	Aura applicator.
	Auras basically work like in diablo :) They make continuous check for all
	targets within given range and apply given spawn to them.
*/
abstract class W3Effect_Aura extends W3ApplicatorEffect
{
	private saved var isOneTimeOnly : bool;						//if true then the aura will fire once and then disable itself
	protected saved var range : float;							//range of the sphere
	private var flags : int;									//flags for gathering targets, basically do we look for actors or all gameplay entities
	
	// Called continuously to apply the spawns on all targets in range
	event OnUpdate(deltaTime : float)
	{
		var ents : array<CGameplayEntity>;
		var i : int;
	
		super.OnUpdate(deltaTime);
	
		FindGameplayEntitiesInSphere(ents, target.GetWorldPosition(), range, 1000, '', flags);
		
		OnPreApplySpawns(ents);
			
		for(i=0; i<ents.Size(); i+=1)															
			ApplySpawnsOn(ents[i]);
			
		if(isOneTimeOnly)
			isActive = false;
	}
	
	event OnPreApplySpawns(out ents : array<CGameplayEntity>){}	
	
	public function CacheSettings()
	{
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var tmpAuraName, tmpName : name;
		var i : int;
		var tmpFloat : float;
		var tmpBool : bool;
		var type : EEffectType;
	
		super.CacheSettings();
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('effects');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpAuraName);
			EffectNameToType(tmpAuraName, type, tmpName);
			if(effectType == type)
			{
				//aura params
				if(dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'isOneTimeOnly', tmpBool))
					isOneTimeOnly = tmpBool;
				if(dm.GetCustomNodeAttributeValueFloat(main.subNodes[i], 'range', tmpFloat))
				{
					range = tmpFloat;	
				}
				else
				{
					LogAssert(false, "W3Effect_Aura.CacheSettings: no range defined for aura applicator <<" + tmpAuraName + ">>, aborting!");
					return;
				}				
			}
		}
		
		//set if we need to look for gameplay entities or just actors
		if(!HasNeutralSpawn())
			flags = FLAG_OnlyAliveActors;		//if we don't have a neutral => we have only hostile || friendly => we need only actors, not all gameplay entities
		else
			flags = 0;
	}	
}