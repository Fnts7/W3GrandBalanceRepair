//-----------------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////
// CAIScaredCombatTree
class CAIScaredCombatTree extends CAISubTree
{
	default aiTreeName = "resdef:ai\combat\npc_scared_combat";
};



///////////////////////////////////////////////////////////////
// CAINpcDefenseAction
abstract class CAINpcDefenseAction extends CAICombatActionTree
{
};

//////////////////////////////////////////////////////
// CAINpcParryAction
class CAINpcParryAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_parry";
	
	editable var activationTimeLimitBonusHeavy : float;
	editable var activationTimeLimitBonusLight : float;
	
	default activationTimeLimitBonusHeavy = 0.9;
	default activationTimeLimitBonusLight = 0.5;
};

////////////////////////////////////////////////////////
// CAINpcDodgeAction
class CAINpcDodgeAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_dodge";
};

//////////////////////////////////////////////////////
// CAINpcCounterAction
class CAINpcCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_counter";
};

//////////////////////////////////////////////////////
// CAINpcCounterFistFightAction
class CAINpcCounterFistFightAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_counter_fistfight";
};

//////////////////////////////////////////////////////
// CAINpcCounterHitAction
class CAINpcCounterHitAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_counterhit";
};

//////////////////////////////////////////////////////
// CAIWildHuntCounterHitAction
class CAIWildHuntCounterHitAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_wildhunt_counterhit";
};

//////////////////////////////////////////////////////
// CAINpcCounterPushAction
class CAINpcCounterPushAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_counter_push";
};

//////////////////////////////////////////////////////
// CAINpcWitcherCounterAction
class CAINpcWitcherCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_witcher_counter";
};

//////////////////////////////////////////////////////
// CAINpcCiriCounterAction
class CAINpcCiriCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_ciri_counter";
};

//////////////////////////////////////////////////////
// CAINpcImlerithCounterAction
class CAINpcImlerithCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_imlerith_counter";
};

//////////////////////////////////////////////////////
// CAINpcImlerithCounterActionSecondStage
class CAINpcImlerithCounterActionSecondStage extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_imlerith_counter_second_stage";
};

////////////////////////////////////////////////////////
// CAINpcImlerithParry
class CAINpcImlerithParry extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_imlerith_parry";
	
	editable var activationTimeLimitBonusHeavy : float;
	editable var activationTimeLimitBonusLight : float;
	
	default activationTimeLimitBonusHeavy = 0.9;
	default activationTimeLimitBonusLight = 0.5;
};

//////////////////////////////////////////////////////
// CAINpcImlerithGuardAction
class CAINpcImlerithGuardAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_imlerith_guard";
};

//////////////////////////////////////////////////////
// CAINpcImlerithSignsBlockAction
class CAINpcImlerithSignsBlockAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_imlerith_signs_block";
};

//////////////////////////////////////////////////////
// CAINpcGregoireCounterAction
class CAINpcGregoireCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_gregoire_counter";
};

//////////////////////////////////////////////////////
// CAINpcEredinCounterAction
class CAINpcEredinCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_eredin_counter";
};

//////////////////////////////////////////////////////
// CAINpcEredinRaiseGuardAction
class CAINpcEredinRaiseGuardAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_eredin_raise_guard";
};

//////////////////////////////////////////////////////
// CAINpcEredinSignsBlockAction
class CAINpcEredinSignsBlockAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_eredin_signs_block";
};

////////////////////////////////////////////////////////
// CAINpcEredinDodgeAction
class CAINpcEredinDodgeAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_eredin_dodge";
};

////////////////////////////////////////////////////////
// CAINpcEredinParryAction
class CAINpcEredinParryAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_eredin_parry";
	
	editable var activationTimeLimitBonusHeavy : float;
	editable var activationTimeLimitBonusLight : float;
	
	default activationTimeLimitBonusHeavy = 0.9;
	default activationTimeLimitBonusLight = 0.5;
};

//////////////////////////////////////////////////////
// CAINpcOlgierdCounterAction
class CAINpcOlgierdCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_olgierd_counter";
};

//////////////////////////////////////////////////////
// CAINpcOlgierdDodgeAction
class CAINpcOlgierdDodgeAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_olgierd_dodge";
};

//////////////////////////////////////////////////////
// CAINpcOlgierdCounterAfterHitAction
class CAINpcOlgierdCounterAfterHitAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_olgierd_counter_after_hit";
};

//////////////////////////////////////////////////////
// CAINpcOlgierdParryAction
class CAINpcOlgierdParryAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_olgierd_parry";
	
	editable var activationTimeLimitBonusHeavy : float;
	editable var activationTimeLimitBonusLight : float;
	
	default activationTimeLimitBonusHeavy = 0.5;
	default activationTimeLimitBonusLight = 0.5;
};

//////////////////////////////////////////////////////
// CAINpcDettlaffVampireCounterAction
class CAINpcDettlaffVampireCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\monsters/monster_dettlaff_vampire_counter";
};
//////////////////////////////////////////////////////
// CAINpcDettlaffVampireCounterAfterHitAction
class CAINpcDettlaffVampireCounterAfterHitAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\monsters/monster_dettlaff_vampire_counter_after_hit";
};
//////////////////////////////////////////////////////
// CAINpcDettlaffVampireParryAction
class CAINpcDettlaffVampireParryAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\monsters/monster_dettlaff_vampire_parry";
	
	editable var activationTimeLimitBonusHeavy : float;
	editable var activationTimeLimitBonusLight : float;
	
	default activationTimeLimitBonusHeavy = 0.5;
	default activationTimeLimitBonusLight = 0.5;
};

//////////////////////////////////////////////////////
// CAINpcDettlaffMinionParryAction
class CAINpcDettlaffMinionParryAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\monsters/monster_dettlaff_minion_parry";
	
	editable var activationTimeLimitBonusHeavy : float;
	editable var activationTimeLimitBonusLight : float;
	
	default activationTimeLimitBonusHeavy = 0.5;
	default activationTimeLimitBonusLight = 0.5;
};
//////////////////////////////////////////////////////
// CAINpcDettlaffMinionCounterAction
class CAINpcDettlaffMinionCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\monsters/monster_dettlaff_minion_counter";
};

////////////////////////////////////////////////////////
// CAINpcSummonGuardsAction
class CAINpcSummonGuardsAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_summon_guards";
};

////////////////////////////////////////////////////////
// CAINpcCaranthirCounterAction
class CAINpcCaranthirCounterAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_caranthir_counter";
};

////////////////////////////////////////////////////////
// CAINpcCaranthirIceArmorAction
class CAINpcCaranthirIceArmorAction extends CAINpcDefenseAction
{
	default aiTreeName = "resdef:ai\combat\npc_def_caranthir_ice_armor";
};

//-----------------------------------------------------------------------------------------------------

////////////////////////////////////////////////////////
// CAINpcTacticTree
abstract class CAINpcTacticTree extends CAISubTree
{
	editable inlined var params : CAINpcTacticTreeParams;
	
	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};

////////////////////////////////////////////////////////
// CAINpcMeleeTacticTree
abstract class CAINpcMeleeTacticTree extends CAINpcTacticTree
{
};

////////////////////////////////////////////////////////
// CAINpcRangedTacticTree
abstract class CAINpcRangedTacticTree extends CAINpcTacticTree
{
};

////////////////////////////////////////////////////////
// CAINpcCustomTacticTree
abstract class CAINpcCustomTacticTree extends CAINpcTacticTree
{
};

// CAINpcTacticTreeParams
class CAINpcTacticTreeParams extends CAISubTreeParameters
{
	//editable inlined var attackBehavior : CAIAttackBehaviorTree;
	
	editable inlined var specialActions : array<CAISpecialAction>;
	
	//editable inlined var closeSteeringGraph : CMoveSteeringBehavior;
	//editable inlined var farSteeringGraph : CMoveSteeringBehavior;
	
	editable var dontUseRunWhileStrafing	: bool;
	editable var allowChangingGuard			: bool;
	
	default dontUseRunWhileStrafing = false;
	default allowChangingGuard 		= true;
	
	function Init()
	{
		//attackBehavior = new CAIAttackBehaviorTree in this;
		//attackBehavior.OnCreated();
	}
	
	function InitializeSpecialActions()
	{
		var i : int;
		
		for ( i = 0; i < specialActions.Size(); i+=1 )
		{
			specialActions[ i ].OnCreated();
		}
	}
};

///////////////////////////////////////////////////////////
// CAINpcSimpleTacticTree
class CAINpcSimpleTacticTree extends CAINpcMeleeTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_simple";
	
	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};

///////////////////////////////////////////////////////////
// CAINpcSurroundTacticTree
class CAINpcSurroundTacticTree extends CAINpcMeleeTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_surround";

	function Init()
	{
		params = new CAINpcSurroundTacticTreeParams in this;
		params.OnCreated();
	}
};

// CAINpcSurroundTacticTreeParams
class CAINpcSurroundTacticTreeParams extends CAINpcTacticTreeParams
{
	editable var minStrafeDist : float;
	editable var maxStrafeDist : float;
	editable var minFarStrafeDist : float;
	editable var maxFarStrafeDist : float;
	
	function Init()
	{
		super.Init();
		minStrafeDist = 3.f;
		maxStrafeDist = 5.f;
		minFarStrafeDist = 8.f;
		maxFarStrafeDist = 12.f;
	}
};

// CAINpcSurroundTacticCloseTree
class CAINpcSurroundTacticCloseTree extends CAINpcMeleeTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_surround_close";
	
	function Init()
	{
		params = new CAINpcSurroundTacticTreeParams in this;
		params.OnCreated();
	}
};

// CAINpcSurroundTacticFarTree
class CAINpcSurroundTacticFarTree extends CAINpcMeleeTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_surround_far";

	function Init()
	{
		params = new CAINpcSurroundTacticTreeParams in this;
		params.OnCreated();
	}
};

// CAINpcSurroundRangedTacticTree
class CAINpcSurroundRangedTacticTree extends CAINpcRangedTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_surround_ranged";

	function Init()
	{
		params = new CAINpcSurroundTacticTreeParams in this;
		params.OnCreated();
	}
};


// CAINpcHoldGroundTacticTree
class CAINpcHoldGroundTacticTree extends CAINpcMeleeTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_holdground";
	
	function Init()
	{
		params = new CAINpcHoldGroundTacticTreeParams in this;
		params.OnCreated();
	}
};

// CAINpcHoldGroundTacticTreeParams
class CAINpcHoldGroundTacticTreeParams extends CAINpcTacticTreeParams
{
	editable var holdPositionTag 					: name;
	editable var engageDist 						: float;
	editable var maxDistanceToHoldGroundPosition 	: float;
	
	function Init()
	{
		super.Init();
		engageDist = 8;
		maxDistanceToHoldGroundPosition = 8;
	}
};

// CAINpcHoldGroundRangedTacticTree
class CAINpcHoldGroundRangedTacticTree extends CAINpcRangedTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_holdground_ranged";
	
	
	function Init()
	{
		params = new CAINpcHoldGroundRangedTacticTreeParams in this;
		params.OnCreated();
	}
};

// CAINpcHoldGroundTacticTreeParams
class CAINpcHoldGroundRangedTacticTreeParams extends CAINpcTacticTreeParams
{
	editable var holdPositionTag 					: name;
	editable var maxDistanceToHoldGroundPosition 	: float;
	
	function Init()
	{
		super.Init();
		maxDistanceToHoldGroundPosition = 0.f;
	}
};

// CAINpcVesemirTutorialTacticTree
class CAINpcVesemirTutorialTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_vesemir_tutorial";
	
	function Init()
	{
		params = new CAINpcVesemirTutorialTacticTreeParams in this;
		params.OnCreated();
	}
};

// CAINpcVesemirTutorialTacticTreeParams
class CAINpcVesemirTutorialTacticTreeParams extends CAINpcTacticTreeParams
{
	editable var backgroundTraining	: bool;
	editable var onlyBlock 			: bool;
	editable var onlyBlocksWithQuen : bool;
	editable var useAttacks 		: bool;
	editable var useCombos 			: bool;
	editable var forceIdle		 	: bool;
	editable var attacksInterval 	: float;
	
	editable var maxDistFromTarget  : float;
	
	default maxDistFromTarget = 5.f;
	
	function Init()
	{
		attacksInterval = 3.f;
		super.Init();
	}
};

// CAINpcSorceressTacticTree
class CAINpcSorceressTacticTree extends CAINpcRangedTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_sorceress";
	
	function Init()
	{
		params = new CAINpcSorceressTacticTreeParams in this;
		params.OnCreated();
	}
};
// CAINpcSorceressTacticTreeParams
class CAINpcSorceressTacticTreeParams extends CAINpcTacticTreeParams
{
	editable var minStrafeDist : float;
	editable var maxStrafeDist : float;
	editable var minFarStrafeDist : float;
	editable var maxFarStrafeDist : float;
	
	function Init()
	{
		super.Init();
		minStrafeDist = 3.f;
		maxStrafeDist = 5.f;
		minFarStrafeDist = 8.f;
		maxFarStrafeDist = 12.f;
	}
};

// CAINpcSorcererTacticTree
class CAINpcSorcererTacticTree extends CAINpcRangedTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_sorcerer";
	
	function Init()
	{
		params = new CAINpcSorcererTacticTreeParams in this;
		params.OnCreated();
	}
};
// CAINpcSorcererTacticTreeParams
class CAINpcSorcererTacticTreeParams extends CAINpcTacticTreeParams
{
	editable var minStrafeDist : float;
	editable var maxStrafeDist : float;
	editable var minFarStrafeDist : float;
	editable var maxFarStrafeDist : float;
	
	function Init()
	{
		super.Init();
		minStrafeDist = 3.f;
		maxStrafeDist = 5.f;
		minFarStrafeDist = 8.f;
		maxFarStrafeDist = 12.f;
	}
};

// CAINpcEredinTacticTree
class CAINpcEredinTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_eredin";

	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};

// CAINpcEredinTESTTacticTree
class CAINpcEredinTESTTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_eredin_test";

	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};

// CAINpcImlerithTacticTree
class CAINpcImlerithTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_imlerith";

	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};

// CAINpcImlerithSecondStageTacticTree
class CAINpcImlerithSecondStageTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_imlerith_second_stage";

	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};

// CAINpcCaranthirTacticTree
class CAINpcCaranthirTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_caranthir";
	
	editable var Phase1 			: bool;
	editable var Phase2 			: bool;

	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};

// CAINpcCaretakerTacticTree
class CAINpcCaretakerTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_caretaker_logic";

	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};

// CAINpcPhilippaTacticTree
class CAINpcPhilippaTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_philippa";
	
	function Init()
	{
		params = new CAINpcSorceressTacticTreeParams in this;
		params.OnCreated();
	}
};

// CAINpcOlgierdTacticTree
class CAINpcOlgierdTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\combat\npc_tactic_olgierd";
	
	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};

// CAINpcDettlaffVampireTacticTree
class CAINpcDettlaffVampireTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\monsters/monster_dettlaff_vampire_logic";
	
	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};
// CAINpcDettlaffMinionTacticTree
class CAINpcDettlaffMinionTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\monsters/monster_dettlaff_minion_logic";
	
	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};

// CAINpcGregoireTacticTree
class CAINpcGregoireTacticTree extends CAINpcCustomTacticTree
{
	default aiTreeName = "resdef:ai\monsters/npc_tactic_gregoire";
	
	function Init()
	{
		params = new CAINpcTacticTreeParams in this;
		params.OnCreated();
	}
};

//-----------------------------------------------------------------------------------------------------
class CAINpcCombatRetreatActionTree extends CAICombatActionTree 
{
	default aiTreeName = "resdef:ai\combat\npc_combataction_retreat";
}

//-----------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
class CAINpcPreCombatWarningActionTree extends CAICombatActionTree 
{
	default aiTreeName = "resdef:ai\combat\npc_combataction_precombatwarning";
}

//-----------------------------------------------------------------------------------------------------

////////////////////////////////////////////////////////
// CAINpcFormationTacticTree
class CAINpcFormationTacticTree extends CAISubTree //make this class abstract when there will more than 1 formation tactic
{
	default aiTreeName = "resdef:ai\combat\npc_formation_tactic_base";
	
	editable inlined var params : CAINpcFormationTacticTreeParams;
	
	
	function Init()
	{
		params = new CAINpcFormationTacticTreeParams in this;
		params.OnCreated();
	}
};
// CAINpcFormationTacticTreeParams
class CAINpcFormationTacticTreeParams extends CAISubTreeParameters
{
	editable inlined var formationFollowerAttackAction 	: CAIAttackActionTree;
	editable inlined var formationLeaderAttackBehavior 	: CAIAttackBehaviorTree;
	
	function Init()
	{
		formationFollowerAttackAction = new CAIBasicAttackActionTree in this;
		formationFollowerAttackAction.OnCreated();
		
		formationLeaderAttackBehavior = new CAIAttackBehaviorTree in this;
		formationLeaderAttackBehavior.OnCreated();
	}
};

//-----------------------------------------------------------------------------------------------------

/////////////////////////////////////////////////////////
// CAIAttackBehaviorTree
class CAIAttackBehaviorTree extends CAICombatActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackbehavior";

	editable inlined var params : CAIAttackBehaviorTreeParams;
	
	function Init()
	{
		params = new CAIAttackBehaviorTreeParams in this;
		params.OnCreated();
	}
};
// CAIAttackBehaviorTreeParams
class CAIAttackBehaviorTreeParams extends CAICombatActionParameters
{
	editable inlined var chargeAction 	: bool;
	editable inlined var approachAction : bool;
	editable inlined var throwBomb 		: bool;
	editable inlined var teleportAction : bool;
	
	editable inlined var attackAction : CAIAttackActionTree;
	editable inlined var attackActionRange : name;
	editable inlined var farAttackAction : CAIAttackActionTree;
	editable inlined var farAttackActionRange : name;
	
	function Init()
	{
		attackAction = new CAIBasicAttackActionTree in this;
		attackAction.OnCreated();
		
		attackActionRange = 'rangeNormal';
		farAttackActionRange = 'rangeFar';
	}
};

//-----------------------------------------------------------------------------------------------------

/////////////////////////////////////////////////////////////////
// CAISpecialAttackTree
abstract class CAISpecialAction extends CAISubTree
{
	var params : CAISpecialActionParams;
	
	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAISpecialActionParams extends CAISubTreeParameters
{
	
};

class CAIDwimeritiumBombSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_throw_dwimeritium";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class CAIAttachEntitiesSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_attach_entities";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIDisperseAttachedEntitiesSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_disperse_attached_entities";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// main
class CAIMagicGroundBlastSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_magic_ground_blast";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicPushSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_magic_push";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// ep1
class CAIMagicSandGroundBlastSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_mage_ground_blast";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// ep2
class CAIMagicSandGroundBlastSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_mage_ground_blast_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// ep2
class CAIMagicWaterGroundBlastSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_water_mage_ground_blast_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// ep1
class CAIMagicSandPushSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_mage_push";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// ep2
class CAIMagicSandPushSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_mage_push_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// ep2
class CAIMagicWaterPushSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_water_mage_push_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicRootAttackSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_root";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// ep1
class CAIMagicTornadoSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_tornado";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// ep2
class CAIMagicTornadoSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_tornado_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// ep2
class CAIMagicWaterTornadoSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_water_tornado_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicWindCoilSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_wind_coil";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// ep2
class CAIMagicWindCoilSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_wind_coil_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// ep2
class CAIMagicWaterCoilSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_water_coil_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicWindGustSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_wind_gust";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicWindGustSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_wind_gust_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicSandCageSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_sand_cage";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// ep2
class CAIMagicWaterCageSpecialAction extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_water_cage_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIMagicSandCageSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_sand_cage_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// ep1
class CAIMagicShieldSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_magic_shield";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// ep2
class CAIMagicShieldSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_magic_shield_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};
// ep2
class CAIWaterMagicShieldSpecialActionBob extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_water_magic_shield_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIShootAttachedEntitiesSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_shoot_attached_entities";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIShootProjectilesFromGroundSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_shoot_projectiles_from_ground";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAILynxWitchShootProjectilesFromGroundSpecialAction extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_shoot_projectiles_from_ground_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class CAICastRipApartSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_rip_apart";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAICastFireballSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_fireball";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAICastLightningSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_lightning";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAILynxWitchCastLightningSpecialAction extends CAISpecialAction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\npc_special_cast_lightning_bob.w2behtree";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIShootBarrelsSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_shoot_barrels";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAICastArcaneMissileSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_arcane_missile";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAICastArcaneExplosionSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_cast_arcane_explosion";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

class CAIShadowDashSpecialAction extends CAISpecialAction
{
	default aiTreeName = "resdef:ai\combat\npc_special_shadow_dash";

	function Init()
	{
		params = new CAISpecialActionParams in this;
		params.OnCreated();
	}
};

//-----------------------------------------------------------------------------------------------------

//////////////////////////////////////////////////////////////////
// CAIAttackActionTree
abstract class CAIAttackActionTree extends CAICombatActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_basic";
	editable inlined var params : CAIAttackActionTreeParams;
	function Init()
	{
		params = new CAIAttackActionTreeParams in this;
		params.OnCreated();
	}
};
// CAIAttackActionTreeParams
class CAIAttackActionTreeParams extends CAICombatActionParameters
{
	function Init()
	{
	}
};

///////////////////////////////////////////////////////////////////
// CAISimpleAttackActionTree
class CAISimpleAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_simple";
	function Init()
	{
		super.Init();
		params = new CAISimpleAttackActionTreeParams in this;
		params.OnCreated();
	}
};
// CAIBasicAttackActionTreeParams
class CAISimpleAttackActionTreeParams extends CAIAttackActionTreeParams
{
};

///////////////////////////////////////////////////////////////////
// CAIBasicAttackActionTree
class CAIBasicAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_basic";
	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};
// CAIBasicAttackActionTreeParams
class CAIBasicAttackActionTreeParams extends CAIAttackActionTreeParams
{
};
////////////////////////////////////////////////////////////////
// CAIComboAttackActionTree

/*class CAIComboAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_combo";
	
	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};*/

class CAIFistAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_fists";
	
	var easyVersion : bool;
	
	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
		easyVersion = true;
	}
};

class CAIComboFistAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_fists_combos";
	
	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};

class CAISword2hAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_sword2h";

	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};



class CAITwoHandedAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_twohanded";

	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};

class CAIPitchforkAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_pitchfork";

	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};

class CAIWitcherAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_witcher";

	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};

class CAICiriAttackActionTree extends CAIAttackActionTree
{
	default aiTreeName = "resdef:ai\combat\npc_attackaction_ciri";

	function Init()
	{
		super.Init();
		params = new CAIBasicAttackActionTreeParams in this;
		params.OnCreated();
	}
};
