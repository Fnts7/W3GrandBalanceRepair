class CR4HudModuleAnchors extends CR4HudModuleBase
{
	//>-----------------------------------------------------------------------------------------------------------------
	// VARIABLES
	//------------------------------------------------------------------------------------------------------------------
	private	var m_fxUpdateAnchorsPositions			: CScriptedFlashFunction;
	private	var m_fxUpdateAnchorsAspectRatio		: CScriptedFlashFunction;
	
	//>-----------------------------------------------------------------------------------------------------------------	
	//------------------------------------------------------------------------------------------------------------------
	/* flash */ event OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		flashModule 		= GetModuleFlash();
		m_fxUpdateAnchorsPositions		= flashModule.GetMemberFlashFunction( "UpdateAnchorsPositions" );
		m_fxUpdateAnchorsAspectRatio 	= flashModule.GetMemberFlashFunction( "UpdateAnchorsAspectRatio" );
		
		hud = ( CR4ScriptedHud )theGame.GetHud();
		if (hud)
		{
			hud.UpdateHudScale();
		}
	}
	
	public function GetAnchorSprite( _AnchorName : string ) : CScriptedFlashSprite
	{
		var flashModule : CScriptedFlashSprite;
		
		flashModule 		= GetModuleFlash();
		return flashModule.GetChildFlashSprite( _AnchorName );
	}
	
	public function UpdateAnchorsPositions()
	{
		m_fxUpdateAnchorsPositions.InvokeSelf();
	}
	
	public function UpdateAnchorsAspectRatio()
	{
		var width : int;
		var height : int;
		theGame.GetCurrentViewportResolution( width, height );
		m_fxUpdateAnchorsAspectRatio.InvokeSelfTwoArgs(FlashArgInt(width), FlashArgInt(height));
	}
}