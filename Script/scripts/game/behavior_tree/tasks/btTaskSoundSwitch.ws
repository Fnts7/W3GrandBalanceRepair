//>--------------------------------------------------------------------------
// BTTaskSoundSwitch
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Switch sounds for the NPCs
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 26-September-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskSoundSwitch extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	public var swichGroupName 	: name;
	public var stateName 		: string;
	public var onActivate 		: bool;
	public var onDeactivate		: bool;
	//>----------------------------------------------------------------------
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnActivate() : EBTNodeStatus
	{
		if( !onActivate ) return BTNS_Active;
		SwitchSound();
		return BTNS_Active;
	}	
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private function OnDeactivate()
	{
		if( !onDeactivate ) return;
		SwitchSound();
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private function SwitchSound()
	{
		GetNPC().SoundSwitch( swichGroupName, stateName );
	}
}
//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class BTTaskSoundSwitchDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSoundSwitch';

	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	private editable var swichGroupName : name;
	private editable var stateName 		: string;
	private editable var onActivate		: bool;
	private editable var onDeactivate	: bool;
}