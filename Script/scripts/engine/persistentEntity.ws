/////////////////////////////////////////////
// Persistent Entity class
/////////////////////////////////////////////
import class CPeristentEntity extends CEntity
{
	event OnBehaviorSnaphot() { return false; }
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
	}
}