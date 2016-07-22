/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CR4FinishersDLCMounter
/** Copyright © 2015
/***********************************************************************/

import class CR4FinisherDLC extends CObject
{
	import public var finisherAnimName : name;
	import public var woundName : name;
	import public var finisherSide : EFinisherSide;
	import public var leftCameraAnimName : name;
	import public var rightCameraAnimName : name;
	import public var frontCameraAnimName : name;
	import public var backCameraAnimName : name;
	
	import public function IsFinisherForAnim( eventAnimInfo : SAnimationEventAnimInfo ) : bool;
}

import class CR4FinishersDLCMounter extends IGameplayDLCMounter
{
	private function LoadFinisher( finisher: CR4FinisherDLC ) : void
	{
		if( finisher.finisherSide == FinisherLeft )
		{
			theGame.GetSyncAnimManager().AddDlcFinisherLeftSide( finisher );
		}
		else if( finisher.finisherSide == FinisherRight )
		{
			theGame.GetSyncAnimManager().AddDlcFinisherRightSide( finisher );
		}
	}
	
	private function UnloadFinisher( finisher: CR4FinisherDLC ) : void
	{	
		if( finisher.finisherSide == FinisherLeft )
		{
			theGame.GetSyncAnimManager().RemoveDlcFinisherLeftSide( finisher );
		}
		else if( finisher.finisherSide == FinisherRight )
		{
			theGame.GetSyncAnimManager().RemoveDlcFinisherRightSide( finisher );
		}
	}
}