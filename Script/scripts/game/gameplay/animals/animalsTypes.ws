/***********************************************************************/
/** Copyright © 2012-2014
/** Author : ?, Tomasz Kozera
/***********************************************************************/

enum EBirdType
{
	Crow,
	Pigeon,
	Seagull,
	Sparrow
}

struct SBirdSpawnpoint
{
	var isBirdSpawned : bool;
	var isFlying : bool;
	var entityId : int;
	var entitySpawnTimestamp : float;
	var bird : W3Bird;
	var position : Vector;
	var rotation : EulerAngles;
}

struct SFishSpawnpoint
{
	var shouldBeErased : bool;
	var isFishSpawned : bool;
	var position : Vector;
	var rotation : EulerAngles;
	var spawnHandler : CCreateEntityHelper;
};