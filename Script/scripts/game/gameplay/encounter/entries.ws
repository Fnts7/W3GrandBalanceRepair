/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Encounter System
/** Copyright © 2010-2013
/***********************************************************************/

import class ISpawnTreeLeafNode extends ISpawnTreeBaseNode
{
}

import class CBaseCreatureEntry extends ISpawnTreeLeafNode
{
	import var quantityMin 					: int;
	import var quantityMax 					: int;
	import var spawnInterval 				: float;
	import var waveDelay 					: float;
	import var waveCounterHitAtDeathRatio 	: float;
	import var randomizeRotation 			: bool;
	import var group						: int;
	import var baseSpawner 					: CSpawnTreeWaypointSpawner;
}
import class CCreatureEntry extends CBaseCreatureEntry
{
	import var creatureDefinition			: name;
}