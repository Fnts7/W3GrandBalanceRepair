class CBTTaskImlerithBreakAttachment extends IBehTreeTask
{
	var rigidMeshComp : CRigidMeshComponent;
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if( animEventName == 'BreakAttachmentShield' )
		{
			GetNPC().shieldDebris.BreakAttachment();
			rigidMeshComp = (CRigidMeshComponent)GetNPC().shieldDebris.GetComponentByClassName( 'CRigidMeshComponent' );
			rigidMeshComp.SetEnabled( true );
			//rigidMeshComp.ApplyForceAtPointToPhysicalObject( Vector( 0, 0, -10 ), GetNPC().shieldDebris.GetWorldPosition() );
			
			return true;
		}
		
		return false;
	}
};

class CBTTaskImlerithBreakAttachmentDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskImlerithBreakAttachment';
};