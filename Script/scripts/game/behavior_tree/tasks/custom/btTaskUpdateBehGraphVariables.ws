//>----------------------------------------------------------------------
// Update various variables used in the NPC Behavior graph
//-----------------------------------------------------------------------
// Copyright © 2014
// Author : R.Pergent - 17-March-2014
//-----------------------------------------------------------------------
class CBTTaskUpdateBehGraphVariables extends IBehTreeTask
{
	//>----------------------------------------------------------------------
	// VARIABLES
	//-----------------------------------------------------------------------
	var updateOnlyOnActivate		: bool;
	var DistanceToTarget			: bool;
	var AngleToTarget				: bool;
	var TargetIsOnGround			: bool;
	var predictionDelay				: float;
	var useCombatTarget				: bool;
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	latent function Main() : EBTNodeStatus
	{	
		while( !updateOnlyOnActivate )
		{
			Update();
			SleepOneFrame();
		}		
		return BTNS_Active;
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function OnActivate() : EBTNodeStatus
	{
		if( !updateOnlyOnActivate ) return BTNS_Active;		
		Update();		
		return BTNS_Active;
	}
	//>----------------------------------------------------------------------
	//-----------------------------------------------------------------------
	function Update()
	{
		var l_npc							: CNewNPC = GetNPC();
		var l_target 						: CNode;
		var l_targetPos, l_npcPos 			: Vector;
		var l_toTarget, l_npcForward		: Vector;
		var l_toTargetAngle, l_npcAngle		: EulerAngles;
		var l_toTargetYaw, l_npcForwardYaw	: float;
		var l_oppositeYaw					: float;
		var l_angleValue					: float;
		
		if( useCombatTarget )
		{
			l_target 	= GetCombatTarget();
		}
		else
		{
			l_target 	= GetActionTarget();
		}
		
		if( predictionDelay <= 0 || !((CActor) l_target) )
		{
			l_targetPos = l_target.GetWorldPosition();
		}
		else
		{
			l_targetPos = ((CActor) l_target).PredictWorldPosition( predictionDelay );
		}
		
		l_npcPos	= l_npc.GetWorldPosition();
		
		if( DistanceToTarget )
		{
			l_npc.SetBehaviorVariable( 'DistanceToTarget', VecDistance( l_targetPos, l_npcPos ) );
		}
		
		if( AngleToTarget )
		{
			
			l_toTarget 		= l_targetPos - l_npcPos;
			l_npcForward 	= l_npc.GetWorldForward();
			
			l_npcAngle 		= VecToRotation( l_npcForward );
			l_toTargetAngle = VecToRotation( l_toTarget   );
			
			l_npcForwardYaw = l_npcAngle.Yaw;
			l_toTargetYaw 	= l_toTargetAngle.Yaw;	
			
			// POSITIVE value : target is on my RIGHT
			// NEGATIVE value : target is on my LEFT
			l_angleValue = AngleDistance( l_npcForwardYaw, l_toTargetYaw );
			l_npc.SetBehaviorVariable( 'AngleToTarget', l_angleValue );
			
		}
		
		if( TargetIsOnGround && (CActor) l_target)
		{
			if( ((CActor) l_target).HasBuff( EET_Knockdown ) ||  ((CActor) l_target).HasBuff( EET_HeavyKnockdown ) )
			{
				l_npc.SetBehaviorVariable( 'TargetIsOnGround', 1 );
			}
			else
			{
				l_npc.SetBehaviorVariable( 'TargetIsOnGround', 0 );
			}
		}
	}
}
//>----------------------------------------------------------------------
//-----------------------------------------------------------------------
class CBTTaskUpdateBehGraphVariablesDef extends IBehTreeTaskDefinition
{	
	default instanceClass = 'CBTTaskUpdateBehGraphVariables';
	
	//-----------------------------------------------------------------------
	editable var updateOnlyOnActivate		: bool;
	editable var DistanceToTarget			: bool;
	editable var AngleToTarget				: bool;
	editable var TargetIsOnGround			: bool;
	editable var predictionDelay			: float;
	editable var useCombatTarget			: bool;
	
	default DistanceToTarget 	= true;
	default AngleToTarget 		= true;
	default TargetIsOnGround 	= true;
	default useCombatTarget 	= true;
	
	default predictionDelay		= 0.5f;
};