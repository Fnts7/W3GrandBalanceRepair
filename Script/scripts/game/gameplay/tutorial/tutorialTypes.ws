/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Tomek Kozera
/***********************************************************************/

enum ETutorialMessageType		//for quests
{
	ETMT_Undefined,
	ETMT_Hint,
	ETMT_Message
}

//give some exp then if player didn't level up since the start of the game add more to force 1 level up
reward function TutorialLevelUp()
{
	var witcher : W3PlayerWitcher;
	
	witcher = GetWitcherPlayer();
	witcher.AddPoints(EExperiencePoint, 50, false);
	if(witcher.GetLevel() == FactsQuerySum('tutorial_starting_level'))
	{
		witcher.AddPoints(EExperiencePoint, witcher.GetMissingExpForNextLevel(), true);
	}
}

struct SUITutorial
{
	editable saved var menuName 							: name;
	editable saved var tutorialStateName 					: name;
	editable saved var triggerCondition 					: EUITutorialTriggerCondition;
	editable saved var requiredGameplayFactName 			: string;
	editable saved var requiredGameplayFactValueInt 		: int;
	editable saved var requiredGameplayFactComparator 	: ECompareOp;
	editable saved var requiredGameplayFactName2 			: string;
	editable saved var requiredGameplayFactValueInt2 		: int;
	editable saved var requiredGameplayFactComparator2 	: ECompareOp;
	editable saved var priority							: int;				//if several UI tutorials trigger at the same time, the one with lowest priority value will be shown only
	editable saved var abortOnMenuClose					: bool;
	editable saved var sourceName							: string;		//optional source of tutorial, used for removing handlers when there are multiple ones of same type
	
	hint priority = "Lesser values are MORE important";
};

enum EUITutorialTriggerCondition
{
	EUITTC_OnMenuOpen
	//EUITTC_OnMenuClose
	//EUITTC_WhenInMenu
}