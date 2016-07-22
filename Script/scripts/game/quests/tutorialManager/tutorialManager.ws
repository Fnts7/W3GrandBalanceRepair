/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

// every property you declare here as "saved" will be stored in savegame and restored on game load before calling OnGameStart()

// REMEMBER TO CLEAR VARS BY HAND ON GAME START IF YOU ADD ANY MORE HERE!!!!
import class CR4TutorialSystem extends IGameSystem
{
	import  saved var needsTickEvent : bool;								//if set OnTick() is send, otherwise not
	private 	  var currentlyShownTutorialIndex : int;					//index from queue of tutorial being currently shown onscreen
	private saved var queuedTutorials : array<STutorialMessage>;			//queued tutorials to show
	private 	  var m_tutorialHintDataObj:W3TutorialPopupData;			//object of currently displayed Hint
	private 	  var delayedQueuedTutorialShowTime : float;				//duration till queued tutorial will be shown
	private 	  var hasDelayedTutorial : bool;							//set if some tutorial is delayed to be shown
	private		  var showNextHintInstantly : bool;							//if set next hint in queue will be shown instantly after previous is close - without delay
	private 	  var enableMenuRestrictions : bool;						//if set only menus from allowedMenusList will be enabled in the CommonMenu
	private 	  var allowedMenusList : array<name>;						//list of enabled menus if enableMenuRestrictions is true
	public saved  var uiHandler : W3TutorialManagerUIHandler;				//handles fullscreen UI tutorials since quest system is paused then and signal is frozen
	private saved var seenTutorials : array<name>;							//list of tutorials stored as seen to avoid duplicate views where not possible to block otherwise
	private 	  var attackProcessed : bool;								//used for dodge tutorial, informs if current attack was processed
	private 	  var testData : W3TutorialPopupData;						//for debug only
	private saved var hudMessage : name;									//tutorial script name to show on hud message
	
	private saved var invisibleTutorialHint : name;							//if messages are disabled this is currently 'shown' hint
	private saved var wereMessagesEnabled : bool;							//if messages were enabled in previous tick
	
	private const var COMBAT_HINT_POS_X, COMBAT_HINT_POS_Y : float;			//default position for hints in combat
	private const var DIALOG_HINT_POS_X, DIALOG_HINT_POS_Y : float;			//default position for hints in dialogs
	private const var UI_HINT_POS_X, UI_HINT_POS_Y : float;					//default position for hints in UI panels	
	private const var HINT_SHOW_DELAY : float;								//delay in seconds between displaying hints (new waits this time before being displayed after previous hides unless _showNextHintInstantly_ is set)
	private const var HINT_DURATION_LONG, HINT_DURATION_SHORT : float;		//default hint durations
	
		default COMBAT_HINT_POS_X = 0;
		default COMBAT_HINT_POS_Y = 0;
		default DIALOG_HINT_POS_X = 0.f;
		default DIALOG_HINT_POS_Y = 0.55f;
		default UI_HINT_POS_X = 0.6;
		default UI_HINT_POS_Y = 0.7;
		default currentlyShownTutorialIndex = -1;		
		default HINT_SHOW_DELAY = 1;
		default needsTickEvent = true;
		default HINT_DURATION_SHORT = 7;
		default HINT_DURATION_LONG = 10;
		
/* use if needed
		
	// this gets called when the user is quits the game session
	event OnGameEnd() {}
	
	// this gets called when a player enters game world
	event OnWorldStart() {}
	
	// this gets called when a player leaves game world
	event OnWorldEnd() {}
*/
	
	//checks if tutorial messages (of any kind) are enabled
	public function AreMessagesEnabled() : bool
	{
		return theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'HudTutorialEnabled') == "true";
	}
	
	//is tutorial manager currently enabled
	//due to memory corruption bugs this is the only way to reliably store bool in save
	public function IsRunning() : bool
	{
		return FactsQuerySum("tutorial_system_is_running");
	}
	
	public function IsOnTickOptimalizationEnabled() : bool
	{
		return !needsTickEvent;
	}
		
	public function IncreaseDodges()					{FactsAdd("tutorial_dodges_cnt");}
	public function IncreaseRolls()						{FactsAdd("tutorial_rolls_cnt");}
	public function IncreaseCounters()					{FactsAdd("tutorial_counters_cnt");}	
	public function IncreaseParries()					{FactsAdd("tutorial_parries_cnt");}
		
	event OnGameStart( restored : bool ) 
	{
		ClearNonSavedVars();
		
		//bug from engine - tutorial keeping saved vars from previous playthrough if new game was started again
		if(!IsRunning())
			ClearSavedVars();
		
		if(restored)
		{
			//don't work if disabled or NG+
			if(!IsRunning() || FactsQuerySum("NewGamePlus") > 0)
				needsTickEvent = false;
				
			uiHandler.OnLoad();
		}
		
		attackProcessed = false;
		
		//patch 1.1+: new entries for pad will not be active since "in journal from beginning" won't work in those cases
		//as the game has already been started before applying patch. We need to activate those entries by hand
		ActivateJournalEntry('TutorialJournalSignCast');
		ActivateJournalEntry('TutorialJournalHeavyAttacks');
		ActivateJournalEntry('TutorialHorseSummon');
		ActivateJournalEntry('TutorialJournalLightAttacks');
		ActivateJournalEntry('TutorialJournalSpecialAttacks');		
		ActivateJournalEntry('TutorialAdrenaline');
	}
	
	public final function ClearSavedVars()
	{
		needsTickEvent = true;
		queuedTutorials.Clear();
		uiHandler = NULL;
		seenTutorials.Clear();
		invisibleTutorialHint = '';
		wereMessagesEnabled = false;
		hudMessage = '';
	}
	
	public final function ClearNonSavedVars()
	{
		currentlyShownTutorialIndex = -1;
		delayedQueuedTutorialShowTime = 0;
		hasDelayedTutorial = false;
		showNextHintInstantly = false;
		enableMenuRestrictions = false;
		allowedMenusList.Clear();
		attackProcessed = false;
		m_tutorialHintDataObj = NULL;
		testData = NULL;
	}
	
	//called when we reinitialize tutorial in EP2
	public function TutorialRestart()	
	{
		if(IsRunning())
			return;
			
		ClearSavedVars();
				
		wereMessagesEnabled = AreMessagesEnabled();
		uiHandler = new W3TutorialManagerUIHandler in this;
		
		//some tutorials were disconnected - mark as seen so that they won't get processed
		MarkMessageAsSeen('TutorialDialog');
		MarkMessageAsSeen('TutorialContainers');
		MarkMessageAsSeen('TutorialLootWindow');
		MarkMessageAsSeen('TutorialHorseStop');
		MarkMessageAsSeen('TutorialQuestBoard');
		MarkMessageAsSeen('TutorialCiriTaunt');
		MarkMessageAsSeen('TutorialWrongSwordSteel');
		MarkMessageAsSeen('TutorialWrongSwordSilver');
		MarkMessageAsSeen('TutorialCampfire');
		MarkMessageAsSeen('TutorialPotionAmmo');
		MarkMessageAsSeen('TutorialOilAmmo');
		
		FactsSet("tutorial_system_is_running", 1);	
	}
	
	//called when we initialize tutorial
	public function TutorialStart(removeTestingSkillsAndItems : bool)
	{
		var dm : CDefinitionsManagerAccessor;
		var i : int;
		var skill : SSimpleSkill;
		var abs : array<name>;
		var witcher : W3PlayerWitcher;
		
		if(IsRunning())
			return;
			
		ClearSavedVars();
				
		wereMessagesEnabled = AreMessagesEnabled();
		uiHandler = new W3TutorialManagerUIHandler in this;
		
		thePlayer.CreateTutorialInput();		
		FactsAdd('tutorial_starting_level', GetWitcherPlayer().GetLevel());
		
		if(removeTestingSkillsAndItems)
		{
			//remove debug skills
			dm = theGame.GetDefinitionsManager();
			dm.GetContainedAbilities('GeraltSkills_Testing', abs);
			
			//remove and unequip skills
			witcher = GetWitcherPlayer();
			skill.level = 0;
			for(i=0; i<abs.Size(); i+=1)
			{
				skill.skillType = SkillNameToEnum(abs[i]);
				if(skill.skillType != S_SUndefined)
				{
					witcher.RemoveTemporarySkill(skill);
				}
			}						
			
			//remove debug inventory
			thePlayer.AddTimer('Debug_RemoveTestingItems', 0.0001, true);
		}
		
		//some tutorials were disconnected - mark as seen so that they won't get processed
		MarkMessageAsSeen('TutorialDialog');
		MarkMessageAsSeen('TutorialContainers');
		MarkMessageAsSeen('TutorialLootWindow');
		MarkMessageAsSeen('TutorialHorseStop');
		MarkMessageAsSeen('TutorialQuestBoard');
		MarkMessageAsSeen('TutorialCiriTaunt');
		MarkMessageAsSeen('TutorialWrongSwordSteel');
		MarkMessageAsSeen('TutorialWrongSwordSilver');
		MarkMessageAsSeen('TutorialCampfire');
		MarkMessageAsSeen('TutorialPotionAmmo');
		MarkMessageAsSeen('TutorialOilAmmo');
		
		FactsSet("tutorial_system_is_running", 1);		
	}
	
	public function TutorialFinish()
	{
		thePlayer.CreateInput();
		FactsSet("tutorial_system_is_running", 0);
	}

	//returns true if given tutorial was already seen and is assumed read by player
	public function HasSeenTutorial(tutorialScriptTag : name) : bool
	{
		return seenTutorials.Contains(tutorialScriptTag);		
	}
	
	//Adds given tutorial to display queue. Tutorial will be shown as soon as possible
	public function DisplayTutorial(tut : STutorialMessage)
	{
		var i : int;
		
		if(!IsRunning())
			return;
		
		//ignore if already queued
		for(i=0; i<queuedTutorials.Size(); i+=1)
		{
			if(queuedTutorials[i].tutorialScriptTag == tut.tutorialScriptTag)
			{
				return;
			}
		}
		
		//if messages disabled and it's a "UI input confirmation hint" - skip it
		if(!AreMessagesEnabled() && tut.type == ETMT_Message)
		{
			//mark as seen if requested
			if(tut.markAsSeenOnShow)
				MarkMessageAsSeen(tut.tutorialScriptTag);
				
			return;
		}
		
		//add to queue
		if(tut.forceToQueueFront && queuedTutorials.Size() > 0)
		{
			//push to front
			HideTutorialHint('', true, true);
			queuedTutorials.Insert(0, tut);
			
			if(CanShowTutorial(tut.canBeShownInDialogs, tut.canBeShownInMenus))
				SelectAndDisplayTutorial(tut);
		}
		else
		{
			//add at the back of queue
			queuedTutorials.PushBack(tut);
			
			//show if only one in queue
			if(queuedTutorials.Size() == 1 && CanShowTutorial(tut.canBeShownInDialogs, tut.canBeShownInMenus))
				SelectAndDisplayTutorial(tut);
		}
	}
	
	//checks if we can currently show tutorial message on screen
	private function CanShowTutorial(canBeShownInDialogs : bool, canBeShownInMenus : bool) : bool
	{		
		if(!canBeShownInDialogs && theGame.IsDialogOrCutscenePlaying())
			return false;
			
		if(!canBeShownInMenus && theGame.GetGuiManager().IsAnyMenu())
			return false;
			
		if(!thePlayer.IsAlive())
			return false;
			
		if ( theGame.IsBlackscreen() || theGame.IsFading() )
		{
			return false;
		}
		
		if(FactsQuerySum("NewGamePlus") > 0 && FactsQuerySum("NewGamePlusForceTutorialsOn") <= 0)
			return false;
			
		return currentlyShownTutorialIndex < 0;
	}
	
	// this gets called every frame, but only if ( needsTickEvent == true )
	//processes tutorial queue. Checks if tutorial can be shown and if so calls it after 1 sec delay
	event OnTick( dt : float )
	{
		var dbg_launchedTutorial : bool;
		var i : int;
		var temp : STutorialMessage;
		
		//permanent HUD message
		ProcessHUDMessage();
		
		//if have a non-menu tutorial in queue and some menu opens
		if(theGame.GetGuiManager().IsAnyMenu() && queuedTutorials.Size() > 0 && m_tutorialHintDataObj)
		{
			//if current hint cannot be shown in menus then close it and restore after
			if(!queuedTutorials[0].canBeShownInMenus)
			{
				//Hide deletes current hint so we need to duplicate it before hiding
				HideTutorialHint('', true, true);
			}
		}
		
		//detecting message enable/disable fact change
		if(wereMessagesEnabled && !AreMessagesEnabled())
		{
			//disabled messages
			if(queuedTutorials[0].hintDurationType == ETHDT_Infinite)
				HideTutorialHint('', true, true);
			else
				HideTutorialHint('', true);
		}
		if(wereMessagesEnabled != AreMessagesEnabled())
		{
			wereMessagesEnabled = !wereMessagesEnabled;
		}
		
		if(hasDelayedTutorial)
		{
			if(delayedQueuedTutorialShowTime <= 0)
			{
				if(queuedTutorials.Size() > 0)	//tutorial might have been closed in the meantime without showing
				{
					if(CanShowTutorial(queuedTutorials[0].canBeShownInDialogs, queuedTutorials[0].canBeShownInMenus))
					{
						DelayedQueuedTutorialShow();
						dbg_launchedTutorial = true;
					}
				}
				hasDelayedTutorial = false;
			}
			else
			{
				delayedQueuedTutorialShowTime -= dt;
			}
		}
		else
		{
			//look for first message in queue that can be shown now
			for(i=0; i<queuedTutorials.Size(); i+=1)
			{
				if(CanShowTutorial(queuedTutorials[i].canBeShownInDialogs, queuedTutorials[i].canBeShownInMenus))
				{
					//set delay for showing hint
					if(showNextHintInstantly)
						delayedQueuedTutorialShowTime = 0;
					else
						delayedQueuedTutorialShowTime = HINT_SHOW_DELAY;
						
					hasDelayedTutorial = true;
					
					//move to front
					if(i != 0)
					{
						temp = queuedTutorials[i];
						queuedTutorials.Insert(0, temp);
						queuedTutorials.Erase(i+1);
					}
					
					break;
				}
			}
		}		
		
		//vesemir dodge
		if(thePlayer.IsThreatened() && ShouldProcessTutorial('TutorialDodge'))
		{
			ProcessDodges();			
		}
		//vesemir roll
		if(thePlayer.IsThreatened() && ShouldProcessTutorial('TutorialRoll'))
		{
			ProcessRolls();			
		}
	}
	
	public final function OnInputDeviceChanged()
	{
		if(queuedTutorials.Size() > 0 && currentlyShownTutorialIndex >= 0)
		{
			ReloadMessageOnInputChange( theInput.LastUsedGamepad(), true );			
		}
	}
		
	private final function ProcessDodges()
	{
		var ves : CNewNPC;
		
		ves = theGame.GetNPCByTag('vesemir');
		if(!ves)
			return;
			
		if(ves.IsAttacking())
		{
			if(FactsQuerySum('tut_in_dodge'))
				attackProcessed = true;
		}
		else
		{
			if(attackProcessed && GameplayFactsQuerySum("tut_failed_dodge") < 1)
			{
				IncreaseDodges();
			}
			
			attackProcessed = false;
		}		
	}
	
	private final function ProcessRolls()
	{
		var ves : CNewNPC;
		
		ves = theGame.GetNPCByTag('vesemir');
		if(!ves)
			return;
			
		if(ves.IsAttacking())
		{
			if(FactsQuerySum('tut_in_roll'))
				attackProcessed = true;
		}
		else
		{
			if(attackProcessed && GameplayFactsQuerySum("tut_failed_roll") < 1)
			{
				IncreaseRolls();
			}
			
			attackProcessed = false;
		}		
	}
	
	//shows first tutorial in queue
	private function DelayedQueuedTutorialShow()
	{		
		SelectAndDisplayTutorial(queuedTutorials[0]);
		delayedQueuedTutorialShowTime = 0;
		
		//LogTutorial("Show index is now: 0");
	}
	
	//called when some tutorial message (of any kind) is closing
	event OnTutorialClosing(scriptName : name, closedByUIPanel : bool, optional willBeCloned : bool)
	{
		var i,j : int;
		var inQueue : bool;
		var factOnSeen : string;
	
		for(i=0; i<queuedTutorials.Size(); i+=1)
		{
			if(queuedTutorials[i].tutorialScriptTag == scriptName)
			{
				//cache fact to add if message was finally disaplayed with full duration
				factOnSeen = queuedTutorials[i].factOnFinishedDisplay;
				
				//don't remove message if it was not closed manually (case where opening UI panel closes hint - we need to restore it one menu is closed)
				if( !closedByUIPanel || willBeCloned )
				{					
					//mark seen - we need to do this here as the message might show and then be closed due to various reasons only to reappear 
					//later - in such case it should not be marked after it disappears before forced close
					//However, we don't mark it as seen if the message will be cloned and reshown immediately (e.g. input device changed)
					if(queuedTutorials[i].markAsSeenOnShow  && !willBeCloned)
						MarkMessageAsSeen(queuedTutorials[i].tutorialScriptTag);
						
					queuedTutorials.Erase(i);
				}
				
				if(i == 0)
				{
					currentlyShownTutorialIndex = -1;
					//LogTutorial("Show index is now: -1");
				}
				
				LogTutorial("Closed tutorial <<" + scriptName + ">>, fromUI = " + closedByUIPanel );
				RemoveMenuRestrictions();
				
				//if message is no longer in queue and was closed - then it was 'finally' displayed, add fact
				if(factOnSeen != "" && !willBeCloned)
				{
					inQueue = false;
					for(j=0; j<queuedTutorials.Size(); j+=1)
					{
						if(queuedTutorials[j].tutorialScriptTag == scriptName)
						{
							inQueue = true;
							break;
						}
					}
				
					if(!inQueue)
						FactsAdd(factOnSeen);
				}
	
				break;
			}
		}
	}
	
	//called when some tutorial message (of any kind) was closed
	event OnTutorialClosed(scriptName : name, closedByUIPanel : bool, informUIHandler : bool)
	{
		if( informUIHandler )
		{
			uiHandler.OnTutorialClosed(scriptName, closedByUIPanel);
		}
	}
	
	//displays tutorial based on its type (message or hint)
	private function SelectAndDisplayTutorial(tut : STutorialMessage)
	{
		if(tut.type == ETMT_Undefined)
		{
			LogTutorial("SelectAndDisplayTutorial: tutorial <<" + tut.tutorialScriptTag + ">> has no type set - not showing!");
			LogAssert(false, "SelectAndDisplayTutorial: tutorial <<" + tut.tutorialScriptTag + ">> has no type set - not showing!");
		}
		
		DisplayTutorialHint(tut);		
	}
	
	//displays tutorial hint, does not pause the game
	private function DisplayTutorialHint(tut : STutorialMessage)
	{
		var tutorialEntry : CJournalTutorial;
		var i : int;
		
		//don't show if marked seen or disabled
		if( (!tut.force && HasSeenTutorial(tut.tutorialScriptTag)) || !AreMessagesEnabled())
		{
			if(!AreMessagesEnabled())
				FactsAdd(queuedTutorials[0].factOnFinishedDisplay);
				
			queuedTutorials.EraseFast(0);
			return;
		}
	
		//if tutorial meassages disabled
		/*
		if(!AreMessagesEnabled())
		{
			if(tut.hintDurationType != ETHDT_Infinite)
			{
				invisibleTutorialHint = tut.tutorialScriptTag;
				AddTimer('TutorialInvisibleHint', tut.hintDuration, , , , true);
			}
			
			return;
		}
		*/
		
		tutorialEntry = GetMessageText(tut.tutorialScriptTag, JS_Inactive);	//mark tutorial displayed (JS_Active) but not yet read (JS_Success)
		
		//if cannot load tutorial entry then skip this tutorial
		if(!tutorialEntry)
		{
			queuedTutorials.Erase(0);
			return;
		}
				
		if (m_tutorialHintDataObj)
		{
			// skip or force close
		}
		//request window
		m_tutorialHintDataObj = new W3TutorialPopupData in this;
		m_tutorialHintDataObj.managerRef = this;
		m_tutorialHintDataObj.scriptTag = tut.tutorialScriptTag;
		m_tutorialHintDataObj.messageTitle = GetLocStringById(tutorialEntry.GetNameStringId());
		m_tutorialHintDataObj.messageText = GetTutorialLocalizedText(tutorialEntry.GetDescriptionStringId());
		m_tutorialHintDataObj.imagePath = tutorialEntry.GetImagePath();
		m_tutorialHintDataObj.enableGlossoryLink = false;		//disabled, we don't want it. Otherwise use =tut.glossaryLink;		
		m_tutorialHintDataObj.autosize = !tut.disableHorizontalResize;
		m_tutorialHintDataObj.blockInput = tut.blockInput;
		m_tutorialHintDataObj.pauseGame = tut.pauseGame;
		m_tutorialHintDataObj.fullscreen = tut.fullscreen;
		m_tutorialHintDataObj.canBeShownInMenus = tut.canBeShownInMenus;
		
		//non-fullscreen blocker
		if(tut.hintDurationType == ETHDT_Input && tut.type != ETMT_Message)
		{
			m_tutorialHintDataObj.enableAcceptButton = true;
			m_tutorialHintDataObj.blockInput = true;
		}
				
		if(tut.type == ETMT_Message)
			m_tutorialHintDataObj.fullscreen = true;
		
		if(tut.isHUDTutorial)
		{
			DisplayHUDTutorialHighlight(tut.tutorialScriptTag,true);
		}
		else
		{
			for(i=0; i<tut.highlightAreas.Size(); i+=1) // here
			{
				m_tutorialHintDataObj.AddHighlightedArea( tut.highlightAreas[i].x, tut.highlightAreas[i].y, tut.highlightAreas[i].width, tut.highlightAreas[i].height);
			}
		}
		//position
		switch(tut.hintPositionType)
		{
			case ETHPT_DefaultGlobal :
				m_tutorialHintDataObj.posX = 0;
				m_tutorialHintDataObj.posY = 0;
				break;
			case ETHPT_DefaultDialog :
				m_tutorialHintDataObj.posX = DIALOG_HINT_POS_X;
				m_tutorialHintDataObj.posY = DIALOG_HINT_POS_Y;
				break;			
			case ETHPT_DefaultCombat :
				m_tutorialHintDataObj.posX = COMBAT_HINT_POS_X;
				m_tutorialHintDataObj.posY = COMBAT_HINT_POS_Y;
				break;
			case ETHPT_DefaultUI :
				m_tutorialHintDataObj.posX = UI_HINT_POS_X;
				m_tutorialHintDataObj.posY = UI_HINT_POS_Y;
				break;
			case ETHPT_Custom :
				m_tutorialHintDataObj.posX = tut.hintPosX;
				m_tutorialHintDataObj.posY = tut.hintPosY;
				break;
			case ETHPT_DefaultRadialMenu :
				m_tutorialHintDataObj.posX = 0;
				m_tutorialHintDataObj.posY = 0.43;
				
		}
			
		if(tut.hintDurationType == ETHDT_Short)
		{
			m_tutorialHintDataObj.duration = HINT_DURATION_SHORT * 1000;
		}
		else if(tut.hintDurationType == ETHDT_Long)
		{
			m_tutorialHintDataObj.duration = HINT_DURATION_LONG * 1000;
		}
		else if(tut.hintDurationType == ETHDT_Infinite || tut.hintDurationType == ETHDT_Input)
		{
			m_tutorialHintDataObj.duration = -1;
		}
		else if(tut.hintDurationType == ETHDT_Custom && tut.hintDuration > 0)
		{
			m_tutorialHintDataObj.duration = tut.hintDuration * 1000;
		}
		else
		{
			m_tutorialHintDataObj.duration = tut.hintDuration;
		}
		
		ShowTutorialHint(m_tutorialHintDataObj);
		
		//activate journal entry if any
		ActivateJournalEntry(tut.journalEntryName);
		
		//block panels if any
		if(tut.disabledPanelsExceptions.Size() > 0)
		{
			SetMenuRestrictions(tut.disabledPanelsExceptions);
		}
				
		//cleanup
		showNextHintInstantly = false;
		currentlyShownTutorialIndex = 0;
		
		LogTutorial( "Now showing tutorial <<" + tut.tutorialScriptTag + ">>" );
	}
	
	private function DisplayHUDTutorialHighlight(tutorialName : name ,bShow : bool )
	{
		var hud : CR4ScriptedHud;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if(hud)
			hud.DisplayTutorialHighlight(tutorialName,bShow);
	}
	
	public function HintFeedback(tutorialScriptTag : name, optional negative : bool)
	{
		if(m_tutorialHintDataObj && m_tutorialHintDataObj.scriptTag == tutorialScriptTag)
			m_tutorialHintDataObj.PlayFeedbackAnim(!negative);
	}
	
	// Temp function for testing	
	public function DEBUG_TestTutorialHint(optional x,y,w,h,d : float)
	{
		var testMenusList : array<name>;
		
		testData = new W3TutorialPopupData in this; 
		testData.managerRef = this;
		testData.enableGlossoryLink = true;
		testData.autosize = false;
		testData.posX = 0.99f;
		testData.posY = 0.99f;
		testData.canBeShownInMenus = true;
		//testData.imagePath = "icons\Skills\Signs\magic_s9.png";
		testData.messageTitle = "Destruir Toda!";
		testData.messageText = "Test internetowa usługa tłumaczeń Google błyskawicznie tłumaczy tekst i strony internetowe.";
		
		if(x > 0 && y > 0 && w > 0 && h > 0)
			testData.AddHighlightedArea(x, y, w, h);
		else
			testData.AddHighlightedArea(.5, .8, .1, .2);
			
		testData.duration = d;
		ShowTutorialHint(testData);
		
		/*		
		testMenusList.PushBack('GlossaryParent');
		testMenusList.PushBack('GlossaryCharactersMenu');
		testMenusList.PushBack('InventoryMenu');
		SetMenuRestrictions(testMenusList);		
		*/
		
		m_tutorialHintDataObj = testData;
	}
	
	public function DEBUG_TestTutFeedback(optional isCorrect:bool):void
	{
		if (testData)
		{
			testData.PlayFeedbackAnim(isCorrect);
		}
	}
	
	//activate and get proper journal entry for tutorial message
	private function GetMessageText(scriptTag : string, status : EJournalStatus) : CJournalTutorial
	{
		var entryBase : CJournalBase;
		var resource : CJournalResource;
		var manager : CWitcherJournalManager;
		var tutorialEntry : CJournalTutorial;
		
		manager = theGame.GetJournalManager();
		
		//entry - base version
		entryBase = ((CJournalResource)LoadResource(scriptTag)).GetEntry();
		
		if(!entryBase)
		{
			LogTutorial( "Cannot load journal entry file for <<" + scriptTag + ">>" );		
			LogAssert(false, "W3TutorialManager.GetMessageText: cannot load resource <<" + scriptTag + ">>!");
			return NULL;
		}
		
		manager.ActivateEntry( entryBase, status);
		
		//entry - pad version
		if(theInput.UsesPlaystationPadScript())
		{
			resource = (CJournalResource)LoadResource(scriptTag + "_ps4");
		}		
		if(!resource)
		{
			resource = (CJournalResource)LoadResource(scriptTag + "_pad");
		}
		
		if(resource)
		{
			entryBase = resource.GetEntry();
			if(entryBase)
				manager.ActivateEntry( entryBase, status);
		}
			
		//get data from journal - if using pad try getting pad		
		if(theInput.LastUsedGamepad())
		{
			if(theInput.UsesPlaystationPadScript())
				tutorialEntry = (CJournalTutorial)manager.GetEntryByString(scriptTag + "_ps4");
				
			if(!tutorialEntry)
				tutorialEntry = (CJournalTutorial)manager.GetEntryByString(scriptTag + "_pad");
		}
		
		//else (or if failed) - get normal entry
		if(!tutorialEntry)
			tutorialEntry = (CJournalTutorial)manager.GetEntryByString(scriptTag);
			
		return tutorialEntry;
	}
	
	//Forces currently shown hint to hide
	public function HideTutorialHint(scriptTag : name, optional forceCloseAny : bool, optional dontRemoveFromQueue : bool)
	{
		var i : int;
		var clone : STutorialMessage;
		
		//close if currently shown
		if (m_tutorialHintDataObj && (forceCloseAny || m_tutorialHintDataObj.scriptTag == scriptTag))
		{
			if(forceCloseAny)
				scriptTag = queuedTutorials[i].tutorialScriptTag;
				
			//prepare clone
			if(dontRemoveFromQueue)
			{
				clone = queuedTutorials[0];						
			}						
			
			//remove old message
			m_tutorialHintDataObj.CloseTutorialPopup(dontRemoveFromQueue);
			
			//hint might not close if you mash buttons so call it mechanically to make sure. UI should close if can so both calls are needed
			OnTutorialClosing(scriptTag, dontRemoveFromQueue, true);
			
			currentlyShownTutorialIndex = -1;	//normally this is handled when hint closes but if the game is paused there is no OnTick() so this doesn't update
				
			//add clone
			if(dontRemoveFromQueue)
			{
				queuedTutorials.Insert(0, clone);
			}
		}
		else
		{
			//otherwise remove from queue
			if(!dontRemoveFromQueue)
			{
				for(i=0; i<queuedTutorials.Size(); i+=1)
				{
					if(queuedTutorials[i].tutorialScriptTag == scriptTag)
					{						
						//not using EraseFast as the order must not change
						queuedTutorials.Erase(i);
						i -= 1;
					}
				}
			}
		}
	}
		
	public function HandleTutorialMessageHidden(scriptTag : name, forcedClose:bool)
	{
		OnTutorialClosing(scriptTag, forcedClose);
	}
	
	public function OnTutorialHintClosing(scriptTag : name, forcedClose:bool, optional closedByUser:bool, optional willBeCloned : bool)
	{
		OnTutorialClosing(scriptTag, forcedClose/*HACKFIX || !closedByUser*/, willBeCloned);
	}
	
	public function OnTutorialHintClosed(scriptTag : name, forcedClose:bool, informUIHandler : bool )
	{
		OnTutorialClosed(scriptTag, forcedClose, informUIHandler);
		//if(queuedTutorials[currentlyShownTutorialIndex].isHUDTutorial)
		//{
			DisplayHUDTutorialHighlight(scriptTag,false);
		//}
	}
		
	//hack used for tutorial quest debuging
	public function HAX_DEBUG_ForceTutorialMessageAsSeen(tutorialScriptTag : name, showInJournal : bool)
	{
	}
		
	public function MarkMessageAsSeen(tutorialScriptTag : name)
	{
		if(!seenTutorials.Contains(tutorialScriptTag))
			seenTutorials.PushBack(tutorialScriptTag);
	}
	
	public function UnmarkMessageAsSeen(tutorialScriptTag : name)
	{
		if (seenTutorials.Contains(tutorialScriptTag))
			seenTutorials.Remove(tutorialScriptTag);
	}
	
	//called when we have some interaction on screen
	//
	// WHEN UPDATING ALSO UPDATE ShouldProcessInteractionTutorials()
	//	
	public function SetInteraction(component : CInteractionComponent)
	{
		var actionName : name;
		var container, talk, door, examine, repairSword, repairArmor, mountBoat, fastTravel, campfire, monsterNest, craftsman, stash : bool;
		var ent : CEntity;
		var repairObj : W3ItemRepairObject;
		
		//set action
		if(component)
		{
			actionName = component.GetInputActionName();			
			ent = component.GetEntity();
			repairObj = (W3ItemRepairObject)ent;
			if(repairObj)
			{
				if(repairObj.RepairsSword())
					repairSword = true;
				if(repairObj.RepairsArmor())
					repairArmor = true;
			}
			else if( (W3FastTravelEntity)ent )
			{
				fastTravel = true;
			}
			else if( (CMonsterNestEntity)ent )
			{
				monsterNest = true;
			}
			else if(ent.GetComponentByClassName('W3MeditationComponent'))
			{
				campfire = true;
			}
			else if(ent.GetComponentByClassName('CBoatComponent') || (W3Boat)ent || ent.GetComponentByClassName('CBoatDestructionComponent'))	//noone seems to know for sure what is actually used
			{
				mountBoat = true;
			}
			else if( (W3Stash)ent )
			{
				stash = true;
			}
			else if(actionName == 'Container')
			{
				container = true;
			}
			else if(actionName == 'Talk')
			{
				talk = true;
				
				if( ent.GetComponentByClassName('W3CraftsmanComponent') )
					craftsman = true;
			}		
			else if(actionName == 'Examine')
			{
				examine = true;
			}			
		}
			
		//set facts
		if(container)
			FactsAdd("tutorial_interaction_container");
		else
			FactsRemove("tutorial_interaction_container");
		
		if(talk)
			FactsAdd("tutorial_interaction_talk");
		else
			FactsRemove("tutorial_interaction_talk");
						
		if(examine)
			FactsAdd("tutorial_interaction_examine");
		else
			FactsRemove("tutorial_interaction_examine");
			
		if(repairArmor)
			FactsAdd("tutorial_interaction_repair_armor");
		else
			FactsRemove("tutorial_interaction_repair_armor");
			
		if(repairSword)
			FactsAdd("tutorial_interaction_repair_sword");
		else
			FactsRemove("tutorial_interaction_repair_sword");
			
		if(mountBoat)
			FactsAdd("tutorial_interaction_boat");
		else
			FactsRemove("tutorial_interaction_boat");
			
		if(fastTravel)
			FactsAdd("tutorial_interaction_fast_travel");
		else
			FactsRemove("tutorial_interaction_fast_travel");
			
		if(campfire)
			FactsAdd("tutorial_interaction_campfire");
		else
			FactsRemove("tutorial_interaction_campfire");
			
		if(monsterNest)
			FactsAdd("tutorial_interaction_mon_nest");
		else
			FactsRemove("tutorial_interaction_mon_nest");
		
		if(craftsman)
			FactsAdd("tutorial_interaction_craftsman");
		else
			FactsRemove("tutorial_interaction_craftsman");

		if(stash)
			FactsAdd("tutorial_interaction_stash");
		else
			FactsRemove("tutorial_interaction_stash");
	}
	
	// Create TutorialPopupMenu and display tutorial hint
	public function ShowTutorialHint(hintData : W3TutorialPopupData):void
	{
		theGame.RequestPopup( 'TutorialPopup',  hintData );	
	}
	
	//Activates journal entry by given name (unless name is empty) - both PC and pad.
	public function ActivateJournalEntry(entryName : name)
	{
		var entryBase : CJournalBase;
		var resource : CJournalResource;
		var manager : CWitcherJournalManager;
		
		if(!IsNameValid(entryName))
			return;
		
		manager = theGame.GetJournalManager();
		
		//entry - base version
		resource = (CJournalResource)LoadResource(entryName);
		if(resource)
		{
			entryBase = resource.GetEntry();
			if(entryBase)
				manager.ActivateEntry( entryBase, JS_Active);
		}
		
		//entry - pad version
		resource = (CJournalResource)LoadResource(entryName + "_pad");
		if(resource)
		{
			entryBase = resource.GetEntry();
			if(entryBase)
				manager.ActivateEntry( entryBase, JS_Active);
		}
		
		//entry - ps4 version
		resource = (CJournalResource)LoadResource(entryName + "_ps4");
		if(resource)
		{
			entryBase = resource.GetEntry();
			if(entryBase)
				manager.ActivateEntry( entryBase, JS_Active);
		}
	}
	
	//returns scriptName of currently shown tutorial
	public function GetCurrentlyShownTutorialScriptName() : name
	{
		if(queuedTutorials.Size() > 0 && m_tutorialHintDataObj && currentlyShownTutorialIndex >= 0)
		{
			return queuedTutorials[currentlyShownTutorialIndex].tutorialScriptTag;
		}
		
		return '';
	}
	
	public function IncreaseGeraltsLightAttacksCount(victimTags : array<name>)
	{
		var i : int;
		
		for(i=0; i<victimTags.Size(); i+=1)
		{
			FactsAdd("tut_light_attack_" + victimTags[i]);
		}
	}
	
	public function IncreaseGeraltsHeavyAttacksCount(victimTags : array<name>)
	{
		var i : int;
		
		for(i=0; i<victimTags.Size(); i+=1)
		{
			FactsAdd("tut_heavy_attack_" + victimTags[i]);
		}
	}
	
	//called when a dialog or cutscene starts/ends
	public function OnCutsceneOrDialogChange(isNowOn : bool)
	{
		if(!isNowOn)
			return;
			
		//if have anything in queue and something is being displayed currently
		if(queuedTutorials.Size() > 0 && m_tutorialHintDataObj)
		{
			//if current hint cannot be shown in dialogs then close it and restore after dialog
			if(!queuedTutorials[0].canBeShownInDialogs)
			{
				//Hide deletes current hint so we need to duplicate it before hiding
				HideTutorialHint('', true, true);
			}
		}
	}
	
	// called when guard tells player to put away his sword
	public function OnGuardSwordWarning()
	{
		FactsAdd("tut_guard_warning", 1, 1);
		thePlayer.DisplayHudMessage( GetLocStringByKeyExt("guards_taunting_message") );
	}
	
	// called when guard warns player
	public function OnGuardGeneralWarning()
	{
		thePlayer.DisplayHudMessage( GetLocStringByKeyExt("guards_taunting_message") );
	}
	
	// called when guard warns player about stealing
	public function OnGuardLootingWarning()
	{
		thePlayer.DisplayHudMessage( GetLocStringByKeyExt("guards_stealing_message") );
		if(!HasSeenTutorial('TutorialStealing'))
			FactsAdd("tut_stealing");
	}
	
	//checks if message should be reloaded due to input device change or not and if so reload
	public final function ReloadMessageOnInputChange(startedUsingPad : bool, optional forceShowImmediately : bool)
	{
		var resPad, resCommon : CJournalResource;
		var tutorialEntry : CJournalTutorial;
		var performReload : bool;
		var manager : CWitcherJournalManager;
		
		//if nothing is currently shown then abort
		if(queuedTutorials.Size() == 0)
			return;
		
		performReload = false;
		
		//try to load resources
		if(theInput.UsesPlaystationPadScript())
		{
			resPad = (CJournalResource)LoadResource(queuedTutorials[0].tutorialScriptTag + "_ps4");
			if(!resPad)
				resPad = (CJournalResource)LoadResource(queuedTutorials[0].tutorialScriptTag + "_pad");
		}
		else
		{
			resPad = (CJournalResource)LoadResource(queuedTutorials[0].tutorialScriptTag + "_pad");
		}
		
		if(resPad)
		{
			//there is a different resource for both input types so it definitely changed
			performReload = true;
		}
		else
		{
			//if has the same entry for both cases, we still need to reload if there are any tags inside to update the icons
			resCommon = (CJournalResource)LoadResource(queuedTutorials[0].tutorialScriptTag);
				
			//get entry					
			manager = theGame.GetJournalManager();				
			tutorialEntry = (CJournalTutorial)manager.GetEntryByString(queuedTutorials[0].tutorialScriptTag);
			if(!tutorialEntry)
			{
				//actiavte entry if not activated yet
				manager.ActivateEntry( resCommon.GetEntry(), JS_Inactive);
				tutorialEntry = (CJournalTutorial)manager.GetEntryByString(queuedTutorials[0].tutorialScriptTag);
			}
			
			//if has tag or (failsafe) we cannot load entry
			if(!tutorialEntry || HasLolcalizationTags( GetLocStringById(tutorialEntry.GetDescriptionStringId()) ) )
				performReload = true;
		}
				
		if(performReload)
		{
			//duplicate current hint and hide it
			showNextHintInstantly = true;			
			HideTutorialHint('', true, true);
			
			//force reload from UI menus - game is paused then so OnTick() is not being called and we need it process reload
			if(forceShowImmediately)
			{
				DelayedQueuedTutorialShow();
			}
		}
	}

	//using loc key prepares text to show (icons)
	private function GetTutorialLocalizedText(locId : int) : string
	{
		return ReplaceTagsToIcons(GetLocStringById(locId));
	}
	
	// disable all common menu tabs exept enabledMenuList
	private function SetMenuRestrictions(enabledMenuList:array<name>):void
	{
		var commonMenuRef  : CR4CommonMenu;
		
		enableMenuRestrictions = true;
		allowedMenusList = enabledMenuList;
		
   		commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
   		if (commonMenuRef)
   		{
			commonMenuRef.UpdateTutorialRestruction();
   		}
	}
	
	// enable all common menu tabs
	private function RemoveMenuRestrictions():void
	{
		enableMenuRestrictions = false;
		allowedMenusList.Clear();
	}
	
	// for CommonMenu.ws
	public function IsMenuRestrictionsEnable() : bool
	{
		return enableMenuRestrictions;
	}
	
	// for CommonMenu.ws
	public function GetAllowedMenuList() : array <name>
	{
		return allowedMenusList;
	}
	
	public final function Failsafe()
	{
		queuedTutorials.Clear();
		HideTutorialHint('', true);
		currentlyShownTutorialIndex = -1;
		delayedQueuedTutorialShowTime = 0;
		hasDelayedTutorial = false;
		showNextHintInstantly = false;
		enableMenuRestrictions = false;
		invisibleTutorialHint = '';
		allowedMenusList.Clear();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////  @HUD MESSAGES  ///////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public final function SetHudMessage(tutorialMessageName : name, on : bool)
	{
		var hud : CR4ScriptedHud;
		var messageModule : CR4HudModuleMessage;
		
		if(on)
		{
			hudMessage = tutorialMessageName;
		}
		else
		{
			hudMessage = '';
			
			hud = (CR4ScriptedHud)theGame.GetHud();
			if( hud )
			{
				messageModule = (CR4HudModuleMessage)hud.GetHudModule("MessageModule");
				if( messageModule )
				{
					messageModule.OnMessageHidden();
				}
			}
		}
	}
	
	private final function ProcessHUDMessage()
	{
		var tutorialEntry : CJournalTutorial;
		var msgText : string;
	
		if(IsNameValid(hudMessage) && AreMessagesEnabled())
		{
			tutorialEntry = GetMessageText(hudMessage, JS_Inactive);
			msgText = GetTutorialLocalizedText(tutorialEntry.GetDescriptionStringId());
			thePlayer.DisplayHudMessage(msgText);
		}
	}	
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////  @DISABLING MESSAGES  /////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private timer function TutorialInvisibleHint(dt : float, id : int)
	{
		HideTutorialHint(invisibleTutorialHint);
	}
	
	public final function ForcedAlchemyCleanup()
	{
		//allow to leave UI panels
		uiHandler.LockCloseUIPanels(false);
		
		//tutorial done
		FactsRemove("tut_forced_preparation");
		
		//allow leaving inventory panel
		uiHandler.LockLeaveMenu(false);
		
		//unlock everything, tutorial is done
		thePlayer.BlockAllActions('tut_forced_preparation', false);
		
		//unregister forced UI tutorial
		uiHandler.UnregisterUIState('ForcedAlchemy');
		
		//unregister forced alchemy
		uiHandler.UnregisterUIState('Alchemy', "forced");
			
		//unregister forced potion
		uiHandler.UnregisterUIState('Potions', "forced");
	}
	
	public final function RemoveAllQueuedTutorials()
	{
		queuedTutorials.Clear();
		uiHandler.ClearAllListeners();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////  @UI PANELS  //////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public final function OnOpeningMenuHandleNonMenuTutorial()
	{
		if(queuedTutorials.Size() > 0 && currentlyShownTutorialIndex >= 0)
		{
			//if current hint cannot be shown in UI panels - hide without removing from queue
			if(!queuedTutorials[currentlyShownTutorialIndex].canBeShownInMenus)
				HideTutorialHint(queuedTutorials[currentlyShownTutorialIndex].tutorialScriptTag, ,true);
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////  @DEBUG  //////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public final function DEBUG_LogQueuedTutorials()
	{
		var i : int;
		
		LogTutorial("Printing tutorial queue:");
		for(i=0; i<queuedTutorials.Size(); i+=1)
		{
			LogTutorial(i + ") " + queuedTutorials[i].tutorialScriptTag);
		}
	}
}

exec function logtutorialqueue()
{
	theGame.GetTutorialSystem().DEBUG_LogQueuedTutorials();
}
