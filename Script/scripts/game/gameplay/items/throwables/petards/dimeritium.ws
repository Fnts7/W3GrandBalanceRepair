﻿/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

class W3Dimeritium extends W3Petard
{
	editable var affectedFX, affectedFXCluster : name;	
	private var disableTimerCalled : bool;
	private const var DISABLED_FX_CHECK_DELAY : float;
	private var disabledFxDT : float;
	
		hint affectedFX = "Additional FX that is added when there are affected targets in the area";
		hint affectedFXCluster = "Additional FX for Clusters that is added when there are affected targets in the area";
		
		default disableTimerCalled = false;
		default DISABLED_FX_CHECK_DELAY = 1.f;

	/*script*/ event OnImpact()
	{
		super.OnImpact();
		
		//HACK: for some reason this doesn't work with default keyword;
		disabledFxDT = DISABLED_FX_CHECK_DELAY;
	}
	
	protected function ProcessMechanicalEffect(targets : array<CGameplayEntity>, isImpact : bool, optional dt : float)
	{
		var i : int;
		var witcher : W3PlayerWitcher;
		var rift : CRiftEntity;
	
		super.ProcessMechanicalEffect(targets, isImpact, dt);
			
		//abort witcher quen cast
		witcher = GetWitcherPlayer();
		if(targets.Contains(witcher) && witcher.GetCurrentlyCastSign() == ST_Quen)
			witcher.CastSignAbort();
			
		//abort npc quen cast
		//TODO
		
		//close rifts
		for(i=0; i<targets.Size(); i+=1)
		{
			rift = (CRiftEntity)targets[i];
			if(rift)
			{	
				rift.PlayEffect( 'rift_dimeritium' );
				rift.DeactivateRiftIfPossible();
			}
		}
	}
	
	protected function LoopFunction(dt : float)
	{
		var skill : ESkill;
		var i, j : int;
		var blocked, isPlayer : bool;
		var actor : CActor;
		
		super.LoopFunction(dt);
		
		//delay for checking: performance
		disabledFxDT -= dt;
		if( disabledFxDT > 0.f )
		{
			return;
		}
		disabledFxDT = DISABLED_FX_CHECK_DELAY;
		
		//check if there is at least one target in range which is affected by the bomb
		blocked = false;
		for(i=0; i<targetsSinceLastCheck.Size(); i+=1)
		{
			actor = (CActor)targetsSinceLastCheck[i];
			if(!actor)
				continue;
				
			if(actor == thePlayer)
				isPlayer = true;
			else
				isPlayer = false;
				
			for(j=0; j<loopParams.disabledAbilities.Size(); j+=1)
			{
				//check if it's skill				
				if(isPlayer)
				{
					skill = SkillNameToEnum(loopParams.disabledAbilities[j].abilityName);
					blocked = thePlayer.IsSkillBlocked(skill);
				}
				else
				{
					blocked = actor.IsAbilityBlocked(loopParams.disabledAbilities[j].abilityName);
				}
	
				if(blocked)
					break;
			}
			
			if(blocked)
				break;
		}	
		
		//show additional fx if someone is in and has something blocked
		if(blocked)
		{
			if(isCluster && IsNameValid(affectedFXCluster))
				PlayEffectInternal(affectedFXCluster);
			else
				PlayEffectInternal(affectedFX);
				
			RemoveTimer('DisableAffectedFx');
			disableTimerCalled = false;
		}
		else if(!disableTimerCalled)
		{
			disableTimerCalled = true;
			AddTimer('DisableAffectedFx', 0.5);
		}
	}
	
	timer function DisableAffectedFx(dt : float, id : int)
	{
		StopEffect(affectedFXCluster);
		StopEffect(affectedFX);
	}
	
	//called when target leaves loop AoE
	protected function ProcessTargetOutOfArea(entity : CGameplayEntity)
	{
		var bombLevel, i : int;
		var duration : float;
		var target : CActor;
		var min, max : SAbilityAttributeValue;
		
		if(GetOwner() == thePlayer)
		{
			target = (CActor)entity;
			
			if(target && target.IsAlive())
			{
				theGame.GetDefinitionsManager().GetItemAttributeValueNoRandom(itemName, true, 'level', min, max);
				bombLevel = RoundMath(CalculateAttributeValue(min));
				
				//if friendly actor - remove ability locks
				if(GetAttitudeBetween(GetOwner(), target) == AIA_Friendly && !friendlyFire)
				{
					for(i=0; i<loopParams.disabledAbilities.Size(); i+=1)
					{
						BlockTargetsAbility(target, loopParams.disabledAbilities[i].abilityName, 0.f, true);
					}
				}
				//if not friendly and level 3 - block abilities for some more
				else if(bombLevel == 3)
				{
					theGame.GetDefinitionsManager().GetItemAttributeValueNoRandom(itemName, true, 'duration_out_of_cloud', min, max);
					duration = CalculateAttributeValue(min);
					
					for(i=0; i<loopParams.disabledAbilities.Size(); i+=1)
					{
						target.BlockAbility(loopParams.disabledAbilities[i].abilityName, true, duration);
					}
				}					
			}
		}
	}
}