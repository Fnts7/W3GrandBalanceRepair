
import abstract class IAIExplorationTree extends IAITree
{
};

abstract class IAIDoorExplorationTree extends IAIExplorationTree
{
};

class CAIDoorMoveExplorationTree extends IAIDoorExplorationTree
{
	default aiTreeName = "resdef:ai\exploration/door_move";
};


////////////////////////////////////////////////////////////
class CAIUseExplorationActionTree extends IAIExplorationTree
{
	default aiTreeName = "resdef:ai\exploration/use_exploration_general";	
	
	editable var explorationType 	: EExplorationType;
	editable var skipTeleportation 	: bool;
};

class CAIRunExplorationActionTree extends IAIBaseAction
{
	default aiTreeName = "resdef:ai\exploration/use_exploration_action_general";
	editable inlined var params : CAIRunExplorationActionTreeParams;
	function Init()
	{	
		params = new CAIRunExplorationActionTreeParams in this;
		params.OnCreated();
	}
};
// CAIBasicAttackActionTreeParams
class CAIRunExplorationActionTreeParams extends IAIActionParameters
{
	editable var explorationType : EExplorationType;
	editable var entityTag		 : name;
};