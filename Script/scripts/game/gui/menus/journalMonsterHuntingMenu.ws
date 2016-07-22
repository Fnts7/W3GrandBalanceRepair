/***********************************************************************/
/** Witcher Script file - quest hunting journal
/***********************************************************************/
/** Copyright © 2013 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4JournalMonsterHuntingMenu extends CR4JournalQuestMenu
{	
	default DATA_BINDING_NAME 		= "journal.monsterhunting.list";
	default DATA_BINDING_NAME_SUBLIST	= "journal.monsterhunting.objectives.list";
	default DATA_BINDING_NAME_DESCRIPTION	= "journal.monsterhunting.description";
	
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
				if( questTemp.GetType() == MonsterHunt /*QuestType_MonsterHunt*/ )
				{
					allQuests.PushBack(questTemp);
				}
			}
		}
		
		ShowRenderToTexture("");
	}
	
	event /* C++ */ OnGuiSceneEntitySpawned(entity : CEntity)
	{
		UpdateSceneEntityFromCreatureDataComponent( entity );

		Event_OnGuiSceneEntitySpawned();
	}
	
	event /* C++ */ OnGuiSceneEntityDestroyed()
	{
		Event_OnGuiSceneEntityDestroyed();
	}
	
	function UpdateImage( entryName : name ) 
	{
		var creature : CJournalCreature;
		var questTemp : CJournalQuest;
		var monsterTag : name;
		var monsterStr : string;
		var templatepath : string;
		questTemp = (CJournalQuest)m_journalManager.GetEntryByTag(entryName);
		monsterTag = questTemp.GetHuntingQuestCreatureTag();
		creature = (CJournalCreature)m_journalManager.GetEntryByTag(monsterTag);
		
		if (m_journalManager.GetQuestHasMonsterKnown(questTemp))
		{
			if(creature)
			{
				templatepath = creature.GetEntityTemplateFilename();
				if (templatepath == "")
				{
					ShowRenderToTexture("characters\npc_entities\monsters\wraith_lvl1.w2ent");
				}
				else
				{
					ShowRenderToTexture(templatepath);
				}
			}
			else
			{
				ShowRenderToTexture("");
			}
		}
	}
	
	/*function UpdateQuestLegend()
	{
		var l_feedbackFlashArray		: CScriptedFlashArray;
		var l_feedbackDataFlashObject	: CScriptedFlashObject;
		
		l_feedbackFlashArray = m_flashValueStorage.CreateTempFlashArray();	
				
		l_feedbackDataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_feedbackDataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt('MonsterHunt') );
		l_feedbackDataFlashObject.SetMemberFlashString(  "dropDownLabel", "" );		
		l_feedbackDataFlashObject.SetMemberFlashInt( "isStory", 0 );					
		l_feedbackDataFlashObject.SetMemberFlashString( "iconPath", GetQuestIconByType(MonsterHunt) );			
		l_feedbackDataFlashObject.SetMemberFlashBool( "isNew", false );
		l_feedbackDataFlashObject.SetMemberFlashBool( "selected", false );		
		l_feedbackDataFlashObject.SetMemberFlashInt( "status", JS_Active );
		l_feedbackDataFlashObject.SetMemberFlashBool( "tracked", false );
		l_feedbackDataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_journal_legend_monsterhunt") );
		l_feedbackFlashArray.PushBackFlashObject(l_feedbackDataFlashObject);		
		
		m_flashValueStorage.SetFlashArray( "journal.legend.quests.list", l_feedbackFlashArray );
	}*/
}