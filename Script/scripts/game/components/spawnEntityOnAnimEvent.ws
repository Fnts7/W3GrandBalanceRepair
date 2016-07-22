//>--------------------------------------------------------------------------
// W3SpawnEntityOnAnimEvent
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Extension of CScriptedComponent - spawns entities through Anim Events.
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Brad Lansford & Ryan Pergant - 18-April-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class W3SpawnEntityOnAnimEvent extends CScriptedComponent
{
	editable var animEvent 		: name;
	editable var entityName		: name;
	
	default animEvent = 'SpawnEntityEvent';
	
	hint animEvent = "Animation Event Name";
	hint entityName = "Resource Name";
	
	private var entityTemplate	: CEntityTemplate;
	//>---------------------------------------------------------------
	//----------------------------------------------------------------
	event OnComponentAttached()
	{
		var l_actor : CActor;
		l_actor = (CActor) GetEntity();
		if( l_actor )
		{
			l_actor.AddAnimEventChildCallback(this,animEvent,'OnAnimEvent_Custom');
		}	
		
		entityTemplate = (CEntityTemplate) LoadResource( entityName );
	}
	
	
	event OnAnimEvent_Custom( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SpawnEntity();
	}
	//Spawn Entity
	function SpawnEntity()
	{
		var spawnPos 			: Vector;
		var entity 				: CEntity;
		var damageAreaEntity 	: CDamageAreaEntity;
		
		// End if resource is NOT an Entity
		if( !entityTemplate )
		{
			return;
		}
		
		spawnPos = GetEntity().GetWorldPosition();
		entity = theGame.CreateEntity( entityTemplate, spawnPos, GetEntity().GetWorldRotation() );
		damageAreaEntity = (CDamageAreaEntity)entity;
		if ( damageAreaEntity )
		{
			damageAreaEntity.owner = (CActor) GetEntity();
		}
	}
}