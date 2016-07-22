/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2014
/** Author : Dennis Zoetebier
/***********************************************************************/

class W3SE_ManageClue extends W3SwitchEvent
{
	editable var clueHandle : array<EntityHandle>;
	editable var clueTag	: name;
	editable var operations	: array< EClueOperation >;
	var myTags : array < name >;
	
	hint clueHandle = "Array of clues selected on the level";
	hint clueTag	= "Tag of the clues";
	hint operations	= "Operations to perform on all above clues";
	
	public function PerformArgNode( parnt : CEntity, node : CNode )
	{
		var clueEntity	: W3MonsterClue;
		var entities	: array<CEntity>;
		var i 			: int;
		var activator 	: CActor;
		var notAClueEntity : CEntity;
		var notAClueEntityName : string;
		
		activator  = ( CActor )node;
		
		// If we get entities by handle, handle them.
		if (clueHandle.Size() > 0)
		{
			for( i = 0; i < clueHandle.Size(); i += 1 )
			{
				clueEntity = (W3MonsterClue) EntityHandleGet( clueHandle[i] );
				if ( !clueEntity )
				{
					notAClueEntity = EntityHandleGet( clueHandle[i] );
					if (notAClueEntity)
					{
						notAClueEntityName = notAClueEntity.GetName();
						LogAssert( false, "Handled entity array" + notAClueEntityName + " contains an entity which is not a W3MonsterClue" );
					}
					else
					{
						LogAssert( false, "Handled entity array links to an item which can't be found. Deleted?" );
					}
				}
				else
				{
					clueEntity.OnManageClue( operations );
				}
			}
		}
		
		// If we get entities by tag, handle them.
		if (clueTag)
		{
			theGame.GetEntitiesByTag( clueTag, entities );
			
			if ( entities.Size() == 0 )
			{
				LogAssert( false, "No entities found with tag <" + clueTag + ">" );
				return;
			}
			for ( i = 0; i < entities.Size(); i += 1 )
			{
				clueEntity = (W3MonsterClue)entities[ i ];
				if ( !clueEntity )
				{
					LogAssert( false, "Entity with tag <" + clueTag + "> is not a W3MonsterClue" );
				}
				else
				{
					clueEntity.OnManageClue( operations );
				}
			}
		}
	}
}