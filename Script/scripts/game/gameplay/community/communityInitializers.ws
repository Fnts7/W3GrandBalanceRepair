class CSpawnTreeInitializerSetImmortality extends ISpawnTreeScriptedInitializer
{
	editable var immortalityMode : EActorImmortalityMode;
	var previousImmortalityMode : EActorImmortalityMode;

	function GetEditorFriendlyName() : string
	{
		return "SetImmortality";
	}
	
	function Init( actor : CActor ) : bool
	{
		var npc : CNewNPC;
		previousImmortalityMode = actor.GetImmortalityMode();
		actor.SetImmortalityMode( immortalityMode, AIC_Default );
		npc = (CNewNPC)actor;
		if ( npc )
			npc.SetImmortalityInitialized();
			
		return true;
	}
	
	function DeInit( actor : CActor ) : bool
	{
		actor.SetImmortalityMode( previousImmortalityMode, AIC_Default );
		return true;
	}
};