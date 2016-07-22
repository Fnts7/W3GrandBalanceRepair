/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2015
/** Author : A. Kwiatkowski
/***********************************************************************/

struct SNoiseEntity
{
	var noiseEntity 		: CEntity;
	var noiseLevel 			: float;
	var animatedComponent 	: CAnimatedComponent;
}

class CBTTaskManageBlindCreature extends IBehTreeTask
{
	public  var resourceName					: name;
	public  var forgetTargetIfNPCSpeedLowerThan : float;
	public  var remberTargetIfCloserThan 		: float;
	public  var ignoreNoiseLowerThanWhenSprinting: float;
	public  var prioritizePlayerAsTarget 		: bool;
	
	private var teleportEntity 					: bool;
	private var checkedForActors 				: bool;
	private var echoPingShot 					: bool;
	private var echoTimeStamp 					: float;
	private var delayEchoDetectionFX 			: float;
	private var noiseSourceEntities 			: array<SNoiseEntity>;
	private var actors 							: array<CActor>;
	private var noiseSourceEntity 				: SNoiseEntity;
	private var entity 							: CEntity;
	private var entityTemplate					: CEntityTemplate;
	
	private const var PING_SPEED				: float;	default PING_SPEED 		 		 	= 14.5f; //14.5;
	private const var PING_NOISE_LEVEL			: float;	default PING_NOISE_LEVEL 		 	= 10.0f;
	private const var BOMB_NOISE_LEVEL			: float;	default BOMB_NOISE_LEVEL 		 	= 9.0f;
	private const var SIGN_NOISE_LEVEL			: float;	default SIGN_NOISE_LEVEL 		 	= 8.0f;
	private const var BATTLECRY_NOISE_LEVEL		: float;	default BATTLECRY_NOISE_LEVEL 	 	= 6.0f;
	private const var ATTACK_NOISE_LEVEL		: float;	default ATTACK_NOISE_LEVEL 		 	= 4.0f;
	private const var MOVE_NOISE_LEVEL			: float;	default MOVE_NOISE_LEVEL 		 	= 2.0f;
	private const var Z_TOLERANCE 				: float;	default Z_TOLERANCE 			 	= 30.0f;
	private const var NAVIGATION_SEARCH_RADIUS 	: float;	default NAVIGATION_SEARCH_RADIUS 	= 7.0f;
	private const var NAVIGATION_SEARCH_TIMEOUT : float;	default NAVIGATION_SEARCH_TIMEOUT 	= 0.5f;
	
	
	latent function Main() : EBTNodeStatus
	{
		var npc 				: CNewNPC = GetNPC();
		var actor 				: CActor;
		var component 			: CAnimatedComponent;
		var playerNoiseSources 	: array<SNoiseEntity>;
		var distance 			: float;
		var echoDistance 		: float;
		var timeStamp 			: float;
		var i, j, k 			: int;
		
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );
		component = ( CAnimatedComponent )npc.GetComponentByClassName( 'CAnimatedComponent' );
		
		if( entityTemplate )
		{
			SpawnEntity();
		}
		
		if ( !checkedForActors && actors.Size() == 0 )
		{
			actors = GetActorsInRange( npc, 50, 999, '', true );
			if ( actors.Size() > 0 )
			{
				for ( i = 0 ; i < actors.Size() ; i += 1 )
				{
					if ( actors[i] != npc && GetAttitudeBetween( npc, actors[i] ) == AIA_Hostile && actors[i].IsAlive() )
					{
						noiseSourceEntity.noiseEntity = (CEntity) actors[i];
						noiseSourceEntity.animatedComponent = ( CAnimatedComponent )noiseSourceEntity.noiseEntity.GetComponentByClassName( 'CAnimatedComponent' );
						noiseSourceEntities.PushBack( noiseSourceEntity );
					}
				}
			}
			
			checkedForActors = true;
		}
		
		while ( true )
		{
			timeStamp = GetLocalTime();
			SleepOneFrame();
			
			if ( noiseSourceEntities.Size() > 0 )
			{
				for ( i = noiseSourceEntities.Size() - 1 ; i >= 0 ; i -= 1 )
				{
					// decrease noise level by time delta
					noiseSourceEntities[i].noiseLevel -= GetLocalTime() - timeStamp;
					if ( noiseSourceEntities[i].noiseLevel <= MOVE_NOISE_LEVEL )
					{
						actor = (CActor)noiseSourceEntities[i].noiseEntity;
						// update noise level for moving entities
						if ( noiseSourceEntities[i].animatedComponent && noiseSourceEntities[i].animatedComponent.GetMoveSpeedRel() > 0 )
						{
							noiseSourceEntities[i].noiseLevel = MOVE_NOISE_LEVEL;
							teleportEntity = true;
						}
						else if ( noiseSourceEntities[i].noiseLevel <= 0 && !actor )
						{
							noiseSourceEntities.Erase( i );
						}
					}
				}
				
				if ( prioritizePlayerAsTarget )
				{
					playerNoiseSources = noiseSourceEntities;
					for ( k = playerNoiseSources.Size() - 1 ; k >= 0 ; k -= 1 )
					{
						// remove npcs, we need only player generated noises
						if ( (CNewNPC)playerNoiseSources[k].noiseEntity )
						{
							playerNoiseSources.Erase( k );
						}
					}
					j = ArrayFindMaxFloatFromStruct( playerNoiseSources );
					noiseSourceEntity = playerNoiseSources[j];
					if ( noiseSourceEntity.noiseLevel <= 0 )
					{
						j = ArrayFindMaxFloatFromStruct( noiseSourceEntities );
						noiseSourceEntity = noiseSourceEntities[j];
					}
				}
				else // return loudest entity
				{
					j = ArrayFindMaxFloatFromStruct( noiseSourceEntities );
					noiseSourceEntity = noiseSourceEntities[j];
				}
			}
			
			if ( noiseSourceEntity.noiseLevel > 0 )
			{
				if ( teleportEntity && entity )
				{
					if ( ignoreNoiseLowerThanWhenSprinting > 0 )
					{
						// if owner is sprinting he cannot hear noises quieter than ignoreNoiseLowerThanWhenSprinting value
						if ( component && component.GetMoveSpeedRel() > 2.4 )
						{
							if ( noiseSourceEntity.noiseLevel > ignoreNoiseLowerThanWhenSprinting )
							{
								TeleportSafe( noiseSourceEntity.noiseEntity.GetWorldPosition() );
								teleportEntity = false;
							}
						}
						else
						{
							TeleportSafe( noiseSourceEntity.noiseEntity.GetWorldPosition() );
							teleportEntity = false;
						}
					}
					else
					{
						TeleportSafe( noiseSourceEntity.noiseEntity.GetWorldPosition() );
						teleportEntity = false;
					}
					
					SleepOneFrame();
					npc.GetVisualDebug().AddSphere( 'entityPos', 1.0, entity.GetWorldPosition(), true, Color( 0,255,0 ), noiseSourceEntity.noiseLevel );
				}
				if ( GetActionTarget() != entity )
				{
					SetActionTarget( entity );
				}
			}
			else
			{
				/*
				distance = VecDistance( entity.GetWorldPosition(), noiseSourceEntity.noiseEntity.GetWorldPosition() );
				if ( distance > 3 )
				{
					SetActionTarget( NULL );
				}*/
				
				distance = VecDistance( npc.GetWorldPosition(), noiseSourceEntity.noiseEntity.GetWorldPosition() );
				// if target is close, sharley doesn't loose the scent
				if ( remberTargetIfCloserThan > 0 && distance < remberTargetIfCloserThan )
				{
					//
				}
				// if owner started moving towards the target, he won't forget where he's going in the middle
				else if ( forgetTargetIfNPCSpeedLowerThan > 0 )
				{
					if ( component && component.GetMoveSpeedRel() < forgetTargetIfNPCSpeedLowerThan )
					{
						SetActionTarget( NULL );
					}
				}
				else
				{
					SetActionTarget( NULL );
				}
			}
			// detection fx
			if ( echoPingShot && GetLocalTime() > echoTimeStamp + delayEchoDetectionFX )
			{
				echoPingShot = false;
				npc.SignalGameplayEvent( 'echoFX' );
			}
		}
		
		return BTNS_Active;
	}
	
	function OnListenedGameplayEvent( eventName: CName ) : bool
	{
		if ( eventName == 'BombExplosionAction' )
		{
			SetNamedTarget( 'tempTarget', GetNamedTarget( 'ReactionTarget' ) );
			noiseSourceEntity.noiseEntity = (CEntity) GetNamedTarget( 'tempTarget' );
			noiseSourceEntity.noiseLevel = BOMB_NOISE_LEVEL;
			noiseSourceEntity.animatedComponent = ( CAnimatedComponent )noiseSourceEntity.noiseEntity.GetComponentByClassName( 'CAnimatedComponent' );
			noiseSourceEntities.PushBack( noiseSourceEntity );
			teleportEntity = true;
		}
		else if ( eventName == 'CastSignActionFar' ) // AARD - much louder than other Signs
		{
			SetNamedTarget( 'tempTarget', GetNamedTarget( 'ReactionTarget' ) );
			noiseSourceEntity.noiseEntity = (CEntity) GetNamedTarget( 'tempTarget' );
			noiseSourceEntity.noiseLevel = SIGN_NOISE_LEVEL;
			noiseSourceEntity.animatedComponent = ( CAnimatedComponent )noiseSourceEntity.noiseEntity.GetComponentByClassName( 'CAnimatedComponent' );
			noiseSourceEntities.PushBack( noiseSourceEntity );
			teleportEntity = true;
		}
		else if ( eventName == 'CastSignAction' )
		{
			SetNamedTarget( 'tempTarget', GetNamedTarget( 'ReactionTarget' ) );
			noiseSourceEntity.noiseEntity = (CEntity) GetNamedTarget( 'tempTarget' );
			noiseSourceEntity.noiseLevel = ATTACK_NOISE_LEVEL;
			noiseSourceEntity.animatedComponent = ( CAnimatedComponent )noiseSourceEntity.noiseEntity.GetComponentByClassName( 'CAnimatedComponent' );
			noiseSourceEntities.PushBack( noiseSourceEntity );
			teleportEntity = true;
		}
		else if ( eventName == 'BattleCryNormal' || eventName == 'BattleCryGroupOrder' || 
				  eventName == 'BattleCryGroupAnswer' || eventName == 'BattleCryCastSign' || eventName == 'BattleCryDeath' )
		{
			SetNamedTarget( 'tempTarget', GetNamedTarget( 'ReactionTarget' ) );
			noiseSourceEntity.noiseEntity = (CEntity) GetNamedTarget( 'tempTarget' );
			noiseSourceEntity.noiseLevel = BATTLECRY_NOISE_LEVEL;
			noiseSourceEntity.animatedComponent = ( CAnimatedComponent )noiseSourceEntity.noiseEntity.GetComponentByClassName( 'CAnimatedComponent' );
			noiseSourceEntities.PushBack( noiseSourceEntity );
			teleportEntity = true;
		}
		else if ( eventName == 'RecoveredFromCriticalEffect' || eventName == 'MoveNoise' )
		{
			SetNamedTarget( 'tempTarget', GetNamedTarget( 'ReactionTarget' ) );
			noiseSourceEntity.noiseEntity = (CEntity) GetNamedTarget( 'tempTarget' );
			noiseSourceEntity.noiseLevel = MOVE_NOISE_LEVEL;
			noiseSourceEntity.animatedComponent = ( CAnimatedComponent )noiseSourceEntity.noiseEntity.GetComponentByClassName( 'CAnimatedComponent' );
			noiseSourceEntities.PushBack( noiseSourceEntity );
			teleportEntity = true;
		}
		else if ( eventName == 'ActorInHitReaction' )
		{
			SetNamedTarget( 'tempTarget', GetNamedTarget( 'ReactionTarget' ) );
			noiseSourceEntity.noiseEntity = (CEntity) GetNamedTarget( 'tempTarget' );
			noiseSourceEntity.noiseLevel = BATTLECRY_NOISE_LEVEL;
			noiseSourceEntity.animatedComponent = ( CAnimatedComponent )noiseSourceEntity.noiseEntity.GetComponentByClassName( 'CAnimatedComponent' );
			noiseSourceEntities.PushBack( noiseSourceEntity );
			teleportEntity = true;
		}
		else if ( eventName == 'NpcAttackAction' )
		{
			SetNamedTarget( 'tempTarget', GetNamedTarget( 'ReactionTarget' ) );
			noiseSourceEntity.noiseEntity = (CEntity) GetNamedTarget( 'tempTarget' );
			noiseSourceEntity.noiseLevel = ATTACK_NOISE_LEVEL;
			noiseSourceEntity.animatedComponent = ( CAnimatedComponent )noiseSourceEntity.noiseEntity.GetComponentByClassName( 'CAnimatedComponent' );
			noiseSourceEntities.PushBack( noiseSourceEntity );
			teleportEntity = true;
		}
		
		// additional gameplay events that could be used
		/*
		PlayerEvade
		PlayerSpecialAttack
		DrawSwordAction
		PlayerSprintAction
		PlayerJumpAction
		*/
		if ( eventName == 'LeavingCombat' && entity )
		{
			noiseSourceEntities.Clear();
			actors.Clear();
			entity.Destroy();
		}
		return true;
	}
	
	final function SpawnEntity()
	{
		var npc 		: CNewNPC = GetNPC();
		var spawnPos 	: Vector;
		
		if ( entity )
		{
			return;
		}
		
		spawnPos = npc.GetWorldPosition();
		entity = theGame.CreateEntity( entityTemplate, spawnPos );
	}
	
	// Returns index of highest element
	final function ArrayFindMaxFloatFromStruct( a : array< SNoiseEntity > ) : int
	{
		var i, s, index : int;
		var val : float;	
		
		s = a.Size();
		if( s > 0 )
		{			
			index = 0;
			val = a[0].noiseLevel;
			for( i=1; i<s; i+=1 )
			{
				if( a[i].noiseLevel > val )
				{
					index = i;
					val = a[i].noiseLevel;
				}
			}
			
			return index;
		}	
		
		return -1;			
	}
	
	final latent function TeleportSafe( pos : Vector )
	{
		var npc 			: CNewNPC = GetNPC();
		var newPos 			: Vector;
		var noisePos 		: Vector;
		var radius 			: float;
		var searchRadius 	: float;
		var timeStamp 		: float;
		var z 				: float;
		var res 			: bool;
		
		radius = npc.GetRadius();
		timeStamp = GetLocalTime();
		res = theGame.GetWorld().NavigationFindSafeSpot( pos, radius, NAVIGATION_SEARCH_RADIUS, newPos );
		if ( !theGame.GetWorld().NavigationLineTest( npc.GetWorldPosition(), newPos, radius ) )
		{
			res = false;
		}
		
		while ( !res && GetLocalTime() < timeStamp + NAVIGATION_SEARCH_TIMEOUT )
		{
			noisePos = pos + VecRingRand( searchRadius, searchRadius );
			searchRadius += 0.2;
			if ( theGame.GetWorld().NavigationComputeZ( noisePos, noisePos.Z - Z_TOLERANCE, noisePos.Z + ( Z_TOLERANCE / 6 ), z ) )
			{
				noisePos.Z = z;
				res = theGame.GetWorld().NavigationFindSafeSpot( noisePos, radius, NAVIGATION_SEARCH_RADIUS, newPos );
				if ( !theGame.GetWorld().NavigationLineTest( npc.GetWorldPosition(), newPos, radius ) )
				{
					res = false;
				}
			}
			SleepOneFrame();
		}
		
		if ( res )
		{
			entity.Teleport( newPos );
		}
		else
		{
			LogChannel( 'dupa', "bTTaskManageBlindCreature : npc cannot navigate to heard noise" );
		}
		
		//npc.GetVisualDebug().AddSphere( 'entityPosTest', 1.0, newPos, true, Color( 255,0,0 ), noiseSourceEntity.noiseLevel );
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == 'ping' )
		{
			Echolocation();
			return true;
		}
		
		return false;
	}
	// finds all targets that are not hidden behind obstacles
	final function Echolocation()
	{
		var actor 			: CActor;
		var npcPos 			: Vector;
		var echoDistance 	: float;
		var i 				: int;
		
		if ( noiseSourceEntities.Size() > 0 )
		{
			npcPos = GetNPC().GetWorldPosition();
			
			for ( i = noiseSourceEntities.Size() - 1 ; i >= 0 ; i -= 1 )
			{
				actor = (CActor)noiseSourceEntities[i].noiseEntity;
				if ( actor && StaticTrace(i) && actor.IsAlive() && GetAttitudeBetween( GetNPC(), actor ) == AIA_Hostile )
				{
					//if ( theGame.GetWorld().NavigationLineTest( npcPos, actor.GetWorldPosition(), 1.5, false, true ) )
					noiseSourceEntities[i].noiseLevel = PING_NOISE_LEVEL;
					teleportEntity = true;
					
					if ( actor == thePlayer )
					{
						echoPingShot = true;
						echoTimeStamp = GetLocalTime();
						echoDistance = VecDistance( npcPos, actor.GetWorldPosition() );
						delayEchoDetectionFX = PING_SPEED / echoDistance;
					}
				}
			}
		}
	}
	
	// RETURNS TRUE IF THERE'S NOTHING IN THE WAY
	final function StaticTrace( i : int ) : bool 
	{
		var npcPos, traceStartPos, traceEndPos, traceEffect, normal : Vector;
		var npc 			: CNewNPC = GetNPC();
		var actor 			: CActor;
		var targetEntity 	: CGameplayEntity;
		var headBoneIdx 	: int;
		var entMat 			: Matrix;
		
		actor = (CActor) noiseSourceEntities[i].noiseEntity;
		npcPos = npc.GetWorldPosition();
		traceStartPos = npcPos;
		traceStartPos.Z += (( CMovingPhysicalAgentComponent )npc.GetMovingAgentComponent()).GetCapsuleHeight() * 0.75;
		
		if ( actor )
		{
			headBoneIdx = actor.GetHeadBoneIndex();
			if ( headBoneIdx >= 0 )
			{
				traceEndPos = MatrixGetTranslation( actor.GetBoneWorldMatrixByIndex( headBoneIdx ) );
			}
			else
			{
				traceEndPos = actor.GetWorldPosition();
				traceEndPos.Z += (( CMovingPhysicalAgentComponent )actor.GetMovingAgentComponent()).GetCapsuleHeight() * 0.75;
			}
		}
		
		if( theGame.GetWorld().StaticTrace( traceStartPos, traceEndPos, traceEffect, normal ) )
		{
			return false;
		}
		else
		{
			return true;
		}
	}
};

class CBTTaskManageBlindCreatureDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskManageBlindCreature';
	
	editable var resourceName 						: name;
	editable var forgetTargetIfNPCSpeedLowerThan 	: float;
	editable var remberTargetIfCloserThan 			: float;
	editable var ignoreNoiseLowerThanWhenSprinting	: float;
	editable var prioritizePlayerAsTarget 			: CBehTreeValBool;
	
	default resourceName = 'fx_dummy_entity';
	default forgetTargetIfNPCSpeedLowerThan = 2.4f;
	default remberTargetIfCloserThan = 3.0f;
	default ignoreNoiseLowerThanWhenSprinting = 4.0f;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'LeavingCombat' );
		listenToGameplayEvents.PushBack( 'BombExplosionAction' );
		listenToGameplayEvents.PushBack( 'CastSignAction' );
		listenToGameplayEvents.PushBack( 'CastSignActionFar' );
		listenToGameplayEvents.PushBack( 'BattleCryNormal' );
		listenToGameplayEvents.PushBack( 'BattleCryGroupOrder' );
		listenToGameplayEvents.PushBack( 'BattleCryGroupAnswer' );
		listenToGameplayEvents.PushBack( 'BattleCryCastSign' );
		listenToGameplayEvents.PushBack( 'BattleCryDeath' );
		listenToGameplayEvents.PushBack( 'RecoveredFromCriticalEffect' );
		listenToGameplayEvents.PushBack( 'MoveNoise' );
		listenToGameplayEvents.PushBack( 'ActorInHitReaction' );
		listenToGameplayEvents.PushBack( 'NpcAttackAction' );
	}
};
