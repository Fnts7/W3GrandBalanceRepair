/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2014
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTCondHasTag extends IBehTreeTask
{
	public var tag		: name;
	
	function IsAvailable() : bool
	{
		return GetActor().HasTag( tag );
	}
};


class CBTCondHasTagDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHasTag';

	editable var tag		: name;
};


/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2014
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTAddTag extends IBehTreeTask
{
	public var tag				: name;
	public var toOwner 			: bool;
	public var toTarget 		: bool;
	public var useCombatTarget 	: bool;
	public var onActivate 		: bool;
	public var onDeactivate 	: bool;
	
	function OnActivate() : EBTNodeStatus
	{
		if ( onActivate )
		{
			Execute();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( onDeactivate )
		{
			Execute();
		}
	}
	
	final function Execute()
	{
		var actor 	: CActor = GetActor();
		var target 	: CNode;
		
		if ( IsNameValid( tag ) )
		{
			if ( toOwner )
			{
				actor.AddTag( tag );
			}
			if ( toTarget )
			{
				if ( useCombatTarget )
				{
					target = GetCombatTarget();
				}
				else
				{
					target = GetActionTarget();
				}
				if ( target )
				{
					target.AddTag( tag );
				}
			}
		}
	}
	
};


class CBTAddTagDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTAddTag';

	editable var tag			: name;
	editable var toOwner 		: bool;
	editable var toTarget 		: bool;
	editable var useCombatTarget: bool;
	editable var onActivate 	: bool;
	editable var onDeactivate 	: bool;
};
