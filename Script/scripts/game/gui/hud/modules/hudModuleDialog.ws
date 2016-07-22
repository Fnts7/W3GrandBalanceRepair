import struct SSceneChoice
{
	import var description : string;
	import var emphasised : bool;
	import var previouslyChoosen : bool;
	import var disabled : bool;
	import var dialogAction : EDialogActionIcon;
	import var playGoChunk : name;
}

class CR4HudModuleDialog extends CR4HudModuleBase
{
	private var m_fxSentenceSetSFF					: CScriptedFlashFunction;
	private var m_fxPreviousSentenceSetSFF			: CScriptedFlashFunction;
	private var m_fxPreviousSentenceHideSFF			: CScriptedFlashFunction;
	private var m_fxSentenceHideSFF					: CScriptedFlashFunction;
	
	private var m_fxChoiceTimeoutSetSFF				: CScriptedFlashFunction;
	private var m_fxChoiceTimeoutHideSFF			: CScriptedFlashFunction;
	private var m_fxSkipConfirmShowSFF				: CScriptedFlashFunction;
	private var m_fxSkipConfirmHideSFF				: CScriptedFlashFunction;
	private var m_fxSetBarValueSFF					: CScriptedFlashFunction;
	private var m_fxSetCanBeSkipped					: CScriptedFlashFunction;
	private var m_fxSetAlternativeDialogOptionView  : CScriptedFlashFunction;
	
	private var monsterBarganingPopupMenu   		: CR4MenuPopup;
	private var m_guiManager			 			: CR4GuiManager;
	
	// Bet and Monster Hunt Negotiation variables
	private var m_LastNegotiationResult		: ENegotiationResult;
	private var currentRewardName			: name;
	private var currentRewardMultiply		: float;
	private var isBet 						: bool;
	private var isReverseHaggling 			: bool;
	public var isPopupOpened 				: bool;
	private var isGwentMode 				: bool;
	public var anger 						: float;
	private var currentReward				: int;			//currently selected value of haggle
	private var minimalHagglingReward		: int;			//minimal value of the haggle bar
	private var maxHaggleValue 				: int;			//maximal value of the haggle bar
	private var NPCsPrettyClose				: float;		//multiplier of minimalHagglingReward which is a border between "deal" and "pretty close"
	private var NPCsTooMuch					: float;		//multiplier of minimalHagglingReward which is a border between "pretty close" and "too much"
	private var LowestPriceControlFact		: string;
	default anger = 0;
	
	protected var lastSetChoices 			: array< SSceneChoice >;

	event /* flash */ OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		m_anchorName = "ScaleOnly";	
		flashModule = GetModuleFlash();
		
		m_guiManager = theGame.GetGuiManager();
		
		m_fxSentenceSetSFF				   = flashModule.GetMemberFlashFunction( "SentenceSet" );
		m_fxPreviousSentenceSetSFF		   = flashModule.GetMemberFlashFunction( "PreviousSentenceSet" );
		m_fxPreviousSentenceHideSFF		   = flashModule.GetMemberFlashFunction( "PreviousSentenceHide" );
		m_fxSentenceHideSFF				   = flashModule.GetMemberFlashFunction( "SentenceHide" );
		m_fxChoiceTimeoutSetSFF			   = flashModule.GetMemberFlashFunction( "ChoiceTimeoutSet" );
		m_fxChoiceTimeoutHideSFF		   = flashModule.GetMemberFlashFunction( "ChoiceTimeoutHide" );
		m_fxSkipConfirmShowSFF			   = flashModule.GetMemberFlashFunction( "SkipConfirmShow" );
		m_fxSkipConfirmHideSFF			   = flashModule.GetMemberFlashFunction( "SkipConfirmHide" );
		m_fxSetBarValueSFF				   = flashModule.GetMemberFlashFunction( "setBarValue" );
		m_fxSetCanBeSkipped				   = flashModule.GetMemberFlashFunction( "setCanBeSkipped" );
		m_fxSetAlternativeDialogOptionView = flashModule.GetMemberFlashFunction( "setAlternativeDialogOptionView" );
		
		UpdateCanBeSkipped(theGame.GetStorySceneSystem().IsSkippingLineAllowed());
		
		super.OnConfigUI();
	}

	public function SetGwentMode( value : bool )
	{
		isGwentMode = value;
	}

	event OnTick( timeDelta : float )
	{
	}
	
	public function UpdateCanBeSkipped(canBeSkipped:bool)
	{
		m_fxSetCanBeSkipped.InvokeSelfOneArg(FlashArgBool(canBeSkipped));
	}
	
	public function OnMissingContentDialogClosed()
	{
		SendDialogChoicesToUI(lastSetChoices, false);
	}

	event /* flash */ OnDialogOptionSelected( index : int )
	{
		var system : CStorySceneSystem = theGame.GetStorySceneSystem();
		LogChannel('DIALOG', "***************************" );
		LogChannel('DIALOG', "OnDialogOptionSelected " + index );
		LogChannel('DIALOG', "***************************" );
		system.SendSignal( SSST_Highlight, index );
	}

	event /* flash */ OnDialogOptionAccepted( index : int )
	{
		var system : CStorySceneSystem = theGame.GetStorySceneSystem();
		var acceptedChoice : SSceneChoice;
		var progress : float;
		
		acceptedChoice = lastSetChoices[index];
		
		LogChannel('DIALOG', "***************************" );
		LogChannel('DIALOG', "OnDialogOptionAccepted " + index );
		
		LogChannel('DIALOG', "***************************" );
		
		if (!acceptedChoice.disabled)
		{
			system.SendSignal( SSST_Accept, index );
			
			m_guiManager.RequestMouseCursor(false);
			theGame.ForceUIAnalog(false);
		}
		else
		{
			if (acceptedChoice.dialogAction == DialogAction_CONTENT_MISSING)
			{
				if (!theGame.IsContentAvailable(acceptedChoice.playGoChunk))
				{
					progress = theGame.ProgressToContentAvailable(acceptedChoice.playGoChunk);
					theSound.SoundEvent("gui_global_denied");
					theGame.GetGuiManager().ShowProgressDialog(UMID_MissingContentOnDialogError, "", "panel_map_cannot_travel_downloading_content", true, UDB_Ok, progress, UMPT_Content, acceptedChoice.playGoChunk);
				}
				else
				{
					system.SendSignal( SSST_Accept, index );
					m_guiManager.RequestMouseCursor(false);
					theGame.ForceUIAnalog(false);
				}
			}
			else
			{
				OnPlaySoundEvent("gui_global_denied");
			}
		}
	}
	
	event /* flash */ OnDialogSkipped( value : int )
	{
		var system : CStorySceneSystem = theGame.GetStorySceneSystem();
		
		LogChannel('DIALOG', "***************************" );
		LogChannel('DIALOG', "OnDialogSkipped" );
		LogChannel('DIALOG', "***************************" );
		
		system.SendSignal( SSST_Skip, value );
	}

	function OnDialogSentenceSet( text : string, optional alternativeUI : bool )
	{
		if( theGame.isDialogDisplayDisabled )
		{
			text = "";
		}
		else
		if (alternativeUI)
		{
			text = "<FONT COLOR='#5ACCF6'>" + GetLocStringByKeyExt("Witold") + ": " + text + "</FONT>";
		}
		m_fxSentenceSetSFF.InvokeSelfOneArg( FlashArgString( text ) );
	}
	
	function OnDialogPreviousSentenceSet( text : string )
	{
		if( theGame.isDialogDisplayDisabled )
		{
			text = "";
		}
		m_fxPreviousSentenceSetSFF.InvokeSelfOneArg( FlashArgString( text ) );
	}
	
	function OnDialogPreviousSentenceHide()
	{
		m_fxPreviousSentenceHideSFF.InvokeSelf();
	}
	
	function OnDialogSentenceHide()
	{
		m_fxSentenceHideSFF.InvokeSelf();
	}

	function OnDialogChoicesSet( choices : array< SSceneChoice >, alternativeUI : bool )
	{
		m_fxSetAlternativeDialogOptionView.InvokeSelfOneArg( FlashArgBool(alternativeUI) );
		SendDialogChoicesToUI(choices, true);
		m_guiManager.RequestMouseCursor(true);
		theGame.ForceUIAnalog(true);
	}
	
	private function SendDialogChoicesToUI( choices : array< SSceneChoice >, allowContentMissingDialog : bool)
	{
		var i : int;
		var flashValueStorage 		: CScriptedFlashValueStorage;
		var choiceFlashArray		: CScriptedFlashArray;
		var choiceFlashObject		: CScriptedFlashObject;
		var hasContentMissing		: bool;
		var missingContent			: name;
		var progress 				: float;
		
		hasContentMissing = false;
		
		flashValueStorage = GetModuleFlashValueStorage();
		
		choiceFlashArray = flashValueStorage.CreateTempFlashArray();
		
		lastSetChoices = choices;
		
///////////////////////////////////////////
//
//
//
//m_fxSetAlternativeDialogOptionView.InvokeSelfOneArg( FlashArgBool( true ) );
//
//
//
///////////////////////////////////////////
		
		for ( i = 0; i < lastSetChoices.Size(); i += 1 )
		{
			choiceFlashObject = flashValueStorage.CreateTempFlashObject();
			choiceFlashObject.SetMemberFlashInt( "prefix",      i + 1 );
			choiceFlashObject.SetMemberFlashString( "name",     lastSetChoices[ i ].description );
			choiceFlashObject.SetMemberFlashInt( "icon",     	lastSetChoices[ i ].dialogAction );		
			choiceFlashObject.SetMemberFlashBool( "read",     	lastSetChoices[ i ].previouslyChoosen == false );		
			choiceFlashObject.SetMemberFlashBool( "emphasis", 	lastSetChoices[ i ].emphasised );
			
			if (lastSetChoices[i].disabled && lastSetChoices[i].dialogAction == DialogAction_CONTENT_MISSING)
			{
				if (theGame.IsContentAvailable(lastSetChoices[i].playGoChunk))
				{
					choiceFlashObject.SetMemberFlashBool( "locked", false );
				}
				else
				{
					hasContentMissing = true;
					missingContent = lastSetChoices[i].playGoChunk;
					choiceFlashObject.SetMemberFlashBool( "locked", lastSetChoices[ i ].disabled );
				}
			}
			else
			{
				choiceFlashObject.SetMemberFlashBool( "locked", lastSetChoices[ i ].disabled );
			}
			
			choiceFlashArray.SetElementFlashObject( i, choiceFlashObject );
		}
		
		////////////////////////////////////////////////
		//
		//
		//
		
		// EXTRA LINES
		/*
			if ( choiceFlashArray.GetLength() > 0 )
			{
				choiceFlashObject = flashValueStorage.CreateTempFlashObject();
				choiceFlashObject.SetMemberFlashInt( "prefix",      choiceFlashArray.GetLength() + 1 );
				choiceFlashObject.SetMemberFlashString( "name",     "Lalala to jest dluga linia dialogowa, chce zobaczyc jak bedzie wygladac w nowym dialog module" );
				choiceFlashObject.SetMemberFlashInt( "icon",     	0 );		
				choiceFlashObject.SetMemberFlashBool( "read",     	true );		
				choiceFlashObject.SetMemberFlashBool( "emphasis", 	false );
				choiceFlashObject.SetMemberFlashBool( "locked",     false );
				choiceFlashArray.SetElementFlashObject( choiceFlashArray.GetLength(), choiceFlashObject );

				choiceFlashObject = flashValueStorage.CreateTempFlashObject();
				choiceFlashObject.SetMemberFlashInt( "prefix",      choiceFlashArray.GetLength() + 1 );
				choiceFlashObject.SetMemberFlashString( "name",     "Locked" );
				choiceFlashObject.SetMemberFlashInt( "icon",     	0 );		
				choiceFlashObject.SetMemberFlashBool( "read",     	false );		
				choiceFlashObject.SetMemberFlashBool( "emphasis", 	false );
				choiceFlashObject.SetMemberFlashBool( "locked",     true );
				choiceFlashArray.SetElementFlashObject( choiceFlashArray.GetLength(), choiceFlashObject );
			
				choiceFlashObject = flashValueStorage.CreateTempFlashObject();
				choiceFlashObject.SetMemberFlashInt( "prefix",      choiceFlashArray.GetLength() + 1 );
				choiceFlashObject.SetMemberFlashString( "name",     "Emphased" );
				choiceFlashObject.SetMemberFlashInt( "icon",     	0 );		
				choiceFlashObject.SetMemberFlashBool( "read",     	true );		
				choiceFlashObject.SetMemberFlashBool( "emphasis", 	true );
				choiceFlashObject.SetMemberFlashBool( "locked",     false );
				choiceFlashArray.SetElementFlashObject( choiceFlashArray.GetLength(), choiceFlashObject );

				choiceFlashObject = flashValueStorage.CreateTempFlashObject();
				choiceFlashObject.SetMemberFlashInt( "prefix",      choiceFlashArray.GetLength() + 1 );
				choiceFlashObject.SetMemberFlashString( "name",     "Jeszcze jedna linijka" );
				choiceFlashObject.SetMemberFlashInt( "icon",     	0 );		
				choiceFlashObject.SetMemberFlashBool( "read",     	true );		
				choiceFlashObject.SetMemberFlashBool( "emphasis", 	false );
				choiceFlashObject.SetMemberFlashBool( "locked",     false );
				choiceFlashArray.SetElementFlashObject( choiceFlashArray.GetLength(), choiceFlashObject );

				choiceFlashObject = flashValueStorage.CreateTempFlashObject();
				choiceFlashObject.SetMemberFlashInt( "prefix",      choiceFlashArray.GetLength() + 1 );
				choiceFlashObject.SetMemberFlashString( "name",     "I jeszcze jedna..." );
				choiceFlashObject.SetMemberFlashInt( "icon",     	0 );		
				choiceFlashObject.SetMemberFlashBool( "read",     	true );		
				choiceFlashObject.SetMemberFlashBool( "emphasis", 	false );
				choiceFlashObject.SetMemberFlashBool( "locked",     false );
				choiceFlashArray.SetElementFlashObject( choiceFlashArray.GetLength(), choiceFlashObject );

				choiceFlashObject = flashValueStorage.CreateTempFlashObject();
				choiceFlashObject.SetMemberFlashInt( "prefix",      choiceFlashArray.GetLength() + 1 );
				choiceFlashObject.SetMemberFlashString( "name",     "A to juz nadmiarowa..." );
				choiceFlashObject.SetMemberFlashInt( "icon",     	0 );		
				choiceFlashObject.SetMemberFlashBool( "read",     	true );		
				choiceFlashObject.SetMemberFlashBool( "emphasis", 	false );
				choiceFlashObject.SetMemberFlashBool( "locked",     false );
				choiceFlashArray.SetElementFlashObject( choiceFlashArray.GetLength(), choiceFlashObject );

				choiceFlashObject = flashValueStorage.CreateTempFlashObject();
				choiceFlashObject.SetMemberFlashInt( "prefix",      choiceFlashArray.GetLength() + 1 );
				choiceFlashObject.SetMemberFlashString( "name",     "I ostatnia..." );
				choiceFlashObject.SetMemberFlashInt( "icon",     	0 );		
				choiceFlashObject.SetMemberFlashBool( "read",     	false );		
				choiceFlashObject.SetMemberFlashBool( "emphasis", 	true );
				choiceFlashObject.SetMemberFlashBool( "locked",     false );
				choiceFlashArray.SetElementFlashObject( choiceFlashArray.GetLength(), choiceFlashObject );
			}
		//*/
		
		//
		//
		//
		////////////////////////////////////////////////
		
		if (allowContentMissingDialog && hasContentMissing && !theGame.IsContentAvailable(missingContent))
		{
			progress = theGame.ProgressToContentAvailable(missingContent);
			theSound.SoundEvent("gui_global_denied");
			theGame.GetGuiManager().ShowProgressDialog(UMID_MissingContentOnDialogError, "", "panel_map_cannot_travel_downloading_content", true, UDB_Ok, progress, UMPT_Content, missingContent);
		}
		
		flashValueStorage.SetFlashArray( "hud.dialog.choices", choiceFlashArray );
		
		//reset gwent mode special case
		if ( choices.Size() > 0 )
		{
			SetGwentMode( false );
		}
	}

	function OnDialogChoiceTimeoutSet(timeOutPercent : float)
	{
		m_fxChoiceTimeoutSetSFF.InvokeSelfOneArg(FlashArgNumber(timeOutPercent));
	}

	function OnDialogChoiceTimeoutHide()
	{
		m_guiManager.RequestMouseCursor(false);
		theGame.ForceUIAnalog(false);
		m_fxChoiceTimeoutHideSFF.InvokeSelf();
	}

	function OnDialogSkipConfirmShow()
	{
		m_fxSkipConfirmShowSFF.InvokeSelf();
	}

	function OnDialogSkipConfirmHide()
	{
		m_fxSkipConfirmHideSFF.InvokeSelf();
	}
	
	function OpenMonsterHuntNegotiationPopup( rewardName : name, minimalGold : int, alwaysSuccessful : bool, optional isItemReward : bool  )
	{
		var popupData   : DialogueMonsterBarganingSliderData;
		var rewrd	    : SReward;
		var maxMult     : float;
		var rewardValue : int;
		
		if(theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning())		
		{
			theGame.GetTutorialSystem().uiHandler.OnOpeningMenu('MonsterHuntNegotiationMenu');
		}
		
		popupData = new DialogueMonsterBarganingSliderData in this;
		popupData.ScreenPosX = 0.05;
		popupData.ScreenPosY = 0.5;
		
		theGame.GetReward( rewardName, rewrd );
		currentRewardName = rewardName;
		isBet = false;
		isReverseHaggling = false;
		isPopupOpened = true;
		m_fxSetBarValueSFF.InvokeSelfOneArg(FlashArgNumber(0));
		
		popupData.SetMessageTitle( GetLocStringByKeyExt("panel_hud_dialogue_title_negotiation"));
		popupData.dialogueRef = this;
		popupData.BlurBackground = false; // @TODO UI #Y - implement bluring state
		popupData.m_DisplayGreyBackground = false;
		popupData.alternativeRewardType = isItemReward;
		
		if( isItemReward && rewrd.items.Size() > 0 )
		{
			// UI limitation, we can bargaining only for one kind of items from the list
			rewardValue = rewrd.items[0].amount;
		}
		else
		{
			rewardValue = minimalGold;
		}
		
		if( anger == 0 ) //#B first time 
		{			
			currentRewardMultiply = 1.f;
			minimalHagglingReward = FloorF(rewardValue);
			maxMult = RandRangeF(0.5, 0.35);						//max increase from base value
			maxHaggleValue = FloorF( rewardValue * (1.f + maxMult) );
			currentReward = minimalHagglingReward;
			
			if ( alwaysSuccessful )
			{
				NPCsPrettyClose = 1.f + maxMult;
				NPCsTooMuch = NPCsPrettyClose;
			}
			else
			{
				NPCsPrettyClose = 1.f + RandRangeF(0.7, 0.2f) * maxMult;		//we can haggle +20% to +70% of available range
				NPCsTooMuch = NPCsPrettyClose + 0.3 * maxMult;				//too much is always 30% above that
			}
			
			LogHaggle("");
			LogHaggle("Haggling for " + rewardName);
			LogHaggle("min/base gold: " + rewardValue);
			LogHaggle("max bar value: " + maxHaggleValue);
			LogHaggle("default bar value (1.0): " + NoTrailZeros(currentReward));
			LogHaggle("deal/pretty close border (" + NoTrailZeros(NPCsPrettyClose) + "): " + NoTrailZeros(NPCsPrettyClose * rewardValue));
			LogHaggle("pretty close/too much border (" + NoTrailZeros(NPCsTooMuch) + "): " + NoTrailZeros(NPCsTooMuch * rewardValue));
			LogHaggle("");
			
			popupData.currentValue = minimalHagglingReward;
		}
		else
		{
			popupData.currentValue = currentReward;
		}
		
		popupData.minValue = rewardValue;
		popupData.baseValue = rewardValue;
		popupData.anger = anger;
		popupData.maxValue = maxHaggleValue;
		
		theGame.RequestMenu('PopupMenu', popupData);		
	}
	
	
	function OpenLowerPriceNegotiationPopup( controlFact : string, bestBarginModifier : float, optional lowestPriceModifier : float )
	{
		var popupData : DialogueMonsterBarganingSliderData;
		var maxMult : float;		
		
		/*
		if(theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning())		
		{
			theGame.GetTutorialSystem().uiHandler.OnOpeningMenu('MonsterHuntNegotiationMenu');
		}
		*/
		popupData = new DialogueMonsterBarganingSliderData in this;
		
		popupData.ScreenPosX = 0.05;
		popupData.ScreenPosY = 0.5;
		
		isBet = false;
		isReverseHaggling = true;
		isPopupOpened = true;
		m_fxSetBarValueSFF.InvokeSelfOneArg(FlashArgNumber(0));
		
		
		popupData.SetMessageTitle( GetLocStringByKeyExt("panel_hud_dialogue_title_negotiation"));
		popupData.dialogueRef = this;
		popupData.BlurBackground = false; // @TODO UI #Y - implement bluring state
		popupData.m_DisplayGreyBackground = false;		
		
		if( anger == 0 ) //#B first time 
		{
			if( lowestPriceModifier > bestBarginModifier )
			{
				bestBarginModifier = lowestPriceModifier;
			}
			LowestPriceControlFact = controlFact;
			
			currentRewardMultiply = 1.f;					//max increase from base value
			maxHaggleValue = FactsQuerySum( LowestPriceControlFact );
			minimalHagglingReward = FloorF( maxHaggleValue * lowestPriceModifier );
			currentReward = maxHaggleValue;
			
			NPCsPrettyClose	= 1.0f * bestBarginModifier;
			NPCsTooMuch = NPCsPrettyClose * 0.7f;
			
			LogHaggle("");
			LogHaggle("Haggling for " + maxHaggleValue);
			LogHaggle("min/base gold: " + minimalHagglingReward);
			LogHaggle("deal/pretty close border (" + NoTrailZeros(NPCsPrettyClose) + "): " + NoTrailZeros(NPCsPrettyClose * (maxHaggleValue - minimalHagglingReward ) + minimalHagglingReward));
			LogHaggle("pretty close/too much border (" + NoTrailZeros(NPCsTooMuch) + "): " + NoTrailZeros(NPCsTooMuch * (maxHaggleValue - minimalHagglingReward ) + minimalHagglingReward));
			LogHaggle("");	
			
			popupData.currentValue = maxHaggleValue;
		}
		else
		{
			popupData.currentValue = currentReward;
		}
		
		popupData.minValue = minimalHagglingReward;
		
		popupData.baseValue = maxHaggleValue;
		popupData.anger = anger;
		popupData.maxValue = maxHaggleValue;
		theGame.RequestMenu('PopupMenu', popupData);		
	}	
	
	
	function OpenBetPopup( rewardName : name, overrideCurrent : int )
	{
		var rewrd				: SReward;
		var popupData 			: BettingSliderData;
		var flashValueStorage 	: CScriptedFlashValueStorage;
		
		//bypassing betting popup if this is gwent and we have no money (to play for free)
		if ( isGwentMode && thePlayer.GetMoney() == 0 )
		{
			thePlayer.SetRewardMultiplier(rewardName, 0);
			return;
		}
		
		flashValueStorage = GetModuleFlashValueStorage();
		OnDialogPreviousSentenceSet("");
		OnDialogSentenceSet("");
		
		popupData = new BettingSliderData in this;
		
		popupData.ScreenPosX = 0.62;
		popupData.ScreenPosY = 0.65;
		
		theGame.GetReward( rewardName, rewrd );
		currentRewardName = rewardName;
		currentRewardMultiply = 0;
		isBet = true;
		isReverseHaggling = false;
		isPopupOpened = true;
		
		popupData.SetMessageTitle( GetLocStringByKeyExt("panel_hud_dialogue_title_bet"));
		popupData.dialogueRef = this;
		popupData.BlurBackground = false;  // @TODO UI #Y - implement bluring state
		
		popupData.minValue = 1;
		popupData.maxValue = rewrd.gold;
		
		if( overrideCurrent > 0 )
		{
			popupData.currentValue = Max (1, Min( rewrd.gold, thePlayer.GetMoney() ) * overrideCurrent / 100);
		}
		else
		{
			popupData.currentValue = rewrd.gold;
		}

		theGame.RequestMenu('PopupMenu', popupData);
		
		if(theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning())		
		{
			theGame.GetTutorialSystem().uiHandler.OnOpeningMenu('BetMenu');
		}
	}

	function DialogueSliderDataPopupResult( value : float, optional isItemReward : bool )
	{
		var rewrd : SReward;
		var a     : float;
		
		theGame.GetReward( currentRewardName, rewrd );
		
		if( isReverseHaggling )
		{	
			currentReward = FloorF(value);
			currentRewardMultiply = (value - minimalHagglingReward) / (maxHaggleValue-minimalHagglingReward);
			
			if( currentRewardMultiply < NPCsTooMuch )
			{
				m_LastNegotiationResult = TooMuch;
				a = RandRangeF(60,40);				
				anger += a;
			}		
			else if( currentRewardMultiply < NPCsPrettyClose )
			{
				m_LastNegotiationResult = PrettyClose;
				a = RandRangeF(20,10);
				anger += a;
			}
			else
			{
				m_LastNegotiationResult = WeHaveDeal;
				anger = 0;
				FactsSet( LowestPriceControlFact, FloorF(value), -1 );
				LogHaggle("Deal!");
			}
			
			//too angry, only get base value
			if( anger >= 100 )
			{
				m_LastNegotiationResult = GetLost;
				anger = 0;
				LogHaggle("NPC is furious - game over.");
				LogHaggle("");
			}
			
			isBet = false;			
			
		}
		else
		{
			if( isBet )
			{
				currentRewardMultiply = ( value / rewrd.gold ) * 2; // #B because it's a bet and you get what you bet + your money back
				thePlayer.RemoveMoney( RoundF( value ) ); // Remove the money bet from the inventory
				thePlayer.SetRewardMultiplier(currentRewardName, currentRewardMultiply);
				isBet = false;
			}
			else
			{
				currentReward = FloorF(value);
				
				if( isItemReward && rewrd.items.Size() > 0)
				{
					currentRewardMultiply = value / rewrd.items[0].amount;
				}
				else
				{
					currentRewardMultiply = value / rewrd.gold;
				}
				
				LogHaggle("Offering " + NoTrailZeros(value) + ", mult of " + NoTrailZeros(currentRewardMultiply));
				
				if( currentRewardMultiply > NPCsTooMuch )
				{
					m_LastNegotiationResult = TooMuch;
					a = RandRangeF(60,40);				
					LogHaggle("Too Much. Increasing anger from " + NoTrailZeros(anger) + " to " + NoTrailZeros(anger+a));
					anger += a;
				}		
				else if( currentRewardMultiply > NPCsPrettyClose )
				{
					m_LastNegotiationResult = PrettyClose;
					a = RandRangeF(20,10);
					LogHaggle("Pretty Close. Increasing anger from " + NoTrailZeros(anger) + " to " + NoTrailZeros(anger+a));
					anger += a;
				}
				else
				{
					m_LastNegotiationResult = WeHaveDeal;
					anger = 0;
					LogHaggle("Deal!");
					
					thePlayer.SetRewardMultiplier(currentRewardName, currentRewardMultiply, isItemReward);
				}
				LogHaggle("");
				
				//too angry, only get base value
				if( anger >= 100 )
				{
					m_LastNegotiationResult = GetLost;
					anger = 0;
					LogHaggle("NPC is furious - game over.");
					LogHaggle("");
					thePlayer.SetRewardMultiplier(currentRewardName, 1.f);
				}
				
				isBet = false;
			}
		}
		
		if( (m_LastNegotiationResult == WeHaveDeal || m_LastNegotiationResult == GetLost) && theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning())
		{
			theGame.GetTutorialSystem().uiHandler.OnClosingMenu('MonsterHuntNegotiationMenu');
		}
		
		m_fxSetBarValueSFF.InvokeSelfOneArg(FlashArgNumber(anger));
		isPopupOpened = false;
	}	

	function GetLastNegotiationResult() : ENegotiationResult
	{
		return m_LastNegotiationResult;
	}	

	function IsPopupOpened() : bool
	{
		return isPopupOpened;
	}
}

/*
	Quantity popup. Used inside Inventory menu
*/
class DialogueSliderData extends SliderPopupData
{
	public var dialogueRef:CR4HudModuleDialog;
	
	protected /* override */ function GetContentRef() : string 
	{
		return "QuantityPopupRef";
	}
	
	protected /* override */ function DefineDefaultButtons():void
	{
		AddButtonDef("panel_button_common_accept","enter-gamepad_A", IK_Enter );
	}
	
	public function /* override */ OnUserFeedback( KeyCode:string ) : void
	{
		if (KeyCode == "enter-gamepad_A")
		{
			dialogueRef.DialogueSliderDataPopupResult( currentValue );
			ClosePopup();
		}
	}
}

class BettingSliderData extends DialogueSliderData
{
	public /* override */ function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
	{
		var l_flashObject : CScriptedFlashObject;
		l_flashObject = super.GetGFxData(parentFlashValueStorage);
		l_flashObject.SetMemberFlashInt("playerMoney", thePlayer.GetMoney());	
		l_flashObject.SetMemberFlashBool("displayMoneyIcon", true);		
		return l_flashObject;
	}

	public function /* override */ OnUserFeedback( KeyCode:string ) : void
	{
		if (KeyCode == "enter-gamepad_A")
		{
			//player can't bet more than he has
			if ( currentValue > thePlayer.GetMoney() )
			{
				theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt("panel_shop_notification_not_enough_money") );
				return;
			}
			
			dialogueRef.DialogueSliderDataPopupResult( currentValue );
			ClosePopup();
		}
	}
}



class DialogueMonsterBarganingSliderData extends DialogueSliderData
{	
	public var baseValue:int;
	public var anger:float;
	public var alternativeRewardType:bool;

	protected /* override */ function GetContentRef() : string 
	{
		return "QuantityMonsterBarganingPopupRef";
	}
	
	protected /* override */ function DefineDefaultButtons():void
	{
		AddButtonDef("panel_button_common_accept","enter-gamepad_A", IK_Enter );
	}
	
	public function /* override */ OnUserFeedback( KeyCode:string ) : void
	{
		if (KeyCode == "enter-gamepad_A")
		{
			if( dialogueRef.IsPopupOpened() )
			{
				dialogueRef.DialogueSliderDataPopupResult( currentValue, alternativeRewardType );
				ClosePopup();
			}
		}
	}
	
	public /* override */ function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
	{
		var l_flashObject : CScriptedFlashObject;
		
		l_flashObject = super.GetGFxData(parentFlashValueStorage);
		l_flashObject.SetMemberFlashInt("baseValue", baseValue );
		l_flashObject.SetMemberFlashNumber("anger", anger );
		l_flashObject.SetMemberFlashBool("alternativeRewardType", alternativeRewardType );		
		return l_flashObject;
	}
}
