
class CR4LocomotionSwimToStop extends CR4LocomotionDirectControllerScript
{
	var player 		: CR4Player;
	var targetPoint	: Vector;
	var closeEnough	: bool;
	
	
	function Activate() : bool
	{
		var exploration : SExplorationQueryToken;
		
		player		= (CR4Player)agent.GetEntity();
		
		// Where do we want to orient to?
		exploration	= thePlayer.substateManager.m_SharedDataO.GetLastExploration();
		targetPoint	= exploration.pointOnEdge;
		
		// Init data
		closeEnough	= false;
		
		
		return super.Activate();
	}

	function Deactivate()
	{
		player.UpdateRequestedDirectionVariables_PlayerDefault();
		
		super.Deactivate();
	}
	
	function UpdateLocomotion()
	{
		var direction		: Vector;
		var directionYaw	: float;
		
		
		//previousSpeed = player.GetBehaviorVariable( 'playerSpeed');
		
		// Get the target orientation
		direction		= targetPoint - player.GetWorldPosition();
		directionYaw	= VecHeading( direction );
		directionYaw	= AngleNormalize180( AngleDistance( player.GetHeading(), directionYaw ) );
		directionYaw	= ClampF( directionYaw, -90.0f, 90.0f ) / 90.0f;
		closeEnough		= AbsF( directionYaw ) < 0.3f;
		
		player.GetMovingAgentComponent().ResetMoveRequests();
		//player.SetBehaviorVariable( 'playerDir', directionYaw);
		//player.SetBehaviorVariable( 'playerInputAngSpeed', angularInputSpeed);
	}
	
	public function GetIsCloseEnough() : bool
	{
		return closeEnough;
	}
};
