/***********************************************************************/
/** Copyright © 2013
/** Author : Tomasz Kozera
/***********************************************************************/

// Instant death executor buff - kills the owner
class W3Executor_InstantDeath extends IInstantEffectExecutor
{
	default executorName = 'InstantDeath';

	public function Execute( executor : CGameplayEntity, target : CActor, optional source : string ) : bool
	{
		if(target)
		{
			target.Kill( 'Combat Focus Mode', executor);
			return true;
		}
		return false;
	}	
}