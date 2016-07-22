class W3ReplacerChanger extends W3GameplayTrigger
{
	editable var replacerTemplate : String;
	var recentlyChanged : bool;
	default recentlyChanged = false;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( activator.GetEntity() == thePlayer )
		{
			if( !recentlyChanged )
			{
				recentlyChanged = true;
				theGame.ChangePlayer( replacerTemplate );
			}
			else
			{
				recentlyChanged = false;
			}
		}
	}
}