abstract class CBTHackDef extends IBehTreeTaskDefinition
{
};

class CBTCondIsMan extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		if ( GetActor().IsMan() )
			return true;
		
		return false;
	}
}

class CBTCondIsManDef extends CBTHackDef
{
	default instanceClass = 'CBTCondIsMan';
};