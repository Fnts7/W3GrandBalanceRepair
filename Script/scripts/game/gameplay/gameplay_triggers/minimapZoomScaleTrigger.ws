/***********************************************************************/
/** Witcher Script file - Trigger for setting minimap scale
/***********************************************************************/
/** Copyright © 2013
/** Author : Bartosz Bigaj
/***********************************************************************/

class W3MinimapZoomScaleTrigger extends CGameplayEntity //#B for now it can block only meditation
{
	private editable var zoomScale : float;
	default zoomScale = 1.0f;
	
	private var previousZoomScale : float;

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		// TO BE INCLUDED IN INTERIOR TRIGGER
		/*
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			previousZoomScale = hud.GetMinimapZoom();
			hud.SetMinimapZoom( zoomScale );
		}
		*/
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		// TO BE INCLUDED IN INTERIOR TRIGGER
		/*
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if ( hud )
		{
			hud.SetMinimapZoom( previousZoomScale );
		}
		*/
	}
}