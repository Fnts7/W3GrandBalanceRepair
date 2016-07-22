class CBTCondHorseCanFlee extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		if( GetNPC().GetCanFlee() )
		{
			return true;
		}
		return false;
	}
};

class CBTCondHorseCanFleeDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHorseCanFlee';
};
