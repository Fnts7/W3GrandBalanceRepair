/***********************************************************************/
/** 
/***********************************************************************/

////////////////////////////////////////////////////////////
// Combat
////////////////////////////////////////////////////////////
class CAINpcCombat extends CAICombatTree
{
	default aiTreeName = "resdef:ai\npc_basecombat";

	editable inlined var params : CAINpcCombatParams;
	
	function Init()
	{
		params = new CAINpcCombatParams in this;
		params.OnCreated();
	}
}
/*
enum ECombatTargetSelectionSkipTarget
{
	CTSST_SKIP_ALWAYS,
	CTSST_SKIP_IF_THERE_ARE_OTHER_TARGETS,
	CTSST_DONT_SKIP,
};
*/
//------------------------------------------------------------
class CAINpcCombatParams extends CAICombatParameters
{
	editable var scaredCombat : bool;
	editable inlined var scaredBranch  : CAIScaredSubTree;
	editable inlined var combatStyles : array<CAINpcCombatStyle>;
	editable inlined var criticalState : CAINpcCriticalState;
	
	editable var preferedCombatStyle : EBehaviorGraph;
	editable var increaseHitCounterOnlyOnMelee : bool;
	
	default increaseHitCounterOnlyOnMelee = true;
	
	//editable var potentialFollower : bool;		default potentialFollower = false;
	
	// combat target selection params
	editable var reachabilityTolerance : float;
	editable var targetOnlyPlayer : bool;
	editable var hostileActorWeight : float;
	editable var currentTargetWeight : float;
	editable var rememberedHits : int;
	editable var hitterWeight : float;
	editable var maxWeightedDistance : float;
	editable var distanceWeight : float;
	editable var playerWeightProbability : int;
	editable var playerWeight : float;
	editable var skipVehicle : ECombatTargetSelectionSkipTarget;
	editable var skipVehicleProbability : int;
	editable var skipUnreachable : ECombatTargetSelectionSkipTarget;
	editable var skipUnreachableProbability : int;
	editable var monsterWeight : float;
	
	//this is a base value. It is added to every potential target
	default	hostileActorWeight 	= 10.0f;
	
	default reachabilityTolerance = 2.0f;
	
	default	hitterWeight 		= 20.0f; //	>= playerWeight + currentTargetWeight
	default	currentTargetWeight = 9.0f;  // 
	default	playerWeight		= 100.0f; // i will target notPlayer when potentialTarget is playerWeight[meters] closer
	
	
	//both values the same will give us 1 point per meter
	//if every potentialTarget is above maxWeightedDistance player will be selected as target for sure.
	default	distanceWeight 		= 30.0f;
	default maxWeightedDistance = 30.0f;
	
	default monsterWeight		= 101.0f;
		
	//other flags
	default	targetOnlyPlayer = false;
	default	playerWeightProbability = 100;
	default rememberedHits = 2;

	//targetting vehicles ( horses )
	default skipVehicle 		   = CTSST_SKIP_ALWAYS;
	default	skipVehicleProbability = 100;		
	
	// unreachable (by navitagtion) targets
	default skipUnreachable 		   	= CTSST_SKIP_IF_THERE_ARE_OTHER_TARGETS;
	default	skipUnreachableProbability	= 100;
	
	function Init()
	{		
		SetupCombatStyles();
		
		scaredBranch = new CAIScaredTree in this;
		scaredBranch.OnCreated();
		
		criticalState = new CAINpcCriticalState in this;
		criticalState.OnCreated();
		criticalState.params.FinisherAnim 		= 'HumanKnockDownFinisher';
	}
	
	protected function SetupCombatStyles()
	{
		combatStyles.Clear();
	}
	
	protected function SetupCSFinisherAnims()
	{
		
	}
	
	protected function ClearCSFinisherAnims()
	{
		criticalState.params.FinisherAnim = '';		
	}
	
	public function InitializeCombatStyles()
	{
		var i : int;
		
		for ( i = 0; i < combatStyles.Size(); i+=1 )
		{
			combatStyles[ i ].OnCreated();
		}
	}
}

//////////////////////////////////////////////////////////////
// Fists
//////////////////////////////////////////////////////////////
class CAINpcFistsDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcFistsCombat in this;
		combatTree.OnCreated();
		
		deathTree = new CAIDefeated in this;
		deathTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcFistsCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcFistsCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcFistsCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// FistsEasy
//////////////////////////////////////////////////////////////
class CAINpcFistsEasyDefaults extends CAINpcFistsDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcFistsEasyCombat in this;
		combatTree.OnCreated();
		
		deathTree = new CAIDefeated in this;
		deathTree.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcFistsEasyCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcFistsEasyCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcFistsEasyCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcFistsEasyCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// FistsHard
//////////////////////////////////////////////////////////////
class CAINpcFistsHardDefaults extends CAINpcFistsDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcFistsHardCombat in this;
		combatTree.OnCreated();
		
		deathTree = new CAIDefeated in this;
		deathTree.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcFistsHardCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcFistsHardCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcFistsHardCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcFistsHardCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// Guard
//////////////////////////////////////////////////////////////
class CAINpcGuardDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcGuardCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcGuardCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcGuardCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcGuardCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTwoHandedAnyCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcOneHandedAnyCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// OneHanded
//////////////////////////////////////////////////////////////
class CAINpcOneHandedDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcOneHandedCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcOneHandedCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcOneHandedCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcOneHandedCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcOneHandedSwordCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// OneHandedAxe
//////////////////////////////////////////////////////////////
class CAINpcOneHandedAxeDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcOneHandedAxeCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcOneHandedAxeCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcOneHandedAxeCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcOneHandedAxeCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcOneHandedAxeCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// OneHandedBlunt
//////////////////////////////////////////////////////////////
class CAINpcOneHandedBluntDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcOneHandedBluntCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcOneHandedBluntCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcOneHandedBluntCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcOneHandedBluntCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcOneHandedBluntCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// TwoHandedHammer
//////////////////////////////////////////////////////////////
class CAINpcTwoHandedHammerDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcTwoHandedHammerCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcTwoHandedHammerCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcTwoHandedHammerCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcTwoHandedHammerCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTwoHandedHammerCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// TwoHandedAxe
//////////////////////////////////////////////////////////////
class CAINpcTwoHandedAxeDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcTwoHandedAxeCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcTwoHandedAxeCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcTwoHandedAxeCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcTwoHandedAxeCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTwoHandedAxeCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// TwoHandedHalberd
//////////////////////////////////////////////////////////////
class CAINpcTwoHandedHalberdDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcTwoHandedHalberdCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcTwoHandedHalberdCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcTwoHandedHalberdCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcTwoHandedHalberdCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTwoHandedHalberdCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// TwoHandedSpear
//////////////////////////////////////////////////////////////
class CAINpcTwoHandedSpearDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcTwoHandedSpearCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcTwoHandedSpearCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcTwoHandedSpearCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcTwoHandedSpearCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTwoHandedSpearCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// Pitchfork
//////////////////////////////////////////////////////////////
class CAINpcPitchforkDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcPitchforkCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcPitchforkCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcPitchforkCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcPitchforkCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcPitchforkCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// Shield
//////////////////////////////////////////////////////////////
class CAINpcShieldDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcShieldCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcShieldCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcShieldCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcShieldCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcShieldCombatStyle in this );
		combatStyles.PushBack( new CAINpcOneHandedAnyCombatStyle in this );
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this );
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// Bow
//////////////////////////////////////////////////////////////
class CAINpcBowDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcBowCombat in this;
		combatTree.Init();
	}
};
//------------------------------------------------------------
class CAINpcBowCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcBowCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcBowCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcBowCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcBowmanMeleeCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
		
		preferedCombatStyle = EBG_Combat_Bow;
	}
}

//////////////////////////////////////////////////////////////
// Crossbow
//////////////////////////////////////////////////////////////
class CAINpcCrossbowDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcCrossbowCombat in this;
		combatTree.Init();
	}
};
//------------------------------------------------------------
class CAINpcCrossbowCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcCrossbowCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcCrossbowCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcCrossbowCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcBowmanMeleeCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
		
		preferedCombatStyle = EBG_Combat_Crossbow;
	}
}

//////////////////////////////////////////////////////////////
// TwoHandedSword
//////////////////////////////////////////////////////////////
class CAINpcTwoHandedSwordDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcTwoHandedSwordCombat in this;
		combatTree.Init();
	}
};
//------------------------------------------------------------
class CAINpcTwoHandedSwordCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcTwoHandedSwordCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcTwoHandedSwordCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTwoHandedSwordCombatStyle in this );  
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
		
		preferedCombatStyle = EBG_Combat_2Handed_Sword;
	}
}

//////////////////////////////////////////////////////////////
// Gregoire
//////////////////////////////////////////////////////////////
class CAINpcGregoireDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcGregoireCombat in this;
		combatTree.Init();
	}
};
//------------------------------------------------------------
class CAINpcGregoireCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcGregoireCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcGregoireCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcGregoireCombatStyle in this );  	
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// Hjalmar
//////////////////////////////////////////////////////////////
class CAIHjalmarDefaults extends CAINpcDefaults
{
	function Init()
	{
		var hjalmarStyle : CAINpcCombatStyle;
		super.OnCreated();
		combatTree.params.combatStyles.Clear();
		hjalmarStyle = new CAINpcCombatStyle in this;
		hjalmarStyle.OnCreated();
		hjalmarStyle.params = new CAINpcStyleHjalmarParams in this;
		hjalmarStyle.params.OnCreated();
		combatTree.params.combatStyles.PushBack(hjalmarStyle);
		hjalmarStyle = new CAINpcCombatStyle in this;
		hjalmarStyle.OnCreated();
		hjalmarStyle.params = new CAINpcStyleFistsHardParams in this;
		hjalmarStyle.params.OnCreated();
		combatTree.params.combatStyles.PushBack(hjalmarStyle);
	}
};

//////////////////////////////////////////////////////////////
// Witcher
//////////////////////////////////////////////////////////////
class CAINpcWitcherDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcWitcherCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcWitcherCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcWitcherCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcWitcherCombatParams extends CAINpcCombatParams
{
	protected function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcWitcherCombatStyle in this ); 
		combatStyles.PushBack( new CAINpcFistsCombatStyle in this ); 		
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// Eredin
//////////////////////////////////////////////////////////////
class CAINpcEredinDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcEredinCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcEredinCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcEredinCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcEredinCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcEredinCombatStyle in this ); 	
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// Imlerith
//////////////////////////////////////////////////////////////
class CAINpcImlerithDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcImlerithCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcImlerithCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcImlerithCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcImlerithCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcImlerithCombatStyle in this ); 		
		combatStyles.PushBack( new CAINpcImlerithSecondStageCombatStyle in this );
		
		InitializeCombatStyles();
		
	}
}


//////////////////////////////////////////////////////////////
// Caranthir
//////////////////////////////////////////////////////////////
class CAINpcCaranthirDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcCaranthirCombat in this;
		combatTree.OnCreated();
		
	}
};
//------------------------------------------------------------
class CAINpcCaranthirCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcCaranthirCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcCaranthirCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcCaranthirCombatStyle in this ); 
		increaseHitCounterOnlyOnMelee = false;
		LogEffects( "increaseHitCounterOnlyOnMelee " + increaseHitCounterOnlyOnMelee);
		
		InitializeCombatStyles();
		
	}
}

//////////////////////////////////////////////////////////////
// Caretaker
//////////////////////////////////////////////////////////////
class CAINpcCaretakerDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcCaretakerCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcCaretakerCombat extends CAINpcCombat
{		
	
	function Init()
	{
		params = new CAINpcCaretakerCombatParams in this;
		params.OnCreated();		
	}
	
}
//------------------------------------------------------------
class CAINpcCaretakerCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcCaretakerCombatStyle in this ); 
		increaseHitCounterOnlyOnMelee = false;
		
		InitializeCombatStyles();		
	}
}

//////////////////////////////////////////////////////////////
// WitcherFollower
//////////////////////////////////////////////////////////////
class CAINpcWitcherFollowerDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcWitcherFollowerCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcWitcherFollowerCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcWitcherFollowerCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcWitcherFollowerCombatParams extends CAINpcWitcherCombatParams
{
	var i : int;
	
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		super.SetupCombatStyles();
		
		combatStyles[0].params.combatTacticTree.params.specialActions.PushBack( new CAIDwimeritiumBombSpecialAction in combatStyles[0].params.combatTacticTree.params );
		combatStyles[0].params.combatTacticTree.params.InitializeSpecialActions();
		
		for ( i=0 ; i<combatStyles.Size() ; i+=1 )
		{
			combatStyles[i].params.potentialFollower = true;
		}
	}
}

//////////////////////////////////////////////////////////////
// Ciri
//////////////////////////////////////////////////////////////
class CAINpcCiriDefaults extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcCiriCombat in this;
		combatTree.OnCreated();
	}
};
//------------------------------------------------------------
class CAINpcCiriCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcCiriCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcCiriCombatParams extends CAINpcCombatParams
{
	var i : int;
	
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcCiriCombatStyle in this );		
		
		InitializeCombatStyles();
		
		for ( i=0 ; i<combatStyles.Size() ; i+=1 )
		{
			combatStyles[i].params.potentialFollower = true;
		}
	}
}

//////////////////////////////////////////////////////////////
// Sorceress
//////////////////////////////////////////////////////////////
abstract class CAINpcSorceressDefaults extends CAINpcDefaults
{
};

class CAINpcYenneferDefaults extends CAINpcSorceressDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcYenneferCombat in this;
		combatTree.Init();
	}
};

class CAINpcTrissDefaults extends CAINpcSorceressDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcTrissCombat in this;
		combatTree.Init();
	}
};

class CAINpcKeiraDefaults extends CAINpcSorceressDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcKeiraCombat in this;
		combatTree.Init();
	}
};

class CAINpcPhilippaDefaults extends CAINpcSorceressDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcPhilippaCombat in this;
		combatTree.Init();
		reactionTree = new CAIPhilippaReactionsTree in this;
		reactionTree.Init();
	}
};

class CAINpcLynxWitchDefaults extends CAINpcSorceressDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcLynxWitchCombat in this;
		combatTree.Init();
	}
};

//------------------------------------------------------------
/*class CAINpcSorceressCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcSorceressCombatParams in this;
		params.OnCreated();
	}
}*/
class CAINpcYenneferCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcYenneferCombatParams in this;
		params.OnCreated();
	}
}
class CAINpcTrissCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcTrissCombatParams in this;
		params.OnCreated();
	}
}
class CAINpcKeiraCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcKeiraCombatParams in this;
		params.OnCreated();
	}
}
class CAINpcPhilippaCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcPhilippaCombatParams in this;
		params.OnCreated();
	}
}
class CAINpcLynxWitchCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcLynxWitchCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcSorceressCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		var i : int;
		
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcSorceressCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}
class CAINpcYenneferCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcYenneferCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}
class CAINpcTrissCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTrissCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}
class CAINpcKeiraCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcKeiraCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}

class CAINpcPhilippaCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcPhilippaCombatStyle in this );
		combatStyles.PushBack( new CAINpcPhilippaCustomCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}

class CAINpcLynxWitchCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcLynxWitchCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// Sorcerers
//////////////////////////////////////////////////////////////
abstract class CAINpcSorcererDefaults extends CAINpcDefaults
{
};

class CAINpcDruidDefaults extends CAINpcSorcererDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcDruidCombat in this;
		combatTree.Init();
	}
};

class CAINpcDruidCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcDruidCombatParams in this;
		params.OnCreated();
	}
}
// ep1
class CAINpcWindMageDefaults extends CAINpcSorcererDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcWindMageCombat in this;
		combatTree.Init();
	}
};
// ep1
class CAINpcWindMageCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcWindMageCombatParams in this;
		params.OnCreated();
	}
}

// ep2
class CAINpcBobWindMageDefaults extends CAINpcSorcererDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcBobWindMageCombat in this;
		combatTree.Init();
	}
};
// ep2
class CAINpcBobWindMageCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcBobWindMageCombatParams in this;
		params.OnCreated();
	}
}

// ep2
class CAINpcBobWaterMageDefaults extends CAINpcSorcererDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcBobWaterMageCombat in this;
		combatTree.Init();
	}
};
// ep2
class CAINpcBobWaterMageCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcBobWaterMageCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcAvallachDefaults extends CAINpcSorcererDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcAvallachCombat in this;
		combatTree.Init();
	}
};

class CAINpcAvallachCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcAvallachCombatParams in this;
		params.OnCreated();
	}
}

//------------------------------------------------------------
class CAINpcSorcererCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		var i : int;
		
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcSorcererCombatStyle in this );		
		
		InitializeCombatStyles();
	}
};

class CAINpcDruidCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcDruidCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}

class CAINpcWindMageCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcWindMageCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}

class CAINpcBobWindMageCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcWindMageCombatStyleBob in this );		
		
		InitializeCombatStyles();
	}
}

class CAINpcBobWaterMageCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcWaterMageCombatStyleBob in this );		
		
		InitializeCombatStyles();
	}
}

class CAINpcAvallachCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcAvallachCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}


//////////////////////////////////////////////////////////////
//Main NPC
abstract class CAINpcMainDefaults extends CAINpcDefaults
{
}

//////////////////////////////////////////////////////////////
//Iorwveth
class CAINpcIorwvethDefaults extends CAINpcMainDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcBowCombat in this;
		combatTree.Init();
		combatTree.params.preferedCombatStyle = EBG_Combat_1Handed_Any;
	}
};

//////////////////////////////////////////////////////////////
//Zoltan
class CAINpcZoltanDefaults extends CAINpcMainDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcZoltanCombat in this;
		combatTree.Init();
		combatTree.params.preferedCombatStyle = EBG_Combat_2Handed_Axe;
	}
};

class CAINpcZoltanCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcZoltanCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcZoltanCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcTwoHandedAxeCombatStyle in this );		
		combatStyles.PushBack( new CAINpcOneHandedBluntCombatStyle in this );		
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// Ves
class CAINpcVesDefaults extends CAINpcMainDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcVesCombat in this;
		combatTree.Init();
	}
};

class CAINpcVesCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcVesCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcVesCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcOneHandedSwordCombatStyle in this );		
		combatStyles.PushBack( new CAINpcBowCombatStyle in this );		
		
		InitializeCombatStyles();
		
		combatStyles[1].params.combatTacticTree.params.specialActions.PushBack( new CAIShootBarrelsSpecialAction in combatStyles[1].params.combatTacticTree.params );
		combatStyles[1].params.combatTacticTree.params.InitializeSpecialActions();
		
		preferedCombatStyle = EBG_Combat_1Handed_Sword;
	}
}


//////////////////////////////////////////////////////////////
// Roche
class CAINpcRocheDefaults extends CAINpcMainDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcRocheCombat in this;
		combatTree.Init();
	}
};

class CAINpcRocheCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcRocheCombatParams in this;
		params.OnCreated();
	}
}

class CAINpcRocheCombatParams extends CAINpcCombatParams
{
	function Init()
	{
		super.Init();
		
		ClearCSFinisherAnims();
	}
	
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcOneHandedSwordCombatStyle in this );		
		combatStyles.PushBack( new CAINpcCrossbowCombatStyle in this );
		
		InitializeCombatStyles();
		
		combatStyles[1].params.combatTacticTree.params.specialActions.PushBack( new CAIShootBarrelsSpecialAction in combatStyles[1].params.combatTacticTree.params );
		combatStyles[1].params.combatTacticTree.params.InitializeSpecialActions();
		
		preferedCombatStyle = EBG_Combat_1Handed_Sword;
	}
}

//////////////////////////////////////////////////////////////
// Olgierd
//////////////////////////////////////////////////////////////
class CAINpcOlgierdCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcOlgierdCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcOlgierdCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcOlgierdCombatStyle in this ); 	
		
		InitializeCombatStyles();
	}
}

//////////////////////////////////////////////////////////////
// Dettlaff Vampire
//////////////////////////////////////////////////////////////
class CAINpcDettlaffVampireCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcDettlaffVampireCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcDettlaffVampireCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcDettlaffVampireCombatStyle in this ); 	
		
		InitializeCombatStyles();
	}
}
//////////////////////////////////////////////////////////////
// Dettlaff Minion
//////////////////////////////////////////////////////////////
class CAINpcDettlaffMinion extends CAINpcDefaults
{
	function Init()
	{
		super.Init();
		
		combatTree = new CAINpcDettlaffMinionCombat in this;
		combatTree.OnCreated();
		
		deathTree = new CAIDettlaffMinionDeath in this;
		deathTree.OnCreated();
	}
};
class CAIDettlaffMinionDeath extends CAIDeathTree
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\monster_dettlaff_minion_death.w2behtree";

	editable inlined var params : CAINpcDeathParams;
	
	function Init()
	{
		params = new CAINpcDeathParams in this;
		params.OnCreated();
	}
};
class CAINpcDettlaffMinionCombat extends CAINpcCombat
{	
	function Init()
	{
		params = new CAINpcDettlaffMinionCombatParams in this;
		params.OnCreated();
	}
}
//------------------------------------------------------------
class CAINpcDettlaffMinionCombatParams extends CAINpcCombatParams
{
	private function SetupCombatStyles()
	{
		combatStyles.Clear();
		combatStyles.PushBack( new CAINpcDettlaffMinionCombatStyle in this ); 	
		
		InitializeCombatStyles();
	}
}