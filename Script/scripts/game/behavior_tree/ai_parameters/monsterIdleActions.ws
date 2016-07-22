// CAIMonsterIdleAction
abstract class CAIMonsterIdleAction extends IAIActionTree
{
	editable inlined var params : CAIMonsterIdleActionParams;

	function Init()
	{
		params = new CAIMonsterIdleActionParams in this;
		params.Init();
	}
};

// CAIMonsterIdleAction
abstract class CAIMonsterFlyIdleAction extends CAIMonsterIdleAction
{
	function Init()
	{
		params = new CAIMonsterFlyIdleActionParams in this;
		params.Init();
	}
};

// CAIMonsterIdleActionParams
class CAIMonsterIdleActionParams extends CAISubTreeParameters
{
	editable var cooldown 		: float;
	editable var loopTime 		: float;
	editable var actionName		: name;
	editable var onlyOnGround 	: bool;
	
	default cooldown = 5.0;
	default onlyOnGround = true;
};

// CAIMonsterFlyIdleActionParams
class CAIMonsterFlyIdleActionParams extends CAIMonsterIdleActionParams
{
	editable var minDistanceFromGround 		: float;
};

// CAIMonsterIdleEat
class CAIMonsterIdleEat extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.cooldown = 20.0;
		params.loopTime = 10.0;
		params.actionName = 'Eat';
		
	}
};

// CAIMonsterIdleDig
class CAIMonsterIdleDig extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.loopTime = 10.0;
		params.actionName = 'Dig';
		
	}
};

// CAIMonsterIdleClean
class CAIMonsterIdleClean extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.loopTime = 5.0;
		params.actionName = 'Clean';
	}
};

// CAIMonsterIdleOnGroundAndClean
class CAIMonsterIdleOnGroundAndClean extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.cooldown = 100.0;
		params.loopTime = 30.0;
		params.actionName = 'OnGroundAndClean';
	}
};

// CAIMonsterIdleSit
class CAIMonsterIdleSit extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.cooldown = 60.0;
		params.loopTime = 30.0;
		params.actionName = 'Sit';
	}
};

// CAIMonsterIdleSit
class CAIMonsterIdleLie extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.cooldown = 60.0;
		params.loopTime = 30.0;
		params.actionName = 'Lie';
	}
};

// CAIMonsterIdleOnGround
class CAIMonsterIdleOnGround extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.cooldown = 60.0;
		params.loopTime = 30.0;
		params.actionName = 'OnGround';
	}
};

// CAIMonsterIdleHowl
class CAIMonsterIdleHowl extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_howl";

	function Init()
	{
		super.Init();
		
		params.cooldown = 60.0;
		params.loopTime = 5.0;
	}
};

// CAIMonsterIdleSleep
class CAIMonsterIdleSleep extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.cooldown = 200.0;
		params.loopTime = 100.0;
		params.actionName = 'Sleep';
	}
};

// CAIMonsterIdleRoll
class CAIMonsterIdleRoll extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'Roll';
	}
};

// CAIMonsterIdleStretch
class CAIMonsterIdleStretch extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'Stretch';
	}
};

// CAIMonsterIdleCough
class CAIMonsterIdleCough extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'Cough';
	}
};

// CAIMonsterIdleStrikeFists
class CAIMonsterIdleStrikeFists extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'StrikeFists';
	}
};

// CAIMonsterIdleGrowl
class CAIMonsterIdleGrowl extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'Growl';
	}
};

// CAIMonsterIdleWings
class CAIMonsterIdleWings extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'Wings';
	}
};

// CAIMonsterIdleLookAround
class CAIMonsterIdleLookAround extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		params.cooldown = 0;
		params.actionName = 'LookAround';
	}
};

// CAIMonsterIdleYawn
class CAIMonsterIdleYawn extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'Yawn';
	}
};

// CAIMonsterIdleSniff
class CAIMonsterIdleSniff extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.actionName = 'Sniff';
	}
};

// CAIMonsterIdleTail
class CAIMonsterIdleTail extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_slot";

	function Init()
	{
		super.Init();
		
		params.cooldown = 20.0;
		params.loopTime = 10.0;
		params.actionName = 'Tail';
	}
};



// CAIMonsterIdleFlyBarrel
class CAIMonsterIdleFlyBarrel extends CAIMonsterFlyIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_flying_idle_action_slot";

	function Init()
	{
		super.Init();		
		params.actionName = 'FlyBarrel';
	}
};

// CAIMonsterIdleFlyAirDive
class CAIMonsterIdleFlyAirDive extends CAIMonsterFlyIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_flying_idle_action_slot";

	function Init()
	{
		var flyingParams : CAIMonsterFlyIdleActionParams;
		super.Init();		
		params.actionName = 'FlyAirDive';
		flyingParams = ((CAIMonsterFlyIdleActionParams) params);
		flyingParams.minDistanceFromGround = 13;
	}
};

// CAIMonsterIdlePlayAround
class CAIMonsterIdlePlayAround extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_play_around_idle";

	function Init()
	{
		super.Init();		
		params.cooldown = 10.0;
	}
};

// CAIAnimalRunWild
class CAIAnimalRunWild extends CAIDynamicWander
{
	editable var packRegroupEvent 	: name;
	editable var leaderRegroupEvent : name;
	
	default aiTreeName = "resdef:ai\idle/animal_run_wild_idle";
	
	default packRegroupEvent 	= 'PackRunsWild';
	default leaderRegroupEvent 	= 'LeaderMoves';
	
	default dynamicWanderMoveDuration = 15;
};


// CAIMonsterIdleFlyOnCurve
class CAIMonsterIdleFlyOnCurve extends CAIMonsterIdleAction
{
	default aiTreeName = "resdef:ai\idle/monster_idle_action_fly_on_curve";

	function Init()
	{
		super.Init();
		
		this.params = new CAIMonsterIdleFlyOnCurveParamsDefault in this;
		this.params.Init();
	}
};

// CAIMonsterIdleFlyOnCurveParamsDefault
class CAIMonsterIdleFlyOnCurveParamsDefault extends CAIMonsterIdleActionParams
{
	editable var curveTag				: name;
	editable var rotateBeforeTakeOff	: bool;
	
	editable var animationName			: name;
	editable var curveDummyName			: string;
	editable var blendInTime			: float;
	editable var slotAnimation			: name;
		
	editable var animValPitch			: string;
	editable var animValYaw				: string;
	editable var maxPitchInput			: float;
	editable var maxPitchOutput			: float;
	editable var maxYawInput			: float;
	editable var maxYawOutput			: float;
	

	default animationName			= 'Move';
	default blendInTime				= 2.0;
	
	default animValPitch			= "FlyPitch";
	default animValYaw				= "FlyYaw";
	default maxPitchInput			= 15.0;
	default maxPitchOutput			= 1.0;
	default maxYawInput				= 30.0;
	default maxYawOutput			= 1.0;
};