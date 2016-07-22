/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for Community System
/** Copyright © 2012-2013
/***********************************************************************/

import class CCommunitySystem extends IGameSystem
{
	import var communitySpawnInitializer : ISpawnTreeInitializerAI;
	
	function Init()
	{
		communitySpawnInitializer = new ISpawnTreeInitializerCommunityAI in this;
		communitySpawnInitializer.Init();
	}
};

// Debug stuff

import function DumpCommunityAgentsCPP();
exec function DumpCommunityAgents()
{
	DumpCommunityAgentsCPP();
}