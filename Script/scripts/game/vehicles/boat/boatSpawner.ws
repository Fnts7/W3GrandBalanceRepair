//layer must be AutoStatic, Gameplay to work properly
import statemachine class W3BoatSpawner extends CGameplayEntity
{
	public saved var spawnedBoat : EntityHandle;	//pointer to boat spawned by this spawner	
	editable var respawnDistance : float;
	var isAttemptingBoatSpawn : bool;
	
	default autoState = 'Idle';
	default respawnDistance = 10.f;
	default isAttemptingBoatSpawn = false;
	
	hint respawnDistance = "Distance at which new boat is spawned, must be lower than spawner's streaming distance";
	
	event OnSpawned(spawndata : SEntitySpawnData)
	{
		if(!isAttemptingBoatSpawn)
		{
			if(!EntityHandleGet(spawnedBoat) && GetCurrentStateName() != 'SpawnBoatLatentHack' )
				GotoState('SpawnBoatLatentHack');
			else
				GotoStateAuto();
		}
	}
	
	event OnStreamIn()
	{
		var currentStateName : name;
		
		if(!isAttemptingBoatSpawn)
		{
			currentStateName = GetCurrentStateName();	
			if(!EntityHandleGet(spawnedBoat) && currentStateName != 'SpawnBoatLatentHack' )
				GotoState('SpawnBoatLatentHack');
			else
				GotoStateAuto();
		}
	}
	
	//ACHTUNG!! actual stream out range is 53% bigger then the one set in entity
	//Currently setting to 100 to get real value of 153 meters which is a little bit smaller than boat streaming range (160m).
	event OnStreamOut()
	{
		var boat : CEntity;
		var distToBoat : float;
		
		boat = EntityHandleGet(spawnedBoat);
		if(boat)
		{
			distToBoat =  VecDistance2D(GetWorldPosition(), boat.GetWorldPosition());
			
			//if boat is far away from spawner
			if(distToBoat > respawnDistance)
			{
				theGame.AddDynamicallySpawnedBoatHandle(spawnedBoat);
				EntityHandleSet( spawnedBoat, NULL );
			}
		}
		
		GotoStateAuto();
	}
	
	timer function DelayedSpawnBoat( td : float , id : int)
	{
		RemoveTimer( 'DelayedSpawnBoat' );
		( ( W3BoatSpawnerStateSpawnBoatLatentHack )GetState( 'SpawnBoatLatentHack' ) ).OnDelayedSpawnedBoat();
	}
}

state Idle in W3BoatSpawner {}

state SpawnBoatLatentHack in W3BoatSpawner
{
	event OnEnterState(prevStateName : name)
	{
		if( !parent.isAttemptingBoatSpawn )
		{
			parent.isAttemptingBoatSpawn = true;
			parent.AddTimer( 'DelayedSpawnBoat', 0.1f );
		}
		else
		{	
			GotoStateAuto();
		}
	}
	
	event OnDelayedSpawnedBoat()
	{
		Hack_Entry_Name_Collision_Bug_W3BoatSpawner_SpawnBoatLatentHack();
		parent.isAttemptingBoatSpawn = false;
		GotoStateAuto();
	}
	
	entry function Hack_Entry_Name_Collision_Bug_W3BoatSpawner_SpawnBoatLatentHack()
	{
		var entityTemplate : CEntityTemplate;
		var boat : W3Boat;
		var pos : Vector;
		
		entityTemplate = (CEntityTemplate)LoadResourceAsync('boat');	
		if ( entityTemplate )
		{
			pos = virtual_parent.GetWorldPosition();
			pos.Z = theGame.GetWorld().GetWaterLevel(pos);
			boat = (W3Boat)theGame.CreateEntity(entityTemplate, pos, virtual_parent.GetWorldRotation(), , , , PM_Persist);
			if(boat)
			{
				EntityHandleSet(parent.spawnedBoat, boat);
			}
		}
	}
}
