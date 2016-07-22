/***********************************************************************/
/** Witcher Script file - Autosave Warning Menu
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Jason Slama
/***********************************************************************/

class CR4AutosaveWarningMenu extends CR4MenuBase
{	
	protected var m_fxSetDuration : CScriptedFlashFunction;
	protected var m_fxSetAutosaveMessage : CScriptedFlashFunction;
	
	event /*flash*/ OnConfigUI()
	{
		super.OnConfigUI();
		
		m_fxSetDuration = GetMenuFlash().GetMemberFlashFunction("setShowTimerDuration");
		m_fxSetAutosaveMessage = GetMenuFlash().GetMemberFlashFunction("setAutosaveMessage");
		
		m_fxSetDuration.InvokeSelfOneArg(FlashArgInt(5000)); // in milliseconds
		
		SetAutosaveMessageText();
	}
	
	event OnRefresh()
	{
		SetAutosaveMessageText();
	}
	
	private function SetAutosaveMessageText():void
	{
		switch (theGame.GetPlatform())
		{
		case Platform_Xbox1:
		case Platform_PC:
			m_fxSetAutosaveMessage.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt("error_message_autosave_x1")));
			break;
		case Platform_PS4:
			m_fxSetAutosaveMessage.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt("error_message_autosave_ps4")));
			break;
		}
	}
	
	event /* C++ */ OnClosingMenu()
	{
		super.OnClosingMenu();
	}
}

exec function TestAutosave()
{
	theGame.RequestMenu('AutosaveWarningMenu');
}