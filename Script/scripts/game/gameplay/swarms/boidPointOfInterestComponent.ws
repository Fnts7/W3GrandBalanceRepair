import class CBoidPointOfInterestComponent extends CComponent
{
	import function Disable( disable : bool );
};


import class CBoidPointOfInterestComponentScript  extends CBoidPointOfInterestComponent
{
	function OnUsed(count : int, deltaTime : float)
	{
	}
};

class CFoodBoidPointOfInterest  extends CBoidPointOfInterestComponentScript
{
	editable var expirationTime : int;
	
	private var useCounter : float;
			var entity : CEntity;
			var poiDisp : W3POIDispenser;
			var poi : W3PointOfInterestEntity;
	
	default useCounter 	= 0.0;
	default expirationTime = 20;
	
	function OnUsed(count : int, deltaTime : float)
	{			
		useCounter += deltaTime * count;
		// if one boid uses the food for expirationTime sec, despawn/deactivate the entity :
		if ( useCounter > expirationTime )
		{
			entity = this.GetEntity();
			
			poi = (W3PointOfInterestEntity)entity;
			if(poi)
			{				
				poiDisp = poi.GetDispenser();
				
				if( poi.CanBeDestroyed() )
				{
					poiDisp.DespawnPOI( poi );
				}
				else
				{
					poiDisp.DeactivatePOI( poi );
				}
			}
			else
			{
				entity.GetComponentByClassName( 'CFoodBoidPointOfInterest' ).SetEnabled( false );
				//this.GetEntity().Destroy();
			}
		}
	}
};