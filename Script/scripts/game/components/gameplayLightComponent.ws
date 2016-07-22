/***********************************************************************/
/** gameplayLightComponent - Class that can manipulate light entities
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Shadi Dadenji
/***********************************************************************/

import class CGameplayLightComponent extends CInteractionComponent
{
	import function SetLight			(toggle:bool) : void;
	import function SetFadeLight		(toggle:bool) : void;
	import function SetInteractive		(toggle:bool) : void;
	
	import function IsLightOn			() : bool;
	import function IsCityLight			() : bool;
	import function IsInteractive		() : bool;
	import function IsAffectedByWeather	() : bool;
	
	
	editable var factOnIgnite 			: name;
	var actionBlockingExceptions 		: array<EInputActionBlock>;
	private saved var restoreItemLAtEnd	: bool;
	
	
	//this event allows us to toggle lights on/off using the interaction button
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if ( activator == thePlayer )
		{
			if( thePlayer.tiedWalk )
			{
				return false;
			}
			
			if( !thePlayer.CanPerformPlayerAction(isEnabledInCombat) )
			{
				return false;
			}
			
			thePlayer.AddAnimEventChildCallback(this,'SetLight','OnAnimEvent_SetLight');
			thePlayer.AddAnimEventChildCallback(this,'UnlockInteraction','OnAnimEvent_UnlockInteraction');
		}
		
		//if light is off
		if(!IsLightOn())
		{
			thePlayer.PlayerStartAction( PEA_IgniLight );
			BlockPlayerLightInteraction();
		}
		else
		{
			thePlayer.PlayerStartAction( PEA_AardLight );
			BlockPlayerLightInteraction();			
		}
		if ( thePlayer.IsHoldingItemInLHand() )
		{
			thePlayer.OnUseSelectedItem( true );
			restoreItemLAtEnd = true;
		}
	}
	
	event OnAnimEvent_SetLight( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventType == AET_DurationEnd )
		{
			ToggleLight();
			thePlayer.RemoveAnimEventChildCallback(this,'SetLight');
		}
	}
	
	event OnAnimEvent_UnlockInteraction( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventType == AET_DurationEnd )
		{
			thePlayer.BlockAllActions( 'LightInteraction', false );
			thePlayer.RemoveAnimEventChildCallback(this,'UnlockInteraction');
			
			if ( restoreItemLAtEnd )
			{
				thePlayer.OnUseSelectedItem( );
				restoreItemLAtEnd = false;
			}
		}
	}
	
	function ToggleLight()
	{
		if ( !IsLightOn() )
		{
			SetLight(true);
			
			//adds Fact on Ignite, added for Quests
			if( factOnIgnite )
			{
				FactsAdd( factOnIgnite, 1 );
			}		
		}
		else
		{
			SetLight(false);
		}
	}
	
	//these get triggered from gameplayEntity
	function AardHit()
	{
		if(IsInteractive())
		{
			if(IsLightOn())
			{
				SetLight(false);
			}
		}
	}
	function IgniHit()
	{
		if(IsInteractive())
		{
			if(!IsLightOn())
			{
				SetLight(true);
			}
		}
	}
	function FrostHit()
	{
		if(IsInteractive())
		{
			if(IsLightOn())
			{
				SetLight(false);
			}
		}
	}
	function FireHit()
	{
		if(IsInteractive())
		{
			if(!IsLightOn())
			{
				SetLight(true);
				
				//adds Fact on Ignite, added for Quests
				if( factOnIgnite )
				{
					FactsAdd( factOnIgnite, 1 );
				}
			}
		}
	}
	function BlockPlayerLightInteraction()
	{
		actionBlockingExceptions.PushBack(EIAB_RunAndSprint);
		actionBlockingExceptions.PushBack(EIAB_Sprint);
		thePlayer.BlockAllActions( 'LightInteraction', true, actionBlockingExceptions );
	}

}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////QUEST BLOCKS//////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

quest function SetLightSignsReaction(value:bool, tag:name)
{
	var comp:CComponent;
	var lightSource:CEntity;

	lightSource = theGame.GetEntityByTag(tag);
	comp = lightSource.GetComponentByClassName('CGameplayLightComponent');

	((CGameplayLightComponent)comp).SetInteractive(value);
}

quest function IsLightOn(tag:name) : bool
{
	var comp:CComponent;
	var lightSource:CEntity;

	lightSource = theGame.GetEntityByTag(tag);
	comp = lightSource.GetComponentByClassName('CGameplayLightComponent');

	return ((CGameplayLightComponent)comp).IsLightOn();
}

quest function SetLights(value:bool, tag:name, optional allowLightsFade:bool)
{
	var comp:CComponent;
	var lightSources:array<CEntity>;
	var i:int;

	theGame.GetEntitiesByTag(tag, lightSources);

	for (i = 0; i < lightSources.Size(); i+=1)
	{
		comp = lightSources[i].GetComponentByClassName('CGameplayLightComponent');
		if ( allowLightsFade )
		{
			((CGameplayLightComponent)comp).SetFadeLight(value);
		}
		else
		{			
			((CGameplayLightComponent)comp).SetLight(value);
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////CONSOLE FUNCS//////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

exec function execSetLight(value:bool, tag:name)
{
	var comp:CComponent;
	var lightSource:CEntity;

	lightSource = theGame.GetEntityByTag(tag);

	comp = lightSource.GetComponentByClassName('CGameplayLightComponent');
	((CGameplayLightComponent)comp).SetLight(value);
}

exec function execIsLightOn(tag:name) : bool
{
	var comp:CComponent;
	var lightSource:CEntity;

	lightSource = theGame.GetEntityByTag(tag);
	comp = lightSource.GetComponentByClassName('CGameplayLightComponent');

	return ((CGameplayLightComponent)comp).IsLightOn();
}

exec function execSetInteractive(value:bool, tag:name)
{
	var comp:CComponent;
	var lightSource:CEntity;

	lightSource = theGame.GetEntityByTag(tag);
	comp = lightSource.GetComponentByClassName('CGameplayLightComponent');

	((CGameplayLightComponent)comp).SetInteractive(value);
}
