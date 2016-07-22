/***********************************************************************/
/** Witcher Script file - End Screen Menu
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4EndScreenMenu extends CR4StartScreenMenuBase
{	
	event /*flash*/ OnConfigUI()
	{	
		super.OnConfigUI();
	}
	
	event /*flash*/ OnCloseMenu()
	{
		theGame.FadeInAsync(thePlayer.GetStartScreenFadeInDuration());
		thePlayer.SetEndScreenIsOpened(false);
		CloseMenu();
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
	}
	
	event OnKeyPress() // doesn't close for now
	{
		//theSound.SoundEvent("mus_loc_silent"); // #B old, check
		//theSound.EnterGameState( ESGS_Movie ); // #B old, check
		//theGame.FadeOutAsync(_fadeDuration);
	}	
}