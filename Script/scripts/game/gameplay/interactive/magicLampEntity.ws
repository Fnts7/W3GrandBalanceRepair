class W3MagicLampEntity extends CInteractiveEntity
{
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();
		
		if ( activator.GetEntity() == thePlayer )
		{
			if ( area == GetComponent( "ShowMapPinTrigger" ) )
			{
				GetComponent( "ShowMapPinTrigger" ).SetEnabled( false );
				mapManager.SetEntityMapPinDiscoveredScript( false, entityName, true );
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
	}

	// TURNING OFF MAPPIN OF THIS ENTITY:
	//
	//mapManager.SetEntityMapPinDiscoveredScript( false, entityName, false );
	//
}
