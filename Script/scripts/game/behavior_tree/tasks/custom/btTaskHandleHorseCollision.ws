class BTTaskHandleHorseCollision extends BTTaskGameplayEventListener
{	
	function IsAvailable() : bool
	{
		return super.IsAvailable();
	}
	
	function OnActivate() : EBTNodeStatus
	{	
		return super.OnActivate();
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if( this.isActive )
			return false;
			
		if( GetNPC().IsHorse() && GetNPC().GetCanFlee() && GetNPC().GetHorseComponent().IsDismounted() )
		{
			SetCustomTarget( GetNPC().GetWorldPosition(), 0.0 );
			SetEventRetvalInt( 1 );
			return super.OnListenedGameplayEvent( eventName );
		}
		else
		{
			SetEventRetvalInt( 0 );
			return false;
		}
	}
}

class BTTaskHandleHorseCollisionDef extends BTTaskGameplayEventListenerDef
{
	default instanceClass = 'BTTaskHandleHorseCollision';
}