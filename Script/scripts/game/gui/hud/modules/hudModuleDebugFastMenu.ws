class CR4HudModuleDebugFastMenu extends CR4HudModuleBase // #B obsolete
{
	var bOpened : bool;
	var m_flashValueStorage : CScriptedFlashValueStorage;	
	default bOpened = false;

	event /* flash */ OnConfigUI()
	{
		m_anchorName = "ScaleOnly";
		m_flashValueStorage = GetModuleFlashValueStorage();
		super.OnConfigUI();
        
		//ShowElement(false); // #B temporary
		//theInput.RegisterListener( this, 'OnFastMenu', 'FastMenu' );
		UpdateFastMenuEntries();
	}
	
	function UpdateFastMenuEntries()
	{
		var l_FlashArray			: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;


		l_FlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject(); 
		l_DataFlashObject.SetMemberFlashString(  "label", StrUpper("DEBUG OPEN MAIN MENU") );	
		l_DataFlashObject.SetMemberFlashUInt(  "menuName", NameToFlashUInt( 'MainMenu') );		
		l_FlashArray.PushBackFlashObject(l_DataFlashObject);	
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_inventory") );		
		l_DataFlashObject.SetMemberFlashUInt(  "menuName", NameToFlashUInt( 'InventoryMenu') );		
		l_FlashArray.PushBackFlashObject(l_DataFlashObject);
				
		//l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject(); // #B info for BIDON FIX ---> E3 2014 HACK, can be removed later
		//l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_title_character") );	
		//l_DataFlashObject.SetMemberFlashUInt(  "menuName", NameToFlashUInt( 'CharacterMenu') );		
		//l_FlashArray.PushBackFlashObject(l_DataFlashObject);
				
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_title_journal") );
		l_DataFlashObject.SetMemberFlashUInt(  "menuName", NameToFlashUInt( 'JournalQuestMenu') );				
		l_FlashArray.PushBackFlashObject(l_DataFlashObject);
				

				
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_title_alchemy") );	
		l_DataFlashObject.SetMemberFlashUInt(  "menuName", NameToFlashUInt( 'AlchemyMenu') );		
		l_FlashArray.PushBackFlashObject(l_DataFlashObject);
				
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_title_glossary") );	
		l_DataFlashObject.SetMemberFlashUInt(  "menuName", NameToFlashUInt( 'GlossaryBestiaryMenu') );		
		l_FlashArray.PushBackFlashObject(l_DataFlashObject);
				
		 l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject(); 
		l_DataFlashObject.SetMemberFlashString(  "label", StrUpper(GetLocStringByKeyExt("panel_button_common_quittomainmenu")) );	
		l_DataFlashObject.SetMemberFlashUInt(  "menuName", NameToFlashUInt( 'Quit') );		
		l_FlashArray.PushBackFlashObject(l_DataFlashObject);	
		
		if( IsDebugPagesAvailable() )            
		{
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			l_DataFlashObject.SetMemberFlashString(  "label", "DEBUG PAGES" );	
			l_DataFlashObject.SetMemberFlashUInt(  "menuName", NameToFlashUInt( 'Debug') );
			l_FlashArray.PushBackFlashObject(l_DataFlashObject);
		}
		
		m_flashValueStorage.SetFlashArray( "hud.fastmenu.entries", l_FlashArray );
	}
	
	function IsDebugPagesAvailable() : bool
	{
		var sum : int;
		if ( FactsDoesExist("DebugPagesOff") )
		{
			sum = FactsQuerySum("DebugPagesOff");

			if ( sum >= 1 )
				return false;
			else
				return true;
		}
		
		return true;
	}
	
	event OnFastMenu( action : SInputAction )
	{
		// always allow to hide radial menu when player releases the button
		// check for input only when radial menu is supposed to be shown
		if( action.value > 0.7f && thePlayer.IsActionAllowed( EIAB_OpenFastMenu ) )
		{
			bOpened = !bOpened;
			UpdateFastMenuEntries();
			OnShowFastMenu(bOpened);
		}
	}

	event /* flash */ OnShowFastMenu( opened : bool )
	{
		LogChannel( 'DEBUGFASTMENU', "ShowFastMenu " + opened );
		if ( opened )
		{
			theGame.Pause( "FastMenu" );
			theInput.StoreContext( 'FastMenu' );			
			
		}
		else
		{
			theGame.GetSecondScreenManager().SendGameMenuClose();
			theGame.Unpause( "FastMenu" );
			theInput.RestoreContext( 'FastMenu', false );
		}
		
		//ShowElement( opened, true ); // #B Show
		bOpened = opened;
	}

	event /* flash */ OnItemChosen( choosenPanelId : name )
	{		
		LogChannel( 'DEBUGFASTMENU', "OnItemChosen " + choosenPanelId );
		switch(choosenPanelId)
		{
			case 'InventoryMenu':
				if(thePlayer.IsActionAllowed(EIAB_OpenInventory))
				{
					theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
				}
				break;
			case 'CharacterMenu':
				if(thePlayer.IsActionAllowed(EIAB_OpenCharacterPanel))
				{
					//theGame.RequestMenuWithBackground( 'CharacterMenu', 'CommonMenu' );
					theGame.RequestMenu( 'CharacterMenu' ); // #Y while dont have this tab in the main menu
				}
				break;
			case 'JournalQuestMenu':
				if(thePlayer.IsActionAllowed(EIAB_OpenJournal))
				{
					theGame.RequestMenuWithBackground( 'JournalQuestMenu', 'CommonMenu' ); // #B change to JournalMenu
				}
				break;
			case 'MapMenu': //HUB MAP
				if(thePlayer.IsActionAllowed(EIAB_OpenMap))
				{				
					theGame.RequestMenuWithBackground( 'MapMenu', 'CommonMenu' );
				}
				break;
 			case 'AlchemyMenu':
				if(thePlayer.IsActionAllowed(EIAB_OpenAlchemy))
				{
					theGame.RequestMenuWithBackground( 'AlchemyMenu', 'CommonMenu' );
				}
				break; 	 	
			case 'GlossaryBestiaryMenu':
				if(thePlayer.IsActionAllowed(EIAB_OpenGlossary))
				{
					theGame.RequestMenuWithBackground( 'GlossaryBestiaryMenu', 'CommonMenu' );
				}
				break; 			
			case 'MainMenu':
				theGame.SetMenuToOpen( '' );
				theGame.RequestMenu(/*'MainMenu',*/'CommonMainMenu');
				break; 		
			case 'Quit':
				theGame.RequestEndGame();
				break;
			case 'Debug':
				OpenDebugWindows();
				break;

		}
		OnShowFastMenu( false );
	}
}
