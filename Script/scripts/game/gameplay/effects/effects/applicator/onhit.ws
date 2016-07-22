/***********************************************************************/
/** Copyright © 2013
/** Author : Tomasz Kozera
/***********************************************************************/

// Applicator which adds spawns each time the buffs target hits someone (e.g. flaming sword)
abstract class W3Effect_ApplicatorOnHit extends W3ApplicatorEffect
{
	private saved var fromSilverSword : bool;		//fired when hitting with silver sword
	private saved var fromSteelSword : bool;		//fired when hitting with steel sword
	private saved var fromSign : bool;				//fired when hitting with signs
	private saved var fromAll : bool;				//fired always
	
	// Applies spawns on victim if flags are met
	public function ProcessOnHit(victim : CActor, silverSword : bool, steelSword : bool, sign : bool)
	{
		if( fromAll || (silverSword && fromSilverSword) || (steelSword && fromSteelSword) || (sign && fromSign))
			ApplySpawnsOn(victim);
	}	
	
	public function CacheSettings()
	{
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var tmpApplicatorName, tmpName : name;
		var i : int;
		var tmpBool : bool;
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
				//applicator params
				if(dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'fromSilverSword', tmpBool))
					fromSilverSword = tmpBool;
				if(dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'fromSteelSword', tmpBool))
					fromSteelSword = tmpBool;
				if(dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'fromSign', tmpBool))
					fromSign = tmpBool;
				if(dm.GetCustomNodeAttributeValueBool(main.subNodes[i], 'fromAll', tmpBool))
					fromAll = tmpBool;
			}
		}
	}	
}