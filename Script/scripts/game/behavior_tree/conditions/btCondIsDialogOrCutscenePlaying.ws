

class CBTCondIsDialogOrCutscenePlaying extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		return theGame.IsDialogOrCutscenePlaying();
	}
};


class CBTCondIsDialogOrCutscenePlayingDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsDialogOrCutscenePlaying';
};
