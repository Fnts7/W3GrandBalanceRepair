//This is searching for currently mount head instead of the current head in head manager to work with custom heads as well
class W3QuestCond_PlayerHead extends CQuestScriptedCondition
{
	editable var headItemName : name;
	editable var inverted : bool;
	
	function Evaluate() : bool
	{
		var currentHeadName : name;
		var headsMatch : bool;
		var ids : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		var i: int;
		
		inv = thePlayer.GetInventory();
		ids = inv.GetItemsByCategory( 'head' );
		
		for( i=0; i < ids.Size(); i +=  1 )
		{
			if( inv.IsItemMounted( ids[i] ) )
			{
				currentHeadName = inv.GetItemName( ids[i] );
			}
		}
		
		if( currentHeadName == headItemName  )
			headsMatch = true;
		else
			headsMatch = false;
		
		if ( !inverted )
		{
			return headsMatch;
		}
		else
		{
			return !headsMatch;
		}
	}
}

class W3QuestCond_IsGeraltShaved extends CQuestScriptedCondition
{
	editable var inverted : bool;
	
	function Evaluate() : bool
	{
		var currentHeadName : name;
		var headsMatch : bool;
		var ids : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		var i: int;
		
		inv = thePlayer.GetInventory();
		ids = inv.GetItemsByCategory( 'head' );
		
		for( i=0; i < ids.Size(); i +=  1 )
		{
			if( inv.IsItemMounted( ids[i] ) )
			{
				currentHeadName = inv.GetItemName( ids[i] );
			}
		}
		
		if( currentHeadName == 'head_0' || currentHeadName == 'head_0_tattoo' )
			headsMatch = true;
		else
			headsMatch = false;
		
		if ( !inverted )
		{
			return headsMatch;
		}
		else
		{
			return !headsMatch;
		}
	}
}