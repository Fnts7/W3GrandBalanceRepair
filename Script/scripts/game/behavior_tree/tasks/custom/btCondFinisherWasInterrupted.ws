//>--------------------------------------------------------------------------
// BTCondFinisherWasInterrupted
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Check if the finisher played on this npc was interrupted
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 29-May-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTCondFinisherWasInterrupted extends IBehTreeTask
{
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	function IsAvailable() : bool
	{
		var l_availability	: bool;
		l_availability = GetNPC().WasFinisherAnimInterrupted();
		return l_availability;
	}
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	function OnDeactivate()
	{
		GetNPC().ResetFinisherAnimInterruptionState();
	}
}
//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTCondFinisherWasInterruptedDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondFinisherWasInterrupted';
};