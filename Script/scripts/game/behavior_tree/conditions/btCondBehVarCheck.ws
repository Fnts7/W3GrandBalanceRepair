/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2013
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTCondBehVarCheck extends IBehTreeTask
{
	public var behVarName	: name;
	public var behVarValue	: int;
	public var compareOperation : ECompareOp;

	function IsAvailable() : bool
	{
		var value : float = GetActor().GetBehaviorVariable( behVarName );
		
		return ProcessCompare( compareOperation, value, behVarValue );
	}
};

class CBTCondBehVarCheckDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondBehVarCheck';

	editable var behVarName 	: name;
	editable var behVarValue 	: int;
	editable var compareOperation : ECompareOp;
	
	default compareOperation = CO_Equal;
};

class CBTCondBehVarCheckFloat extends IBehTreeTask
{
	public var behVarName	: name;
	public var behVarValue	: float;
	public var compareOperation : ECompareOp;

	function IsAvailable() : bool
	{
		var value : float = GetActor().GetBehaviorVariable( behVarName );
		
		return ProcessCompare( compareOperation, value, behVarValue );
	}
};

class CBTCondBehVarCheckFloatDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondBehVarCheckFloat';

	editable var behVarName 	: name;
	editable var behVarValue 	: float;
	editable var compareOperation : ECompareOp;
	
	default compareOperation = CO_Equal;
};