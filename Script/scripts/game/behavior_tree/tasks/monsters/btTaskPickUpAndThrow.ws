/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Patryk Fiutowski
/***********************************************************************/

class CBTTaskPickUpAndThrow extends IBehTreeTask
{
	var projectileTemplate : CEntityTemplate;
	
	var proj : W3AdvancedProjectile;
	
	var range : float;
	var tag : name;
	var angleDist : float;
	
	var slotName : name;
	
	var pickUp : bool;
	
	var dodgeable : bool;

	var physicalComponent : CComponent;
	
	var wantedHeadingVec : Vector;
	
	default pickUp = false;

	latent function Main() : EBTNodeStatus
	{
		var components : array< CComponent >;
		var npc : CNewNPC = GetNPC();
		var object : W3EnvironmentThrowable;
		var size : int;
		var i : int;
		var angleDist : float;
		var heading : float;
		var ass : SAnimatedSlideSettings;
	
		ResetAnimatedSlideSettings( ass );
		
		/*
		object = (W3EnvironmentThrowable)this.GetActionTarget();
		
		if ( !object )
		{
			return BTNS_Failed;
		}
		*/
//		phantom component needs to used here
		//components = object.GetComponents();
	
		//physicalComponent = (CComponent)this.GetActionTarget();
		
		if ( physicalComponent && physicalComponent.HasDynamicPhysic() )
		{
		}
		else if ( !projectileTemplate )
		{
			return BTNS_Failed;
		}
		
		/*
		size = components.Size();
		for( i = 0; i < size; i += 1 )
		{
			if( ! components[ i ].HasDynamicPhysic() ) continue;
		
			physicalComponent = components[ i ];
			break;
		}*/

		angleDist = NodeToNodeAngleDistance(GetCombatTarget(), npc);
		if ( angleDist > 0 )
		{
			npc.SetBehaviorVariable( 'TurnDirection', 0 );
			slotName = 'r_middle1';
			ass.animation = 'monster_cave_troll_throw_l';
		}
		else
		{
			npc.SetBehaviorVariable( 'TurnDirection', 1 );
			slotName = 'l_middle1';
			ass.animation = 'monster_cave_troll_throw_r';
		}
		
		ass.slotName = 'GAMEPLAY_SLOT';
		
		//if ( !npc.RaiseForceEvent('Throw') )
		//{
		//	return BTNS_Failed;
		//}
		
		//angleDist = NodeToNodeAngleDistance(GetCombatTarget(), npc);
		heading = npc.GetHeading() + angleDist;
		AngleNormalize180( heading );
		
		npc.ActionAnimatedSlideToStatic(ass,npc.GetWorldPosition(),heading,false,false);
		
		
		//npc.WaitForBehaviorNodeDeactivation('Throw',3.0);
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( GetActor().HasChildAttachment(physicalComponent) )
			GetActor().BreakChildAttachment( physicalComponent, slotName );
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc : CNewNPC = GetNPC();
		var component : CComponent;
		
		if ( eventName == 'RotateEventStart' )
		{
			// TODO rotate?
			return true;
		}
		else if ( eventName == 'Throwable' )
		{
			component = (CComponent)GetEventParamObject();
			if ( component.HasDynamicPhysic() )
			{
				physicalComponent = component;
			}
			return true;
		}
		
		return false;
	}
	
	function ScaleAnim()
	{
		var npc : CNewNPC = GetNPC();
		var ass : SAnimatedSlideSettings;
		var angleDist : float;
		var heading : float;
		
		if( slotName =='r_middle1' )
			ass.animation = '';
		else
		{
		
		}
		
		angleDist = NodeToNodeAngleDistance(GetCombatTarget(), npc);
		heading = npc.GetHeading() + angleDist;
		AngleNormalize180( heading );
		//npc.ActionAnimatedSlideToStatic(ass,npc.GetWorldPosition(),heading,false,true);
		
	}
	
	function SpawnAndAttach()
	{
		//var proj : W3AdvencedProj;
		var res : bool;
		
		proj = (W3AdvancedProjectile)(theGame.CreateEntity(projectileTemplate,GetActor().GetWorldPosition()));
		
		res = proj.CreateAttachment(GetActor(), slotName);
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var resultForce : Vector;
		var spawnPos, targetPos : Vector;
		var tempvec : Vector;
		var projectileFlightTime, distanceToTarget : float;
		
		if ( animEventName == 'PickUp' )
		{
			pickUp = true;
			if ( projectileTemplate )
				SpawnAndAttach();
			else
				GetActor().CreateChildAttachment( physicalComponent, slotName );
				
			//ScaleAnim();
			
			return true;
		}
		if ( animEventName == 'Throw' )
		{
			if ( proj )
			{
				proj.BreakAttachment();
				proj.Init(GetActor());
				targetPos = GetCombatTarget().GetWorldPosition();
				targetPos.Z += 1.5;
				proj.ShootProjectileAtPosition(proj.projAngle,proj.projSpeed, targetPos);
				
				if ( dodgeable )
				{
					distanceToTarget = VecDistance( npc.GetWorldPosition(), target.GetWorldPosition() );		
					
					// used to dodge projectile before it hits
					projectileFlightTime = distanceToTarget / proj.projSpeed;
					target.SignalGameplayEventParamFloat('Time2DodgeProjectile', projectileFlightTime );
				}
				
				return true;
			}
			else if ( projectileTemplate )
			{
				return false;
			}
			GetActor().BreakChildAttachment( physicalComponent, slotName );
			
			spawnPos = physicalComponent.GetWorldPosition();
			targetPos = GetCombatTarget().GetWorldPosition();
			
			if ( GetCombatTarget() == thePlayer )
			{
				if ( !thePlayer.IsInCombatAction() )
				{
					//FIXME this does not mean that the player is or will move, he can use radial menu or be immobilized at the same time
					//if player is pushing stick
					if(theInput.GetActionValue( 'GI_AxisLeftX' ) != 0 || theInput.GetActionValue( 'GI_AxisLeftY' ) != 0)
						targetPos += 1.5*VecNormalize(VecFromHeading(thePlayer.rawPlayerHeading));
				}
			}
			//targetPos = (targetPos - spawnPos);
			targetPos.Z += 2;
			
			//resultForce = VecNormalize(targetPos - spawnPos)*20;
			resultForce = targetPos - spawnPos;
			resultForce = VecNormalize( resultForce );
			
			resultForce *= 50;
			
			tempvec = physicalComponent.GetPhysicalObjectLinearVelocity();
			
			//resultForce.W = 1;
			
			//GetCombatTarget().SetOnContact();
			
			physicalComponent.SetPhysicalObjectLinearVelocity( resultForce );
			physicalComponent.SetPhysicalObjectAngularVelocity( resultForce );
			
			return true;
		}
		if ( animEventName == 'AllowBlend' )
		{
			Complete(true);
		}
		return false;
	}
}

class CBTTaskPickUpAndThrowDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskPickUpAndThrow';

	editable var projectileTemplate : CEntityTemplate;
	editable var dodgeable : bool;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'Throwable' );
	}
}
