/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2014
/** Author : Dennis Zoetebier
/***********************************************************************/
class W3TrapWolfPit extends W3Trap
{
	//>---------------------------------------------------------------------
	// VARIABLES
	//----------------------------------------------------------------------
	//private editable var alarmSoundString		: string;
	//>---------------------------------------------------------------------
	//----------------------------------------------------------------------
	/*
	public function Activate( optional _Target: CNode ):void
	{
		SoundEvent( alarmSoundString );
		super.Activate( _Target );
	}
	*/
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var l_actor	: CActor;
		l_actor = (CActor) activator.GetEntity();
		
		l_actor.Kill( 'Trap', true );
	}	
	
}