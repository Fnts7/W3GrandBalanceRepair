//>---------------------------------------------------------------------
// Witcher Script file - Duration Obstacle 
//----------------------------------------------------------------------
// Obstacle that will disappear after some time.
//----------------------------------------------------------------------
// R.Pergent - 01-April-2014
// Copyright © 2014 CDProjektRed
//----------------------------------------------------------------------
class W3DurationObstacle extends CGameplayEntity
{
	//>---------------------------------------------------------------------
	// VARIABLES
	//----------------------------------------------------------------------
	protected editable var	lifeTimeDuration				: SRangeF;
	protected editable var	disappearanceEffectDuration		: float; default disappearanceEffectDuration 	= 3;
	protected editable var	disappearEffectName				: name;
	protected editable var	simplyStopEffect				: bool;
	
	hint simplyStopEffect = "Instead of playing a new effect when disappear, will just stop the named effect";
	//>---------------------------------------------------------------------
	//----------------------------------------------------------------------
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if ( lifeTimeDuration.min > 0 || lifeTimeDuration.max > 0 )
		{
			AddTimer('Disappear', RandRangeF( lifeTimeDuration.max, lifeTimeDuration.min) , false, , , true);
		}
	}
	//>---------------------------------------------------------------------
	//----------------------------------------------------------------------
	public timer function Disappear( optional delta:float, optional id : int)
	{
		if( simplyStopEffect )
		{
			StopEffect( disappearEffectName );
		}
		else
		{
			PlayEffect( disappearEffectName );
		}
		AddTimer('DestroyTimer', disappearanceEffectDuration, false, , , true);
		
		SpecificDisappear();
	}
	//>---------------------------------------------------------------------
	// This function is meant to be overridden (as we cannot override timers)
	//----------------------------------------------------------------------
	private function SpecificDisappear()
	{	
	}
}