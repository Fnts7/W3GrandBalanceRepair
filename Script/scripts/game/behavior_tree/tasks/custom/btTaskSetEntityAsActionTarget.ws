//>--------------------------------------------------------------------------
// BTTaskSetEntityAsActionTarget
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Set the action target to an entity with the defined tag
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 05-May-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskSetEntityAsActionTarget extends IBehTreeTask
{
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	var targetTag			: name;
	var multipleTargetsTags : array<name>;
	var completeImmediately : bool;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnActivate() : EBTNodeStatus
	{	
		var l_target		: CNode;
		var l_selectedTag	: name;
		var l_size			: int;
		
		l_size = multipleTargetsTags.Size();
		
		if ( l_size > 0 )
			l_selectedTag = multipleTargetsTags[RandRange(l_size)];
		else
			l_selectedTag = targetTag;
		
		l_target = theGame.GetNodeByTag( l_selectedTag );		
		SetActionTarget( l_target );
		
		if ( completeImmediately )
			return BTNS_Completed;
		else
			return BTNS_Active;
	}

}
//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTTaskSetEntityAsActionTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetEntityAsActionTarget';
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	editable var targetTag	: CBehTreeValCName;
	editable var multipleTargetsObjectName : name;
	editable var completeImmediately : bool;
	
	default multipleTargetsObjectName = 'multipleTargetsTags';
	default completeImmediately = true;
	
	hint multipleTargetsObjectName = "only works for parametrization.";
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var task : BTTaskSetEntityAsActionTarget;
		task = (BTTaskSetEntityAsActionTarget) taskGen;
		task.multipleTargetsTags =((W3BehTreeValNameArray)GetObjectByVar(multipleTargetsObjectName)).GetArray();
	}
}
