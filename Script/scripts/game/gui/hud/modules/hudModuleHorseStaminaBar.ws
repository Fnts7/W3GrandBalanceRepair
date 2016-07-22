/***********************************************************************/
/** Witcher Script file - Stamina bar expressing horse's gallop ability
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Shadi Dadenji, Bartosz Bigaj
/***********************************************************************/

class CR4HudModuleHorseStaminaBar extends CR4HudModuleBase
{	
	private var m_fxSetStaminaSFF : CScriptedFlashFunction;
	private var _stamina : float;
	
	defaults
	{
		_stamina = 1.0;
	}

	event /* flash */ OnConfigUI()
	{		
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorHorseStaminaBar";
		super.OnConfigUI();
		flashModule = GetModuleFlash();	
		m_fxSetStaminaSFF = flashModule.GetMemberFlashFunction( "setStamina" );
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if (hud)
		{
			hud.UpdateHudConfig('HorseStaminaBarModule', true);
		}
	}

	event OnTick( timeDelta : float )
	{
		if ( thePlayer.GetCurrentStateName() == 'HorseRiding' )
			UpdateStamina();
		else
			_stamina = 1;
	}
	
	private function UpdateStamina()
	{
		var curStamina : float;
		curStamina = GetCurrentStamina();

		//even though this shouldn't be here but dying on a horse has been changed and the player is considered 'HorseRiding'
		//longer now causing the stamina bar to show for a split second upon death. Quickest fix!
		if ( thePlayer.GetHealthPercents() <= 0.f )
			return;

		if ( _stamina != curStamina )
		{
			_stamina = curStamina;
			m_fxSetStaminaSFF.InvokeSelfOneArg( FlashArgNumber( _stamina ) );
		}
	}
	
	private function GetCurrentStamina() : float
	{
		var vehicle : CGameplayEntity;
		var horse : CActor;
		var curStamina : float;
		
		//for some reason if we do this in one line SS tries to convert vehicle to CName o_0
		vehicle = thePlayer.GetUsedVehicle();
		horse = (CActor)vehicle;

		curStamina = horse.GetStatPercents( BCS_Stamina );
		return curStamina;
	}


	protected function UpdatePosition(anchorX:float, anchorY:float) : void
	{
		var l_flashModule 		: CScriptedFlashSprite;
		l_flashModule 	= GetModuleFlash();
		
		l_flashModule.SetX( anchorX );
		l_flashModule.SetY( anchorY );	
	}	
}
