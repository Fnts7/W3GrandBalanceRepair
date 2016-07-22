/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

class W3Potion_Blizzard extends CBaseGameplayEffect
{
	private saved var slowdownCauserIds : array<int>;		//we need to track IDs of sources that affect the game speed to properly remove them when they cumulate
	private var slowdownFactor : float;
	private var currentSlowMoDuration : float;
	private const var SLOW_MO_DURATION : float;

	default effectType = EET_Blizzard;
	default attributeName = 'slow_motion';
	default SLOW_MO_DURATION = 3.f;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		super.OnEffectAdded(customParams);	
		
		slowdownFactor = CalculateAttributeValue(effectValue);		
	}
	
	public final function IsSlowMoActive() : bool
	{
		return slowdownCauserIds.Size();
	}
	
	public function KilledEnemy()
	{
		if(slowdownCauserIds.Size() == 0)
		{
			theGame.SetTimeScale( slowdownFactor, theGame.GetTimescaleSource(ETS_PotionBlizzard), theGame.GetTimescalePriority(ETS_PotionBlizzard) );
			slowdownCauserIds.PushBack(target.SetAnimationSpeedMultiplier( 1 / slowdownFactor ));			
		}
		
		currentSlowMoDuration = 0.f;
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		RemoveSlowMo();
	}
	
	public function OnTimeUpdated(dt : float)
	{
		if(slowdownCauserIds.Size() > 0)
		{
			super.OnTimeUpdated(dt / slowdownFactor);
			
			currentSlowMoDuration += dt / slowdownFactor;
			if(currentSlowMoDuration > SLOW_MO_DURATION)
			{
				RemoveSlowMo();
			}
		}
		else
		{
			super.OnTimeUpdated(dt);
		}
	}
	
	event OnEffectRemoved()
	{
		RemoveSlowMo();
		
		super.OnEffectRemoved();
	}
	
	private final function RemoveSlowMo()
	{
		var i : int;
		
		for(i=0; i<slowdownCauserIds.Size(); i+=1)
		{
			target.ResetAnimationSpeedMultiplier(slowdownCauserIds[i]);
		}
		
		theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_PotionBlizzard) );
		
		slowdownCauserIds.Clear();
	}
}