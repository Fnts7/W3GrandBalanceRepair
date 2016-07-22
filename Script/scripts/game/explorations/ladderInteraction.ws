// W3LadderInteraction
//------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------
// (Eduard Lopez Plans) 	27/10/2014
//------------------------------------------------------------------------------------------------------------------

class W3LadderInteraction extends CGameplayEntity
{
	public editable var associatedDoorTag : name;
	default associatedDoorTag = '';
	var associatedDoor : W3NewDoor;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var components : array< CComponent >;
		var ic : CInteractionComponent;
		var i, size : int;
		
		// PB:
		// Hackfix for patch 1.1 (TTP 112159)
		// This should be fixed in the assets, but since we are limited by patch size we need to do it that way.
		// Once it will be (hopefully) fixed in assets for patch 1.3 this piece of code should be removed.
		if ( associatedDoorTag == '' && this.HasTag( 'q305_ladder_midgets_cellar' ) )
		{
			associatedDoorTag = 'q305_midgets_trapdoor';
		}

		// if there is associated door, we force scripted test in components
		if ( associatedDoorTag )
		{
			components = GetComponentsByClassName( 'CInteractionComponent' );
			size = components.Size();
			for ( i = 0; i < size; i+=1 )
			{
				ic = (CInteractionComponent)components[i];
				if ( ic )
				{
					ic.performScriptedTest = true;
				}
			}
		}
	}

	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		if ( associatedDoorTag )
		{
			if ( !associatedDoor )
			{
				associatedDoor = (W3NewDoor)theGame.GetNodeByTag( associatedDoorTag );
			}
			if ( associatedDoor && !associatedDoor.IsOpen() )
			{
				return false;
			}
		}
		return true;
	}
	
	/*
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if ( actionName == "ClimbLadder" )
		{
			GetComponent("ClimbLadder").SetEnabled(false);
		}
	}
	*/
	
	
	private function PlayerHasLadderExplorationReady() : bool
	{
		if( !thePlayer.substateManager.CanInteract() )
		{
			return false;
		}
		
		if( !thePlayer.substateManager.m_SharedDataO.HasValidLadderExploration() )
		{
			return false;
		}
		
		return true;
	}
}