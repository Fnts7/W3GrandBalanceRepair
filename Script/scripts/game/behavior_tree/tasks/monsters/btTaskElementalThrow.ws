/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Patryk Fiutowski
/***********************************************************************/

class CBTTaskElementalThrow extends IBehTreeTask
{
	var physicalComponent : CMeshComponent;
	var objectEntity : CEntityTemplate;
	var object : CEntity;
	
	function OnActivate() : EBTNodeStatus
	{
		GetActor().PlayEffect('fire_hand');
		
		return BTNS_Active;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		var resultForce : Vector;
		var spawnPos, targetPos : Vector;
		
		var owner : CActor = GetActor();
		var objectRot : EulerAngles;
		var objectPos : Vector;
		
		if ( physicalComponent && ( animEventName == 'Throw' ) && object )
		{
			//GetActor().BreakChildAttachment( physicalComponent, 'arm' );
			//objectEntity.BreakAttachment();
			
			spawnPos = physicalComponent.GetWorldPosition();
			targetPos = GetCombatTarget().GetWorldPosition();
			
			//physicalComponent.SetVisible(true);
			object.PlayEffect('fire_fx');
			GetActor().StopEffect('fire_hand');
			
			if ( GetCombatTarget() == thePlayer )
			{
				if ( !thePlayer.IsInCombatAction() )
				{
					//FIXME this does not mean that the player is or will move, he can use radial menu or be immobilized at the same time
					//      also this is a copy paste from PickUpAndThrow task - why?
					//if player is pushing stick
					if(theInput.GetActionValue( 'GI_AxisLeftX' ) != 0 || theInput.GetActionValue( 'GI_AxisLeftY' ) != 0)
						targetPos += 1.5*VecNormalize(VecFromHeading(thePlayer.rawPlayerHeading));
				}
			}
			//targetPos = (targetPos - spawnPos);
			//targetPos.Z += 2;
			
			//resultForce = VecNormalize(targetPos - spawnPos)*20;
			resultForce = targetPos - spawnPos;
			resultForce = VecNormalize( resultForce );
			
			resultForce *= 20;
			
			//resultForce.W = 1;
			
			//GetCombatTarget().SetOnContact();
			
			physicalComponent.SetPhysicalObjectLinearVelocity( resultForce );
			physicalComponent.SetPhysicalObjectAngularVelocity( resultForce );
			
			((W3MonsterElementalArm)object).SetIsActive(true);
			
			return true;
		}
		else if ( animEventName == 'Prepare' )
		{
			//matrix = entity.CalcEntitySlotMatrix( slotName );
			objectPos = owner.GetWorldPosition() + owner.GetHeadingVector();
			objectRot = owner.GetWorldRotation();
			objectPos.Z += 5.5;
			object = theGame.CreateEntity( objectEntity, objectPos, objectRot );
			
			physicalComponent = (CMeshComponent)(object.GetComponentByClassName('CRigidMeshComponent'));
			
			if( physicalComponent )
			{
				physicalComponent.SetVisible(false);
			}
			
			//object.CreateAttachment(owner,slotName);
			
			((W3MonsterElementalArm)object).SetOwner( owner );
			//object.PlayEffect('fire_fx');
		}
		
		return false;
	}
	
}

class CBTTaskElementalThrowDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskElementalThrow';

	editable var objectEntity : CEntityTemplate;
}
