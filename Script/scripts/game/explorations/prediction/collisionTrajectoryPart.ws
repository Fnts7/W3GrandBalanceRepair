

//---------------------------------------------------------------------------------
//---------------------------------------------------------------------------------
class CollisionTrajectoryPart extends CPhantomComponent
{
	private 			var triggeredCollisions 		: int;
	private 			var	waterCollisions				: int;
	private 			var ownerTrajectory				: CollisionTrajectory;
	public	editable	var part						: ECollisionTrajectoryPart;
	private	editable	var	waterUpPosCheckSlotName		: name;
	private	editable	var	waterDownPosCheckSlotName	: name;
	
	
	//---------------------------------------------------------------------------------
	public function Initialize( owner : CollisionTrajectory )
	{
		triggeredCollisions	= 0;
		waterCollisions		= 0;
		ownerTrajectory		= owner;
	}
	
	//---------------------------------------------------------------------------------
	public function HasCollisions() : bool
	{
		//return GetNumObjectsInside();
		
		return triggeredCollisions	> 0;
	}	
	
	//---------------------------------------------------------------------------------
	event OnCollisionEnter( object : CObject, physicalActorindex : int, shapeIndex : int  )
	{
		var component : CComponent;
		
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		if( !IsValidCollider( component ) )
		{
			return false;
		}
		
		if( !component.GetEntity() )
		{
			waterCollisions += 1;
		}
		
		triggeredCollisions	+= 1;
	}
	
	//---------------------------------------------------------------------------------
	event OnCollisionExit( object : CObject, physicalActorindex : int, shapeIndex : int  )
	{
		var component : CComponent;
		
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
	
		if( !IsValidCollider( component ) )
		{
			return false;
		}
		
		if( !component.GetEntity() )
		{
			waterCollisions -= 1;
		}
		
		triggeredCollisions	= Max( triggeredCollisions - 1, 0 );
	}
	
	//------------------------------------------------------------------------------------------------------------------
	private function IsValidCollider( component :CComponent ) : bool
	{
		// Part of the trajectory
		if( component && ( CPhantomComponent ) component )
		{
			return false;
		}
		
		// owner
		if( component.GetEntity() == ownerTrajectory.stateManager.m_OwnerE )
		{
			return false;
		}
		
		return true;
	}	
	
	//------------------------------------------------------------------------------------------------------------------
	public function GetDebugText() : string
	{
		return "   " + part + " " + triggeredCollisions; // GetNumObjectsInside(); //
	}
	
	//------------------------------------------------------------------------------------------------------------------
	public function IsGoingToWater() : bool
	{
		var positionUp		: Vector;
		var positionDown	: Vector;
		var slotMatrix		: Matrix;
		
		
		GetEntity().CalcEntitySlotMatrix( waterUpPosCheckSlotName, slotMatrix );
		positionUp		= MatrixGetTranslation( slotMatrix );
		GetEntity().CalcEntitySlotMatrix( waterDownPosCheckSlotName, slotMatrix );
		positionDown	= MatrixGetTranslation( slotMatrix );
		
		
		return ownerTrajectory.stateManager.m_CollisionManagerO.IsThereWaterAndIsItDeepEnough( positionUp, positionDown.Z, 0.4f );
	}
}
