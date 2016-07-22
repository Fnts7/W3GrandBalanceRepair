/***********************************************************************/
/** Copyright © ?-2014
/** Author : Wojciech Żerek, Tomek Kozera
/***********************************************************************/

enum EToxicCloudOperation
{
	TCO_Enable,
	TCO_Disable
}

import statemachine class W3ToxicCloud extends CGameplayEntity
{
	editable var poisonDamage		: SAbilityAttributeValue;
	editable var explosionDamage	: SAbilityAttributeValue;
	editable var restorationTime	: float;
	editable var settlingTime		: float;
	editable var fxOnSettle			: name;
	editable var fxOnSettleCluster 	: name;
	editable var fxOnExplode		: name;
	editable var fxOnExplodeCluster : name;
	editable var bIsEnabled 		: bool;
	editable var usePoisonBuffWithAnim : bool;
	editable var cameraShakeRadius  : float;
	editable var isEnvironment 		: bool;
	editable var burningChance		: float;
	editable var excludedTags 		: array<name>;
	
		default isEnvironment = true;
		default burningChance = 1;

	protected var chainedExplosion : bool;									//set to true if this entity ignites from another gas cloud explosion
	protected var entitiesInPoisonRange : array<CActor>;					//entities being in poison/explosion range
	protected saved var effectType : EEffectType;
	private var poisonArea, explosionArea : CTriggerAreaComponent;
	private var explodingTargetDamages : array<SRawDamage>;					//damage dealt when target killed with gas dies (exploding and dealing additional damage)
	private var entitiesInExplosionRange : array<CGameplayEntity>;
	private var isFromBomb : bool;											//set to true if gas is created from bomb
	private var buffParams : SCustomEffectParams;							//cached params for poison buff
	private var buffSpecParams : W3BuffDoTParams;							//cached special params for poison buff
	private var isFromClusterBomb : bool;									//set to true if gas is created as a result of cluster bomb explosion
	private var bombOwner : CActor;											//who threw bomb - used to avoid hitting friendlies & neutrals	
	protected var wasPerk16Active : bool;	
	private var canMultiplyDamageFromPerk20 : bool;							//used for Perk 20
	private var friendlyFire : bool;
		
		default isFromBomb = false;
		
		hint restorationTime = "Time till cloud restores. If -1 will work only once";
		hint burningChance = "Chance (0-1) that explosion will add BurningEffect on target";
		hint fxOnSettleCluster = "Gas fx to be used with Cluster bombs";
		hint fxOnExplodeCluster = "Explosion fx to be used with Cluster bombs";
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		
		chainedExplosion = false;
				
		if(usePoisonBuffWithAnim)
			effectType = EET_PoisonCritical;
		else
			effectType = EET_Poison;
		
		Enable( bIsEnabled );
	}
	
	event OnStreamIn()
	{
		Log( "Toxic Cloud streamed in" );
	}
	
	event OnStreamOut()
	{
		Log( "Toxic Cloud streamed out" );
	}
	
	public function SetBurningChance(c : float)
	{
		burningChance = c;
	}
	
	public function SetIsFromClusterBomb(b : bool)
	{
		isFromClusterBomb = b;
	}
	
	public function IsFromClusterBomb() : bool
	{
		return isFromClusterBomb;
	}
	
	public function SetFromBomb(owner : CActor)
	{
		bombOwner = owner;
		isFromBomb = true;
	}
	
	public function IsFromBomb() : bool
	{
		return isFromBomb;
	}
	
	public function IsActorInPoisonRange(a : CActor) : bool
	{
		return entitiesInPoisonRange.Contains(a);
	}
	
	public function SetExplodingTargetDamages(dmg : array<SRawDamage>)
	{
		explodingTargetDamages = dmg;
	}
	
	public function GetExplodingTargetDamages() : array<SRawDamage>
	{
		return explodingTargetDamages;
	}
	
	public function SetWasPerk16Active( d : bool )
	{
		wasPerk16Active = d;
	}
 
	public function GetWasPerk16Active() : bool
	{
		return wasPerk16Active;
	}
	
	public function HasExplodingTargetDamages() : bool
	{
		return explodingTargetDamages.Size() > 0;
	}
	
	public function SetPerk20DamageMultiplierOn()
	{
		canMultiplyDamageFromPerk20 = true;
	}
	
	public function SetFriendlyFire( f : bool )
	{
		friendlyFire = f;
	}
	
	public function PermanentlyDisable()
	{
		var area : CTriggerAreaComponent;
		
		area = GetPoisonAreaUnsafe();
		if(area)
			area.SetEnabled(false);
		else
			AddTimer('KeepTryingToDisable', 0.1, true, , , true);
			
		entitiesInPoisonRange.Clear();
		StopPoisonTimer();		
		
		StopAllEffects();
		DestroyAfter(5);	//destroy when fx off, if dynamic
	}
	
	timer function KeepTryingToDisable(dt : float, id : int)
	{
		var area : CTriggerAreaComponent;
		
		area = GetPoisonAreaUnsafe();
		if(area)
		{
			area.SetEnabled(false);
			RemoveTimer('KeepTryingToDisable');
		}
	}
	
	public function Enable(b : bool)
	{
		if(b)
			GotoState('Settle');
		else
			GotoState('Disabled');
	}
	
	//might be NULL if trigger did not stream yet
	public function GetPoisonAreaUnsafe() : CTriggerAreaComponent
	{
		if(!poisonArea)
			poisonArea = (CTriggerAreaComponent)GetComponent('PoisonArea');	
			
		return poisonArea;
	}
	
	//might be NULL if trigger did not stream yet
	public function GetGasAreaUnsafe() : CTriggerAreaComponent
	{
		if(!explosionArea)
			explosionArea = (CTriggerAreaComponent)GetComponent('ExplosionArea');
			
		return explosionArea;
	}
	
	public function OnManageToxicCloud( operations : array< EToxicCloudOperation > )
	{
		if(operations.Size() == 0)
			return;
			
		Enable( operations.Contains(TCO_Enable) );
	}
	
	public function IsChainedExplosion() : bool
	{
		return chainedExplosion;
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		var gameplayEnt : CGameplayEntity;
		var i : int;
		var ent : CEntity;
		var expBolt : W3ExplosiveBolt;
		var perk20Bonus : SAbilityAttributeValue;
		
		//entity with fire - explode
		ent = activator.GetEntity();
		if(area == GetPoisonAreaUnsafe() && ent.HasTag(theGame.params.TAG_OPEN_FIRE) && GetCurrentStateName() == 'Armed')
		{
			((W3ToxicCloudStateArmed)(GetCurrentState())).Explode(ent);
			return true;
		}	
		
		if( excludedTags.Size() > 0 )
		{
			for( i = 0; i < excludedTags.Size(); i += 1 )
			{
				if( ent.HasTag( excludedTags[i] ) )
					return false;
			}
		}
				
		if(area == GetPoisonAreaUnsafe())
		{
			actor = (CActor)ent;
			if(actor && !entitiesInPoisonRange.Contains(actor) && (!bombOwner || IsRequiredAttitudeBetween(bombOwner, actor, true)) )
			{
				entitiesInPoisonRange.PushBack(actor);
				
				if(entitiesInPoisonRange.Size() == 1)
				{
					//if buff params not set yet
					if(buffParams.effectType == EET_Undefined)
					{						
						buffParams.effectType = effectType;
						buffParams.creator = this;
						buffParams.duration = 0.5;
						buffParams.effectValue = poisonDamage;
						buffParams.buffSpecificParams = buffSpecParams;
						buffParams.sourceName = 'ToxicGasCloud';
					}
					//Perk 20 - decreases amount of bombs in stack, but increases their damage (including expl dmg from toxic cloud)
					if( canMultiplyDamageFromPerk20 )
					{
						perk20Bonus = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_20, 'dmg_multiplier', false, false);
						buffParams.effectValue.valueAdditive *= ( 1 + perk20Bonus.valueMultiplicative );
					}
					if(!buffSpecParams)
					{
						buffSpecParams = new W3BuffDoTParams in this;
						buffSpecParams.isEnvironment = isEnvironment;
					}
		
					AddTimer('PoisonTimer', 0.01, true);
				}
								
				if( (CR4Player)actor && GetCurrentStateName() == 'Armed')
				{
					SetCanBeTargeted( false );
					if( thePlayer.CanPlaySpecificVoiceset() )
					{
						thePlayer.PlayVoiceset( 100, "coughing" );
						thePlayer.SetCanPlaySpecificVoiceset( false );
						thePlayer.AddTimer( 'ResetSpecificVoicesetFlag', 10.0 );
					}
				}
			}		
		}
		else if(area == GetGasAreaUnsafe())
		{
			gameplayEnt = (CGameplayEntity)ent;
			if(gameplayEnt && (!bombOwner || IsRequiredAttitudeBetween(bombOwner, gameplayEnt, true, false, friendlyFire) ) )
			{
				entitiesInExplosionRange.PushBack(gameplayEnt);
				
				expBolt = (W3ExplosiveBolt)gameplayEnt;
				if(expBolt)
				{
					expBolt.AddToxicCloud(this);
				}
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var ent : CEntity;
		var gameplayEnt : CGameplayEntity;
		var actor : CActor;
		var expBolt : W3ExplosiveBolt;
		
		ent = activator.GetEntity();

		if( (CR4Player)ent && GetCurrentStateName() == 'Armed' )
		{
			SetCanBeTargeted( true );
		}
		
		if(area == GetPoisonAreaUnsafe())
		{			
			actor = (CActor)activator.GetEntity();
			if(actor)
			{
				entitiesInPoisonRange.Remove(actor);
				
				if(entitiesInPoisonRange.Size() == 0)
				{
					StopPoisonTimer();
				}
			}
		}
		else if(area == GetGasAreaUnsafe())
		{
			gameplayEnt = (CGameplayEntity)ent;
			if(gameplayEnt)
			{
				entitiesInExplosionRange.Remove(gameplayEnt);
				
				expBolt = (W3ExplosiveBolt)gameplayEnt;
				if(expBolt)
				{
					expBolt.RemoveToxicCloud(this);
				}
			}
		}
	}
	
	public function ClearEntitiesInPoisonRange()
	{
		entitiesInPoisonRange.Clear();
	}
	
	public function GetCamShakeRadius() : float
	{
		return cameraShakeRadius;
	}
	
	public function GetEntitiesInExplosionRange() : array<CGameplayEntity>
	{
		return entitiesInExplosionRange;
	}
	
	public function GetActorsInPoisonRange() : array<CActor>
	{
		return entitiesInPoisonRange;
	}
	
	protected function SetCanBeTargeted( flag : bool )
	{
		if ( flag )
		{
			if ( !this.HasTag( theGame.params.TAG_SOFT_LOCK ) )
				this.AddTag( theGame.params.TAG_SOFT_LOCK );			
		}
		else
			this.RemoveTag( theGame.params.TAG_SOFT_LOCK );
	}
	
	timer function PoisonTimer(dt : float, id : int)
	{
		var i : int;
	
		for(i=0; i<entitiesInPoisonRange.Size(); i+=1)
		{
			((CActor)entitiesInPoisonRange[i]).AddEffectCustom(buffParams);
		}	
	}
	
	public final function StopPoisonTimer()
	{
		RemoveTimer('PoisonTimer');
		if(buffSpecParams)
			delete buffSpecParams;
	}
}

//-------------------------------------------------------------------- DISABLED ----------------------------------------------------------------------
state Disabled in W3ToxicCloud
{
	event OnEnterState( prevStateName : name )
	{
		var area : CTriggerAreaComponent;
		
		parent.StopAllEffects();
		
		area = parent.GetPoisonAreaUnsafe();
		if(area)
			area.SetEnabled(false);
		else
			parent.AddTimer('KeepTryingToDisable', 0.1, true, , , true);
			
		parent.ClearEntitiesInPoisonRange();
	}
}

//-------------------------------------------------------------------- SETTLE ----------------------------------------------------------------------
state Settle in W3ToxicCloud
{
	event OnEnterState( prevStateName : name )
	{
		//gas cloud fx
		if(parent.IsFromClusterBomb() && IsNameValid(parent.fxOnSettleCluster))
			parent.PlayEffectSingle(parent.fxOnSettleCluster);
		else
			parent.PlayEffectSingle(parent.fxOnSettle);
			
		parent.chainedExplosion = false;
		
		W3ToxicCloud_Settle_Loop();
	}
	
	entry function W3ToxicCloud_Settle_Loop()
	{
		Sleep(parent.settlingTime + RandF());
		parent.GotoState('Armed');
	}
}

//-------------------------------------------------------------------- ARMED ----------------------------------------------------------------------
state Armed in W3ToxicCloud
{
	private var isExploding : bool;

	event OnEnterState( prevStateName : name )
	{
		var area : CTriggerAreaComponent;
		var actors : array<CActor>;
		var i : int;
		
		isExploding = false;

		//make cloud targetable again if Player is outside it's area
		area = parent.GetPoisonAreaUnsafe();
		area.SetEnabled(true);				
		
		if (area && area.TestEntityOverlap( thePlayer ) )
			parent.SetCanBeTargeted( false );
		else
			parent.SetCanBeTargeted( true );
		
		//check if there's a fire entity already in trigger
		//due to performance we only check actors, there's no function to get entities
		actors = parent.GetActorsInPoisonRange();
		for(i=0; i<actors.Size(); i+=1)
			if(actors[i].HasTag(theGame.params.TAG_OPEN_FIRE))
				Explode(actors[i]);	//this will go to other state
				
		if(parent.IsActorInPoisonRange(thePlayer))
		{
			parent.SetCanBeTargeted( false );
		}
	}
		
	event OnFireHit(source : CGameplayEntity)
	{
		if(isExploding)
			return true;	//already handling it at the moment
			
		parent.OnFireHit(source);
		
		//chain explosion
		if((W3ToxicCloud)source)
			parent.chainedExplosion = true;
		
		Explode(source);		
	}
	
	public function Explode(source : CEntity)
	{
		var i : int;
		var entitiesInRange : array<CGameplayEntity>;
		var damage : W3DamageAction;
		var actor : CActor;
		var dmgVal  : float;
	
		isExploding = true;
	
		//achievement
		actor = (CActor)source;
		if(actor && actor.HasBuff(EET_Burning) && parent.IsFromBomb())
			theGame.GetGamerProfile().IncStat(ES_DragonsDreamTriggers);
			
		parent.StopAllEffects();
		parent.StopPoisonTimer();
		
		//explosion fx
		if(parent.IsFromClusterBomb() && IsNameValid(parent.fxOnExplodeCluster))
			parent.PlayEffectSingle(parent.fxOnExplodeCluster);
		else
			parent.PlayEffectSingle(parent.fxOnExplode);
			
		GCameraShake( 0.5, true, parent.GetWorldPosition(), parent.GetCamShakeRadius());
				
		entitiesInRange = parent.GetEntitiesInExplosionRange();
		entitiesInRange.Remove(parent);
		for( i = 0; i < entitiesInRange.Size(); i += 1 )
		{
			if((W3SignEntity)entitiesInRange[i] || (W3SignProjectile)entitiesInRange[i])
			{
				continue;
			}
			
			// Perk 16 - Player is immune to effects of his own bombs & bolts
			if( parent.GetWasPerk16Active() && entitiesInRange[i] == GetWitcherPlayer() )
			{
				continue;
			}
		
			actor = (CActor)entitiesInRange[i];
			if(actor)
			{
				damage = new W3DamageAction in parent;
				damage.Initialize( parent, entitiesInRange[i], parent, parent, EHRT_None, CPS_Undefined, false, false, false, true );
				dmgVal = parent.explosionDamage.valueAdditive + parent.explosionDamage.valueMultiplicative * actor.GetMaxHealth();
				damage.AddDamage( theGame.params.DAMAGE_NAME_FIRE, dmgVal);
				damage.AddEffectInfo(EET_KnockdownTypeApplicator);
				damage.SetSuppressHitSounds(true);
				
				if(RandF() < parent.burningChance)
					damage.AddEffectInfo(EET_Burning);
				
				theGame.damageMgr.ProcessAction( damage );
				
				delete damage;
			}
			else
			{
				entitiesInRange[i].OnFireHit(parent);
			}
		}
		
		parent.GotoState('Wait');
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		parent.StopAllEffects();
		parent.OnAardHit(sign);
		parent.GotoState('Wait');
	}
}

//-------------------------------------------------------------------- WAIT ----------------------------------------------------------------------
state Wait in W3ToxicCloud
{
	event OnEnterState( prevStateName : name )
	{
		parent.SetCanBeTargeted( false );
		parent.GetPoisonAreaUnsafe().SetEnabled(false);
		parent.ClearEntitiesInPoisonRange();
		W3ToxicCloud_Wait_Loop();
	}
	
	entry function W3ToxicCloud_Wait_Loop()
	{			
		if(parent.restorationTime < 0)
		{
			parent.PermanentlyDisable();
		}
		else
		{
			LogChannel('tox', "sleeping...");
			Sleep(parent.restorationTime);
			
			LogChannel('tox', "go to settle");
			parent.GotoState('Settle');
		}
	}
}
