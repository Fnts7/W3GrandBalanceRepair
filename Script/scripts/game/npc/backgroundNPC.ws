/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

//Enum used in behavior to decide which type of work to use with given entity
enum EBackgroundNPCWork_Single
{
	EBNWS_None,
	EBNWS_Brush,
	EBNWS_Sit,	
	EBNWS_SitPipe,
	EBNWS_Spyglass,		
	EBNWS_StandWall,
	EBNWS_Tired,
	EBNWS_WarmUp,	
	EBNWS_PlayingFlute,
	EBNWS_SitSquat,
	EBNWS_DrunkStandRope,
	EBNWS_Crouch,
	EBNWS_WriteList,
	EBNWS_GuardStand,
	EBNWS_Rowing,
	EBNWS_StandTalk1,
	EBNWS_StandTalk2,
	EBNWS_StandTalk3,
	EBNWS_SitDrink,
	EBNWS_SitEat,
	EBNWS_Kneel,
	EBNWS_SitGroundHurt,
	EBNWS_Scout,
	EBNWS_Puke,
	EBNWS_Sex,
	EBNWS_Fishing
}

/* 
	Class for background NPC entity. It's a fake entity of NPC doing some static job e.g. sawing wood
	or sitting with a pipe. The NPC does not move out of it's actionpoint.
	The entity is not an acutal NPC or even Actor - that was the whole point.
	This way we can have a lot of these on a level while not caring about AI, movement and other
	overhead which is not needed at all in this case.
	
	The Entity has an animated model and a fake physics (in template). So basically it's only a model 
	with looped animation and fake simple physics (most likely box).
*/
class W3NPCBackground extends CGameplayEntity
{
	public editable var work : EBackgroundNPCWork_Single;					//type of work (animation) to play
	private var parentPairedBackgroundNPCEntity : W3NPCBackgroundPair;		//background pair entity - used for paired background npcs only
	private var isWorkingSingle : bool;										//set to true if it's a single NPC or a pair (false)
	
		default isWorkingSingle = false;
	
	event OnSpawned(spawnData : SEntitySpawnData)
	{
		//if not a paired NPC then fire single work
		if(!parentPairedBackgroundNPCEntity)
		{
			isWorkingSingle = true;
			SetBehaviorVariable( 'WorkTypeEnum_Single',(int)work);
		}
	}
	
	public function SetParentPairedBackgroundNPCEntity(ent : W3NPCBackgroundPair)
	{
		parentPairedBackgroundNPCEntity = ent;
		if(isWorkingSingle)
		{
			isWorkingSingle = false;
			SetBehaviorVariable( 'WorkTypeEnum_Single',(int)EBNWS_None);
		}
	}
}