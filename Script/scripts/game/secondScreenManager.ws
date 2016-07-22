/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CR4SecondScreenManagerScriptProxy
/** Copyright © 2014
/***********************************************************************/

import class CR4SecondScreenManagerScriptProxy extends CObject
{
	import final function SendGlobalMapPins( mappins : array< SCommonMapPinInstance > );
	import final function SendAreaMapPins( areaType: int, mappins :array< SCommonMapPinInstance > );
	import final function SendGameMenuOpen();
	import final function SendGameMenuClose();
	import final function SendFastTravelEnable();
	import final function SendFastTravelDisable();
	import final function PrintJsonObjectsMemoryUsage();

	private function FastTravelLocal( mapPinTag: name ) : void
	{
	/*
		var manager	: CCommonMapManager;
		manager	= theGame.GetCommonMapManager();
		
		if ( !manager )
		{
			return;
		}
		
		manager.UseMapPin( mapPinTag, true );
		manager.DelayedLocalFastTravelTeleport( mapPinTag );
			
		// lets give some time for the loading menu to open before teleporting to other place
		thePlayer.AddTimer( 'LocalFastTravelTimer', 1.5 );
	*/
	}
	
	private function FastTravelGlobal( areaType: int, mapPinTag: name ) : void
	{		
	/*
		var manager	: CCommonMapManager;
		manager	= theGame.GetCommonMapManager();
		
		if ( !manager )
		{
			return;
		}
		manager.DelayedGlobalFastTravelTeleport( areaType, mapPinTag );
			
		// lets give some time for the loading menu to open before loading other world
		thePlayer.AddTimer( 'GlobalFastTravelTimer', 1.5 );
	*/
	}
}