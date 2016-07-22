/***********************************************************************/
/** Witcher Script file - Meditation Menu
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4MeditationClockMenu extends CR4MenuBase
{
	private var m_fxSetBlockMeditation		 	: CScriptedFlashFunction;
	private var m_fxSetCanMeditate			 	: CScriptedFlashFunction;
	private var m_fxSetBonusMeditationTime	 	: CScriptedFlashFunction;
	private var m_fxSetGeraltBackgroundVisible	: CScriptedFlashFunction;
	private var m_fxSet24HRFormat			 	: CScriptedFlashFunction;
	
	private var canMeditateWait				 	: bool;
	private var isGameTimePaused			 	: bool;
	
	private var BONUS_MEDITATION_TIME : int;
	default BONUS_MEDITATION_TIME = 1;

	event /*flash*/ OnConfigUI()
	{	
		var commonMenu : CR4CommonMenu;
		var locCode : string;
		var initData : W3SingleMenuInitData;
		
		super.OnConfigUI();
		
		GetWitcherPlayer().MeditationClockStart(this);
		SendCurrentTimeToAS();
		m_fxSetBlockMeditation = m_flashModule.GetMemberFlashFunction( "SetBlockMeditation" );
		m_fxSet24HRFormat = m_flashModule.GetMemberFlashFunction( "Set24HRFormat" );
		m_fxSetGeraltBackgroundVisible = m_flashModule.GetMemberFlashFunction( "setGeraltBackgroundVisible" );
		m_fxSetBonusMeditationTime = m_flashModule.GetMemberFlashFunction( "setBonusMeditationTime" );
		
		m_fxSetBonusMeditationTime.InvokeSelfOneArg( FlashArgInt( BONUS_MEDITATION_TIME ) );
		
		
		//we need to unpause menus because CanMeditateWait() returns false if game time is paused (if time does not flow we cannot speed it up
		//by waiting)
		theGame.Unpause("menus");		
		
		initData = (W3SingleMenuInitData)GetMenuInitData();
		
		if( initData && initData.isBonusMeditationAvailable )
		{
			SetMeditationBonuses();
		}
		
		if(GetWitcherPlayer().CanMeditate() && GetWitcherPlayer().CanMeditateWait(true) || ( initData && initData.ignoreMeditationCheck ) )
		{
			canMeditateWait = true;
			isGameTimePaused = false;			
		}
		else if(theGame.IsGameTimePaused())
		{
			canMeditateWait = false;
			isGameTimePaused = true;
		}
		
		if (canMeditateWait) // Comment out when enabling rendering in meditation
		{
			commonMenu = (CR4CommonMenu)m_parentMenu;
			if (commonMenu)
			{
				commonMenu.SetMeditationMode(true);
			}
			
			m_fxSetGeraltBackgroundVisible.InvokeSelfOneArg(FlashArgBool(false)); // Uncomment to enable rendering in meditation
		}
		
		m_fxSetBlockMeditation.InvokeSelfOneArg( FlashArgBool( !canMeditateWait ) );
		
		//24-hr time format
		
		locCode = GetCurrentTextLocCode();
		m_fxSet24HRFormat.InvokeSelfOneArg(FlashArgBool(locCode != "EN"));
		
		//meditation restoring		
		if(GameplayFactsQuerySum("GamePausedNotByUI") > 0 && !thePlayer.IsInCombat())
		{
			GetWitcherPlayer().MeditationRestoring(0);				
		}	
		
		//if (!canMeditateWait)
		//{
			theGame.Pause("menus");
		//}
	}
	
	event /* C++ */ OnClosingMenu()
	{
		var commonMenu : CR4CommonMenu;
		
		theGame.GetGuiManager().SendCustomUIEvent( 'ClosedMeditationClockMenu' );
		
		commonMenu = (CR4CommonMenu)m_parentMenu;
		if (commonMenu)
		{
			commonMenu.SetMeditationMode(false);
			
			if( commonMenu.GetIsPlayerMeditatingInBed() )
			{
				GetWitcherPlayer().ManageSleeping();
			}
		}
		
		GetWitcherPlayer().MeditationClockStop();
	}
	
	event /*flash*/ OnCloseMenu()
	{
		if(thePlayer.GetCurrentStateName() == 'MeditationWaiting')
		{
			MeditatingEnd();
		}
		
		if (!theGame.IsPaused())
		{
			theGame.Pause("menus");
		}
		

		
		CloseMenu();
		
		if( m_parentMenu )
		{
			m_parentMenu.ChildRequestCloseMenu();
		}
	}
	
	private function SetMeditationBonuses():void
	{
		var defManager	: CDefinitionsManagerAccessor;
		var flashObject	: CScriptedFlashObject;
		var flashArray	: CScriptedFlashArray;
		var bedEntity	: W3WitcherBed;
		var bedLevel	: int;
		var min, max    : SAbilityAttributeValue;
		var arrStr		: array< string >;
		var abilityVal  : float;
		var durationStr : string;
		var bedLevelString	: string;
		
		defManager = theGame.GetDefinitionsManager();
		bedEntity = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );
		flashArray = m_flashValueStorage.CreateTempFlashArray();
		
		// BED
		
		if( bedEntity )
		{
			flashObject = m_flashValueStorage.CreateTempFlashObject();
			
			bedLevel = bedEntity.GetBedLevel();
			
			if( bedLevel > 0 )
			{
				flashObject.SetMemberFlashBool( "available",  true );
			}
			else
			{
				flashObject.SetMemberFlashBool( "available",  false );
				bedLevel = 1;
			}
			
			bedLevelString = "bed_level_" + IntToString( bedLevel );
			
			arrStr.PushBack( IntToString( bedLevel ) );
			flashObject.SetMemberFlashString( "title", GetLocStringByKeyExtWithParams( "panel_title_buff_bed",,, arrStr ) + " " + GetLocStringByKeyExt( bedLevelString ) );
			arrStr.Clear();
			
			defManager.GetAbilityAttributeValue( 'WellRestedEffect', 'vitality', min, max);
			abilityVal = CalculateAttributeValue( min );
			if( bedLevel > 1 )
				abilityVal *= 2;
			arrStr.PushBack( FloatToStringPrec( abilityVal, 0 ) );
			flashObject.SetMemberFlashString( "description", GetLocStringByKeyExtWithParams( "panel_buff_bed_descr",,, arrStr ) );
			arrStr.Clear();
			
			defManager.GetAbilityAttributeValue( 'WellRestedEffect', 'duration', min, max);
			abilityVal = CalculateAttributeValue( min );
			if( bedLevel == 2 )
				abilityVal *= 2;
			arrStr.PushBack( FloatToString( abilityVal / 60 ) );
			durationStr = GetLocStringByKeyExtWithParams( "panel_buff_duration",,, arrStr );
			flashObject.SetMemberFlashString( "duration", durationStr );
			arrStr.Clear();
			
			flashObject.SetMemberFlashString( "type", "bed" );
			flashArray.PushBackFlashObject( flashObject );
		}
		
		// BOOKSHELF
		
		flashObject = m_flashValueStorage.CreateTempFlashObject();
		
		defManager.GetAbilityAttributeValue( 'BookshelfBuffEffect', 'nonhuman_exp_bonus_when_fatal', min, max);
		abilityVal = CalculateAttributeValue( min );
		arrStr.PushBack( FloatToStringPrec( ( abilityVal * 100 ), 0 ) );
		flashObject.SetMemberFlashString( "description", GetLocStringByKeyExtWithParams( "panel_buff_bookshelf_descr",,, arrStr ) );
		arrStr.Clear();
		
		defManager.GetAbilityAttributeValue( 'BookshelfBuffEffect', 'duration', min, max);
		abilityVal = CalculateAttributeValue( min );
		arrStr.PushBack( FloatToString( abilityVal / 60 ) );
		durationStr = GetLocStringByKeyExtWithParams( "panel_buff_duration",,, arrStr );
		flashObject.SetMemberFlashString( "duration", durationStr );
		arrStr.Clear();
		
		flashObject.SetMemberFlashString( "title", GetLocStringByKeyExt( "panel_title_buff_bookshelf" ) );
		flashObject.SetMemberFlashString( "type", "bookshelf" );
		flashObject.SetMemberFlashBool( "available",  true );
		
		flashArray.PushBackFlashObject( flashObject );
		
		// ALCHEMY TABLE
		
		flashObject = m_flashValueStorage.CreateTempFlashObject();
		flashObject.SetMemberFlashString( "title", GetLocStringByKeyExt( "panel_title_buff_alchemy_table" ) );
		flashObject.SetMemberFlashString( "duration", "" );
		flashObject.SetMemberFlashString( "type", "alchemytable" );
		flashArray.PushBackFlashObject( flashObject );
		
		arrStr.PushBack( IntToString( theGame.params.QUANTITY_INCREASED_BY_ALCHEMY_TABLE ) );
		flashObject.SetMemberFlashString( "description", GetLocStringByKeyExtWithParams( "panel_buff_alchemy_table_descr",,, arrStr ) );
		arrStr.Clear();
		
		if( FactsDoesExist( "AlchemyTableExists" ) )
		{
			flashObject.SetMemberFlashBool( "available",  true );
		}
		else
		{
			flashObject.SetMemberFlashBool( "available",  false );
		}
		
		// STABLES
		
		flashObject = m_flashValueStorage.CreateTempFlashObject();
		flashObject.SetMemberFlashString( "title", GetLocStringByKeyExt( "panel_title_buff_stables" ) );
		flashObject.SetMemberFlashString( "type", "stable" );
		
		defManager.GetAbilityAttributeValue( 'HorseStableBuff', 'stamina', min, max );
		abilityVal = CalculateAttributeValue( min );
		arrStr.PushBack( FloatToStringPrec( abilityVal, 0 ) );
		flashObject.SetMemberFlashString( "description", GetLocStringByKeyExtWithParams( "panel_buff_stables_descr",,,  arrStr ) );
		arrStr.Clear();
		
		defManager.GetAbilityAttributeValue( 'HorseStableBuffEffect', 'duration', min, max );
		abilityVal = CalculateAttributeValue( min );
		arrStr.PushBack( FloatToString( abilityVal / 60 ) );
		durationStr = GetLocStringByKeyExtWithParams( "panel_buff_duration",,, arrStr );
		flashObject.SetMemberFlashString( "duration", durationStr );
		arrStr.Clear();
		
		if( FactsDoesExist( "StablesExists" ) )
		{
			flashObject.SetMemberFlashBool( "available",  true );
		}
		else
		{
			flashObject.SetMemberFlashBool( "available",  false );
		}
		
		flashArray.PushBackFlashObject( flashObject );
		
		// --
		
		m_flashValueStorage.SetFlashArray( "meditation.bonus", flashArray );
	}
	
	function SetButtons()
	{
		AddInputBinding("panel_button_common_exit", "escape-gamepad_B", -1);
		super.SetButtons();
	}
	
	public function UpdateCurrentHours( ):void
	{
		var timeHours : int = GetCurrentDayTime( "hours" );
		var	timeMinutes : int = GetCurrentDayTime( "minutes" );
		m_flashValueStorage.SetFlashInt( "meditation.clock.hours.update", timeHours );
		m_flashValueStorage.SetFlashInt( "meditation.clock.minutes", timeMinutes );
	}
	
	public function SendCurrentTimeToAS():void
	{
		var  timeHours : int = GetCurrentDayTime( "hours" );
		var  timeMinutes : int = GetCurrentDayTime( "minutes" );
		
		m_flashValueStorage.SetFlashInt( "meditation.clock.hours", timeHours );
		m_flashValueStorage.SetFlashInt( "meditation.clock.minutes", timeMinutes );
	}
	
	event /*flash*/ OnMeditate( dayTime : float )
	{
		var medd : W3PlayerWitcherStateMeditation;
		
		if (!canMeditateWait)
		{
			ShowDisallowedNotification();			
		}
		else
		{		
			if (theGame.IsPaused())
			{
				theGame.Unpause("menus");
			}
			
			if( GetWitcherPlayer().Meditate() )
			{
				OnPlaySoundEvent( "gui_meditation_start" );
				
				LogChannel('CLOCK',"	** OnMeditate ** ");
				if(dayTime == GameTimeHours(theGame.GetGameTime()))
					return false;
				
				medd = (W3PlayerWitcherStateMeditation)thePlayer.GetCurrentState();
				medd.MeditationWait(CeilF(dayTime));
				//m_flashValueStorage.SetFlashBool( "meditation.clock.blocked", false );
				
				StartWaiting();
			}
		}
	} 
	
	event /*flash*/ OnMeditateBlocked()
	{
		ShowDisallowedNotification();
	}
	
	event /*flash*/ OnStopMeditate()
	{
		var waitt : W3PlayerWitcherStateMeditationWaiting;
	
		if(thePlayer.GetCurrentStateName() == 'MeditationWaiting')
		{
			waitt = (W3PlayerWitcherStateMeditationWaiting)thePlayer.GetCurrentState();
			if(waitt)
				waitt.RequestWaitStop();
		}
		
		MeditatingEnd();
	}
	
	function GetCurrentDayTime( type : string ) : int //@FIXME BIDON -> move it to better place
	{
		var gameTime : GameTime = theGame.GetGameTime();
		var currentDays : int;
		var currentHours : int;
		var currentMinutes : int;
		var currentTime : int;
		
		switch( type )
		{
			case "days" :
			{
				currentTime = GameTimeDays( gameTime );
				break;
			}
			case "hours" :
			{
				currentDays = GameTimeDays( gameTime );
				currentHours = GameTimeHours( gameTime );
				currentTime = currentHours /*- currentDays*24*/;
				break;
			}
			case "minutes" :
			{
				currentDays = GameTimeDays( gameTime );
				currentHours = GameTimeHours( gameTime );
				currentMinutes = GameTimeMinutes( gameTime );
				currentTime = currentMinutes/* - (currentHours - currentDays*24)*60*/;
				break;
			}	
		}
		return currentTime;
	}
	
	
	// TODO: Implement input blocking:
	
	public function StartWaiting():void
	{
		theGame.GetCityLightManager().SetUpdateEnabled( false );
		m_flashValueStorage.SetFlashBool( "meditation.clock.blocked", true );
		SetMenuNavigationEnabled(false);
	}
	
	public function StopWaiting():void
	{
		m_flashValueStorage.SetFlashBool( "meditation.clock.blocked", false );
		SetMenuNavigationEnabled(true);
	}
	
	function MeditatingEnd()
	{
		theGame.GetCityLightManager().ForceUpdate();
		theGame.GetCityLightManager().SetUpdateEnabled( true );
		m_flashValueStorage.SetFlashBool( "meditation.clock.blocked", false );
		SetMenuNavigationEnabled(true);
	}
	
	function PlayOpenSoundEvent()
	{
		// Common Menu takes care of this for us
		//OnPlaySoundEvent("gui_global_panel_open");	
	}
	
	private final function ShowDisallowedNotification()
	{		
		if(thePlayer.IsInCombat())
		{
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
		}
		else
		{
			showNotification(GetLocStringByKeyExt( "menu_cannot_perform_action_now" ));
		}
		
		OnPlaySoundEvent("gui_global_denied");
	}
}