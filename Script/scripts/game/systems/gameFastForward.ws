/***********************************************************************/
/** Copyright © 2014
/** Author : Slovian
/***********************************************************************/

import class CGameFastForwardSystem extends IGameSystem
{
	import function BeginFastForward( optional dontSpawnHostilesClose : bool /* = false */, optional coverWithBlackscreen : bool  );
	import function AllowFastForwardSelfCompletion();
	import function RequestFastForwardShutdown( optional coverWithBlackscreen : bool /* = false */);
	import function EndFastForward();
};