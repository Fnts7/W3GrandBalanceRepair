/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Rafal Jarczewski, Andrzej Kwiatkowski, Tomek Kozera
/***********************************************************************/

class W3Effect_Trap extends W3CriticalEffect
{
	default criticalStateType			= ECST_Trap;
	default effectType 					= EET_Trap;
	default isDestroyedOnInterrupt 		= true;
	default airHandling 				= ECH_HandleNow;
	default postponeHandling 			= ECH_Abort;
	default attachedHandling			= ECH_Abort;
	default onHorseHandling				= ECH_HandleNow;
	default canBeAppliedOnDeadTarget 	= true;
	default	explorationStateHandling 	= ECH_HandleNow;
	default usesFullBodyAnim			= true;
	default resistStat 					= CDS_ForceRes;
	
	public function CacheSettings()
	{
		super.CacheSettings();
		
		allowedHits[EHRT_Light] = false;
		allowedHits[EHRT_LightClose] = false;
		allowedHits[EHRT_Heavy] = false;
		allowedHits[EHRT_Igni] = false;
		
	}
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		if(isOnPlayer)
		{
			thePlayer.OnRangedForceHolster( true, true, false );
			thePlayer.PlayEffectSingle('q704_trap_loop');
			thePlayer.BlockAllActions('W3Effect_Trap', true);
			thePlayer.FinishQuen(false);
		}

	}
	
	event OnEffectRemoved()
	{
		if(isOnPlayer)
		{
			thePlayer.StopEffect('q704_trap_loop');
			thePlayer.SetBehaviorVariable( 'bCriticalStopped', 1 );
			thePlayer.BlockAllActions('W3Effect_Trap', false);
		}
		//movementAdjustor.Cancel( ticket );
		
		super.OnEffectRemoved();
	}
}