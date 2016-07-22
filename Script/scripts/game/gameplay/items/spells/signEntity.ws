statemachine abstract class W3SignEntity extends CGameplayEntity
{
	// cached owner of this sign entity
	protected 	var owner 				: W3SignOwner;
	protected 	var attachedTo 			: CEntity;
	protected 	var boneIndex 			: int;
	protected 	var fireMode 			: int;
	protected 	var skillEnum 			: ESkill;
	public    	var signType 			: ESignType;
	public    	var actionBuffs   		: array<SEffectInfo>;	
	editable  	var friendlyCastEffect	: name;
	protected		var cachedCost			: float;
	protected 	var usedFocus			: bool;
	
	public function GetSignType() : ESignType
	{
		return ST_None;
	}
	
	event OnProcessSignEvent( eventName : name )
	{
		LogChannel( 'Sign', "Process anim event " + eventName );
		
		if( eventName == 'cast_begin' )
		{
			//this gets called on EACH sign cast start - but at this point we don't know yet if the cast will succeed or not
			if(owner.GetActor() == thePlayer)
			{
				thePlayer.SetPadBacklightColorFromSign(GetSignType());				
			}
	
			OnStarted();
		}
		else if( eventName == 'cast_throw' )
		{
			OnThrowing();
		}
		else if( eventName == 'cast_end' )
		{
			OnEnded();
		}
		else if( eventName == 'cast_friendly_begin' )
		{
			Attach( true );
		}		
		else if( eventName == 'cast_friendly_throw' )
		{
			OnCastFriendly();
		}
		else
		{
			return false;
		}
		
		return true;
	}
	
	public function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool ) : bool
	{
		var player : CR4Player;
		var focus : SAbilityAttributeValue;
		var witcher: W3PlayerWitcher;
		
		owner = inOwner;
		fireMode = 0;
		GetSignStats();
		
		if ( skipCastingAnimation || owner.InitCastSign( this ) )
		{
			if(!notPlayerCast)
			{
				owner.SetCurrentlyCastSign( GetSignType(), this );				
				CacheActionBuffsFromSkill();
			}
			
			// send event for reactions only when animation is played;
			if ( !skipCastingAnimation )
			{
				AddTimer( 'BroadcastSignCast', 0.8, false, , , true );
			}
			
			//add adrenaline if player has skill
			player = (CR4Player)owner.GetPlayer();
			if(player && !notPlayerCast && player.CanUseSkill(S_Perk_10))
			{
				focus = player.GetAttributeValue('focus_gain');
				//bonus from skill
				if ( player.CanUseSkill(S_Sword_s20) )
				{
					focus += player.GetSkillAttributeValue(S_Sword_s20, 'focus_gain', false, true) * player.GetSkillLevel(S_Sword_s20);
				}
				player.GainStat(BCS_Focus, 0.1f * (1 + CalculateAttributeValue(focus)) );	//normally focus has base defined which changes per attack type - here we have no attack type
			}
			
			//mutation 1 custom FX when we start casting sign
			witcher = (W3PlayerWitcher) owner.GetPlayer();
			if( witcher && !notPlayerCast )
			{
				if( witcher.IsMutationActive( EPMT_Mutation1 ) )
				{
					PlayMutation1CastFX();
				}
				else if( witcher.IsMutationActive( EPMT_Mutation6 ) )
				{
					theGame.MutationHUDFeedback( MFT_PlayOnce );
				}
			}
			
 			return true;
		}
		else
		{
			owner.GetActor().SoundEvent( "gui_ingame_low_stamina_warning" );
			CleanUp();
			Destroy();
			return false;
		}
	}
	
	public final function PlayMutation1CastFX()
	{
		var i : int;
		var swordEnt : CItemEntity;
		var swordID : SItemUniqueId;
		var playerFx, swordFx : name;
		
		swordID = GetWitcherPlayer().GetHeldSword();
		if( thePlayer.inv.IsIdValid( swordID ) )
		{
			swordEnt = thePlayer.inv.GetItemEntityUnsafe( swordID );
			if( swordEnt )
			{
				//why cast? because all signs have signType == ST_Aard... Trzymajcie mnie
				if( ( W3AardEntity ) this )
				{
					playerFx = 'mutation_1_aard_power';
					swordFx = 'aard_power';
				}
				else if( ( W3IgniEntity ) this )
				{
					playerFx = 'mutation_1_igni_power';
					swordFx = 'igni_power';
				}
				else if( ( W3QuenEntity ) this )
				{
					playerFx = 'mutation_1_quen_power';
					swordFx = 'quen_power';
				}
				else if( ( W3YrdenEntity ) this )
				{
					playerFx = 'mutation_1_yrden_power';
					swordFx = 'yrden_power';
				}
				else
				{
					return;
				}
				
				thePlayer.PlayEffect( playerFx );
				swordEnt.PlayEffect( swordFx );
			}
		}
		
		//hud helix
		theGame.MutationHUDFeedback( MFT_PlayRepeat );
	}
	
	//called when arbitrarily you start casting (already well inside casting start animation)
	event OnStarted()
	{
		var player : CR4Player;
		
		Attach();
		
		player = (CR4Player)owner.GetActor();
		if(player)
		{
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();			
			player.AddTimer('ResetPadBacklightColorTimer', 2);
		}
	}
		
	//called when the sign's effect should be released - this is last moment when it can be canceled
	event OnThrowing()
	{
	}
	
	//called when arbitrarily you finish casting (a lot before sign cast end anim finishes)
	event OnEnded(optional isEnd : bool)
	{
		var witcher : W3PlayerWitcher;
		var abilityName : name;
		var abilityCount, maxStack : float;
		var min, max : SAbilityAttributeValue;
		var addAbility : bool;
		var mutagen17 : W3Mutagen17_Effect;

		var camHeading : float;
		//
		witcher = (W3PlayerWitcher)owner.GetActor();
		if(witcher && witcher.IsCurrentSignChanneled() && witcher.GetCurrentlyCastSign() != ST_Quen && witcher.bRAxisReleased )
		{
			if ( !witcher.lastAxisInputIsMovement )
			{
				camHeading = VecHeading( theCamera.GetCameraDirection() );
				if ( AngleDistance( GetHeading(), camHeading ) < 0 )
					witcher.SetCustomRotation( 'ChanneledSignCastEnd', camHeading + witcher.GetOTCameraOffset(), 0.0, 0.2, false );
				else
					witcher.SetCustomRotation( 'ChanneledSignCastEnd', camHeading - witcher.GetOTCameraOffset(), 0.0, 0.2, false );
			}
			witcher.ResetLastAxisInputIsMovement();
		}
		
		//use mutagen 17 boost
		witcher = (W3PlayerWitcher)owner.GetActor();
		if(witcher && witcher.HasBuff(EET_Mutagen17))
		{
			 mutagen17 = (W3Mutagen17_Effect)witcher.GetBuff(EET_Mutagen17);
			 if(mutagen17.HasBoost())
			 {
				mutagen17.ClearBoost();
			 }
		}		
		
		//mutagen 22
		if(witcher && witcher.HasBuff(EET_Mutagen22) && witcher.IsInCombat() && witcher.IsThreatened())
		{
			abilityName = witcher.GetBuff(EET_Mutagen22).GetAbilityName();
			abilityCount = witcher.GetAbilityCount(abilityName);
			
			if(abilityCount == 0)
			{
				addAbility = true;
			}
			else
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen22_max_stack', min, max);
				maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
				
				if(maxStack >= 0)
				{
					addAbility = (abilityCount < maxStack);
				}
				else
				{
					addAbility = true;
				}
			}
			
			if(addAbility)
			{
				witcher.AddAbility(abilityName, true);
			}
		}
		
		CleanUp();
	}

	/*//called to abort sign cast
	public function Cancel( optional force : bool )
	{
		CleanUp();
		// Just in case... it must be handled in states
		Destroy();
	}*/
	
	//called to abort sign cast
	event OnSignAborted( optional force : bool )
	{
		CleanUp();
		// Just in case... it must be handled in states	
		Destroy();
	}	

	event OnCheckChanneling()
	{
		return false;
	}

	public function GetOwner() : CActor
	{
		return owner.GetActor();
	}

	//called when sign relevant skill was unequipped
	public function SkillUnequipped( skill : ESkill ){}
	
	//called when sign relevant skill was equipped
	public function SkillEquipped( skill : ESkill ){}

	//called when we do a normal (non-alternate) cast
	public function OnNormalCast()
	{
		if(owner.GetActor() == thePlayer && GetWitcherPlayer().IsInitialized())
			theGame.VibrateControllerLight();	//non-alternate sign cast
	}

	public function SetAlternateCast( newSkill : ESkill )
	{
		fireMode = 1;
		skillEnum = newSkill;
		GetSignStats(); // <--- You should only load the changes... not common stuff again
	}
	
	public function IsAlternateCast() : bool
	{
		return fireMode == 1;
	}

	protected function GetSignStats(){}
		
	protected function CleanUp()
	{	
		owner.RemoveTemporarySkills();
		
		//hide hud mutation helix
		if( (W3PlayerWitcher)owner.GetPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation1 ) )
		{
			theGame.MutationHUDFeedback( MFT_PlayHide );
		}
	}
	
	public function GetUsedFocus() : bool
	{
		return usedFocus;
	}
	
	public function SetUsedFocus( b : bool )
	{
		usedFocus = b;
	}
			
	//WHY THE F*** DOES THIS FUNCTION *** N O T *** ATTACH THE ENTITY!?!?!?!??!?!
	function Attach( optional toSlot : bool, optional toWeaponSlot : bool )
	{		
		var loc : Vector;
		var rot : EulerAngles;	
		var ownerActor : CActor;
		
		ownerActor = owner.GetActor();
		if ( toSlot )
		{
			if (!toWeaponSlot && ownerActor.HasSlot( 'sign_slot', true ) )
			{
				CreateAttachment( ownerActor, 'sign_slot' );			
			}
			else
			{
				CreateAttachment( ownerActor, 'l_weapon' );						
			}
			boneIndex = ownerActor.GetBoneIndex( 'l_weapon' );
			attachedTo = NULL;
		}
		else
		{
			//SEE ANY ATTACHMENTS HERE? I DON'T
			
			attachedTo = ownerActor;
			boneIndex = ownerActor.GetBoneIndex( 'l_weapon' );
			//boneIndex = ownerActor.GetBoneIndex( 'l_hand' );		
		}
		
		if ( attachedTo )
		{
			if ( boneIndex != -1 )
			{
				loc = MatrixGetTranslation( attachedTo.GetBoneWorldMatrixByIndex( boneIndex ) );
				
				//MS: Hack fix for weird Aard rotation (Aard should be using l_weapon but it's not. WTF! )
				if ( ownerActor == thePlayer && (W3AardEntity)this )
				{
					rot = VecToRotation( thePlayer.GetLookAtPosition() - MatrixGetTranslation( thePlayer.GetBoneWorldMatrixByIndex( thePlayer.GetHeadBoneIndex() ) ) );
					rot.Pitch = -rot.Pitch;
					if ( rot.Pitch < 0.f && ( thePlayer.GetPlayerCombatStance() == PCS_Normal || thePlayer.GetPlayerCombatStance() == PCS_AlertFar ) )
						rot.Pitch = 0.f;
					
					thePlayer.GetVisualDebug().AddSphere( 'signEntity', 0.3f, thePlayer.GetLookAtPosition(), true, Color( 255, 0, 0 ), 30.f ); 
					thePlayer.GetVisualDebug().AddArrow( 'signHeading', thePlayer.GetWorldPosition(), thePlayer.GetWorldPosition() + RotForward( rot )*4, 1.f, 0.2f, 0.2f, true, Color(0,128,128), true,10.f );
				}
				else
					rot = attachedTo.GetWorldRotation();
				
				
			}
			else
			{
				loc = attachedTo.GetWorldPosition();
				rot = attachedTo.GetWorldRotation();
			}
			
			//WTF? IT'S (SUPPOSEDLY) ATTACHED SO WHY TELEPORT THIS??? AND WHY TELEPORTING IN LOCALSPACE USING GLOBALSPACE COORDS???
			TeleportWithRotation( loc, rot );
		}
		
		// debug stuff only for player
		if ( owner.IsPlayer() )
		{
			//localrot = this.GetLocalRotation();
			//thePlayer.GetVisualDebug().AddSphere( 'signEntity', 0.3f, this.GetWorldPosition(), true, Color( 255, 0, 0 ), 30.f ); 
			//thePlayer.GetVisualDebug().AddSphere( 'signBone', 0.5f, VecTransformDir(attachedTo.GetBoneWorldMatrixByIndex( boneIndex ),Vector(0,1,0)),true, Color( 0,255,0),30.f);
			//thePlayer.GetVisualDebug().AddArrow( 'signHeading', thePlayer.GetWorldPosition(), thePlayer.GetWorldPosition() + this.GetHeadingVector()*4, 1.f, 0.2f, 0.2f, true, Color(0,128,128), true,10.f );
		}
	}
	
	function Detach()
	{
		BreakAttachment();
		attachedTo = NULL;
		boneIndex = -1;
	}
	
	// Initializes damage info
	public function InitSignDataForDamageAction( act : W3DamageAction)
	{
		act.SetSignSkill( skillEnum );
		FillActionDamageFromSkill( act );
		FillActionBuffsFromSkill( act );
	}	
	
	private function FillActionDamageFromSkill( act : W3DamageAction )
	{
		var attrs : array< name >;
		var i, size : int;
		var val : float;
		var dm : CDefinitionsManagerAccessor;
		
		if ( !act )
		{
			LogSigns( "W3SignEntity.FillActionDamageFromSkill: action does not exist!" );
			return;
		}
				
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributes( owner.GetSkillAbilityName( skillEnum ), attrs );
		size = attrs.Size();
		
		for ( i = 0; i < size; i += 1 )
		{
			if ( IsDamageTypeNameValid( attrs[i] ) )
			{
				val = CalculateAttributeValue( owner.GetSkillAttributeValue( skillEnum, attrs[i], false, true ) );
				act.AddDamage( attrs[i], val );
			}
		}
	}
	
	protected function FillActionBuffsFromSkill(act : W3DamageAction)
	{
		var i : int;
		
		for(i=0; i<actionBuffs.Size(); i+=1)
			act.AddEffectInfo(actionBuffs[i].effectType, , , actionBuffs[i].effectAbilityName);
	}
	
	protected function CacheActionBuffsFromSkill()
	{
		var attrs : array< name >;
		var i, size : int;
		var signAbilityName : name;
		var dm : CDefinitionsManagerAccessor;
		var buff : SEffectInfo;
		
		actionBuffs.Clear();
		dm = theGame.GetDefinitionsManager();
		signAbilityName = owner.GetSkillAbilityName( skillEnum );
		dm.GetContainedAbilities( signAbilityName, attrs );
		size = attrs.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			if( IsEffectNameValid(attrs[i]) )
			{
				EffectNameToType(attrs[i], buff.effectType, buff.effectAbilityName);
				actionBuffs.PushBack(buff);
			}		
		}
	}
	
	public function GetSkill() : ESkill
	{
		return skillEnum;
	}
	
	timer function BroadcastSignCast( deltaTime : float , id : int)
	{		
		// right now we react only to signs casted by player
		if ( owner.IsPlayer() )
		{			
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'CastSignAction', -1, 8.0f, -1.f, -1, true ); //reactionSystemSearch
			if ( GetSignType() == ST_Aard )
			{
				theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( this, 'CastSignActionFar', -1, 30.0f, -1.f, -1, true ); //reactionSystemSearch
			}
			LogReactionSystem( "'CastSignAction' was sent by Player - single broadcast - distance: 10.0" ); 
		}
		// To have different logic for each sign
		BroadcastSignCast_Override();
	}	
	
	function BroadcastSignCast_Override()
	{
	}

	event OnCastFriendly()
	{
		PlayEffect( friendlyCastEffect );
		AddTimer('DestroyCastFriendlyTimer', 0.1, true, , , true);
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'CastSignAction', -1, 8.0f, -1.f, -1, true ); //reactionSystemSearch
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( this, 'CastSignActionFar', -1, 30.0f, -1.f, -1, true ); //reactionSystemSearch
		thePlayer.GetVisualDebug().AddSphere( 'dsljkfadsa', 0.5f, this.GetWorldPosition(), true, Color( 0, 255, 255 ), 10.f );
	}
	
	timer function DestroyCastFriendlyTimer(dt : float, id : int)
	{
		var active : bool;

		active = IsEffectActive( friendlyCastEffect );
			
		if(!active)
		{
			Destroy();
		}
	}
	
	public function ManagePlayerStamina()
	{
		var l_player			: W3PlayerWitcher;
		var l_cost, l_stamina	: float;
		var l_gryphonBuff		: W3Effect_GryphonSetBonus;
		
		l_player = owner.GetPlayer();
		
		l_gryphonBuff = (W3Effect_GryphonSetBonus)l_player.GetBuff( EET_GryphonSetBonus );
		l_gryphonBuff.SetWhichSignForFree( this );
		
		if( !l_gryphonBuff || l_gryphonBuff.GetWhichSignForFree() != this )
		{
			if( l_player.CanUseSkill( S_Perk_09 ) )
			{
				l_cost = l_player.GetStaminaActionCost(ESAT_Ability, SkillEnumToName( skillEnum ), 0);
				l_stamina = l_player.GetStat(BCS_Stamina, true);
				
				if( l_cost > l_stamina )
				{
					l_player.DrainFocus(1);
					SetUsedFocus( true );
				}
				else
				{
					l_player.DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( skillEnum ) );
				}
			}
			else
			{
				l_player.DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( skillEnum ) );
			}
		}		
	}
	
	public function ManageGryphonSetBonusBuff()
	{
		var l_player		: W3PlayerWitcher;
		var l_gryphonBuff	: W3Effect_GryphonSetBonus;
		
		l_player = owner.GetPlayer();
		l_gryphonBuff = (W3Effect_GryphonSetBonus)l_player.GetBuff( EET_GryphonSetBonus );		
		
		if( l_player && l_player.IsSetBonusActive( EISB_Gryphon_1 ) && !l_gryphonBuff && !usedFocus )
		{			
			l_player.AddEffectDefault( EET_GryphonSetBonus, NULL, "gryphonSetBonus" );
		}
		else if( l_gryphonBuff && l_gryphonBuff.GetWhichSignForFree() == this )
		{
			l_player.RemoveBuff( EET_GryphonSetBonus, false, "gryphonSetBonus" );
		}
	}
}

state Finished in W3SignEntity
{
	event OnEnterState( prevStateName : name )
	{
		var player			: W3PlayerWitcher;
		
		player = GetWitcherPlayer();	
		
		//parent.Detach();
		parent.DestroyAfter( 8.f );
		
		if ( parent.owner.IsPlayer() )
		{
			//parent.owner.GetPlayer().RemoveCustomOrientationTarget( 'Signs' );	
			parent.owner.GetPlayer().GetMovingAgentComponent().EnableVirtualController( 'Signs', false );	
		}
		parent.CleanUp();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		if ( parent.owner.IsPlayer() )
		{
			parent.owner.GetPlayer().RemoveCustomOrientationTarget( 'Signs' );
		}
	}
	
	event OnSignAborted( optional force : bool )
	{
		//Already canceled, do nothing
	}
}

state Active in W3SignEntity
{
	var caster : W3SignOwner;
	
	event OnEnterState( prevStateName : name )
	{
		caster = parent.owner;
	}
	
	event OnSignAborted( optional force : bool )
	{
		// This spell is already active, cancel it only when new one is cast
		if( force )
		{
			parent.StopAllEffects();
			parent.GotoState( 'Finished' );
		}
	}
}

state BaseCast in W3SignEntity
{
	var caster : W3SignOwner;
	
	event OnEnterState( prevStateName : name )
	{
		caster = parent.owner;
		if ( caster.IsPlayer() && !( (W3QuenEntity)parent || (W3YrdenEntity)parent ) )
			caster.GetPlayer().GetMovingAgentComponent().EnableVirtualController( 'Signs', true );
	}
	
	event OnLeaveState( nextStateName : name )
	{
		caster.GetActor().SetBehaviorVariable( 'IsCastingSign', 0 );
		caster.SetCurrentlyCastSign( ST_None, NULL );
		LogChannel( 'ST_None', "ST_None" );
	}
	
	event OnThrowing()
	{		
		var l_player : W3PlayerWitcher;
		var l_gryphonBuff : W3Effect_GryphonSetBonus;
		
		l_player = caster.GetPlayer();
		
		if( l_player )
		{
			FactsAdd("ach_sign", 1, 4 );		
			theGame.GetGamerProfile().CheckLearningTheRopes();
			
			l_gryphonBuff = (W3Effect_GryphonSetBonus)l_player.GetBuff( EET_GryphonSetBonus );
			
			if( l_gryphonBuff && !l_gryphonBuff.GetWhichSignForFree() )
			{
				l_gryphonBuff.SetWhichSignForFree( parent );
			}
			
		}
		return true;
	}
	
	event OnEnded(optional isEnd : bool)
	{
		parent.OnEnded(isEnd);
		parent.GotoState( 'Finished' );
	}
	
	event OnSignAborted( optional force : bool )
	{
		var l_gryphonBuff	: W3Effect_GryphonSetBonus;
		
		l_gryphonBuff = (W3Effect_GryphonSetBonus)caster.GetActor().GetBuff( EET_GryphonSetBonus );
		if( l_gryphonBuff )
		{
			l_gryphonBuff.SetWhichSignForFree( NULL );
		}
		
		parent.CleanUp();
		parent.StopAllEffects();
		parent.GotoState( 'Finished' );
	}
}

state NormalCast in W3SignEntity extends BaseCast
{
	event OnEnterState( prevStateName : name )
	{
		var player : CR4Player;
		var cost, stamina : float;
		
		super.OnEnterState(prevStateName);
		
		//FIXME URGENT - WHAT IF CASTER IS NOT PLAYER
		/* 
		caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		
		player = caster.GetPlayer();
		if(player && player.CanUseSkill(S_Perk_09))
		{
			cost = player.GetStaminaActionCost(ESAT_Ability, SkillEnumToName( parent.skillEnum ), 0);
			stamina = player.GetStat(BCS_Stamina, true);
			
			if(cost > stamina)
				player.DrainFocus(1);
		}
		*/
		return true;
	}
	
	event OnEnded(optional isEnd : bool)
	{
		var player : CR4Player;
		var cost, stamina : float;
		
		//FIXME URGENT - WHAT IF CASTER IS NOT PLAYER
		/*
		caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		
		player = caster.GetPlayer();
		if(player && player.CanUseSkill(S_Perk_09))
		{
			cost = player.GetStaminaActionCost(ESAT_Ability, SkillEnumToName( parent.skillEnum ), 0);
			stamina = player.GetStat(BCS_Stamina, true);
			
			if(cost > stamina)
				player.DrainFocus(1);
		}
		*/
		super.OnEnded(isEnd);
	}
}

state Channeling in W3SignEntity extends BaseCast
{
	event OnEnterState( prevStateName : name )
	{
		//all BUT aard enter here in alternate cast
		super.OnEnterState( prevStateName );
		parent.cachedCost = -1.0f;
		
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( parent.owner.GetActor(), 'CastSignAction', -1, 8.0f, 0.2f, -1, true );
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( parent, 'CastSignActionFar', -1, 30.0f, -1.f, -1, true );
	}

	event OnLeaveState( nextStateName : name )
	{
		caster.GetActor().ResumeStaminaRegen( 'SignCast' );
		
		theGame.GetBehTreeReactionManager().RemoveReactionEvent( parent.owner.GetActor(), 'CastSignAction' );
		theGame.GetBehTreeReactionManager().RemoveReactionEvent( parent, 'CastSignActionFar' );
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( parent.owner.GetActor(), 'CastSignAction', -1, 8.0f, -1.f, -1, true );
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( parent, 'CastSignActionFar', -1, 30.0f, -1.f, -1, true );
		//LogChannel( 'CreateReactionEventIfPossible', "CreateReactionEventIfPossible : Stop" );	
		
		super.OnLeaveState( nextStateName );
	}
	
	event OnThrowing()
	{
		var actor : CActor;
		var player : CR4Player;
		var stamina : float;
		
		if( super.OnThrowing() )
		{
			actor = caster.GetActor();
			player = (CR4Player)actor;
			
			if(player)
			{
				if( parent.cachedCost <= 0.0f )
				{
					parent.cachedCost = player.GetStaminaActionCost( ESAT_Ability, SkillEnumToName( parent.skillEnum ), 0 );
				}
			
				stamina = player.GetStat(BCS_Stamina);
			}
			
			actor.DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
			actor.StartStaminaRegen();
			actor.PauseStaminaRegen( 'SignCast' );
			
			if(player && ( parent.cachedCost > stamina ) && ( player.CanUseSkill( S_Perk_10 ) ) )
				player.DrainFocus( 1 );
				
			return true;
		}
		
		return false;
	}
	
	event OnCheckChanneling()
	{
		return true;
	}
	
	//called when channeling all signs EXCEPT aard
	function Update() : bool
	{
		var multiplier, stamina, leftStaminaCostPerc, leftStaminaCost : float;
		var player : CR4Player;
		var reductionCounter : int;
		var stop, abortAxii : bool;
		var costReduction : SAbilityAttributeValue;
		
		player = caster.GetPlayer();
		abortAxii = false;
		
		if(player)
		{
			if( player.HasBuff( EET_Mutation11Buff ) )
			{
				return true;
			}
			
			stop = false;
			if( ShouldStopChanneling() )
			{
				stop = true;
				abortAxii = true;
			}
			else
			{
				if(player.CanUseSkill(S_Perk_09))
				{
					if(player.GetStat( BCS_Stamina ) <= 0 && player.GetStat(BCS_Focus) <= 0)
						stop = true;
					else
						stop = false;
				}
				else
				{
					stop = (player.GetStat( BCS_Stamina ) <= 0);
				}
			}
		}		
		
		if(stop)
		{
			if( parent.skillEnum == S_Magic_s05 && abortAxii )		//can't check signType as it's not set and equal to ST_Aard for Axii... Halp!
			{
				OnSignAborted( true );
			}
			else
			{
				OnEnded();
			}
			
			return false;
		}
		else
		{
			if(player && !((W3QuenEntity)parent) )	//for some reason (signType != ST_Quen) returns ST_Aard for Quen... doh... not that it surprises me...
			{
				theGame.VibrateControllerLight();	//sign channeling (except aard & quen)
			}
			
			//FIXME URGENT - WHAT IF CASTER IS NOT PLAYER
			reductionCounter = caster.GetSkillLevel(virtual_parent.skillEnum) - 1;
			multiplier = 1;
			if(reductionCounter > 0)
			{
				costReduction = caster.GetSkillAttributeValue(virtual_parent.skillEnum, 'stamina_cost_reduction_after_1', false, false) * reductionCounter;
				multiplier = 1 - costReduction.valueMultiplicative;
			}
			
			//FIXME URGENT - WHAT IF CASTER IS NOT PLAYER
			if (!(virtual_parent.GetSignType() == ST_Quen && caster.CanUseSkill(S_Magic_s04) && multiplier == 0))
			{
				if(player)
				{
					if( parent.cachedCost <= 0.0f )
					{	
						parent.cachedCost = multiplier * player.GetStaminaActionCost( ESAT_Ability, SkillEnumToName( parent.skillEnum ), theTimer.timeDelta );
					}
				
					stamina = player.GetStat(BCS_Stamina);
				}
				
				if(multiplier > 0.f)
					caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ), theTimer.timeDelta, multiplier );
				
				if(player && parent.cachedCost > stamina)
				{
					leftStaminaCost = parent.cachedCost - stamina;
					leftStaminaCostPerc = leftStaminaCost / player.GetStatMax(BCS_Stamina);
										
					//1 full stamina bar equals 1 focus point
					player.DrainFocus(leftStaminaCostPerc);
				}
			}
			caster.OnProcessCastingOrientation( true );
		}
		return true;
	}
	
	protected function ShouldStopChanneling() : bool
	{
		var currentInputContext : name;
		
		if ( theInput.GetActionValue( 'CastSignHold' ) > 0.f )
		{
			return false;
		}
		else if( caster.GetPlayer().HasBuff( EET_Mutation11Buff ) )
		{
			return false;
		}
		else// if ( !theInput.LastUsedPCInput() )
		{
			return true;
		}
		/*else
		{
			if ( theInput.IsActionJustPressed('CastSign') || theInput.IsActionJustPressed('Dodge') || theInput.IsActionJustPressed('CbtRoll') || theInput.IsActionJustPressed('Sprint') || theInput.IsActionJustPressed('SprintToggle') || theInput.IsActionJustPressed('AttackLight') || theInput.IsActionJustPressed('AttackHeavy') )
			{
				return true;
			}
			currentInputContext = theInput.GetContext();
			if ( currentInputContext == thePlayer.GetExplorationInputContext() || currentInputContext == thePlayer.GetCombatInputContext() )
			{
				return false;
			}
			return true;
		}*/
	}
}
