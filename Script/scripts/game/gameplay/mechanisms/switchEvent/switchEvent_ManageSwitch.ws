/*
enum ESwitchOperation
{
	SO_TurnOn,
	SO_TurnOff,
	SO_Toggle,
	SO_Reset,
	SO_Enable,
	SO_Disable,
	SO_Lock,
	SO_Unlock,
};
*/

class W3SE_ManageSwitch extends W3SwitchEvent
{
	editable var switchTag	: name;
	editable var operations	: array< ESwitchOperation >;
	editable var force		: bool;							default force		= true;
	editable var skipEvents	: bool;							default skipEvents	= true;
	
	hint switchTag	= "Tag of the switch";
	hint operation	= "Operations to perform on switch";
	hint force		= "Force even if switch is disabled (applicable only for turning on/off)";
	hint skipEvents	= "Skip events associated with with switch (applicable only for turning on/off)";
	
	public function Perform( parnt : CEntity )
	{
		var switchEntity : W3Switch;
		
		switchEntity = GetSwitchByTag( switchTag );
		if ( !switchEntity )
		{
			LogChannel( 'Switch', "W3SE_ManageSwitch::Activate - cannot find switch with tag <" + switchTag + ">");
			return;
		}
		
		switchEntity.OnManageSwitch( operations, force, skipEvents );
	}
}