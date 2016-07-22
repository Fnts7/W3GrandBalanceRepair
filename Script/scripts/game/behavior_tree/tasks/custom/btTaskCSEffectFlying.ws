/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Patryk Fiutowski
/***********************************************************************/

class CBehTreeTaskCSEffectFlying extends CBehTreeTaskCSEffect
{
	var wasFlying 					: bool;
	var waitingForEndOfDisableHit	: bool;
	
	default wasFlying = false;	
	
	function OnActivate() : EBTNodeStatus
	{
		var owner : CNewNPC = GetNPC();
		var distToGround : float;
		
		owner.SetBehaviorVariable('ForceExitCSEffect', 0);
		
		if ( owner.GetCurrentStance() == NS_Fly )
		{
			owner.SetBehaviorVariable( 'GroundContact', 0.0 );
			distToGround = GetActor().GetDistanceFromGround( 20 );
			owner.SetBehaviorVariable( 'DistanceFromGround', distToGround );
			
			
			//if ( owner.GetMovingAgentComponent().IsFlying() && CSType != ECST_Hypnotized && CSType != ECST_Confusion )
			owner.SetBehaviorVariable( '5AnimCriticalState', 1.0 );
			owner.EnablePhysicalMovement( true ); // enable physics
			((CMovingPhysicalAgentComponent)owner.GetComponentByClassName('CMovingPhysicalAgentComponent')).SetAnimatedMovement( true );
			wasFlying = true;
				
			forceFinisherActivation = true;
		}
		else 
		{
			owner.SetBehaviorVariable( '5AnimCriticalState', 0.0 );
		}
	
		
		
		return super.OnActivate();
	}
	
	latent function Main() : EBTNodeStatus
	{
		var owner 					: CNewNPC = GetNPC();
		var groundPos, normal		: Vector;
		
		while ( wasFlying )
		{
			if (  owner.IsOnGround() || theGame.GetWorld().StaticTrace ( owner.GetWorldPosition(), owner.GetWorldPosition() - Vector( 0,0,0.15f), groundPos, normal ) )
			{				
				OnGroundContact();
				
				if( ShouldEnableFinisher() )
				{
					EnableFinisher();
				}
				
				wasFlying = false;
			}
			
			SleepOneFrame();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var owner : CNewNPC = GetNPC();
		
		super.OnDeactivate();
		
		if ( wasFlying )
		{
			if ( owner.IsOnGround() )
			{
				OnGroundContact();
			}
			else // If is still flying
			{
				((CMovingPhysicalAgentComponent)owner.GetComponentByClassName('CMovingPhysicalAgentComponent')).SetAnimatedMovement( true );
				owner.EnablePhysicalMovement( true ); // enable physics
				owner.SetBehaviorVariable('ForceExitCSEffect', 1); // In case the branch gets interrupted by a scripted action, stop the critical falling animation
			}
		}
		
		if ( waitingForEndOfDisableHit )
			owner.SetCanPlayHitAnim( true );
		
		waitingForEndOfDisableHit = false;
		wasFlying = false;
		forceFinisherActivation = false;
	}
	
	function OnGroundContact()
	{
		var owner 	: CNewNPC = GetNPC();
		var mac 	: CMovingPhysicalAgentComponent;
		owner.SetBehaviorVariable( 'GroundContact', 1.0 );		
		
		mac = ((CMovingPhysicalAgentComponent)owner.GetMovingAgentComponent());
		owner.ChangeStance( NS_Wounded );
		mac.SetAnimatedMovement( false );
		owner.EnablePhysicalMovement( false );
		mac.SnapToNavigableSpace( true );
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var owner : CNewNPC;
		var res : bool;
		var mac 	: CMovingPhysicalAgentComponent;
		
		res = super.OnAnimEvent(animEventName,animEventType,animInfo);
		
		if ( animEventName == 'DisableHitAnim'  )
		{
			owner = GetNPC();
			if( animEventType == AET_DurationEnd )
			{
				owner.SetCanPlayHitAnim( true );
				waitingForEndOfDisableHit = false;
			}
			else
			{			
				owner.SetCanPlayHitAnim( false );
				waitingForEndOfDisableHit = true;
			}
		}
		return res;
	}
}

class CBehTreeTaskCSEffectFlyingDef extends CBehTreeTaskCSEffectDef
{
	default instanceClass = 'CBehTreeTaskCSEffectFlying';
}
