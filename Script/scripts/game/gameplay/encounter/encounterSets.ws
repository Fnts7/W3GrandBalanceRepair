/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Encounter System Creature Sets
/** Copyright © 2013
/***********************************************************************/

import class ISpawnTreeBaseNode extends CObject
{
	import var nodeName	: name;
}

import class ISpawnTreeBranch extends ISpawnTreeBaseNode
{
}

import class ISpawnTreeDecorator extends ISpawnTreeBranch
{
}

import class ISpawnTreeScriptedDecorator extends ISpawnTreeDecorator
{
	// function OnActivate( encounter : CEncounter ) : IScriptable;
	
	// function OnDeactivate( encounter : CEncounter );
	
	// latent function Main( userData : IScriptable );
	
	// function OnFullRespawn( encounter : CEncounter );
	
	// function GetFriendlyName() : string;
}
class CRatClue_SpawnTreeDecorator extends ISpawnTreeScriptedDecorator
{
	function OnActivate( encounter : CEncounter ) : IScriptable
	{
		return NULL;
	}
	
	function OnDeactivate( encounter : CEncounter )
	{//
		
	}

	function GetFriendlyName() : string
	{
		return "RatClueDecorator";
	}
	// Returns to end the fun
	latent function Main( userData : IScriptable )
	{
		Swarm_DisableLair( 'lair_rats', false );
		//Swarm_DisablePOIs( 'poi_rats', false );
		Sleep( 5.0 );
		//Swarm_DisablePOIs( 'poi_rats', true );
		//RequestAllGroupsInstantDespawn( 'lair_rats', true );
		return;
	}
}


class CCrowClue_SpawnTreeDecorator extends ISpawnTreeScriptedDecorator
{
	function OnActivate( encounter : CEncounter ) : IScriptable
	{
		return NULL;
	}
	
	function OnDeactivate( encounter : CEncounter )
	{//
		
	}

	function GetFriendlyName() : string
	{
		return "CrowClueDecorator";
	}
	// Returns to end the fun
	latent function Main( userData : IScriptable )
	{
		Swarm_DisableLair( 'lair_crows', false );
		//FlyingSwarm_RequestCreateGroup( 'lair_crows', 50, 'FlyingSpawn1' );
		//FlyingSwarm_RequestCreateGroup( 'lair_crows', 50, 'FlyingSpawn2' );
		Sleep( 10.0 );
		FlyingSwarm_RequestAllGroupsInstantDespawn( 'lair_crows' );
		//Swarm_DisablePOIs_Quest( 'poi_crows', false );
		//Sleep( 6.0 );
		//Swarm_DisablePOIs_Quest( 'poi_crows', true );
		//Sleep( 6.0 );
		//Swarm_DisableLair( 'lair_crows', true );
		return;
	}
}