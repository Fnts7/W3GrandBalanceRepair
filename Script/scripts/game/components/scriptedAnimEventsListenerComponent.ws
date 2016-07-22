/***********************************************************************/
/** Copyright © 2013
/** Author : collective mind of the CDP
/***********************************************************************/

class CScriptedAnimEventsListenerComponent extends CScriptedComponent
{
	var listeners : array< CComponent >;

	/*event OnComponentAttached()
	{
		var actor : CActor;
		actor = (CActor)GetEntity();
		if ( actor )
		{
			actor.AddAnimEventListener( this );
		}	
	}
	
	public function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var i, size : int;
		size = listeners.Size();
		for ( i = size - 1; i >= 0; i-=1 )
		{
			listeners[i].SignalCustomEvent( animEventName );
		}
	}
	
	public function RegisterListener( component : CComponent, flag : bool )
	{
		if ( flag )
		{
			if ( listeners.FindFirst( component ) == -1 )
			{
				listeners.PushBack( component );
			}		
		}
		else
		{
			listeners.Remove( component );
		}
	}*/
}