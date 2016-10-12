/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_Burning extends W3CriticalDOTEffect
{
	private var cachedMPAC : CMovingPhysicalAgentComponent;
	private var glyphword12Delay : float;
	private var isWithGlyphword12 : bool;
	private var glyphword12Fx : W3VisualFx;
	private var glyphword12BurningChance : float;
	private var glyphword12NotBurnedEntities : array<CGameplayEntity>;

		default criticalStateType = ECST_BurnCritical;
		default effectType = EET_Burning;
		default powerStatType = CPS_SpellPower;
		default resistStat = CDS_BurningRes;
		default canBeAppliedOnDeadTarget = true;
		default glyphword12Delay = 0.f;
	
	public function CacheSettings()
	{
		super.CacheSettings();
		
		allowedHits[EHRT_Igni] = false;
		
		
		blockedActions.PushBack(EIAB_CallHorse);
		blockedActions.PushBack(EIAB_Jump);
		blockedActions.PushBack(EIAB_ThrowBomb);			
		blockedActions.PushBack(EIAB_UsableItem);
		blockedActions.PushBack(EIAB_Parry);
		blockedActions.PushBack(EIAB_Counter);
		
		
		vibratePadLowFreq = 0.1;
		vibratePadHighFreq = 0.2;
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{		
		var vec : Vector;
		var template : CEntityTemplate;
		var chance : SAbilityAttributeValue;
		var surface : CGameplayFXSurfacePost;
		
		if ( this.IsOnPlayer() && thePlayer.IsUsingVehicle() )
		{
			if ( blockedActions.Contains( EIAB_Crossbow ) )
				blockedActions.Remove(EIAB_Crossbow);
		}
		else
			blockedActions.PushBack(EIAB_Crossbow);
	
		super.OnEffectAdded(customParams);
		cachedMPAC = ((CMovingPhysicalAgentComponent)target.GetMovingAgentComponent());
		
		if (isOnPlayer )
		{
			if ( thePlayer.playerAiming.GetCurrentStateName() == 'Waiting' )
				thePlayer.AddCustomOrientationTarget(OT_CustomHeading, 'BurningEffect');
		}
			
		
		if(!target.IsAlive())
			timeLeft = 10;
		
		
		if(EntityHandleGet(creatorHandle) == thePlayer && !isSignEffect)
			powerStatType = CPS_Undefined;
			
		
		if(!isOnPlayer && GetCreator() == thePlayer && thePlayer.HasAbility('Glyphword 12 _Stats', true) && isSignEffect && IsRequiredAttitudeBetween(thePlayer, target, true))
		{
			isWithGlyphword12 = true;
			template = (CEntityTemplate)LoadResource('glyphword_12');
			glyphword12Fx = (W3VisualFx)theGame.CreateEntity(template, target.GetWorldPosition(), target.GetWorldRotation(), , , true);
			glyphword12Fx.CreateAttachment(target, 'pelvis');
			chance = thePlayer.GetAttributeValue('glyphword12_chance');
			glyphword12BurningChance = chance.valueAdditive;
			
			
			surface = theGame.GetSurfacePostFX();
			surface.AddSurfacePostFXGroup(target.GetWorldPosition(), 1, timeLeft, 1, MaxF(5.f, CalculateAttributeValue(target.GetAttributeValue('glyphword12_range'))), 1);
		}
		else
		{
			isWithGlyphword12 = false;
		}

		HandleAnimStopTime();
	}
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		HandleAnimStopTime();
	}

	private function HandleAnimStopTime()
	{
		var animStopTime : float;
		if (!isOnPlayer && (IsAddedByPlayer() || abilityName == 'BurningEffect_DragonsDream1' || abilityName == 'BurningEffect_DragonsDream2' || abilityName == 'BurningEffect_DragonsDream3')
			&& theGame.GetInGameConfigWrapper().GetVarValue('GBRRealisticBurning', 'GBRBurningMode'))
		{
			target.RemoveTimer('StopBurningAnimation');
			
			if (duration > 1.5f
				&& ((abilityName != 'BurningEffect_DancingStar_1' && abilityName != 'BurningEffect_DancingStar_2' && abilityName != 'BurningEffect_DancingStar_3') || RandF() < 0.35f))
			{
				animStopTime = 1.5f + (duration - 1.5f) * 0.4f;
				if (thePlayer.CanUseSkill(S_Magic_s08))
				{
					animStopTime *= 1.0f + 0.06f * thePlayer.GetSkillLevel(S_Magic_s08);
					if (animStopTime >= duration)
						return;
				}
				target.AddTimer('StopBurningAnimation', animStopTime);
			}
		}
	}

	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		target.AddTag(theGame.params.TAG_OPEN_FIRE);
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		
		cachedMPAC = ((CMovingPhysicalAgentComponent)target.GetMovingAgentComponent());
	}

	protected function SetEffectValue()
	{
		var modMult : float;

		super.SetEffectValue();

		if (!isOnPlayer && theGame.GetInGameConfigWrapper().GetVarValue('GBRRealisticBurning', 'GBRBurningDifficulty'))
		{
			if (theGame.GetDifficultyMode() == EDM_Easy)
				modMult = 1.5f;
			else if (theGame.GetDifficultyMode() == EDM_Medium)
				modMult = 1.25f;
			else if (theGame.GetDifficultyMode() == EDM_Hardcore)
				modMult = 0.75f;

			effectValue.valueMultiplicative *= modMult;
		}
	}

	event OnUpdate(deltaTime : float)
	{
		var player : CR4Player = thePlayer;	
		var i : int;
		var range : float;
		var actor : CActor;
		var ents : array<CGameplayEntity>;
		var params 				: SCustomEffectParams;
		var min, max : SAbilityAttributeValue;
	
		if ( this.isOnPlayer )
		{
			if ( player.bLAxisReleased )
				player.SetOrientationTargetCustomHeading( player.GetHeading(), 'BurningEffect' );
			else if ( player.GetPlayerCombatStance() == PCS_AlertNear )
				player.SetOrientationTargetCustomHeading( VecHeading( player.moveTarget.GetWorldPosition() - player.GetWorldPosition() ), 'BurningEffect' );
			else
				player.SetOrientationTargetCustomHeading( VecHeading( theCamera.GetCameraDirection() ), 'BurningEffect' );
		}
		
		else if(isWithGlyphword12)
		{
			glyphword12Delay += deltaTime;
			
			if(glyphword12Delay <= CalculateAttributeValue(player.GetAttributeValue('glyphword12_burning_delay')) )
			{
				range = CalculateAttributeValue(player.GetAttributeValue('glyphword12_range'));
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 12 _Stats', 'duration', min, max);
				FindGameplayEntitiesInCylinder(ents, target.GetWorldPosition(), range, 2.f, 10,,FLAG_OnlyAliveActors + FLAG_ExcludePlayer + FLAG_ExcludeTarget, target);
				
				params.effectType = EET_Burning;
				params.creator = thePlayer;
				params.sourceName = 'glyphword 12';
				params.duration = min.valueAdditive;
				
				
				for(i=0; i<ents.Size(); i+=1)
				{
					actor = (CActor)ents[i];
					
					if(glyphword12NotBurnedEntities.Contains(ents[i]))
						continue;
					
					
					glyphword12NotBurnedEntities.PushBack(ents[i]);
					if(!IsRequiredAttitudeBetween(thePlayer, actor, true, false, false) || (RandF() < glyphword12BurningChance) || actor.HasBuff(EET_Burning))
					{
						continue;
					}
					
					actor.AddEffectCustom(params);					
				}
				
				glyphword12Delay = 0.f;
			}
		}
	
		
		if(cachedMPAC && cachedMPAC.GetSubmergeDepth() <= -1)
			target.RemoveAllBuffsOfType(effectType);
		else
			super.OnUpdate(deltaTime);
	}
	
	event OnEffectRemoved()
	{
		if ( isOnPlayer )	
			thePlayer.RemoveCustomOrientationTarget('BurningEffect');	
	
		target.RemoveTag(theGame.params.TAG_OPEN_FIRE);
		
		if(glyphword12Fx)
		{
			glyphword12Fx.StopAllEffects();
			glyphword12Fx.DestroyAfter(5.f);
		}
		
		super.OnEffectRemoved();

		if (!isOnPlayer && (IsAddedByPlayer() || abilityName == 'BurningEffect_DragonsDream1' || abilityName == 'BurningEffect_DragonsDream2' || abilityName == 'BurningEffect_DragonsDream3')
			&& theGame.GetInGameConfigWrapper().GetVarValue('GBRRealisticBurning', 'GBRBurningMode'))
		{
			target.RemoveTimer('StopBurningAnimation');
		}		
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		var configMod : float;

		if (!isOnPlayer && setInitialDuration)
		{
			configMod = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('GBRRealisticBurning', 'BurningDuration')) / 100;
			duration *= (1.0f + configMod);
		}

		super.CalculateDuration(setInitialDuration);
	}
	
	public function OnTargetDeath()
	{
		
		timeLeft = 10;
	}
	
	
	public function OnTargetDeathAnimFinished()
	{
		
		timeLeft = 10;
	}
	
	public final function IsFromMutation2() : bool
	{
		return sourceName == "Mutation2ExplosionValid";
	}
}