/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/

enum PhysicalSwitchAnimationType
{
	PSAT_Undefined,
	PSAT_Lever,
	PSAT_Button,
}

abstract class W3PhysicalSwitch extends W3Switch
{
	editable			var switchOnAnimationType	: PhysicalSwitchAnimationType;		default switchOnAnimationType = PSAT_Undefined;
	editable			var switchOffAnimationType	: PhysicalSwitchAnimationType;		default switchOffAnimationType = PSAT_Undefined;
	
	protected			var showActorAnimation		: bool;								default showActorAnimation = true;
	
	hint switchOnAnimationType = "Type of animation that to play when switching ON";
	hint switchOffAnimationType = "Type of animation that to play when switching OFF";	
	
	protected function ActivateEvents( events : array<W3SwitchEvent>)
	{		
		if ( showActorAnimation )
		{
			//display anims for actor & switch depending on type, must be synced
		}
		else
		{
			//just the switch animation depending on type
		}
		
		//activate events
		super.ActivateEvents( events );
	}
	
	public function Enable( enable : bool )
	{		
		super.Enable( enable );
	}
	
	public function Lock( lock : bool )
	{
		super.Lock( lock );
	}
	
}
