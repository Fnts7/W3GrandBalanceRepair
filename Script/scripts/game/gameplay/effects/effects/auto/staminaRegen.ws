/***********************************************************************/
/** Copyright © 2012-2013
/** Author : Rafal Jarczewski, Tomek Kozera
/***********************************************************************/

// Automatic stamina regeneration - set this up in entity template
class W3Effect_AutoStaminaRegen extends W3AutoRegenEffect
{
	private var regenModeIsCombat : bool;		//set to true if we're in combat regen mode
	private var cachedPlayer : CR4Player;
	
		default regenStat = CRS_Stamina;	
		default effectType = EET_AutoStaminaRegen;
		default regenModeIsCombat = true;		//defaults to true as 'staminaRegen' is default attributeName for buff and is used in combat
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		regenModeIsCombat = true;
		
		if(isOnPlayer)
			cachedPlayer = (CR4Player)target;
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		if(isOnPlayer)
			cachedPlayer = (CR4Player)target;
	}
	
	event OnUpdate(dt : float)
	{
		if(isOnPlayer)
		{
			//switch regen between combat and out of combat
			if ( regenModeIsCombat != cachedPlayer.IsInCombat() )
			{
				regenModeIsCombat = !regenModeIsCombat;
				if(regenModeIsCombat)
					attributeName = RegenStatEnumToName(regenStat);
				else
					attributeName = 'staminaOutOfCombatRegen';
					
				SetEffectValue();			
			}
			
			//change regen if in guard stance
			if ( cachedPlayer.IsInCombat() )
			{
				if ( thePlayer.IsGuarded() )
					effectValue = target.GetAttributeValue( 'staminaRegenGuarded' );
				else
				{
					attributeName = RegenStatEnumToName(regenStat);
					SetEffectValue();
				}
			}
		}

		super.OnUpdate( dt );
		
		if( target.GetStatPercents( BCS_Stamina ) >= 1.0f )
		{
			target.StopStaminaRegen();
		}
	}
	
	protected function SetEffectValue()
	{
		effectValue = target.GetAttributeValue(attributeName);
	}
}
