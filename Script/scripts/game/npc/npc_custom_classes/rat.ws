class W3Rat extends CNewNPC
{
	editable saved var hasCollision : bool; default hasCollision = false;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		super.OnSpawned( spawnData );
		SetInteractionPriority(IP_Prio_0);
		EnableCharacterCollisions(hasCollision);
	}
	
	/*event OnAardHit( sign : W3AardProjectile )
	{
		super.OnAardHit(sign);
		this.Kill();
	}*/
	
	event OnChangeDyingInteractionPriorityIfNeeded()
	{
		this.EnableCollisions(false);
	}
}