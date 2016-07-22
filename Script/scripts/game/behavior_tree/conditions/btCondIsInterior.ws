/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2014
/** Author : Shadi Dadenji
/***********************************************************************/
 
enum ETestSubject
{
	ETS_Player,
	ETS_Owner
}
 
 
class CBTCondIsInInterior extends IBehTreeTask
{
	var testSubject : ETestSubject;

	function IsAvailable() : bool
	{
		var owner : CNewNPC;

		if ( testSubject == ETS_Player )
		{
			return thePlayer.IsInInterior();
		}
		else
		{
			owner = GetNPC();
			if ( owner )
			{
				return owner.IsInInterior();
			}
		}
		
		return false;
	}
};

class CBTCondIsInInteriorDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsInInterior';

	editable var testSubject : ETestSubject;
	default testSubject = ETS_Owner;
};
