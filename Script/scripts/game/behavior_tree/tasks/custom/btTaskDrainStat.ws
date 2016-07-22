// it only works for stamina, vitality and essence. you need to add more if you need them
class BTTaskDrainStat extends IBehTreeTask
{
	var stat : EBaseCharacterStats;
	var val : float;
	var onActivate : bool;

	function OnActivate() : EBTNodeStatus
	{
		if( onActivate )
		{
			Execute();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( !onActivate ) 
		{
			Execute();
		}
	}
	
	private function Execute()
	{
		switch( stat )
		{
			case BCS_Stamina:
				GetNPC().DrainStamina( ESAT_FixedValue, val );
				break;
			
			case BCS_Vitality:
				GetNPC().DrainVitality( val );
				break;
			
			case BCS_Essence:
				GetNPC().DrainEssence( val );
				break;
			
			default:
				break;
		}
	}
}

class BTTaskDrainStatDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskDrainStat';

	editable var stat : EBaseCharacterStats;
	editable var val : float;
	editable var onActivate : bool;
	
	default stat = BCS_Stamina;
	default onActivate = true;
}