state Runewords in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var RUNEWORDS2, ITEMS, ENCHANTS, ENCHANT_DESC, LEVEL, UI : name;
	private var isClosing : bool;
	private const var LEFT_X, LEFT_Y, RIGHT_X, RIGHT_Y : float;
	
		//default RUNEWORDS 	= 'TutorialRunewords';
		default RUNEWORDS2 	= 'TutorialRunewords2';
		default ITEMS 		= 'TutorialEnchantingItems';
		default ENCHANTS	= 'TutorialEnchantingEnchants';
		default ENCHANT_DESC= 'TutorialEnchantingEnchantDescription';		
		default LEVEL 		= 'TutorialEnchantingEnchantLevel';
		default UI			= 'TutorialEnchantingUI';
		
		default LEFT_X		= 0.02f;
		default LEFT_Y		= 0.6f;
		default RIGHT_X		= 0.67f;
		default RIGHT_Y 	= 0.6f;
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		ShowHint(RUNEWORDS2, RIGHT_X, RIGHT_Y, ETHDT_Input);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		//CloseStateHint(RUNEWORDS);
		CloseStateHint(RUNEWORDS2);
		CloseStateHint(ITEMS);
		CloseStateHint(ENCHANTS);
		CloseStateHint(ENCHANT_DESC);
		CloseStateHint(LEVEL);
		CloseStateHint(UI);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(RUNEWORDS2);

		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array<STutorialHighlight>;
		
		if(closedByParentMenu || isClosing)
			return true;
		
		/*
		if(hintName == RUNEWORDS)
		{
			CloseStateHint(RUNEWORDS);
			ShowHint(RUNEWORDS2, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y+0.1, ETHDT_Input);
		}
		else*/
		if(hintName == RUNEWORDS2)
		{
			highlights.Resize(1);
			highlights[0].x = 0.05;
			highlights[0].y = 0.13;
			highlights[0].width = 0.325;
			highlights[0].height = 0.85;
			
			CloseStateHint(RUNEWORDS2);
			ShowHint(ITEMS, RIGHT_X, RIGHT_Y, ETHDT_Input, highlights);
		}
		else if(hintName == ITEMS)
		{
			highlights.Resize(1);
			highlights[0].x = 0.36;
			highlights[0].y = 0.14;
			highlights[0].width = 0.34;
			highlights[0].height = 0.7;
		
			CloseStateHint(ITEMS);
			ShowHint(ENCHANTS, RIGHT_X, RIGHT_Y, ETHDT_Input, highlights);
		}
		else if(hintName == ENCHANTS)
		{
			highlights.Resize(1);
			highlights[0].x = 0.66;
			highlights[0].y = 0.15;
			highlights[0].width = 0.3;
			highlights[0].height = 0.61;
			
			CloseStateHint(ENCHANTS);
			ShowHint(ENCHANT_DESC, LEFT_X, LEFT_Y, ETHDT_Input, highlights);
		}
		else if(hintName == ENCHANT_DESC)
		{
			highlights.Resize(1);
			highlights[0].x = 0.66;
			highlights[0].y = 0.25;
			highlights[0].width = 0.15;
			highlights[0].height = 0.15;
			
			CloseStateHint(ENCHANT_DESC);
			ShowHint(LEVEL, LEFT_X, LEFT_Y, ETHDT_Input, highlights);
		}
		else if(hintName == LEVEL)
		{
			CloseStateHint(LEVEL);
			ShowHint(UI, LEFT_X, LEFT_Y, ETHDT_Input);
		}
		else if(hintName == UI)
		{
			QuitState();
		}
	}
}

// DEBUG - we need to sleep so hence the overkill with class and state
exec function tutrunewords()
{
	//turn tutorial system ON
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	theGame.GetTutorialSystem().UnmarkMessageAsSeen('TutorialRunewords2');
	
	//register tutorial - this is normally done in quest phase
	TutorialScript3('runewords','');
}