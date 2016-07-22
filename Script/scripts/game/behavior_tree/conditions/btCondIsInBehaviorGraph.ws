/***********************************************************************/
/**
/***********************************************************************/
/** Copyright © 2014
/***********************************************************************/

class CBTCondIsInBehaviorGraph extends IBehTreeTask
{
	var behGraphName : name;
	
	function IsAvailable() : bool
	{
		return GetNPC().GetBehaviorGraphInstanceName() == behGraphName;
	}
}

class CBTCondIsInBehaviorGraphDef extends IBehTreeConditionalTaskDefinition
{
	editable var behGraphName : name; default behGraphName = 'Exploration';
	
	default instanceClass = 'CBTCondIsInBehaviorGraph';
};