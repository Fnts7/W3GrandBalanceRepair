class CBTTaskOlgierdPhantomAttack extends IBehTreeTask
{	
	private var phantomTemplate : CEntityTemplate;
	private var phantom : W3CiriPhantom;

	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if( animEventName == 'PhantomR' )
		{
			//SpawnPhantomWithAnim( GetNPC().GetWorldPosition(), GetNPC().GetWorldRotation(), true );
			return true;
		}
		else if( animEventName == 'PhantomL' )
		{
			//SpawnPhantomWithAnim( GetNPC().GetWorldPosition(), GetNPC().GetWorldRotation(), false );
			return true;
		}
		
		return false;
	}
	
	private function SpawnPhantomWithAnim( position : Vector, rotation : EulerAngles, rightSide : bool  )
	{
		//var animComp : CAnimatedComponent;
		var res : bool;

		phantom = (W3CiriPhantom)theGame.CreateEntity( phantomTemplate, position, rotation );
		
		if( phantom )
		{	
			if( rightSide )
			{
				phantom.RaiseEvent( 'PhantomR' );
			}
			else
			{
				phantom.RaiseEvent( 'PhantomL' );
			}
			
			//animComp = (CAnimatedComponent)phantom.GetComponentByClassName( 'CAnimatedComponent' );
			//if( animComp )
			//{
				//res = animComp.PlaySlotAnimationAsync( animationName, 'GAMEPLAY_SLOT' );
			//}
			
		}
	}
	
	function OnDeactivate()
	{
		phantom.Destroy();
	}
	
	function Initialize()
	{
		phantomTemplate = (CEntityTemplate)LoadResource( 'olgierd_phantom' );
	}
}

class CBTTaskOlgierdPhantomAttackDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskOlgierdPhantomAttack';
}