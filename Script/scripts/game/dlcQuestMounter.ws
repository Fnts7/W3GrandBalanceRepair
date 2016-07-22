/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CR4QuestDLCMounter
/** Copyright © 2015
/***********************************************************************/

import class CR4QuestDLCMounter extends IGameplayDLCMounter
{
	private function LoadQuestLevels( filePath: string ) : void
	{
		theGame.LoadQuestLevels( filePath );
	}
	
	private function UnloadQuestLevels( filePath: string ) : void
	{	
		theGame.UnloadQuestLevels( filePath );
	}
}