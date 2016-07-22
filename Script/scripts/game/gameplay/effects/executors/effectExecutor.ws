/***********************************************************************/
/** Copyright © 2013
/** Author : Marek Roefler, Tomasz Kozera
/***********************************************************************/
/*
	Executors are used in combat focus mode to deliver special effects to hit
	target. The effect be either a buff (via CBuffEffectExecutor) or 
	some instant effect (via IInstantEffectExecutor). 
	Buffs provide effects with duration while instants perform some
	actions and are finished.
*/

// Base class for executors
import abstract class IGameplayEffectExecutor extends CObject
{
	// Performs execution of this effect
	public function Execute( executor : CGameplayEntity, target : CActor, optional source : string ) : bool
	{
		// Implement execution in derived classes
		return false;
	}
	
	public function GetEffectIconPath() : string {return "";}
	public function GetEffectNameLocalisationKey() : string {return "";}
	public function GetEffectDescriptionLocalisationKey() : string {return "";}
}

// Executor class for instant effects 
abstract class IInstantEffectExecutor extends IGameplayEffectExecutor
{
	protected editable var customIconPath : string;						//optional field for custom icon path (overrides the XML default)
	protected editable var customNameLocalisationKey : string;			//optional field for effect's name localization key (overrides the XML default)
	protected editable var customDescriptionLocalisationKey : string;	//optional field for effect's description localization key (overrides the XML default)
	protected var executorName : name;									//must be defined in each child class!!!
		default executorName = '';
	
	hint customIconPath = "Will override XML default";
	hint customNameLocalisationKey = "Will override XML default";
	hint customDescriptionLocalisationKey = "Will override XML default";
		
	public function Execute( executor : CGameplayEntity, target : CActor, optional source : string ) : bool
	{
		// Implement execution in derived classes
		return false;
	}
	
	public final function GetEffectIconPath() : string
	{
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var tmpName, iconTypeName : name;
		var tmpString : string;
		var i : int;
		
		if(customIconPath != "")
			return customIconPath;
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('CFM_instants');
		
		//get icon type
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName))
			{
				if(IsNameValid(tmpName) && tmpName == executorName)
				{
					if(dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'iconType_name', tmpString))
					{
						iconTypeName = tmpName;
						break;
					}
				}
			}
		}
		
		//get icon path
		main = dm.GetCustomDefinition('CFM_instants_icons');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'iconType_name', tmpName))
			{
				if(IsNameValid(tmpName) && tmpName == iconTypeName)
				{
					dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'path', tmpString);
					return tmpString;
				}
			}
		}
		
		LogAssert(false, "IGameplayEffectExecutor.GetEffectIconPath: icon path undefined for executor <<" + executorName + ">>");
		return "";
	}
	
	public final function GetEffectNameLocalisationKey() : string
	{
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var tmpName : name;
		var tmpString : string;
		var i : int;
		
		if(customNameLocalisationKey != "")
			return customNameLocalisationKey;
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('CFM_instants');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName))
			{
				if(IsNameValid(tmpName) && tmpName == executorName)
				{
					dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'nameLocalisationKey', tmpString);
					return tmpString;
				}
			}
		}
		
		LogAssert(false, "IGameplayEffectExecutor.GetEffectNameLocalisationKey: name localisation key undefined for executor <<" + executorName + ">>");
		return "";
	}
	
	public final function GetEffectDescriptionLocalisationKey() : string
	{
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var tmpName : name;
		var tmpString : string;
		var i : int;
		
		if(customDescriptionLocalisationKey != "")
			return customDescriptionLocalisationKey;
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('CFM_instants');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName))
			{
				if(IsNameValid(tmpName) && tmpName == executorName)
				{
					dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'descriptionLocalisationKey', tmpString);
					return tmpString;
				}
			}
		}
		
		LogAssert(false, "IGameplayEffectExecutor.GetEffectDescriptionLocalisationKey: description localisation key undefined for executor <<" + executorName + ">>");
		return "";
	}
}

//////////////////////////////////////////////////////////////////

// Class for executors that apply buff as their result
class CBuffEffectExecutor extends IGameplayEffectExecutor
{
	private editable var effectType			: EEffectType;				//effect to use
	private editable var duration			: float;					//custom duration
	private editable var customEffectValue	: SAbilityAttributeValue;	//custom effect value
	
	public function Execute( executor : CGameplayEntity, target : CActor, optional source : string ) : bool
	{
		var params : SCustomEffectParams;
		
		params.effectType = effectType;
		params.creator = executor;
		params.sourceName = source;
		params.duration = duration;
		params.effectValue = customEffectValue;
		
		target.AddEffectCustom(params);
		return true;
	}
	
	public function GetEffectNameLocalisationKey() : string
	{
		return theGame.effectMgr.GetEffectNameLocalisationKey( effectType );
	}
	
	public function GetEffectDescriptionLocalisationKey() : string
	{
		return theGame.effectMgr.GetEffectDescriptionLocalisationKey( effectType );
	}

	public function GetEffectIconPath() : string
	{
		return theGame.effectMgr.GetEffectIconPath( effectType );
	}
}