class CBTTask3StageIdle extends IBehTreeTask
{
	editable var minTime : float;
	editable var maxTime : float;
	var loopTime 	: float;
	
	latent function Main() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		var time : float;
		
		time = RandRangeF( maxTime, minTime );
		
		Sleep( time );
		
		owner.SetBehaviorVariable( 'IdleLoopEnd', 1 );
		owner.WaitForBehaviorNodeDeactivation( 'IdleEnd', 1.5f );
		
		return BTNS_Completed;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		
		owner.RaiseEvent( '3StateIdle' );
		owner.SetBehaviorVariable( 'IdleLoopEnd', 0 );
		owner.SetBehaviorVariable( 'IdleAnim', RandRange( 2 ) );
		
		return BTNS_Active;
	}
}

class CBTTask3StateIdleDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTask3StageIdle';

	editable var minTime : float;
	editable var maxTime : float;
	
	default minTime = 5.f;
	default maxTime = 8.f;
}