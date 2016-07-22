/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/**			 Rafal Jarczewski
/***********************************************************************/

/**

*/
class W3VirtualSwitch_Sequence extends W3VirtualSwitch
{
	private saved var nextSwitchIndex : int;						//index of the next switch to be triggered
	
	public function Notify( activeSwitch : W3Switch )
	{
		var i, activeSwitchIndex : int;
		var switchEntity : W3Switch;
		
		if( !IsAvailable() )
		{
			return;
		}
			
		for ( i = 0; i < requiredSwitches.Size(); i += 1 )
		{
			switchEntity = GetSwitchByTag( requiredSwitches[ i ].requiredSwitchTag );
			if ( switchEntity )
			{
				if ( switchEntity == activeSwitch )
				{
					activeSwitchIndex = i;
					break;
				}
			}
		}	
		
		if ( ( activeSwitchIndex != nextSwitchIndex ) ||
             ( activeSwitch.IsOff() && requiredSwitches[ activeSwitchIndex ].switchState == ERSS_ON ) ||
             ( activeSwitch.IsOn() && requiredSwitches[ activeSwitchIndex ].switchState == ERSS_OFF ) )
		{
			Fail( activeSwitch );
			return;
		}
					
		if( activeSwitchIndex == requiredSwitches.Size() - 1 )
		{
			// sequence completed, toggle virtual switch
			Toggle( NULL, false, false );
		}
		else
		{
			// wait for next switch
			nextSwitchIndex += 1;
		}
	}
	
	protected function Fail( failed : W3Switch )
	{
		super.Fail(failed);
		
		Reset( RSM_Default, RSM_Default, RSM_Default, true, true );
		ResetSwitches();
		nextSwitchIndex = 0;
	}

	protected function ResetSwitches()
	{
		var i, size : int;
		var switchEntity : W3Switch;
		
		size = requiredSwitches.Size();
		for( i = 0; i < size; i += 1 )
		{
			switchEntity = GetSwitchByTag( requiredSwitches[ i ].requiredSwitchTag );
			if ( switchEntity )
			{
				switchEntity.Reset( RSM_Default, RSM_Default, RSM_Default, true, true );
			}
		}		
	}
}