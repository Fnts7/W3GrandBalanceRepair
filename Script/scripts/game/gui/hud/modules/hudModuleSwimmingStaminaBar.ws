/***********************************************************************/
/** Witcher Script file - Main Visuals Options Menu
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Patry Fiutowski (temp)
/***********************************************************************/
/*
class CR4HudModuleSwimmingStaminaBar extends CR4HudModuleBase
{	
	private var		m_fxSetPanicSFF		: CScriptedFlashFunction;
	private var		_swimming_stamina 	: float;
	private var 	currSwimmingStamina	: float;
	
	defaults
	{
		_swimming_stamina = 0.0;
	}
	
	event OnConfigUI()
	{		
		var flashModule : CScriptedFlashSprite;
		m_anchorName = "mcAnchorHorsePanicBar";
		super.OnConfigUI();
		flashModule = GetModuleFlash();	
		m_fxSetPanicSFF	= flashModule.GetMemberFlashFunction( "setPanic" );
	}

	event OnTick( timeDelta : float )
	{
		var shouldBeShown : bool;
		var show : bool;
		
		show = thePlayer.HasBuff(EET_StaminaDrainSwimming) && thePlayer.GetStat(BCS_Stamina) <= 0;
		
		if ( show )
		{
			UpdateSwimmingStamina();
			shouldBeShown = true;
		}
		else if( shouldBeShown )
		{
			shouldBeShown = false;
			ShowElement(false,true);
		}
	}
	
	private function GetCurrentSwimmingStamina() : float
	{
		return thePlayer.GetStat(BCS_SwimmingStamina);
	}
	
	private function UpdateSwimmingStamina()
	{
		var curSwimmingStamina : float;

		currSwimmingStamina = GetCurrentSwimmingStamina();
		if ( _swimming_stamina != currSwimmingStamina )
		{
			_swimming_stamina = currSwimmingStamina;

			m_fxSetPanicSFF.InvokeSelfOneArg( FlashArgNumber( _swimming_stamina ) );
		}
		if( _swimming_stamina < 1.0 )
		{
			ShowElement(true,true);
		}
		else
		{
			ShowElement(false,true);
		}
	}
}
*/