
class W3DebugScriptBehaviorToolComponent extends CSpriteComponent
{
	//var owner		: CEntity;
	//var controller 	: CombatMovementController;
	
	event OnEditorEnabled( e : CEntity )
	{
		//owner = e;
		
		//controller = new CombatMovementController in this;
		//controller.Init( owner );
	}
	
	event OnEditorDisabled()
	{
		//controller.Deinit();
		//delete controller;
	}
	
	event OnTick( dt : float )
	{
		//var orient, rot : float;
		
		//orient = owner.GetBehaviorVariable( 'torsoOrientation' );
		//rot = owner.GetBehaviorVariable( 'a' );
		
		//controller.Update( theTimer.timeDelta, orient, rot );
	}
}
