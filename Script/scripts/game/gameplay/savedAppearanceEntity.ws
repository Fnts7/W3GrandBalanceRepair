//////////////////////////////////////////////////////////////
// hacked version of saving CGameplayEntity's appearance
//////////////////////////////////////////////////////////////

class W3SavedAppearanceEntity extends CGameplayEntity
{
	saved var appearanceName	: name;
	default appearanceName		= '';
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{		
		// don't change appearance if not restored or default appearance wasn't changed
		if ( IsNameValid( appearanceName ) && spawnData.restored )
		{
			ApplyAppearance( appearanceName );		
		}
	}
	
	public function SetAppearance( appName : name )
	{
		appearanceName = appName;
		ApplyAppearance( appName );
	}
}