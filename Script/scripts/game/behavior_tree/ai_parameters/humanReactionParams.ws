/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SOFT REACTIONS:
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// Combat Soft Reaction Tree
class CAICombatSoftReactionsTree extends CAISoftReactionTree
{
	default aiTreeName = "resdef:ai\reactions/soft_reactions_combat";
};

// Commoner Soft Reaction Tree
class CAICommonerSoftReactionsTree extends CAISoftReactionTree
{
	default aiTreeName = "resdef:ai\reactions/soft_reactions_commoner";
};

// Guard Soft Reaction Tree
class CAIGuardSoftReactionsTree extends CAISoftReactionTree
{
	default aiTreeName = "resdef:ai\reactions/soft_reactions_guard";
};

// Quest Soft Reaction Tree
class CAIQuestSoftReactionsTree extends CAISoftReactionTree
{
	default aiTreeName = "resdef:ai\reactions/soft_reactions_quest";
};

// MainQuest Soft Reaction Tree
class CAIMainQuestSoftReactionsTree extends CAISoftReactionTree
{
	default aiTreeName = "resdef:ai\reactions/soft_reactions_quest_main";
};

// Child Soft Reaction Tree
class CAIChildSoftReactionsTree extends CAISoftReactionTree
{
	default aiTreeName = "resdef:ai\reactions/soft_reactions_child";
};

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// HARD REACTIONS:
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Base Reaction Tree
class CAINpcReactionsTree extends CAIReactionTree
{
	default aiTreeName = "resdef:ai\reactions/npc_base_reactions";

	//editable var reactionCounterName : CName;
	//editable var reactionCounterLowerBound : int;
	//editable var reactionCounterUpperBound : int;
	editable inlined var reactions : array< CAINpcActionSubtree >;
	
	protected function OverriderReactionsPriority( priority : int, optional priorityWhileActive : int )
	{
		var i : int;
		
		for ( i=0 ; i < reactions.Size() ; i+=1 )
		{
			reactions[i].reactionPriority = priority;
			if ( priorityWhileActive > 0 )
			{
				reactions[i].changePriorityWhileActive = true;
				reactions[i].reactionPriorityWhileActive = priorityWhileActive;
			}
		}
	}
};



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// REACTION TREES:
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Commoner Reactions Tree
class CAICommonerReactionTree extends CAINpcReactionsTree
{
	function Init()
	{
		var beingHit		: CAIActionBeingHit			= new CAIActionBeingHit in this;
		var bump			: CAIActionBumpTree 		= new CAIActionBumpTree in this;
		var rain			: CAIActionRain 			= new CAIActionRain in this;
		var taunt			: CAIActionTaunt 			= new CAIActionTaunt in this;
		var drawSword		: CAIActionDrawSword 		= new CAIActionDrawSword in this;
		var attack			: CAIActionAttack 			= new CAIActionAttack in this;
		var castSign		: CAIActionCastSign 		= new CAIActionCastSign in this;
		var crossbowShot 	: CAIActionCrossbowShot 	= new CAIActionCrossbowShot in this;
		var bombExplosion 	: CAIActionBombExplosion 	= new CAIActionBombExplosion in this;
		var combatNearby 	: CAIActionCombatNearby 	= new CAIActionCombatNearby in this;	
		var gossip		 	: CAIActionGossip 			= new CAIActionGossip in this;
		var question 		: CAIActionQuestion 		= new CAIActionQuestion in this;
		//var greeting 		: CAIActionGreeting 		= new CAIActionGreeting in this;
		var barter 			: CAIActionBarter			= new CAIActionBarter in this;
		var jump 			: CAIActionJump				= new CAIActionJump in this;

		beingHit		.OnCreated();
		bump			.OnCreated();
		rain			.OnCreated();
		taunt			.OnCreated();
		drawSword		.OnCreated();
		attack			.OnCreated();
		castSign		.OnCreated();
		crossbowShot	.OnCreated();
		bombExplosion	.OnCreated();
		combatNearby	.OnCreated();
		gossip			.OnCreated();
		question		.OnCreated();
		//greeting		.OnCreated();
		barter			.OnCreated();
		jump			.OnCreated();
		
		taunt.forwardAvailabilityToReactionTree = true;
		attack.forwardAvailabilityToReactionTree = true;
		castSign.forwardAvailabilityToReactionTree = true;
		crossbowShot.forwardAvailabilityToReactionTree = true;
		bombExplosion.forwardAvailabilityToReactionTree = true;
		combatNearby.forwardAvailabilityToReactionTree = true;
		
		reactions.PushBack( beingHit );
		reactions.PushBack( bump );
		reactions.PushBack( rain );
		reactions.PushBack( drawSword );
		reactions.PushBack( taunt );
		reactions.PushBack( attack );
		reactions.PushBack( castSign );
		reactions.PushBack( crossbowShot );
		reactions.PushBack( bombExplosion );
		reactions.PushBack( combatNearby );
		reactions.PushBack( gossip );
		reactions.PushBack( question );
		//reactions.PushBack( greeting );
		reactions.PushBack( barter );
		reactions.PushBack( jump );
	}
}

// Commoner Reactions Tree
class CAIChildReactionTree extends CAINpcReactionsTree
{
	function Init()
	{
		var beingHit		: CAIActionBeingHit			= new CAIActionBeingHit in this;
		var bump			: CAIActionBumpTree 		= new CAIActionBumpTree in this;
		var rain			: CAIActionRain 			= new CAIActionRain in this;
		var taunt			: CAIActionTaunt 			= new CAIActionTaunt in this;
		var drawSword		: CAIActionDrawSword 		= new CAIActionDrawSword in this;
		var attack			: CAIActionAttack 			= new CAIActionAttack in this;
		var castSign		: CAIActionCastSign 		= new CAIActionCastSign in this;
		var crossbowShot 	: CAIActionCrossbowShot 	= new CAIActionCrossbowShot in this;
		var bombExplosion 	: CAIActionBombExplosion 	= new CAIActionBombExplosion in this;
		var combatNearby 	: CAIActionCombatNearby 	= new CAIActionCombatNearby in this;
		
		var tempOverride : CAINpcActionSubtree;
		
		beingHit		.OnCreated();
		bump			.OnCreated();
		rain			.OnCreated();
		taunt			.OnCreated();
		drawSword		.OnCreated();
		attack			.OnCreated();
		castSign		.OnCreated();
		crossbowShot	.OnCreated();
		bombExplosion	.OnCreated();
		combatNearby	.OnCreated();
		
		reactions.PushBack( beingHit );			//0
		reactions.PushBack( bump );				//1
		reactions.PushBack( rain );				//2
		reactions.PushBack( drawSword );		//3
		reactions.PushBack( taunt );			//4
		reactions.PushBack( attack );			//5
		reactions.PushBack( castSign );			//6
		reactions.PushBack( crossbowShot );		//7
		reactions.PushBack( bombExplosion );	//8
		reactions.PushBack( combatNearby );		//9
		
		// overrides
		tempOverride = (CAINpcActionSubtree)reactions[3];
		tempOverride.reactionLogicTree = new CAINpcReactionGetScared in this;
		tempOverride.reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(10.f,false);
		
		tempOverride = (CAINpcActionSubtree)reactions[4];
		tempOverride.reactionLogicTree = new CAINpcReactionGetScared in this;
		tempOverride.reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(10.f,false);
		
		tempOverride = (CAINpcActionSubtree)reactions[5];
		tempOverride.reactionLogicTree = new CAINpcReactionGetScared in this;
		tempOverride.reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(10.f,false);
		
		tempOverride = (CAINpcActionSubtree)reactions[6];
		tempOverride.reactionLogicTree = new CAINpcReactionGetScared in this;
		tempOverride.reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(10.f,false);
		
		tempOverride = (CAINpcActionSubtree)reactions[7];
		tempOverride.reactionLogicTree = new CAINpcReactionGetScared in this;
		tempOverride.reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(10.f,false);
		
		tempOverride = (CAINpcActionSubtree)reactions[8];
		tempOverride.reactionLogicTree = new CAINpcReactionGetScared in this;
		tempOverride.reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(10.f,false);
		
		tempOverride = (CAINpcActionSubtree)reactions[9];
		tempOverride.reactionLogicTree = new CAINpcReactionGetScared in this;
		tempOverride.reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(10.f,false);
	}
}

// Drunk Commoner Reactions Tree
class CAIDrunkCommonerReactionTree extends CAINpcReactionsTree
{
	function Init()
	{
		var beingHit		: CAIActionBeingHit			= new CAIActionBeingHit in this;
		var crossbowShot 	: CAIActionCrossbowShot 	= new CAIActionCrossbowShot in this;
		var bombExplosion 	: CAIActionBombExplosion 	= new CAIActionBombExplosion in this;

		beingHit		.OnCreated();
		crossbowShot	.OnCreated();
		bombExplosion	.OnCreated();
		
		crossbowShot.forwardAvailabilityToReactionTree = true;
		bombExplosion.forwardAvailabilityToReactionTree = true;
		
		reactions.PushBack( beingHit );;
		reactions.PushBack( crossbowShot );
		reactions.PushBack( bombExplosion );
	}
}

// Guard Reactions Tree
class CAIGuardReactionsTree extends CAINpcReactionsTree
{
	function Init()
	{
		var beingHit		: CAIActionBeingHit			= new CAIActionBeingHit in this;
		var bump			: CAIActionBumpTree 		= new CAIActionBumpTree in this;
		var drawSword		: CAIActionDrawSword 		= new CAIActionDrawSword in this;
		var attack			: CAIActionAttack 			= new CAIActionAttack in this;
		var castSign		: CAIActionCastSign 		= new CAIActionCastSign in this;
		var crossbowShot 	: CAIActionCrossbowShot 	= new CAIActionCrossbowShot in this;
		var bombExplosion 	: CAIActionBombExplosion 	= new CAIActionBombExplosion in this;
		var combatNearby 	: CAIActionCombatNearby 	= new CAIActionCombatNearby in this;
		var looting		 	: CAIActionLooting 			= new CAIActionLooting in this;
		var taunt		 	: CAIActionTaunt 			= new CAIActionTaunt in this;
		var jump 			: CAIActionJump				= new CAIActionJump in this;
		var gossip		 	: CAIActionGossip 			= new CAIActionGossip in this;
		var question 		: CAIActionQuestion 		= new CAIActionQuestion in this;
		//var greeting 		: CAIActionGreeting 		= new CAIActionGreeting in this;
		
		var tempOverride : CAINpcActionSubtree;
		
		beingHit		.OnCreated();
		bump			.OnCreated();
		drawSword		.OnCreated();
		attack			.OnCreated();
		castSign		.OnCreated();
		crossbowShot	.OnCreated();
		bombExplosion	.OnCreated();
		combatNearby	.OnCreated();
		looting			.OnCreated();
		taunt			.OnCreated();
		jump			.OnCreated();
		gossip			.OnCreated();
		question		.OnCreated();
		//greeting		.OnCreated();
		
		reactions.PushBack( beingHit );			// 0
		reactions.PushBack( combatNearby );		// 1
		reactions.PushBack( bump );				// 2
		reactions.PushBack( drawSword );		// 3
		reactions.PushBack( attack );			// 4
		reactions.PushBack( castSign );			// 5
		reactions.PushBack( crossbowShot );		// 6
		reactions.PushBack( bombExplosion );	// 7
		reactions.PushBack( taunt );			// 8
		reactions.PushBack( looting );			// 9		
		
		// overrides
		tempOverride = (CAINpcActionSubtree)reactions[0];
		tempOverride.reactionLogicTree = new CAINpcReactionTurnHostile in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.reactionLogicTree.voiceSet = "afraid";
		((CAINpcReactionTurnHostile)tempOverride.reactionLogicTree).SetParams('BeingHitAction');
		
		tempOverride = (CAINpcActionSubtree)reactions[1];
		tempOverride.reactionLogicTree = new CAINpcReactionJoinFight in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.reactionLogicTree.voiceSet = "afraid";
		tempOverride.disallowWhileOnHorse = true;
		
		tempOverride = (CAINpcActionSubtree)reactions[2];
		tempOverride.reactionLogicTree = new CAINpcReactionBump in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.disallowWhileOnHorse = true;
		
		tempOverride = (CAINpcActionSubtree)reactions[3];
		tempOverride.reactionLogicTree = new CAINpcReactionGuardWarnGeneral in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.forwardAvailabilityToReactionTree = true;
		tempOverride.disallowWhileOnHorse = false;
		
		
		tempOverride = (CAINpcActionSubtree)reactions[4];
		tempOverride.reactionLogicTree = new CAINpcReactionGuardWarnGeneral in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.forwardAvailabilityToReactionTree = true;
		tempOverride.disallowWhileOnHorse = false;
		
		tempOverride = (CAINpcActionSubtree)reactions[5];
		tempOverride.reactionLogicTree = new CAINpcReactionGuardWarnGeneral in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.forwardAvailabilityToReactionTree = true;
		tempOverride.disallowWhileOnHorse = false;
		
		tempOverride = (CAINpcActionSubtree)reactions[6];
		tempOverride.reactionLogicTree = new CAINpcReactionGuardWarnGeneral in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.forwardAvailabilityToReactionTree = true;
		tempOverride.disallowWhileOnHorse = false;
		
		tempOverride = (CAINpcActionSubtree)reactions[7];
		tempOverride.reactionLogicTree = new CAINpcReactionTurnHostile in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.disallowWhileOnHorse = false;
		
		tempOverride = (CAINpcActionSubtree)reactions[8];
		tempOverride.reactionLogicTree = new CAINpcReactionGuardWarnGeneral in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.reactionLogicTree.voiceSet = "afraid";
		tempOverride.forwardAvailabilityToReactionTree = true;
		tempOverride.disallowWhileOnHorse = false;
		
		tempOverride = (CAINpcActionSubtree)reactions[9];
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.reactionLogicTree.voiceSet = "afraid";
		
		OverriderReactionsPriority( 60, 59 );
		
		//we don't want to override jump reaction priority
		reactions.PushBack( jump );
		
		
		// beingHit
		tempOverride = (CAINpcActionSubtree)reactions[0];
		tempOverride.changePriorityWhileActive = false;
		tempOverride.reactionPriority = 62;
		
		// combatNearby
		tempOverride = (CAINpcActionSubtree)reactions[1];
		tempOverride.changePriorityWhileActive = false;
		tempOverride.reactionPriority = 61;
		
		tempOverride = (CAINpcActionSubtree)reactions[2];
		tempOverride.changePriorityWhileActive = false;
		tempOverride.reactionPriority = 58;
		
		
		reactions.PushBack( gossip );			//
		reactions.PushBack( question );
		//reactions.PushBack( greeting );

	}
};

// Combat NPC Reactions Tree
class CAICombatNPCReactionsTree extends CAINpcReactionsTree
{
	function Init()
	{
		var beingHit		: CAIActionBeingHit			= new CAIActionBeingHit in this;
		var bump			: CAIActionBumpTree 		= new CAIActionBumpTree in this;
		var combatNearby 	: CAIActionCombatNearby 	= new CAIActionCombatNearby in this;
		var taunt		 	: CAIActionTaunt 			= new CAIActionTaunt in this;
		var jump 			: CAIActionJump				= new CAIActionJump in this;
		var bombExplosion 	: CAIActionBombExplosion 	= new CAIActionBombExplosion in this;
		var combatStarted 	: CAIActionCombatStarted 	= new CAIActionCombatStarted in this;
		
		var tempOverride : CAINpcActionSubtree;
		
		beingHit		.OnCreated();
		bump			.OnCreated();
		combatNearby	.OnCreated();
		taunt			.OnCreated();
		jump			.OnCreated();
		bombExplosion	.OnCreated();
		combatStarted	.OnCreated();
		
		reactions.PushBack( beingHit );			// 0
		reactions.PushBack( combatNearby );		// 1
		reactions.PushBack( bump );				// 2
		reactions.PushBack( taunt );			// 3
		reactions.PushBack( bombExplosion );	// 4
		reactions.PushBack( combatStarted );	// 5
		
		// overrides
		tempOverride = (CAINpcActionSubtree)reactions[0];
		tempOverride.reactionLogicTree = new CAINpcReactionTurnHostile in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.reactionLogicTree.voiceSet = "afraid";
		((CAINpcReactionTurnHostile)tempOverride.reactionLogicTree).SetParams('BeingHitAction');
		
		tempOverride = (CAINpcActionSubtree)reactions[1];
		tempOverride.reactionLogicTree = new CAINpcReactionJoinFight in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.reactionLogicTree.voiceSet = "afraid";
		((CAINpcReactionJoinFight)tempOverride.reactionLogicTree).SetParams(true);
		tempOverride.disallowWhileOnHorse = true;
		
		tempOverride = (CAINpcActionSubtree)reactions[2];
		tempOverride.reactionLogicTree = new CAINpcReactionBump in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.disallowWhileOnHorse = true;
		
		tempOverride = (CAINpcActionSubtree)reactions[3];
		tempOverride.reactionLogicTree = new CAINpcReactionStopAndComment in this;
		tempOverride.reactionLogicTree.OnCreated();
		tempOverride.reactionLogicTree.voiceSet = "afraid";
		
		
		tempOverride = (CAINpcActionSubtree)reactions[4];
		((CAINpcReactionGetScared)tempOverride.reactionLogicTree).SetParams(7.f,false,true);
		
		
		OverriderReactionsPriority( 60, 59 );
		
		//we don't want to override jump reaction priority
		reactions.PushBack( jump ); // 6
		
		tempOverride = (CAINpcActionSubtree)reactions[0];
		tempOverride.changePriorityWhileActive = false;
		
		tempOverride = (CAINpcActionSubtree)reactions[1];
		tempOverride.changePriorityWhileActive = false;
		
		tempOverride = (CAINpcActionSubtree)reactions[3];
		tempOverride.changePriorityWhileActive = false;
		tempOverride.reactionPriority = 24; // lower than combat
	}
};

// Quest NPC Reactions Tree
class CAIQuestNPCReactionsTree extends CAINpcReactionsTree
{
	function Init()
	{
		var bombExplosion 	: CAIActionBombExplosion 	= new CAIActionBombExplosion in this;
		//var taunt		 	: CAIActionTaunt 			= new CAIActionTaunt in this;
		
		bombExplosion	.OnCreated();
		//taunt			.OnCreated();
		
		reactions.PushBack( bombExplosion );
		//reactions.PushBack( taunt );
	}
};

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CUSTOM REACTION TREES:
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Philippa Reactions Tree
class CAIPhilippaReactionsTree extends CAINpcReactionsTree
{
	function Init()
	{
		var bombExplosion : CAIActionBombExplosion = new CAIActionBombExplosion in this;
		
		bombExplosion.OnCreated();
		bombExplosion.forwardAvailabilityToReactionTree = true;
		
		reactions.PushBack( bombExplosion );
	}
};

// Bruxa Commoner Reactions Tree
class CAIBruxaCommonerReactionTree extends CAINpcReactionsTree
{
	function Init()
	{
		var beingHit		: CAIActionBruxaBeingHit				= new CAIActionBruxaBeingHit in this;
		var drawSword		: CAIActionBruxaDrawSword 				= new CAIActionBruxaDrawSword in this;
		var attack			: CAIActionBruxaAttack 					= new CAIActionBruxaAttack in this;
		var friendlyAttack	: CAIActionBruxaFriendlyAttackAction 	= new CAIActionBruxaFriendlyAttackAction in this;
		var castSign		: CAIActionBruxaCastSign 				= new CAIActionBruxaCastSign in this;
		var crossbowShot 	: CAIActionBruxaCrossbowShot 			= new CAIActionBruxaCrossbowShot in this;
		var bombExplosion 	: CAIActionBruxaBombExplosion 			= new CAIActionBruxaBombExplosion in this;
		var playerPresence 	: CAIActionBruxaPlayerPresence 			= new CAIActionBruxaPlayerPresence in this;
		var forcedSpawn 	: CAIActionBruxaPlayerPresenceForced 	= new CAIActionBruxaPlayerPresenceForced in this;
		
		
		beingHit			.OnCreated();
		drawSword			.OnCreated();
		attack				.OnCreated();
		friendlyAttack		.OnCreated();
		castSign			.OnCreated();
		crossbowShot		.OnCreated();
		bombExplosion		.OnCreated();
		playerPresence 		.OnCreated();
		forcedSpawn 		.OnCreated();
		
		beingHit.forwardAvailabilityToReactionTree = true;
		drawSword.forwardAvailabilityToReactionTree = true;
		attack.forwardAvailabilityToReactionTree = true;
		friendlyAttack.forwardAvailabilityToReactionTree = true;
		castSign.forwardAvailabilityToReactionTree = true;
		crossbowShot.forwardAvailabilityToReactionTree = true;
		bombExplosion.forwardAvailabilityToReactionTree = true;
		playerPresence.forwardAvailabilityToReactionTree = true;
		forcedSpawn.forwardAvailabilityToReactionTree = true;
		
		reactions.PushBack( beingHit );
		reactions.PushBack( drawSword );
		reactions.PushBack( attack );
		reactions.PushBack( friendlyAttack );
		reactions.PushBack( castSign );
		reactions.PushBack( crossbowShot );
		reactions.PushBack( bombExplosion );
		reactions.PushBack( playerPresence );
		reactions.PushBack( forcedSpawn );
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ACTIONS:
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// - BeingHit
// - DrawSword
// - Attack
// - CastSign
// - CrossbowShot
// - BombExplosion
// - CombatNearby
// - Gossip
// - Question
// - Greeting
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Base Action Subtree
abstract class CAINpcActionSubtree extends CAISubTree
{
	default aiTreeName = "resdef:ai\reactions/npc_reaction";

	editable inlined var reactionLogicTree : CAINpcReaction;
	
	editable var reactionPriority 					: int;
	editable var actionEventName 					: CName;
	editable var actionCooldownDistance 			: float;
	editable var actionCooldownTimeout 				: float;
	editable var actionFailedCooldown 				: float;
	editable var dontSetActionTarget 				: bool;
	editable var changePriorityWhileActive 			: bool;
	editable var reactionPriorityWhileActive 		: int;
	editable var disallowOutsideOfGuardArea 		: bool;
	editable var forwardAvailabilityToReactionTree 	: bool;
	editable var disableTalkInteraction			 	: bool;
	editable var disallowWhileOnHorse			 	: bool;
	
	default actionCooldownTimeout 	= -1;
	default actionFailedCooldown 	= -1;
	default disableTalkInteraction 	= true;
	default disallowWhileOnHorse 	= true;
};


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////
// NOTES:
//
// Reaction Priorities:
// 50-60 - will intterrupt work
// 20-24 - rest
///////////////////////////

// BeingHit
class CAIActionBeingHit extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionGetScared in this;
		reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)reactionLogicTree).SetParams(10.f,false);
		reactionPriority = 60;
		actionEventName = 'BeingHitAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0;
		disallowWhileOnHorse = false;
	}
};

// Bump
class CAIActionBumpTree extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBump in this;
		reactionLogicTree.OnCreated();
		reactionLogicTree.voiceSet = "bump";

		reactionPriority = 60;
		actionEventName = 'BumpAction';
		actionCooldownDistance = 1;
		actionCooldownTimeout = 1;
		dontSetActionTarget = true;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 51;
		forwardAvailabilityToReactionTree = true;
	}
};

// CombatNearby
class CAIActionCombatNearby extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionObserveFight in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 55;
		actionEventName = 'CombatNearbyAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 54;
	}
};

// DrawSword
class CAIActionDrawSword extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionStopAndComment in this;
		reactionLogicTree.OnCreated();
		reactionLogicTree.voiceSet = "afraid";
		
		reactionPriority = 24;
		actionEventName = 'DrawSwordAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 23;
	}
};

// Attack
class CAIActionAttack extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionTaunt in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 55;
		actionEventName = 'AttackAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 54;
	}
};

// CastSign
class CAIActionCastSign extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionTaunt in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 55;
		actionEventName = 'CastSignAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 54;
	}
};

// CrossbowShot
class CAIActionCrossbowShot extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionStopAndComment in this;
		reactionLogicTree.OnCreated();
		reactionLogicTree.voiceSet = "afraid";
		
		reactionPriority = 24;
		actionEventName = 'CrossbowShotAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 23;
	}
};

// BombExplosion
class CAIActionBombExplosion extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionGetScared in this;
		reactionLogicTree.OnCreated();
		((CAINpcReactionGetScared)reactionLogicTree).SetParams(7.f,false);
		reactionPriority = 56;
		actionEventName = 'BombExplosionAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0;
	}
};

// Looting
class CAIActionLooting extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionGuardWarnGeneral in this;
		reactionLogicTree.OnCreated();
		reactionLogicTree.voiceSet = "afraid";
		((CAINpcReactionGuardWarnGeneral)reactionLogicTree).SetParams(true);
		
		reactionPriority = 50;
		actionEventName = 'LootingAction';
		actionCooldownDistance = 0.5;
		actionFailedCooldown = 2.f;
		actionCooldownTimeout = 0.1;
	}
};

// Taunt
class CAIActionTaunt extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionTaunt in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 55;
		actionEventName = 'TauntAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		dontSetActionTarget = false;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 54;
	}
};

// rain
class CAIActionRain extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionRain in this;
		reactionLogicTree.OnCreated();
		reactionLogicTree.voiceSet = "rain";
		
		reactionPriority = 45;
		actionEventName = 'RainReactionEvent';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 20;
		actionFailedCooldown = 300; 
		
		disableTalkInteraction = false;
		forwardAvailabilityToReactionTree = true;
	}
};

// Jump
class CAIActionJump extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionSurprise in this;
		reactionLogicTree.OnCreated();
		reactionLogicTree.voiceSet = "afraid";
		
		reactionPriority = 24;
		actionEventName = 'PlayerJumpAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 23;
		forwardAvailabilityToReactionTree = true;
	}
};

// CombatStarted
class CAIActionCombatStarted extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionSurprise in this;
		reactionLogicTree.OnCreated();
		((CAINpcReactionSurprise)reactionLogicTree).SetParams(true);
		
		reactionPriority = 45;
		actionEventName = 'CombatStarted';
		actionCooldownDistance = 0.5;
		actionFailedCooldown = 2.f;
		actionCooldownTimeout = 0.1;
		forwardAvailabilityToReactionTree = true;
	}
};


////////////////////////////////////////////////////
// hard-soft reacitons

// Gossip
class CAIActionGossip extends CAINpcActionSubtree
{
	default aiTreeName = "resdef:ai\reactions\reaction_gossip_scene";

	editable var inInWorkBranch : bool;
	
	function Init()
	{
		reactionPriority = 21;
		actionEventName = 'GossipAction';
		actionCooldownDistance = 100;
		actionCooldownTimeout = 60;	
		
		disableTalkInteraction = false;
	}
};

// Question
class CAIActionQuestion extends CAINpcActionSubtree
{
	default aiTreeName = "resdef:ai\reactions\reaction_question_scene";

	editable var inInWorkBranch : bool;
	
	function Init()
	{
		reactionPriority = 21;
		actionEventName = 'QuestionAction';
		actionCooldownDistance = 100;
		actionCooldownTimeout = 60;	
		
		disableTalkInteraction = false;	
	}
};

// Greeting
class CAIActionGreeting extends CAINpcActionSubtree
{
	default aiTreeName = "resdef:ai\reactions\reaction_greeting_scene";

	editable var inInWorkBranch : bool;
	
	function Init()
	{
		reactionPriority = 21;
		actionEventName = 'GreetingAction';
		actionCooldownDistance = 100;
		actionCooldownTimeout = 60;	
		
		disableTalkInteraction = false;
	}
};

// Greeting
class CAIActionBarter extends CAINpcActionSubtree
{
	default aiTreeName = "resdef:ai\reactions\reaction_scene_barter";

	editable var inInWorkBranch : bool;
	
	function Init()
	{
		reactionPriority = 21;
		actionEventName = 'BarterAction';
		actionCooldownDistance = 100;
		actionCooldownTimeout = 60;		
		
		disableTalkInteraction = false;
	}
};

// PlayerPresence
class CAIActionPlayerPresence extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionStopAndComment in this;
		reactionLogicTree.OnCreated();
		reactionLogicTree.voiceSet = "reaction_to_geralt";
		
		reactionPriority = 20; //less important then WORK
		actionEventName = 'PlayerPresenceAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 10;
		forwardAvailabilityToReactionTree = true;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 22;
		
		disableTalkInteraction = false;
	}
};

// QuestPlayerPresence
class CAIQuestActionPlayerPresence extends CAIActionPlayerPresence
{
	function Init()
	{
		super.Init();
		((CAINpcReactionStopAndComment)reactionLogicTree).SetParams(100,-1);
		actionCooldownTimeout = 0;
	}
};


////////////////////////////////////////////////////
// custom reactions

// BruxaBeingHit
class CAIActionBruxaBeingHit extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 60;
		actionEventName = 'BeingHitAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0;
		disallowWhileOnHorse = false;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
	}
};
// BruxaDrawSword
class CAIActionBruxaDrawSword extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 24;
		actionEventName = 'DrawSwordAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
	}
};

// BruxaAttack
class CAIActionBruxaAttack extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 55;
		actionEventName = 'AttackAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
	}
};

// BruxaAttack
class CAIActionBruxaFriendlyAttackAction extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 55;
		actionEventName = 'FriendlyAttackAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
	}
};

// BruxaCastSign
class CAIActionBruxaCastSign extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 55;
		actionEventName = 'CastSignActionFar';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
	}
};

// BruxaCrossbowShot
class CAIActionBruxaCrossbowShot extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 24;
		actionEventName = 'CrossbowShotAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0.5f;
		actionFailedCooldown = 2.f;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
	}
};

// BruxaBombExplosion
class CAIActionBruxaBombExplosion extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 56;
		actionEventName = 'BombExplosionAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 0;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
	}
};

// BruxaPlayerPresence
class CAIActionBruxaPlayerPresence extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 20; //less important then WORK
		actionEventName = 'PlayerPresenceAction';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 20;
		forwardAvailabilityToReactionTree = true;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
		
		disableTalkInteraction = false;
	}
};

// BruxaPlayerPresence
class CAIActionBruxaPlayerPresenceForced extends CAINpcActionSubtree
{
	function Init()
	{
		reactionLogicTree = new CAINpcReactionBruxaSpawn in this;
		reactionLogicTree.OnCreated();
		
		reactionPriority = 100;
		actionEventName = 'ForceBruxaSpawn';
		actionCooldownDistance = 0;
		actionCooldownTimeout = 20;
		forwardAvailabilityToReactionTree = true;
		changePriorityWhileActive = true;
		reactionPriorityWhileActive = 95;
		
		disableTalkInteraction = false;
	}
};

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// REACTIONS:
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// - GetScared
// - StopAndComment
// - JoinFight
// - TurnHostile
// - GuardWarn
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Base Reaction
class CAINpcReaction extends CAISubTree
{
	editable var voiceSet : string;
};

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// GetScared
class CAINpcReactionGetScared extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_get_scared";
	
	editable var scaredTime : float;
	editable var scaredTimeMax : float;
	editable var checkLineOfSight : bool;
	editable var tryToBeHostileFirst : bool;
	
	default scaredTime = 8.f;
	default scaredTimeMax = 11.f;
	default checkLineOfSight = false;
	
	function SetParams( _scaredTime : float, _checkLineOfSight : bool, optional _tryToBeHostileFirst : bool )
	{
		scaredTime = _scaredTime - 2;
		scaredTimeMax = _scaredTime + 1;
		checkLineOfSight = _checkLineOfSight;
		tryToBeHostileFirst = _tryToBeHostileFirst;
	}
};

// GetScared
class CAINpcReactionTaunt extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_taunt";
};

// StopAndComment
class CAINpcReactionStopAndComment extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_stop_and_comment";
	
	editable var stopDuration 			: float;	default stopDuration = 6.f;
	editable var activationChance 		: int;		default activationChance = 20;
	editable var distanceToInterrupt	: int;		default distanceToInterrupt = 10.f;
	
	function SetParams( _activationChance : int, _stopDuration : float )
	{
		activationChance = _activationChance;
		stopDuration = _stopDuration;
	}
};

// Surprise
class CAINpcReactionSurprise extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_surprise";
	
	editable var rotateToActionTargetsTarget : bool;
	
	function SetParams( _rotateToActionTargetsTarget : bool )
	{
		rotateToActionTargetsTarget = _rotateToActionTargetsTarget;
	}
};
 
// JoinFight
class CAINpcReactionJoinFight extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions\reaction_join_fight";
	editable var onlyHelpActorsFromTheSameAttidueGroup : bool;
	
	function SetParams( _onlyHelpActorsFromTheSameAttidueGroup : bool )
	{
		onlyHelpActorsFromTheSameAttidueGroup = _onlyHelpActorsFromTheSameAttidueGroup;
	}
};

// ObserveFight
class CAINpcReactionObserveFight extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions\reaction_observe_fight";
	
	editable var doNotCheckLineOfSight : bool;
	
	function SetParams( _doNotCheckLineOfSight : bool )
	{
		doNotCheckLineOfSight = _doNotCheckLineOfSight;
	}
};

// TurnHostile
class CAINpcReactionTurnHostile extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_turn_hostile";
	editable var setAttitudeGameplayEventName : name;
	
	function SetParams( gameplayEventName : name )
	{
		setAttitudeGameplayEventName = gameplayEventName;
	}
};

// GuardWarn
class CAINpcReactionGuardWarnSword extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_guard_warn_sword";
};

// GuardLooting
class CAINpcReactionGuardWarnGeneral extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions\reaction_guard_warn_general";
	
	editable var lootingReaction : bool;
	
	function SetParams( _lootingReaction : bool )
	{
		lootingReaction = _lootingReaction;
	}
};

// Bump Reaction
class CAINpcReactionBump extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_bump";
};


// Rain Reaction
class CAINpcReactionRain extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_rain";
	
	editable inlined var actionPointSelector 	: CRainActionPointSelector;
	
	function Init()
	{
		actionPointSelector = new CRainActionPointSelector in this;
		
		actionPointSelector.radius 			= 30;
		actionPointSelector.chooseClosestAP = true;
	}
};

// BruxaSpawn
class CAINpcReactionBruxaSpawn extends CAINpcReaction
{
	default aiTreeName = "dlc\bob\data\gameplay\trees\reaction_bruxa_spawn.w2behtree";
	
	editable var activationChance 		: int;		default activationChance = 100;
	editable var distanceToInterrupt	: int;		default distanceToInterrupt = 15.f;
	
	function SetParams( _activationChance : int, _stopDuration : float )
	{
		activationChance = _activationChance;
	}
};

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SCARED BRANCH:
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

abstract class CAIScaredSubTree extends CAISubTree
{

};

class CAIScaredTree extends CAIScaredSubTree
{
	default aiTreeName = "resdef:ai\reactions/npc_scared_reaction";
};

class CAIRunOnlyScaredTree extends CAIScaredSubTree
{
	default aiTreeName = "resdef:ai\reactions/npc_scared_run_only_reaction";
};






















/* OLD STUFF
class CAIScaredReactionTree extends CAISubTree
{
	default aiTreeName = "resdef:ai\reactions/npc_scared_reaction";
}

// Help
class CAIActionHelp extends CAINpcActionSubtree
{
	function Init()
	{
		super.Init();
		params = new CAINpcActionSubtreeParams in this;
		params.OnCreated();
		params.actionEventName = 'HelpAction';
		params.reactionPriority = 100;
		params.actionCooldownDistance = 5;
		params.actionCooldownTimeout = 0.1;
		params.reactionLogicTree = new CAINpcReactionGuardApproachAndHelp in this;
		params.reactionLogicTree.OnCreated();
		params.reactionLogicTree.params.voiceSet = "";
	}
};

// Call Reinforcements
class CAIActionCallReinforcements extends CAINpcActionSubtree
{
	function Init()
	{
		super.Init();
		params = new CAINpcActionSubtreeParams in this;
		params.OnCreated();
		params.actionEventName = 'CallReinforcementsAction';
		params.reactionPriority = 100;
		params.actionCooldownDistance = 5;
		params.actionCooldownTimeout = 0.1;
		params.reactionLogicTree = new CAINpcReactionGuardApproachAndHelp in this;
		params.reactionLogicTree.OnCreated();
		params.reactionLogicTree.params.voiceSet = "";
	}
};



*/



