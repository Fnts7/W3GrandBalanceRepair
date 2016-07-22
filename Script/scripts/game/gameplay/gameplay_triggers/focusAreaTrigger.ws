/***********************************************************************/
/** Copyright © 2013
/** Author : collective mind of the CDP
/***********************************************************************/

// Disabled, functionality moved to focus clues themselves

class W3FocusAreaTrigger extends CGameplayEntity
{

	private const var rumbleIntensityModifier : float;
	private var isDisabled : bool; default isDisabled = false;
	default rumbleIntensityModifier = 1.0;

	editable saved var intensity 	: float;
	saved var isActive				: bool;
	default isActive				= false;
	
	editable var linkedClues : array < EntityHandle >;
	editable var linkedCluesTags : array < name >;

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		/*Only player can activate area
		if ( activator.GetEntity() != thePlayer && !isDisabled )
		{
			return false;
		}
		
		//Connecting area with linked clues
		this.SetupClueConnections();
		
		isActive = true;
		theGame.GetFocusModeController().SetFocusAreaIntensity( intensity * rumbleIntensityModifier );
		*/
	}	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		/* Only player can deactivate area
		if ( activator.GetEntity() != thePlayer && !isDisabled )
		{
			return false;
		}
		
		isActive = false;
		theGame.GetFocusModeController().SetFocusAreaIntensity( 0.0f );
		*/
	}

	event OnAreaActivated( area : CTriggerAreaComponent, activated : bool )
	{
		/*
		if ( isActive && !activated )
		{
			theGame.GetFocusModeController().SetFocusAreaIntensity( 0.0f );		
			isActive = false;
		}
		*/
	}
	
	public function Disable()
	{
		isDisabled = true;
		ChangeFocusAreaIntensity ( 0.0f );
		
	}
	
	public function Enable()
	{
		isDisabled = false;
	}
	
	//Changes intensity of pad ramble and medallion shake
	public function ChangeFocusAreaIntensity ( newIntensity : float )
	{
		/*
		intensity = newIntensity; 
		
		if( newIntensity == 0)
		{
			if( isActive == true )
			{
				isActive = false;
				theGame.GetFocusModeController().SetFocusAreaIntensity( 0.0f );	
			}
		}
		else
		{
			if( isActive == true )
			{
				theGame.GetFocusModeController().SetFocusAreaIntensity( newIntensity * rumbleIntensityModifier );	
			}	
		}
		*/
	}	
	
	//Setups connections between area and 
	private function SetupClueConnections()
	{
		var i : int;
		var k : int;
		var count : int;
		var linkedClueSize : int = linkedClues.Size();
		var ent : CEntity;
		var clue : W3MonsterClue;
		var clueEntities : array<CEntity>;
		
		for ( i = 0; i < linkedClueSize; i += 1 )
		{
			ent = EntityHandleGet( linkedClues[i] );
			clue = (W3MonsterClue) ent;
			
			if( clue )
			{
				clue.linkedFocusArea = this;
				count += 1;
				LogQuest( "Focus Area: linked clue added correctly");	
			}
			
		}
		
		for ( i=0; i <linkedCluesTags.Size(); i+= 1 )
		{
			theGame.GetEntitiesByTag( linkedCluesTags[i], clueEntities );
			
			for ( k=0; k <clueEntities.Size(); k+= 1 )
			{
				clue = (W3MonsterClue)clueEntities[i];
				
				if( clue )
				{
					clue.linkedFocusArea = this;
					count += 1;
					LogQuest( "Focus Area: linked clue added correctly");	
				}
			}
		}
		LogQuest( "Focus Area: Connections processed: "+IntToString(i));
	}
	
	
	//Used in monster clues to handle automatic focus area intensity
	public function SmartFocusAreaCheck ()
	{
		var i : int;
		var k : int;
		var linkedClueSize : int = linkedClues.Size();
		var ent : CEntity;
		var clue : W3MonsterClue;
		var shouldBeActive : bool = false;
		var clueEntities : array<CEntity>;
		
		
		for ( i = 0; i < linkedClueSize; i += 1 )
		{
			ent = EntityHandleGet( linkedClues[i] );
			clue = (W3MonsterClue) ent;
			
			if( clue )
			{
				if( clue.wasDetected == false )
				{
					shouldBeActive =  true;
				}
				
			}
			
		}		
		
		for ( i=0; i <linkedCluesTags.Size(); i+= 1 )
		{
			theGame.GetEntitiesByTag( linkedCluesTags[i], clueEntities );
			
			for ( k=0; k <clueEntities.Size(); k+= 1 )
			{
				clue = (W3MonsterClue)clueEntities[i];
				
				if( clue )
				{
					if( clue.wasDetected == false )
					{
						shouldBeActive =  true;
					}	
				}
			}
		}
		//Should Focus Area be deactivated? 
		if( shouldBeActive == true )
		{
			if( intensity > 1.0 )
			{
				this.ChangeFocusAreaIntensity( intensity - 1.0 );
				LogQuest( "Focus Area: Smart clue changed intensity to: "+FloatToString(intensity));	
			}
			else
			{
			LogQuest( "Focus Area: Intensity already at 1, no change due to smart clue" );
			}
		}
		else
		{
			this.ChangeFocusAreaIntensity( 0.0 );
			LogQuest( "Focus Area: Smart clue changed intensity to: "+FloatToString(intensity));	
		}
		
	}
	
}

