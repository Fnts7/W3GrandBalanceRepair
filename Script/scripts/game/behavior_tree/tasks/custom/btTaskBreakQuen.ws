class CBTTaskBreakQuen extends IBehTreeTask
{
	private var onActivate : bool;

	function OnActivate() : EBTNodeStatus
	{
		if( onActivate )
		{
			BreakQuen();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( !onActivate )
		{
			BreakQuen();
		}
	}
	
	private function BreakQuen()
	{
		thePlayer.FinishQuen( false );
	}
}

class CBTTaskBreakQuenDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskBreakQuen';

	editable var onActivate : bool;

	default onActivate = true;
}