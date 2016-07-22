//>--------------------------------------------------------------------------
// W3MedallionFX
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Class used for medallion ping, might still be useful
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Andrzej Kwiatkowski
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------

class W3MedallionFX extends CEntity
{
	var scaleVector			: Vector;
	var medallionScaleRate	: float;
	var effectDuration		: float;
	
	private autobind medallionComponent : CComponent = "CMeshComponent medalion";
	
	default effectDuration = 1.0f;
	default medallionScaleRate = 1.0f;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		AddTimer( 'ScaleMedallion', 0.01f, true );
		AddTimer( 'DestroyMedallionFX', effectDuration, false );
	}
	
	function TriggerMedallionFX()
	{
		var rot				: EulerAngles;
		var pos 			: Vector;
		var spawnedEntity	: CEntity;
		var entityTemplate	: CEntityTemplate;

		entityTemplate = (CEntityTemplate)LoadResource('medallion_fx');		
		pos = thePlayer.GetWorldPosition();
		
		spawnedEntity = theGame.CreateEntity( entityTemplate, pos, rot );
		spawnedEntity.PlayEffect( 'medalion_fx' );
	}
	
	timer function DestroyMedallionFX( deltaTime : float , id : int)
	{
		RemoveTimer( 'ScaleMedallion' );
		Destroy();
	}
	
	timer function ScaleMedallion( deltaTime : float , id : int)
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		
		medallionScaleRate += 15.0f * deltaTime;
		scaleVector.X = medallionScaleRate;
		scaleVector.Y = medallionScaleRate;
		scaleVector.Z = medallionScaleRate;
		
		if( medallionComponent )
		{
			medallionComponent.SetScale( scaleVector );
		}
		
		witcher.HighlightObjects( medallionScaleRate );
	}
}