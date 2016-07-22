/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

//object that will pass custom params to this buff when added on Actor
class W3FrozenEffectCustomParams extends W3BuffCustomParams
{
	var freezeFadeInTime : float;		//fade in time for the effect to wear off
}

//Frozen buff - character is frozen in animation frame.
class W3Effect_Frozen extends W3ImmobilizeEffect
{
	private saved var killOnHit : bool;
	private var bonusDamagePercents : float;
	private saved var targetWasFlying : bool;
	private var pushPriority : EInteractionPriority;
	private var wasKnockedDown : bool;

		default effectType = EET_Frozen;
		default resistStat = CDS_FrostRes;
		default criticalStateType = ECST_Frozen;
		default isDestroyedOnInterrupt = true;
		default killOnHit = false;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var params : W3FrozenEffectCustomParams;
		var	animatedComponent 	: CAnimatedComponent;
		var mpac				: CMovingPhysicalAgentComponent;
		var npc : CNewNPC;
		var isJumping : bool;
		
		super.OnEffectAdded(customParams);
		
		wasKnockedDown = false;	
		animatedComponent = ( CAnimatedComponent )target.GetComponentByClassName( 'CAnimatedComponent' );
		if( animatedComponent )
		{
			params = (W3FrozenEffectCustomParams)customParams;		//cast params to our custom class
			isJumping = false;
						
			//flying enemies will fall on the ground if in air - in all other cases this should not matter
			npc = (CNewNPC)target;
			if(npc)
			{
				mpac = (CMovingPhysicalAgentComponent)target.GetComponentByClassName('CMovingPhysicalAgentComponent');
				
				targetWasFlying = npc.IsFlying();
				if(targetWasFlying)
				{					
					if(mpac)
						mpac.SetAnimatedMovement( false );
				}
				
				//in air
				if(npc.IsVisuallyOffGround() && !targetWasFlying)
				{
					isJumping = true;
				}
			}
			else
			{
				targetWasFlying = false;
			}
			
			if(!isJumping)
			{
				//DISABLED as there is an issue when you start freezing an enemy on the ground and then it jumps up - freeze must be instant
				//different calls based on passed param of fade in time
				/*
				if(!params || params.freezeFadeInTime <= 0.0f )
					animatedComponent.FreezePose();
				else
					animatedComponent.FreezePoseFadeIn( params.freezeFadeInTime );
				*/
				animatedComponent.FreezePose();
					
				//set unpushable
				pushPriority = target.GetInteractionPriority();
				target.SetInteractionPriority(IP_Max_Unpushable);
			}
			else
			{
				//abort if jumping
				isActive = false;
				return true;
			}
		}
		
		if( target.HasBuff( EET_HeavyKnockdown ) || target.HasBuff( EET_Knockdown ) )
		{
			target.SetStatic();
			wasKnockedDown = true;
		}
		effectManager.PauseAllRegenEffects('FrozenEffect');

		if( target.HasTag( 'scolopendromorph' ) )
		{
			target.StopEffect( 'dirt_base' );
		}
	}
	
	event OnEffectAddedPost()
	{
		var dm : CDefinitionsManagerAccessor;
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAddedPost();
		
		if( sourceName == "Mutation 6" )
		{
			//if frozen but not killed, add frost shader on the ground below NPC
			theGame.GetSurfacePostFX().AddSurfacePostFXGroup( target.GetWorldPosition(), 0.3f, duration, 2.f, 5.f, 0 );
		}
		
		//stop cloth simulation
		target.FreezeCloth( true );
		
		//read additional data based on used ability
		dm = theGame.GetDefinitionsManager();		
		dm.GetAbilityAttributeValue(abilityName, 'hpPercDamageBonusPerHit', min, max);
		bonusDamagePercents = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		
		dm.GetAbilityAttributeValue(abilityName, 'killOnHit', min, max);
		killOnHit = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
	}
	
	event OnEffectRemoved()
	{
		var	animatedComponent 	: CAnimatedComponent;
		var mpac				: CMovingPhysicalAgentComponent;
		
		super.OnEffectRemoved();
		
		animatedComponent = ( CAnimatedComponent )target.GetComponentByClassName( 'CAnimatedComponent' );
		if( animatedComponent )
		{
			animatedComponent.UnfreezePoseFadeOut( 1.0f );
			if(targetWasFlying)
			{
				mpac = (CMovingPhysicalAgentComponent)target.GetComponentByClassName('CMovingPhysicalAgentComponent');
				if(mpac)
				{
					mpac.SetAnimatedMovement(true);
				}
			}
		}
		target.SignalGameplayEventParamInt('ForceStopCriticalEffect',(int)criticalStateType);
		effectManager.ResumeAllRegenEffects('FrozenEffect');
		target.RequestCriticalAnimStop();
		
		//set unpushable
		target.SetInteractionPriority(pushPriority);
		if( wasKnockedDown )
		{
			target.SetKinematic( false );
		}
		
		//stop cloth simulation
		target.FreezeCloth( false );
	}
	
	public function KillOnHit() : bool
	{
		return killOnHit;
	}
	
	//override
	public function OnTimeUpdated(deltaTime : float)
	{
		if ( isActive )
		{
			timeActive += deltaTime;
		}
		
		if(pauseCounters.Size() == 0)
		{							
			if( duration != -1 )
				timeLeft -= deltaTime;				
			OnUpdate(deltaTime);	
		}
		
		// Deactivate the finisher if the time in critical effect left is too short to play the finish animation
		/*if( timeLeft <= 1 )
		{
			target.SignalGameplayEvent('DisableFinisher');
		}*/
		
		if(timeLeft <= 0)
		{
			LogCritical("Deactivating not animated CS <<" + criticalStateType + ">>");
			isActive = false;			
		}
	}
	
	//returns damage bonus percents (0-1) that is dealt each time frozen enemy is hit
	public function GetAdditionalDamagePercents() : float
	{
		return bonusDamagePercents;
	}
}