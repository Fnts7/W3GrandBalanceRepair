class W3FlyingWhale extends CActor
{

	editable var forcedAppearance : string;

	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		super.OnSpawned( spawnData );
		ApplyAppearance( forcedAppearance );
	}
	
}