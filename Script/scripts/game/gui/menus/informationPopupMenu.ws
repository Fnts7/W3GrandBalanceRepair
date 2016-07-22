/***********************************************************************/
/** Witcher Script file - Information Popup Window
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Shadi Dadenji
/***********************************************************************/

class CR4InformationPopupMenu extends CR4MenuBase
{	

	event /*flash*/ OnConfigUI() 
	{	
		super.OnConfigUI();

		SetPopupText("Default text: please check CR4InformationPopupMenu::OnConfigUI");
	}

	public function SetPopupText(value:string) : void
	{
		m_flashValueStorage.SetFlashString("popup.info.text", value);	
	}
	

	//optional functions to modify the buttons (by default, the popup will have one OK button)
	public function SetFirstButton(buttonIcon:string, buttonLabel:string) : void //need to find a way to specify what the buttons actually do
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;

		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();

		l_flashObject.SetMemberFlashString("icon", buttonIcon);
		l_flashArray.PushBackFlashObject(l_flashObject);

		l_flashObject.SetMemberFlashString("label", buttonLabel);
		l_flashArray.PushBackFlashObject(l_flashObject);

		m_flashValueStorage.SetFlashArray("popup.info.button1", l_flashArray);
	}
	public function SetSecondButton(buttonIcon:string, buttonLabel:string) : void
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;

		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();

		l_flashObject.SetMemberFlashString("icon", buttonIcon);
		l_flashArray.PushBackFlashObject(l_flashObject);

		l_flashObject.SetMemberFlashString("label", buttonLabel);
		l_flashArray.PushBackFlashObject(l_flashObject);

		m_flashValueStorage.SetFlashArray("popup.info.button2", l_flashArray);
	}
	//////////////////////////////////////////////////////////////////////////////////////////

	event /*flash*/ OnFirstButtonPress()
	{
		CloseMenu();		
	}

	event /*flash*/ OnSecondButtonPress()
	{
		CloseMenu();		
	}
}

