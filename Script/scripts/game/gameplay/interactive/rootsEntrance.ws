class W3RootsEntrance extends CGameplayEntity
{
	saved var isOpened : bool;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( spawnData.restored )
		{
			if( isOpened )
				Open();
		}
	}
	
	public function Open()
	{
		SetBehaviorVariable( 'moveRootsAway', 1.0 );
		isOpened = true;
	}
	public function Close()
	{
		SetBehaviorVariable( 'moveRootsAway', 0.0 );
		isOpened = false;
	}
}