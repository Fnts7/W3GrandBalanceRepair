/***********************************************************************/
/** Witcher Script file - preparation mutagens
/***********************************************************************/
/** Copyright © 2013 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4PreparationMainMenu extends CR4MenuBase
{
	
	
	event /*flash*/ OnConfigUI()
	{	
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;

		super.OnConfigUI();

		RequestSubMenu( 'PreparationMutagensMenu' );
		
		UpdatePlayerOrens();
		UpdatePlayerLevel();
		
		UpdateNavigationTitles();
	}
	
	private function UpdatePlayerOrens()
	{
		var orens:int;
		orens = thePlayer.GetMoney();
		
		m_flashValueStorage.SetFlashInt("inventory.playerdetails.money",orens,-1);
	}

	private function UpdatePlayerLevel()
	{
		m_flashValueStorage.SetFlashInt("inventory.playerdetails.level",GetCurrentLevel(),-1);
		m_flashValueStorage.SetFlashString("inventory.playerdetails.experience",GetCurrentExperience(),-1);
	}
	
	private function GetCurrentLevel() : int
	{
		var levelManager : W3LevelManager;
		
		levelManager = GetWitcherPlayer().levelManager;
		
		return levelManager.GetLevel();
	}	

	private function GetCurrentExperience() : string
	{
		var levelManager : W3LevelManager;
		var str : string;
		levelManager = GetWitcherPlayer().levelManager;
		
		str = (string)levelManager.GetPointsTotal(EExperiencePoint) + "/" +(string)levelManager.GetTotalExpForNextLevel(); // #B maybe total - previous lvl exp ??
		return str;
	}
	
	function UpdateNavigationTitles() // @FIXME BIDON - bindings are ok ?
	{
		m_flashValueStorage.SetFlashString("inventory.navigation.title", GetLocStringByKeyExt("panel_title_preapration"), -1 );
		m_flashValueStorage.SetFlashString("inventory.navigation.previous", "", -1 );
		m_flashValueStorage.SetFlashString("inventory.navigation.next", "", -1 );
		//m_flashValueStorage.SetFlashString("inventory.navigation.enabled", 2, -1 );
	}
	
	event /*flash*/ OnCloseMenu()
	{
		if ( !GetSubMenu() )
		{
			CloseMenu();
		}
		if( m_parentMenu )
		{
			m_parentMenu.RestoreInput();
		}
	}
	
	
	
	event /*flash*/ OnPreparationTabSelected( tabID : int )
	{
		if( GetSubMenu() )
		{
			GetSubMenu().CloseMenu();
		}
		switch(tabID)
		{	
			case 0:
				RequestSubMenu( 'PreparationMutagensMenu' );
				break;		
			case 1:
				RequestSubMenu( 'PreparationPotionsAndBombsMenu' );
				break;			
			case 2:
				RequestSubMenu( 'PreparationOilsMenu' );
				break;
		}
	}
}
