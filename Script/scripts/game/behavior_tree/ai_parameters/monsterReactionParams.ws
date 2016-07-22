class CAIMonsterCombatReactionsTree extends CAIReactionTree
{
	default aiTreeName = "resdef:ai\reactions/monster_base_reactions";

	editable inlined var params : CAIMonsterReactionsTreeParams;
	
	function Init()
	{
		var leadEscape					: CAIActionLeadEscape 			= new CAIActionLeadEscape in this;
		var leadEscapeFearSomeEvent		: CAIActionLeadEscape 			= new CAIActionLeadEscape in this;
		var escapeInPack				: CAIActionEscapeInPack 		= new CAIActionEscapeInPack in this;
		
		params = new CAIMonsterReactionsTreeParams in this;
		params.Init();
		
		leadEscape		.OnCreated();
		leadEscapeFearSomeEvent.OnCreated();
		escapeInPack	.OnCreated();
		
		leadEscapeFearSomeEvent.actionEventName 		= 'FearsomeEvent';
		leadEscapeFearSomeEvent.saveReactionTargetUnder = 'FearsomeEventSource';
		
		params.reactions.PushBack( leadEscape );
		params.reactions.PushBack( leadEscapeFearSomeEvent );
		params.reactions.PushBack( escapeInPack );
	}
}

class CAIMonsterReactionsTree extends CAIReactionTree
{
	default aiTreeName = "resdef:ai\reactions/monster_base_reactions";

	editable inlined var params : CAIMonsterReactionsTreeParams;
	
	function Init()
	{
		var searchForTarget : CAIActionSearchForTarget 		= new CAIActionSearchForTarget in this;
		var joinSearch 		: CAIActionAllySearchesTarget 	= new CAIActionAllySearchesTarget in this;
		var playAround 		: CAIActionPlayWithTarget 		= new CAIActionPlayWithTarget in this;
		var moveInPack 		: CAIActionMoveInPack 			= new CAIActionMoveInPack in this;
		var runWildInPack 	: CAIActionRunWildInPack 		= new CAIActionRunWildInPack in this;
		
		params = new CAIMonsterReactionsTreeParams in this;
		params.Init();
		
		searchForTarget	.OnCreated();
		joinSearch		.OnCreated();
		playAround		.OnCreated();
		moveInPack		.OnCreated();
		runWildInPack	.OnCreated();
		
		params.reactions.PushBack( searchForTarget );
		params.reactions.PushBack( joinSearch );
		params.reactions.PushBack( playAround );
		params.reactions.PushBack( moveInPack );
		params.reactions.PushBack( runWildInPack );
	}
};

// Base Reaction Tree Params
class CAIMonsterReactionsTreeParams extends CAIReactionsParameters
{
	editable inlined var reactions : array< CAIMonsterActionSubtree >;
	editable var canFly	: bool;
};

// Howl
class CAIReactionHowl extends CAINpcReaction
{
	default aiTreeName = "resdef:ai\reactions/reaction_monster_howl";
};

// Search for target
abstract class CAIMonsterActionSubtree extends CAINpcActionSubtree
{
	default dontSetActionTarget 				= false;
	default changePriorityWhileActive 			= false;
	default disallowOutsideOfGuardArea 			= false;
	default forwardAvailabilityToReactionTree 	= false;
	default disableTalkInteraction			 	= false;
	default disallowWhileOnHorse			 	= false;
}

// Search for target
class CAIActionSearchForTarget extends CAIMonsterActionSubtree
{
	default reactionPriority = 20;
	default actionEventName = 'Danger';
	default actionCooldownDistance = 100;
	default actionCooldownTimeout = 1;		
	default forwardAvailabilityToReactionTree 	= true;
	
	function Init()
	{
		reactionLogicTree = new CAINpcReactionSearchTarget in this;
		reactionLogicTree.OnCreated();
	}
};

// Join search for target
class CAIActionAllySearchesTarget extends CAIMonsterActionSubtree
{
		
	default reactionPriority = 20;
	default actionEventName = 'SearchesForTarget';
	default actionCooldownDistance = 100;
	default actionCooldownTimeout = 1;		
	default forwardAvailabilityToReactionTree 	= true;
	
	function Init()
	{
		reactionLogicTree = new CAINpcReactionJoinSearchForTarget in this;
		reactionLogicTree.OnCreated();
	}
};

// Play around
class CAIActionPlayWithTarget extends CAIMonsterActionSubtree
{
	default reactionPriority = 20;
	default actionEventName = 'PlayAround';
	default actionCooldownDistance = 100;
	default actionCooldownTimeout = 1;
		
	default disallowOutsideOfGuardArea 			= true;
	default forwardAvailabilityToReactionTree 	= true;
	function Init()
	{
		reactionLogicTree = new CAINpcReactionPlayWithTarget in this;
		reactionLogicTree.OnCreated();		
	}
};

// Move to Lure
class CAIActionMoveToLure extends CAIMonsterActionSubtree
{
	default reactionPriority = 20;
	default actionEventName = 'BiesLure';
	default actionCooldownDistance = 100;
	default actionCooldownTimeout = 1;
		
	default forwardAvailabilityToReactionTree 	= true;
	default disallowOutsideOfGuardArea = true;
	
	function Init()
	{
		reactionLogicTree = new CAINpcReactionMoveToLure in this;
		reactionLogicTree.OnCreated();		
	}
};

// Move out
class CAIActionMoveOut extends CAIMonsterActionSubtree
{	
	default reactionPriority 		= 20;
	default actionEventName 		= 'PlayerPresenceAction';
	default actionCooldownDistance 	= 2;
	default actionCooldownTimeout 	= 1;
		
	default disallowOutsideOfGuardArea 			= true;
	default forwardAvailabilityToReactionTree 	= true;
	function Init()
	{
		reactionLogicTree = new CAINpcReactionMoveOut in this;
		reactionLogicTree.OnCreated();		
	}
};

// Move out
class CAIActionTauntAndMoveOut extends CAIMonsterActionSubtree
{	
	default reactionPriority 		= 20;
	default actionEventName 		= 'PlayerPresenceAction';
	default actionCooldownDistance 	= 2;
	default actionCooldownTimeout 	= 1;
		
	default disallowOutsideOfGuardArea 			= true;
	default forwardAvailabilityToReactionTree 	= true;
	function Init()
	{
		reactionLogicTree = new CAINpcReactionTauntAndMoveOut in this;
		reactionLogicTree.OnCreated();		
	}
};

// Move in pack
class CAIActionMoveInPack extends CAIMonsterActionSubtree
{
	public editable var chanceToFollowPack : float;
	
		
	default reactionPriority = 20;
	default actionEventName = 'LeaderMoves';
	default actionCooldownDistance = 100;
	default actionCooldownTimeout = 1;
		
	default disallowOutsideOfGuardArea = true;
	default forwardAvailabilityToReactionTree = true;
		
	default chanceToFollowPack = 100;
	
	function Init()
	{
		reactionLogicTree = new CAINpcReactionMoveInPack in this;
		reactionLogicTree.OnCreated();
	}
};

// Run wild in pack
class CAIActionRunWildInPack extends CAIMonsterActionSubtree
{
	default reactionPriority = 20;
	default actionEventName = 'PackRunsWild';
	default actionCooldownDistance = 100;
	default actionCooldownTimeout = 1;
		
	default disallowOutsideOfGuardArea = true;
	default forwardAvailabilityToReactionTree = true;
	
	function Init()
	{
		reactionLogicTree = new CAINpcReactionRunWildInPack in this;
		reactionLogicTree.OnCreated();
	}
};

// Lead Escape
class CAIActionLeadEscape extends CAIMonsterActionSubtree
{
	public editable var saveReactionTargetUnder : name;
	default saveReactionTargetUnder = 'FearSource';
	
	default reactionPriority = 100;
	default actionEventName = 'MonsterInCombat';
	default actionCooldownDistance = 100;
	default actionCooldownTimeout = 0.1f;
		
	default forwardAvailabilityToReactionTree 	= true;
	default disallowOutsideOfGuardArea 			= true;
	
	function Init()
	{
		reactionLogicTree = new CAINpcReactionLeadEscape in this;
		reactionLogicTree.OnCreated();		
	}
};

// Escape in pack
class CAIActionEscapeInPack extends CAIMonsterActionSubtree
{		
	default reactionPriority = 100;
	default actionEventName = 'MonsterLeadEscape';
	default actionCooldownDistance = 100;
	default actionCooldownTimeout = 0.1f;
		
	default forwardAvailabilityToReactionTree 	= true;
	default disallowOutsideOfGuardArea = true;
	
	function Init()
	{
		reactionLogicTree = new CAINpcReactionEscapeInPack in this;
		reactionLogicTree.OnCreated();
	}
};

// Search for target
class CAINpcReactionSearchTarget extends CAINpcReaction
{	
	default aiTreeName = "resdef:ai\reactions\reaction_search_target";
};
// Join search for target
class CAINpcReactionJoinSearchForTarget extends CAINpcReaction
{	
	default aiTreeName = "resdef:ai\reactions\reaction_join_search_for_target";
};

// Play with target
class CAINpcReactionPlayWithTarget extends CAINpcReaction
{	
	default aiTreeName = "resdef:ai\reactions\reaction_play_around";
};

// Move out
class CAINpcReactionMoveOut extends CAINpcReaction
{	
	default aiTreeName = "resdef:ai\reactions\reaction_move_out";
};

// Taunt and move out
class CAINpcReactionTauntAndMoveOut extends CAINpcReaction
{	
	default aiTreeName = "gameplay\trees\reactions\reaction_taunt_and_move_out.w2behtree";
};

// Move in pack
class CAINpcReactionMoveInPack extends CAINpcReaction
{	
	default aiTreeName = "resdef:ai\reactions\reaction_move_in_pack";
};

// Run wild in pack
class CAINpcReactionRunWildInPack extends CAINpcReaction
{	
	default aiTreeName = "resdef:ai\reactions\reaction_run_wild_in_pack";
};

// Move to lure
class CAINpcReactionMoveToLure extends CAINpcReaction
{	
	default aiTreeName = "resdef:ai\reactions\reaction_monster_move_to_lure";
};

// Lead Escape
class CAINpcReactionLeadEscape extends CAINpcReaction
{	
	default aiTreeName = "resdef:ai\reactions\reaction_monster_lead_escape";
};

// Escape in pack
class CAINpcReactionEscapeInPack extends CAINpcReaction
{	
	default aiTreeName = "resdef:ai\reactions\reaction_monster_escape_in_pack";
};
