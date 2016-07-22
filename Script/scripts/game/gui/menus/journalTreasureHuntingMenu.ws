/***********************************************************************/
/** Witcher Script file - journal treasure hunting 
/***********************************************************************/
/** Copyright © 2013 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4JournalTreasureHuntingMenu extends CR4JournalQuestMenu
{	
	default DATA_BINDING_NAME 		= "journal.treasure.list";
	default DATA_BINDING_NAME_SUBLIST	= "journal.treasure.objectives.list";
	default DATA_BINDING_NAME_DESCRIPTION	= "journal.treasurequest.description";
	
	function GetQuests()
	{
		var tempQuests					: array<CJournalBase>;
		var questTemp					: CJournalQuest;
		var i							: int;
		var questType					: eQuestType;
		
		m_journalManager.GetActivatedOfType( 'CJournalQuest', tempQuests );
		
		initialTrackedQuest = m_journalManager.GetTrackedQuest();
		
		for( i = 0; i < tempQuests.Size(); i += 1 )
		{
			questTemp = (CJournalQuest)tempQuests[i];
			if( questTemp )
			{
				if( questTemp.GetType() == TreasureHunt /*QuestType_TreasureHunt*/ )
				{
					allQuests.PushBack(questTemp);
				}
			}
		}
	}
	
	/*function UpdateQuestLegend()
	{
		var l_feedbackFlashArray		: CScriptedFlashArray;
		var l_feedbackDataFlashObject	: CScriptedFlashObject;
		
		l_feedbackFlashArray = m_flashValueStorage.CreateTempFlashArray();	
				
		l_feedbackDataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_feedbackDataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt('TreasureHunt') );
		l_feedbackDataFlashObject.SetMemberFlashString(  "dropDownLabel", "" );		
		l_feedbackDataFlashObject.SetMemberFlashInt( "isStory", 0 );					
		l_feedbackDataFlashObject.SetMemberFlashString( "iconPath", GetQuestIconByType(TreasureHunt) );			
		l_feedbackDataFlashObject.SetMemberFlashBool( "isNew", false );
		l_feedbackDataFlashObject.SetMemberFlashBool( "selected", false );		
		l_feedbackDataFlashObject.SetMemberFlashInt( "status", JS_Active );
		l_feedbackDataFlashObject.SetMemberFlashBool( "tracked", false );
		l_feedbackDataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_journal_legend_treasurehunt") );
		l_feedbackFlashArray.PushBackFlashObject(l_feedbackDataFlashObject);		
		
		m_flashValueStorage.SetFlashArray( "journal.legend.quests.list", l_feedbackFlashArray );
	}*/
}