//>--------------------------------------------------------------------------
// BTCondIsInGuardArea
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Task description
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - DD-Month-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTCondIsInGuardArea extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------	
	public var position				: ETargetName;
	public var namedTarget			: name;
	public var valueToReturnIfNoGA	: bool;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	final function IsAvailable() : bool
	{
		var l_guardArea : CAreaComponent;
		var l_posToTest	: Vector;
		
		l_guardArea = GetNPC().GetGuardArea();
		
		if( !l_guardArea )
			return valueToReturnIfNoGA;
		
		l_posToTest = GetTargetPos( position );
		
		if( l_guardArea.TestPointOverlap( l_posToTest ) )
			return true;
			
		return false;
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private final function GetTargetPos( _TargetName : ETargetName ) : Vector
	{
		var l_pos 		: Vector;
		var l_heading 	: float;
		
		switch ( _TargetName )
		{
			case TN_Me:
				return GetNPC().GetWorldPosition();
			case TN_CombatTarget:
				return GetCombatTarget().GetWorldPosition();
			case TN_ActionTarget:
				return GetActionTarget().GetWorldPosition();
			case TN_CustomTarget:
				GetCustomTarget( l_pos, l_heading );
				return l_pos;
			case TN_NamedTarget:
				GetNamedTarget( namedTarget ).GetWorldPosition();
			default:
				return Vector( 0, 0, 0 );
		}
		
	}

}


//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTCondIsInGuardAreaDef extends IBehTreeTaskDefinition
{
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	default instanceClass = 'BTCondIsInGuardArea';
	
	private editable var position				: ETargetName;
	private editable var namedTarget			: name;
	private editable var valueToReturnIfNoGA	: bool;
	
	hint valueToReturnIfNoGA = "availability if the npc has no guard area";
}