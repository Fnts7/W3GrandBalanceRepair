/***********************************************************************/
/** Copyright © 2013-2014
/** Author : Wojtek Żerek
/***********************************************************************/

class W3Effect_Snowstorm extends W3CriticalDOTEffect
{
	protected saved var usesCam : bool;
	
	default effectType = EET_Snowstorm;
	default criticalStateType = ECST_Snowstorm;
		
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var params : W3SnowstormCustomParams;
		
		usesCam = false;
		
		if( isOnPlayer )
		{
			//dafuq?
			thePlayer.UnblockAction( EIAB_Interactions, EffectTypeToName( effectType ) );
			
			//cam settings
			params = (W3SnowstormCustomParams)customParams;
			if(params && params.showCamEffect)
			{
				usesCam = true;				
			}
		}
		
		PlayEffects();
		
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		//Snowstorm of any buff needs to break quen as it causes issues with quests
		if(isOnPlayer && GetWitcherPlayer())
			GetWitcherPlayer().FinishQuen(false);
	}
	
	protected function OnPaused()
	{
		super.OnPaused();
		StopEffects();
	}
	
	protected function OnResumed()
	{
		super.OnResumed();
		PlayEffects();
	}
	
	
	event OnEffectRemoved()
	{
		StopEffects();		
		super.OnEffectRemoved();
	}
	
	protected function StopEffects()
	{
		target.StopEffectIfActive( 'critical_frozen' );
		target.StopEffectIfActive( 'ice_breath_gameplay' );
		
		if(usesCam)
		{
			theGame.GetGameCamera().StopEffect( 'frost' );
		}
	}
	
	protected function PlayEffects()
	{
		target.PlayEffectSingle( 'critical_frozen' );
		target.PlayEffectSingle( 'ice_breath_gameplay' );
		
		if(usesCam)
		{
			theGame.GetGameCamera().PlayEffect( 'frost' );
		}
	}
}

class W3SnowstormCustomParams extends W3BuffCustomParams
{
	editable var showCamEffect : bool;
}