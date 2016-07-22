/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3Effect_Drunkenness extends CBaseGameplayEffect
{
	default effectType = EET_Drunkenness;
	default isNegative = true;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		EnableDrunkFx(1.f);
	}
	
	event OnEffectRemoved()
	{
		DisableDrunkFx(1.f);
		/*
		if( target.IsInCombat() )
		{
			FactsRemove( "WasDrunkEntireFight" ); 
		}
		*/
		super.OnEffectRemoved();
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);		
		
		if(!IsPaused())
			EnableDrunkFx(1.f);
	}
	
	protected function OnPaused()
	{
		super.OnPaused();
		DisableDrunkFx();			
	}
	
	protected function OnResumed()
	{
		super.OnResumed();
		EnableDrunkFx();			
	}
}