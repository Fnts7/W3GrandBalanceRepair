/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Entrance entity
/** Copyright © 2014
/***********************************************************************/

class W3EntranceEntity extends CR4MapPinEntity
{	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();
		
		if ( activator.GetEntity() == thePlayer )
		{
			if( area == (CTriggerAreaComponent)GetComponent( "FirstDiscoveryTrigger" ) )
			{
				GetComponent( "FirstDiscoveryTrigger" ).SetEnabled( false );			
				mapManager.SetEntityMapPinDiscoveredScript(false, entityName, true );
			}
		}
	}	
}