/***********************************************************************/
/** Witcher Script file - Gwint
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Robert 
/***********************************************************************/

/*

//////////////////////////////////////
// C++
//////////////////////////////////////

enum EGwintDifficultyMode
{
	EGDM_Easy = 0,
	EGDM_Medium,
	EGDM_Hard,
};

enum EGwintAggressionMode
{
	EGAM_Defensive = 0,		//never chooses heavy tactic if defensive tactic possible to reach target. Strategy value of cards is most important for those tactics
	EGAM_Normal,			//rarely makes heavy push. Prefers steady play	. Strategy value of cards is important for those tactics. Card power sometimes takes core priority
	EGAM_Aggressive,		//likes to push hard. likes tactics all or nothing	. Strategy value of cards is sometimes taken into consideration. Card power is very important
	EGAM_VeryAggressive,	//more aggressive version of above
	EGAM_AllIHave,			//rarely falls back until player is in play. Easly bleeds out his choices. Strategy value of cards is rarely important for those tactics. Card power takes core priority
};

*/



import class CGwintMenuInitData extends CObject
{
	import public var deckName : name;
	import public var difficulty : EGwintDifficultyMode;
	import public var aggression : EGwintAggressionMode;
	import public var allowMultipleMatches : bool;
};

class CR4GwintMenu extends CR4MenuBase
{

	event /*flash*/ OnConfigUI()
	{	
		
	}

	event /* C++ */ OnClosingMenu()
	{
	}

	event OnCloseMenu()
	{
		CloseMenu();
	}

	event /*flash*/ OnTraceMe(text : string)	
	{	
	}
	
	event /*flash*/ OnPlaySound(text : string)	
	{		
	}
	
	event /*flash*/ OnBattleResults(playerLivesLeft : int, enemyLivesLeft : int )	
	{	
		CloseMenu();
	}	
	
	event /*flash*/ OnGetPlayerDeck(index : int)	
	{	
	}
	
	event /*flash*/ OnSetPlayerDeck( factionIndex : int, cardIndex : int)	
	{	
	}
	
	event /*flash*/ OnNewKingChosen( factionIndex : int, kingIndex : int)	
	{		
	}

	event /*flash*/ OnCustomPowersReques(index : int)	
	{	
		
	}
	
	
	function GetPlayerDeck(out container : CScriptedFlashArray, faction : int) :void
	{
		
	}

	function SetBattlefieldAngles() :void
	{
	}
	
	function GameplaySettings() :void
	{	
	}
	
	function SetCardAttributeValue() :void
	{
		
	}	
	
	function GetAICardCollection(out container : CScriptedFlashArray) :void
	{
		
	}

	function GetPlayerCardCollection(out container : CScriptedFlashArray) :void
	{		
		
	}	

	function GetCardDefinitionTest(out container : CScriptedFlashArray) :void
	{
		
	}
		
	function GetKingChoices(out container : CScriptedFlashArray) :void
	{		
	}
	
	function GetKingDefinition(out container : CScriptedFlashArray) :void
	{
	}
	
	function AddIndex(out container : CScriptedFlashArray, index:int):void
	{
	}
	
	function BuildCardObject(out container : CScriptedFlashArray, cardDef : SCardDefinition )
	{
	
	}
	
	function AddPower(out container : CScriptedFlashArray, index:int, playerOwner:bool):void
	{
		
	}
	
	private function ClearDeckDef( out deckDef : SDeckDefinition )
	{
	}

	private function ClearCardDef( out cardDef : SCardDefinition )
	{
	}

} 