/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Łukasz Szczepankowski
/***********************************************************************/

class W3treasureHuntContainer extends W3Container
{
	editable inlined var OnLootedEvents : array< W3SwitchEvent >;		
	
	
	
	public function OnContainerClosed()
	{
		if ( IsEmpty() )
		{
			ProcessOnLootedEvents ();
		}
		super.OnContainerClosed();
	}
	
	function ProcessOnLootedEvents ()
	{
		ActivateEvents ( OnLootedEvents );
	}
	
	private function ActivateEvents( events : array< W3SwitchEvent > )
	{
		var i, size : int;
		
		size = events.Size();
		for( i = 0; i < size; i += 1 )
		{
			if ( events[ i ] )
			{
				events[ i ].TriggerArgNode( this, thePlayer );
			}
		}
	}

}