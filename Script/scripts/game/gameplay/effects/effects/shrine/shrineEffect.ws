/***********************************************************************/
/** Copyright © 2015
/** Author : Tomek Kozera
/***********************************************************************/

abstract class W3Effect_Shrine extends CBaseGameplayEffect
{
	private saved var isFromMutagen23 : bool;
	
	default isPositive = true;
		
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var shrineParams : W3ShrineEffectParams;
		
		super.OnEffectAdded(customParams);
		
		shrineParams = (W3ShrineEffectParams)customParams;
		if(shrineParams)
			isFromMutagen23 = shrineParams.isFromMutagen23;
	}
	
	public function OnTimeUpdated( dt : float )
	{
		//perk enabling only one shrine buff at a time but with infinite duration
		if( target == GetWitcherPlayer() && GetWitcherPlayer().CanUseSkill( S_Perk_14 ) )
		{
			if( isActive && pauseCounters.Size() == 0)
			{
				timeActive += dt;	
			}
			
			timeLeft = -1.f;
			return;
		}
		else if( timeLeft == -1.f )
		{
			timeLeft = GetInitialDurationAfterResists() - timeActive;
		}
		
		super.OnTimeUpdated( dt );
	}
	
	public final function IsFromMutagen23() : bool		{return isFromMutagen23;}
}

class W3ShrineEffectParams extends W3BuffCustomParams
{
	var isFromMutagen23 : bool;
}
