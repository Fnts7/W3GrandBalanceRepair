/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3Effect_OverEncumbered extends CBaseGameplayEffect
{
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_OverEncumbered;
	
	private var timeSinceLastMessage : float;
	private const var OVERWEIGHT_MESSAGE_DELAY : float;
	
		default OVERWEIGHT_MESSAGE_DELAY = 10.f;
		
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{		
		super.OnEffectAdded(customParams);
		
		if(!isOnPlayer)
		{
			LogAssert(false, "W3Effect_OverEncumbered.OnEffectAdded: adding effect <<" + effectType + ">> on non-player actor - aborting!");
			timeLeft = 0;
			return false;
		}
		
		((CR4Player)target).BlockAction( EIAB_RunAndSprint, 'OverEncumbered', true );
		
		//ShowHudMessage();
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		((CR4Player)target).UnblockAction( EIAB_RunAndSprint, 'OverEncumbered');
	}
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		/*timeSinceLastMessage += dt;
		if(timeSinceLastMessage >= OVERWEIGHT_MESSAGE_DELAY && !target.GetUsedVehicle())
		{
			ShowHudMessage();			
		}*/
	}
	
	/*private final function ShowHudMessage()
	{
		//it's not that important so if something is shown then don't add this to queue
		if(thePlayer.GetHudMessagesSize() == 0)
		{
			thePlayer.DisplayHudMessage(GetLocStringByKeyExt("panel_hud_message_overweight"));
		}
		
		timeSinceLastMessage = 0;
	}*/
}