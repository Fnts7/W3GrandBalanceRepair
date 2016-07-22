//>--------------------------------------------------------------------------
// W3DestructSelfEntity
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Entity that will destruct itself after some time
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 02-September-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class W3DestructSelfEntity extends CGameplayEntity
{
	private editable var destructAfterDelay	: float;
	private editable var stopEffectDuration	: float;
	private editable var effectToStop 		: name;
	
	hint stopEffectDuration = "time that the effect takes to completely stops. The stop effect function will be called that long before destroying the entity";
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		SetTimer( destructAfterDelay );
	}
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	public final function SetTimer( _DestructAfterDelay : float )
	{
		var delayToStopEffect : float; 
		
		RemoveTimer( 'Destroy' );
		RemoveTimer( 'StopEffectAfter' );
		
		if( _DestructAfterDelay < 0 ) return;
		
		if ( IsNameValid( effectToStop  ) )
		{
			delayToStopEffect = ClampF( destructAfterDelay - stopEffectDuration, 0, destructAfterDelay );
			AddTimer('StopEffectAfter', delayToStopEffect ,false, , , true);
		}
		
		DestroyAfter( destructAfterDelay );
		
	}
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	private final timer function StopEffectAfter( delta : float , id : int)
	{
		StopEffect( effectToStop );
	}
	
}