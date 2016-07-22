/***********************************************************************/
/** Copyright © 2015
/** Author : Tomek Kozera
/***********************************************************************/

abstract class W3RepairObjectEnhancement extends CBaseGameplayEffect
{
	protected var usesPerkBonus : bool;
	protected var durUpdates : bool;
	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	default usesPerkBonus = false;
	
	public function OnTimeUpdated(dt : float)
	{
		var hasRuneword5 : bool;
		
		//runeword making the buff last infinitely
		if(isOnPlayer)
			hasRuneword5 = GetWitcherPlayer().HasRunewordActive('Runeword 5 _Stats');
		else
			hasRuneword5 = false;
		
		if(hasRuneword5)
		{
			if( isActive && pauseCounters.Size() == 0)
			{
				timeActive += dt;	
			}
			
			timeLeft = 0.f;
			durUpdates = false;
			return;
		}
		else if(!durUpdates)
		{
			timeLeft = duration - timeActive;
			durUpdates = true;
		}
		
		super.OnTimeUpdated(dt);
	}
}