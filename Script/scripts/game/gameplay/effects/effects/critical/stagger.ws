/***********************************************************************/
/** Copyright © 2012-2014
/** Author : Rafal Jarczewski, Andrzej Kwiatkowski, Tomek Kozera
/***********************************************************************/

class W3Effect_Stagger extends W3CriticalEffect
{
	public var timeToEnableDodge : float;
	
	default timeToEnableDodge			= 1.f;
	default criticalStateType			= ECST_Stagger;
	default effectType 					= EET_Stagger;
	default isDestroyedOnInterrupt 		= true;
	default postponeHandling 			= ECH_Abort;
	default airHandling 				= ECH_Abort;
	default attachedHandling 			= ECH_Abort;
	default onHorseHandling 			= ECH_Abort;
	default usesFullBodyAnim			= true;
	
	public function CacheSettings()
	{
		super.CacheSettings();
	
		blockedActions.PushBack(EIAB_Signs);
		blockedActions.PushBack(EIAB_DrawWeapon);
		blockedActions.PushBack(EIAB_CallHorse);
		blockedActions.PushBack(EIAB_Movement);
		blockedActions.PushBack(EIAB_Fists);
		blockedActions.PushBack(EIAB_Jump);
		//blockedActions.PushBack(EIAB_RunAndSprint);
		blockedActions.PushBack(EIAB_ThrowBomb);
		blockedActions.PushBack(EIAB_Crossbow);
		blockedActions.PushBack(EIAB_UsableItem);
		blockedActions.PushBack(EIAB_SwordAttack);
		blockedActions.PushBack(EIAB_Parry);
		//blockedActions.PushBack(EIAB_Sprint);
		blockedActions.PushBack(EIAB_Explorations);
		blockedActions.PushBack(EIAB_Counter);
		blockedActions.PushBack(EIAB_LightAttacks);
		blockedActions.PushBack(EIAB_HeavyAttacks);
		blockedActions.PushBack(EIAB_SpecialAttackLight);
		blockedActions.PushBack(EIAB_SpecialAttackHeavy);
		blockedActions.PushBack(EIAB_QuickSlots);
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var tags : array<name>;
		var i : int;
		var actor : CActor;
		
		if(isOnPlayer)
		{
			blockedActions.PushBack( EIAB_Dodge );
			blockedActions.PushBack( EIAB_Roll );

		}
			
		super.OnEffectAdded(customParams);
				
		if (isOnPlayer && !thePlayer.IsUsingVehicle() )
		{
			actor = (CActor)EntityHandleGet(creatorHandle);
			if(actor)
			{
				thePlayer.SetCustomRotation( 'Stagger',  VecHeading( actor.GetWorldPosition() - thePlayer.GetWorldPosition() ), 0.0f, 0.2f, false );
				
				if( actor.HasTag( 'olgierd_gpl' ) && actor.HasAbility( 'SandAttack' ) )
				{
					actor.PlayEffect( 'smoke_throw_screen' );
				}
			}
		}
		
		//info for quest conditions
		tags = target.GetTags();
		for(i=0; i<tags.Size(); i+=1)
			FactsAdd("actor_"+NameToString(tags[i])+"_was_stunned",1,CeilF(duration)+1 );	//valid for stun duration + 1 sec
	}
	
	public function OnTimeUpdated(dt : float)
	{
		super.OnTimeUpdated(dt);
		
		timeToEnableDodge -= dt;
		if(timeToEnableDodge <= 0.f && isOnPlayer)
		{
			thePlayer.UnblockAction( EIAB_Dodge, EffectTypeToName( effectType ) );
			thePlayer.UnblockAction( EIAB_Roll, EffectTypeToName( effectType ) );
		}
		
		if(target.IsInAir())
		{
			target.RequestCriticalAnimStop(false);
		}
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		if(isOnPlayer)
		{
			thePlayer.UnblockAction( EIAB_Dodge, EffectTypeToName( effectType ) );
			thePlayer.UnblockAction( EIAB_Roll, EffectTypeToName( effectType ) );
		}
	}
}
