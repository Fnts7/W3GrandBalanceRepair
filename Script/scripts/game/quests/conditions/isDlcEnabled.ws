enum EQuestConditionDLCType
{
	QCDT_Undefined,
	QCDT_EP1,
	QCDT_EP2,
	QCDT_NGP,
}

class W3QuestCond_IsDLCEnabled extends CQuestScriptedCondition
{
	editable var dlc : EQuestConditionDLCType;
	editable var invert : bool;
	
	function Evaluate() : bool
	{
		var result : bool;
		
		if( dlc == QCDT_Undefined )
		{
			return false;
		}
		
		if( dlc == QCDT_EP1 )
		{
			result = theGame.GetDLCManager().IsEP1Enabled();
			
			if( invert )
			{
				return !result;
			}
			else
			{
				return result;
			}
		}
		else if( dlc == QCDT_EP2 )
		{
			result = theGame.GetDLCManager().IsEP2Enabled();
			
			if( invert )
			{
				return !result;
			}
			else
			{
				return result;
			}
		}
		else if( dlc == QCDT_NGP )
		{
			result = theGame.GetDLCManager().IsDLCEnabled( 'dlc_009_001' );
			
			if( invert )
			{
				return !result;
			}
			else
			{
				return result;
			}
		}
		
		return false;
	}
}
