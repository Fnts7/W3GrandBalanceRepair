/***********************************************************************/
/** Copyright © 2014
/** Author : Łukasz Szczepankowski
/***********************************************************************/

class W3QuestCond_playerKnowsSchematics_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_playerKnowsSchematics;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition )
		{
			condition.EvaluateImpl();
		}	
	}
}

class W3QuestCond_playerKnowsSchematics extends CQuestScriptedCondition
{
	editable var schematicsName : name;
	var isFulfilled				: bool;
	var listener				: W3QuestCond_playerKnowsSchematics_Listener;
		
	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_playerKnowsSchematics_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListener( GetGlobalEventCategory( SEC_CraftingSchematics ), listener );
			EvaluateImpl();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListener( GetGlobalEventCategory( SEC_CraftingSchematics ), listener );
			delete listener;
			listener = NULL;		
		}
	}

	function Activate()
	{
		EvaluateImpl();
		if ( !isFulfilled )
		{
			RegisterListener( true );
		}		
	}
	
	function Deactivate()
	{
		if ( listener )
		{
			RegisterListener( false );
		}
	}

	function Evaluate() : bool
	{
		if ( !isFulfilled && !listener )
		{
			RegisterListener( true );
		}	
		return isFulfilled;	
	}

	function EvaluateImpl()
	{
		var craftingSchematics			: array<name>;
		var i							: int;
		var	player						: W3PlayerWitcher;
		
		player = (W3PlayerWitcher)thePlayer;
		if ( player )
		{		
			craftingSchematics = player.GetCraftingSchematicsNames();
			for ( i=0; i < craftingSchematics.Size(); i+=1 )
			{
				if ( schematicsName == craftingSchematics[i] )
				{
					isFulfilled = true;
					return;
				}
			}
		}
		
		isFulfilled = false;
	}
}