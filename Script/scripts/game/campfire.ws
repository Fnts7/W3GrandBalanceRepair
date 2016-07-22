/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Campfires need to turn off if there's no one around
/** Copyright © 2014 
/** Author: Shadi Dadenji
/***********************************************************************/
 

class W3Campfire extends CGameplayEntity
{
	editable var dontCheckForNPCs : bool;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if( !dontCheckForNPCs )
		{
			AddTimer('CheckForNPCs', 3.0, true);
		}
	}

	event OnDestroyed()
	{
		if( !dontCheckForNPCs )
		{
			RemoveTimer('CheckForNPCs');
		}
	}
	
		
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		if ( activator == thePlayer && interactionComponentName == "ApplyDamage" )
		{
			ApplyDamage ();
			AddTimer ( 'ApplyDamageTimer', 3.0f, true );
		}
	}
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		if ( activator == thePlayer && interactionComponentName == "ApplyDamage"  )
		{
			RemoveTimer ( 'ApplyDamageTimer' );
		}
	}
	
	function ApplyDamage ()
	{
		if ( IsOnFire() )
		{
			thePlayer.AddEffectDefault(EET_Burning, this, 'environment');
		}
	}
	
	timer function ApplyDamageTimer ( dt : float, id : int )
	{
		ApplyDamage ();
	}
	
	timer function CheckForNPCs( dt : float, id : int )
	{
		var range : float;
		var entities : array< CGameplayEntity >;
		var i : int;
		var actor : CActor;

		//we only perform the check if the player is OUTSIDE a certain radius from the campfire's pos
		range = 30.f;
		if ( VecDistanceSquared( GetWorldPosition(), thePlayer.GetWorldPosition() ) <= range*range )
			return;

		FindGameplayEntitiesInRange(entities, this, 20.0, 10,, 2);

		//no entities found so no people, turn fire off
		if ( entities.Size() == 0 )
		{
			ToggleFire( false );		
		}
		else
		{
			//one live npc is enough to turn the light on
			for ( i = 0; i < entities.Size(); i+=1 )
			{
				actor = (CActor)entities[i];

				//we've found one person, light up and exit
				if ( actor.IsHuman() )
				{
					ToggleFire( true );
					return;
				}
			}
			
			//we finished the loop and found no people (they would've been caught in the if up there)
			//so the fire goes out
			ToggleFire( false );
		}
	}

	function IsOnFire () : bool
	{
		var gameLightComp : CGameplayLightComponent;		
		gameLightComp = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');
		
		return gameLightComp.IsLightOn();
	}
	
	function ToggleFire( toggle : bool )
	{
		var gameLightComp : CGameplayLightComponent;		
		gameLightComp = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');

		if(gameLightComp)
			gameLightComp.SetLight( toggle );		
	}
}	
