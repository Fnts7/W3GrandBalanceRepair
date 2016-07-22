/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

//Work type - for behavior animation choosing
enum EBackgroundNPCWork_Paired
{
	EBNWP_None,
	EBNWP_DrinkingOpposite,
	EBNWP_Saw,
	EBNWP_Q106KilledbyMorowa
}

// Each of NPCs must be either a Master or Slave
enum EBgNPCType
{
	EBNPCT_None,
	EBNPCT_Master,
	EBNPCT_Slave
}

//data to spawn initial entities
struct SBackgroundPairSpawnedEntity
{
	editable var entityTemplate : CEntityTemplate;
	editable var slotName : name;					//on which slot to spawn
	editable var referenceName : name;				//custom name used in entity template to reference used objects
};

//data for mount event
struct SMountEvent
{
	editable var animEventName : name;					//name of event on which to react to
	editable var entityReferenceName : name;			//name of the entity that changes slot
	editable var newSlotName : name;					//name of the new slot to which to attach to
	editable var entityContainingSlot : EBgNPCType;
};

/*
	Paired background NPC uses two background NPC objects to make a paired work, e.g. 2 man sawing wood.
	The entity contains slots on which the two background NPCs will be spawned, as well as other slots
	for other entities used in the animation. If an object will be changing slots (e.g. item being passed
	on from one npc to the other) then it must be created in the dynamic array. Otherwise if it's static
	(e.g. a table) it should be placed directly in the entity template.
*/
statemachine class W3NPCBackgroundPair extends CGameplayEntity
{
	public editable var work : EBackgroundNPCWork_Paired;						//type of animation to use
	public editable var entitiesToSpawn : array<SBackgroundPairSpawnedEntity>;	//array of entities to spawn (npc, tools)
	private var spawnedEntities : array<CEntity>;								//array of currently spawned entities
	private var currentAttachments : array<CEntity>;							//mapping - to which entity is the Nth entity currently attached (to handle re-attaching in the same entity)
	public var slave, master : W3NPCBackground;									//NPC entities
	public editable var mountEvents : array<SMountEvent>;						//array of mount events we are going to respond to (e.g. 'PassCupToSlave')
	public var masterAC, slaveAC : CAnimatedComponent;							//animated component of NPCs, just cached for easier use
	
	//Creates initial entities and changes object state
	event OnSpawned(spawnData : SEntitySpawnData)
	{
		var i : int;	
		var tmp : Vector;
		var newMaster, newSlave : W3NPCBackground;
		
		if(work == EBNWP_None)
		{
			LogAssert(false,"W3NPCBackgroundPair.OnSpawned : <<" + this + ">> has no work type chosen, aborting!");
			return false;
		}
		
		super.OnSpawned(spawnData);
				
		spawnedEntities.Grow(entitiesToSpawn.Size());
		currentAttachments.Grow(entitiesToSpawn.Size());
			
		for(i=0; i<entitiesToSpawn.Size(); i+=1)
		{									
			//spawn entity in slot coords
			spawnedEntities[i] = theGame.CreateEntity(entitiesToSpawn[i].entityTemplate, tmp);	
			spawnedEntities[i].CreateAttachment(this, entitiesToSpawn[i].slotName);
			currentAttachments[i] = this;
			
			if(!spawnedEntities[i])
			{
				LogAssert(false, "W3NPCBackgroundPair.OnSpawned: pair <<" + this + ">> cannot find slot <<" + entitiesToSpawn[i].slotName + ">>, skipping!");
				continue;
			}
			
			LogBgNPC("Initial spawn : pair <<" + this + ">> spawned <<" + spawnedEntities[i] + ">> on slot <<" + entitiesToSpawn[i].slotName + ">>");
			
			//cache master & slave anim components
			if(entitiesToSpawn[i].referenceName == 'master')
			{
				newMaster = (W3NPCBackground)spawnedEntities[i];
				//if npc is of wrong class
				if(!newMaster)
				{
					LogAssert(false, "W3NPCBackgroundPair.OnSpawned: pair <<" + this + ">> master entity must be of class W3NPCBackground - aborting!");
					return false;
				}
				
				//if master is double defined
				if(master)
				{
					LogAssert(false, "W3NPCBackgroundPair.OnSpawned: pair <<" + this + ">> master entity is defined more than once - aborting!");
					return false;
				}
				
				master = newMaster;
				master.SetParentPairedBackgroundNPCEntity(this);					
				masterAC = (CAnimatedComponent)master.GetComponent( 'man_base' );
				
				if(!masterAC)
				{
					LogAssert(false, "W3NPCBackgroundPair.OnSpawned: pair <<" + this + ">> master's root animated component not found! Make sure it's named 'man_base' - aborting!");
					return false;
				}
			}
			else if(entitiesToSpawn[i].referenceName == 'slave')
			{
				newSlave = (W3NPCBackground)spawnedEntities[i];
				//if npc is of wrong class
				if(!newSlave)
				{
					LogAssert(false, "W3NPCBackgroundPair.OnSpawned: pair <<" + this + ">> slave entity must be of class W3NPCBackground - aborting!");
					return false;
				}
				
				//if slave is double defined
				if(slave)
				{
					LogAssert(false, "W3NPCBackgroundPair.OnSpawned: pair <<" + this + ">> slave entity is defined more than once - aborting!");
					return false;
				}
			
				slave = newSlave;
				slave.SetParentPairedBackgroundNPCEntity(this);
				slaveAC = (CAnimatedComponent)slave.GetComponent( 'man_base' );
				
				if(!slaveAC)
				{
					LogAssert(false, "W3NPCBackgroundPair.OnSpawned: pair <<" + this + ">> slave's root animated component not found! Make sure it's named 'man_base' - aborting!");
					return false;
				}
			}
		}
		
		LogAssert(master, "W3NPCBackgroundPair.OnSpawned: cannot find master entity in <<" + this + ">> - aborting!!!");
		LogAssert(slave, "W3NPCBackgroundPair.OnSpawned: cannot find slave entity in <<" + this + ">> - aborting!!!");
		
		if(!master || !slave)
			return false;
				
		//for switch in behavior
		masterAC.SetBehaviorVariable( 'isMaster', 1.f );
		slaveAC.SetBehaviorVariable( 'isMaster', 0.f );
		
		//select work
		masterAC.SetBehaviorVariable( 'WorkTypeEnum_Paired', (int)work );
		slaveAC.SetBehaviorVariable( 'WorkTypeEnum_Paired', (int)work );
		
		//for playing the animation and syncing on the fly we need to use a state
		PushState('DoWork');
	}
		
	//If the slot is in slot component entity gets teleported there.
	//If it's in npc the entity is attached instead
	public function AttachEntityToSlotRegardlessOfSlotType(i : int, slotName : name, entityContainingSlot : EBgNPCType) : bool
	{
		var slotEntity : CEntity;
		var ret : bool;
	
		//set slot parent entity
		switch(entityContainingSlot)
		{
			case EBNPCT_None : 
				slotEntity = this;
				break;
			case EBNPCT_Master : 
				slotEntity = master;
				break;
			case EBNPCT_Slave : 
				slotEntity = slave;
				break;
		}
		
		//FIXME should be handled by C++ in CreateAttachment
		//If we're attaching to the same entity as already attached then we don't break the attachment. Otherwise the object will return to origin and will NOT get attached
		//to new slot
		if(currentAttachments[i] != slotEntity)
			spawnedEntities[i].BreakAttachment();
			
		ret = spawnedEntities[i].CreateAttachment(slotEntity, slotName);
		if(ret)
			currentAttachments[i] = slotEntity;
		else
			LogAssert(false, "W3NPCBackgroundPair.OnAnimEvent: bg entity <<" + this + ">> :: entity <<" + spawnedEntities[i] + ">> did not get attached to slot <<" + slotName + ">> of <<" + slotEntity + ">> !!!");
		return ret;
	}	
	
	//Called when NPC actor fires animation event to mount items
	public function IncomingAnimEvent(eventName : name)
	{
		var i,j : int;
		var knownEvent, knownEntity : bool;
	
		knownEvent = false;
		for(j=0; j<mountEvents.Size(); j+=1)
		{
			//find events
			if(eventName == mountEvents[j].animEventName)
			{
				knownEvent = true;
				knownEntity = false;
				for(i=0; i<entitiesToSpawn.Size(); i+=1)
				{
					//find entity to move
					if(mountEvents[j].entityReferenceName == entitiesToSpawn[i].referenceName)
					{
						knownEntity = true;
						AttachEntityToSlotRegardlessOfSlotType(i, mountEvents[j].newSlotName, mountEvents[j].entityContainingSlot);
						
						LogBgNPC("Event mount - pair <<" + this + ">> got event <<" + eventName + ">> : mounting <<" + spawnedEntities[i] + ">> to slot <<" + mountEvents[j].newSlotName + ">> of <<" + mountEvents[j].entityContainingSlot + ">>");
						break;
					}
				}		

				if(!knownEntity)
					LogAssert(false, "W3NPCBackgroundPair.OnAnimEvent: <<" + this + ">> unknown entity with reference name = <<" + mountEvents[j].entityReferenceName + ">> - nothing done!");		
			}
		}
		
		if(!knownEvent)
			LogAssert(false, "W3NPCBackgroundPair.OnAnimEvent: <<" + this + ">> unknown anim event called <<" + eventName + ">> - nothing done!");		
	}
}

state DoWork in W3NPCBackgroundPair
{
	event OnEnterState( prevStateName : name )
	{		
		DoWork();
	}
		
	entry function DoWork()
	{	
		var ass : SAnimatedComponentSyncSettings;
		
		ResetAnimatedComponentSyncSettings( ass );
		
		//syncing animations
		while( true )
		{
			SleepOneFrame();
			parent.slaveAC.SyncTo( parent.masterAC, ass );
		}
	}
}