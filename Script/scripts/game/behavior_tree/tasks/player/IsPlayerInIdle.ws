class CBTIsPlayerInIdle extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return thePlayer.IsInIdle();
	}
}

class CBTIsPlayerInIdleDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTIsPlayerInIdle';
}