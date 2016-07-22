
import class IQuestCombatManagerBaseBlock extends CQuestGraphBlock
{
	function GetBlockName() : string
	{
		return "PLZ_REDEFINE_MA_NAME";
	}
	function GetAITree() : IAITree
	{
		return NULL;
	}
}

class CQuestCombatManagerBlock extends IQuestCombatManagerBaseBlock
{
	editable inlined var combatStyle : CAINpcCombatStyle;
	
	function GetBlockName() : string
	{
		return "CombatManager: Human";
	}
	
	function GetAITree() : IAITree
	{
		return combatStyle;
	}
	
	function GetContextMenuSpecialOptions( out names : array< string > )
	{
		names.PushBack( "VesemirTutorial" );		// 0
		names.PushBack( "OneHandedSword" );			// 1
		names.PushBack( "OneHandedAxe" );			// 2
		names.PushBack( "OneHandedBlunt" );			// 3
		names.PushBack( "OneHandedAny" );			// 4
		names.PushBack( "Fists" );					// 5
		names.PushBack( "Shield" );					// 6
		names.PushBack( "Bow" );					// 7
		names.PushBack( "Crossbow" );				// 8
		names.PushBack( "TwoHandedHammer" );		// 9
		names.PushBack( "TwoHandedAxe" );			// 10
		names.PushBack( "TwoHandedHalberd" );		// 11
		names.PushBack( "TwoHandedSpear" );			// 12
		names.PushBack( "Witcher" );				// 13
	}
	function RunSpecialOption( option : int )
	{
		switch ( option )
		{
			case 0:
			combatStyle = new CAINpcVesemirTutorialCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 1:
			combatStyle = new CAINpcOneHandedSwordCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 2:
			combatStyle = new CAINpcOneHandedAxeCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 3:
			combatStyle = new CAINpcOneHandedBluntCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 4:
			combatStyle = new CAINpcOneHandedAnyCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 5:
			combatStyle = new CAINpcFistsCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 6:
			combatStyle = new CAINpcShieldCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 7:
			combatStyle = new CAINpcBowCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 8:
			combatStyle = new CAINpcCrossbowCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 9:
			combatStyle = new CAINpcTwoHandedHammerCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 10:
			combatStyle = new CAINpcTwoHandedAxeCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 11:
			combatStyle = new CAINpcTwoHandedHalberdCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 12:
			combatStyle = new CAINpcTwoHandedSpearCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			case 13:
			combatStyle = new CAINpcWitcherCombatStyle in this;
			combatStyle.OnCreated();
			break;
			
			default : return;
		}
	}
};

class CQuestMonsterCombatManagerBlock extends IQuestCombatManagerBaseBlock
{
	editable inlined var combatLogic : CAIMonsterCombatLogic;
	
	function GetBlockName() : string
	{
		return "CombatManager: Monster";
	}
	
	function GetAITree() : IAITree
	{
		return combatLogic;
	}
	
	function GetContextMenuSpecialOptions( out names : array< string > )
	{
		names.PushBack( "Witch1" );		// 0
		names.PushBack( "Witch2" );		// 1
		names.PushBack( "Witch3" );		// 2
	}
	function RunSpecialOption( option : int )
	{
		switch ( option )
		{
			case 0:
			combatLogic = new CAIWitchCombatLogic in this;
			combatLogic.OnCreated();
			break;
			
			case 1:
			combatLogic = new CAIWitch2CombatLogic in this;
			combatLogic.OnCreated();
			break;
			
			case 2:
			combatLogic = new CAIWitchCombatLogic in this;
			combatLogic.OnCreated();
			break;
			
			default : return;
		}
	}
};