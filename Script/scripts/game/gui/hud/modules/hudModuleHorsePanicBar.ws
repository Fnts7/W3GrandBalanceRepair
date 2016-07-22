/***********************************************************************/
/** Witcher Script file - Panic bar expressing horse's fear level
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Shadi Dadenji, Bartosz Bigaj
/***********************************************************************/

class CR4HudModuleHorsePanicBar extends CR4HudModuleBase
{	
	private var m_fxSetPanicSFF	: CScriptedFlashFunction;
	private var _panic : float;
	private var horseMounted : bool;
	private var elementShown : bool;
	
	defaults
	{
		_panic = 0.0;
	}
	
	event /* flash */ OnConfigUI()
	{		
		var hud : CR4ScriptedHud;
		var flashModule : CScriptedFlashSprite;

		m_anchorName = "mcAnchorHorsePanicBar";
		super.OnConfigUI();
		flashModule = GetModuleFlash();	
		m_fxSetPanicSFF	= flashModule.GetMemberFlashFunction( "setPanic" );

		hud = (CR4ScriptedHud)theGame.GetHud();
		if (hud)
		{
			hud.UpdateHudConfig('HorsePanicBarModule', true);
		}
	}

	event OnTick( timeDelta : float )
	{
		//only update if we've mounted a horse
		if ( thePlayer.GetCurrentStateName() == 'HorseRiding' )
			UpdatePanic();
		else
			_panic = 0.0;
	}

	private function UpdatePanic()
	{
		var curPanic : float;
		curPanic = GetCurrentPanic();

		if ( _panic != curPanic )
		{
			_panic = curPanic;
			m_fxSetPanicSFF.InvokeSelfOneArg( FlashArgNumber( _panic ) );
		}
	}
	
	private function GetCurrentPanic() : float
	{
		var vehicle : W3HorseComponent;
		var horse : CActor;
		var curPanic : float;
		
		//for some reason if we do this in one line SS tries to convert vehicle to CName o_0
		vehicle = thePlayer.GetUsedHorseComponent();
		curPanic = vehicle.GetPanicPercent();

		return curPanic;
	}	
	
	protected function UpdatePosition(anchorX:float, anchorY:float) : void
	{
		var l_flashModule 		: CScriptedFlashSprite;
		l_flashModule 	= GetModuleFlash();
		
		l_flashModule.SetX( anchorX );
		l_flashModule.SetY( anchorY );	
	}	
}