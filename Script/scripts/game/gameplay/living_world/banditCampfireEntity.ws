class W3POI_BanditCampfireEntity extends CR4MapPinEntity
{	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var mapManager : CCommonMapManager;
		var component : CComponent;
		
		if ( activator.GetEntity() == thePlayer )
		{
			component = GetComponent( "FirstDiscoveryTrigger" );
			if( area == component )
			{
				component.SetEnabled( false );			
				mapManager = theGame.GetCommonMapManager();
				if ( mapManager )
				{
					mapManager.SetEntityMapPinDiscoveredScript( false, entityName, true );
				}
			}
		}
	}	
}
