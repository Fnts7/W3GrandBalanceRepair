// copyrajt orajt 
// W. Żerek

class CBTTaskSetBehVar extends IBehTreeTask
{
	public var behVarName 		: name;
	public var behVarValue		: float;
	public var inAllBehGraphs	: bool;
	public var onDeactivate		: bool;
	public var onSuccess 		: bool;
	

	function OnActivate() : EBTNodeStatus
	{		
		if( onDeactivate || onSuccess ) return BTNS_Active;
		
		GetNPC().SetBehaviorVariable( behVarName, behVarValue, inAllBehGraphs );
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( onDeactivate ) 
		{
			GetNPC().SetBehaviorVariable( behVarName, behVarValue, inAllBehGraphs );
		}
	}
	
	function OnCompletion( success : bool )
	{
		if ( onSuccess && success )
			GetNPC().SetBehaviorVariable( behVarName, behVarValue, inAllBehGraphs );
	}
};

class CBTTaskSetBehVarDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSetBehVar';

	editable var behVarName 	: CBehTreeValCName;
	editable var behVarValue	: CBehTreeValFloat;
	editable var inAllBehGraphs	: bool;
	editable var onDeactivate	: bool;
	editable var onSuccess 		: bool;
};
