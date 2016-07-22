/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Example gameplay device
/** Copyright © 2012 CD projekt RED
/***********************************************************************/

statemachine class W3FloeEntity extends W3DestroyableTerrain
{
	var m_currentFxID	: int;
	default 			m_currentFxID = 1;
	
	private				var entryTime	: float;
	private				var timerInterval	: float;
	
	default 			timerInterval = 0.0100f;
	default 			entryTime = 0.0f;
	default				autoState = 'OnIdle';
	
	var rot : EulerAngles;
	
	function EnableEffectOne(stop : bool)
	{
		if(!stop)
		{
			StopEffect('fire1');
		}
		else
		{
			PlayEffect('fire1');
		}
	}
	
	function EnableEffectTwo(stop : bool)
	{
		if(!stop)
		{
			StopEffect('fire2');
		}
		else
		{
			PlayEffect('fire2');
		}
	}
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		m_componentName = "CFloePiece";
		
		super.OnSpawned(spawnData);
		
		AddTimer( 'tickTimer', timerInterval, true );
		
		GotoStateAuto();
	}
	
	timer function tickTimer( time : float, id : int)
	{
		var floatHeadingCross: Vector;
		var playerHeading : Vector;
		
		var mpac : CMovingPhysicalAgentComponent;
		var dir : Vector;
		var pos : Vector;
		var diff : Vector;
		
		var arrowA : Vector;
		var arrowB : Vector;

		var rotAngle : float;
		var side : int;
		
		var offset : Vector;
		var slideDir : Vector;
		var mat : Matrix;
		
		entryTime+=time;
		
		rot = super.GetWorldRotation();
		
		rot.Yaw=0;//SinF(entryTime)*0.01f; //obrot
		
		rot.Pitch=SinF(entryTime*2)*0.5f; // poziom
		
		pos = super.GetWorldPosition();
		
		if(m_player)
		{
			mpac = (CMovingPhysicalAgentComponent)m_player.GetMovingAgentComponent();
			/*
			slideDir.X = 0;
			slideDir.Z = 0.01f;
			slideDir.Y = (-rot.Pitch );
			
			pos = mpac.GetAgentPosition();
			pos.Z += 0.1f;

			mpac.ApplyVelocity(slideDir);
			
			mpac.SetRotation(rot);
			*/
		}
		
		//super.TeleportWithRotation(super.GetWorldPosition(),rot);
	}
	
	function Split()
	{
		var pieceID : int;
		var comp : CFloePiece;
		
		comp = (CFloePiece)super.GetDestroyableElement(0,m_currentFxID-1);
		comp.DestroyTick(0);
		
		if(m_currentFxID==1)
		{
			EnableEffectOne(false);
		}
		else if(m_currentFxID==2)
		{
			EnableEffectTwo(false);
		}
		
		m_currentFxID = m_currentFxID + 1;
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		super.OnAreaEnter(area,activator);
	
		PushState( 'OnPreDestroy' );
	}	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		super.OnAreaExit(area,activator);
	}
	
};	

state OnIdle in W3FloeEntity
{
	private				var entryTime	: float;
	private				var timerInterval	: float;
	
	default 			timerInterval = 0.100f;
	default 			entryTime = 0.0f;
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		OnSwimInit();
		
		entryTime = 0;
		
		parent.AddTimer( 'tickTimerSwim', timerInterval, true );
	}
	
	event OnLeaveState( prevStateName : name )
	{
		super.OnLeaveState( prevStateName );
		
		parent.RemoveTimer('tickTimerSwim');
		entryTime=0;
	}
	
	
	entry function OnSwimInit()
	{
	}
	
	timer function tickTimerSwim( time : float, id : int)
	{
		entryTime+=time;
		if(entryTime>10)
		{
			//parent.PushState('OnPreDestroy');
		}
		
	}
}

state OnPreDestroy in W3FloeEntity
{
	private				var entryTime	: float;
	private				var timerInterval	: float;
	
	default 			timerInterval = 0.100f;
	default 			entryTime = 0.0f;
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		entryTime = 0;
		
		OnPreSplitInit();
	}
	
	
	event OnLeaveState( prevStateName : name )
	{
		super.OnLeaveState( prevStateName );
		parent.RemoveTimer('tickTimerPreSplit');
	}
	
	entry function OnPreSplitInit()
	{
		if(parent.m_currentFxID==1)
		{
			parent.EnableEffectOne(true);
		}
		else if(parent.m_currentFxID==2)
		{
			parent.EnableEffectTwo(true);
		}
		
		parent.AddTimer('tickTimerPreSplit', timerInterval, true );
		
	}
	
	timer function tickTimerPreSplit( time : float, id : int)
	{
		var comp : CFloePiece;
		
		comp = (CFloePiece)parent.GetDestroyableElement(0,parent.m_currentFxID-1);
		comp.PreDestroyTick(time);
		
		entryTime+=time;
		
		if(entryTime > 10.0f)
		{
			parent.PushState( 'OnDestroy' );
		}
	}
}

state OnDestroy in W3FloeEntity
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		OnSplitInit();
	}
	
	event OnLeaveState( prevStateName : name )
	{
		super.OnLeaveState( prevStateName );
	}
	entry function OnSplitInit()
	{
		parent.Split();
		parent.PopState( true );
	}
}
