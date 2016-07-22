﻿///////////////////////////////
//  Copyright © 2016		 //
//	Author: Andrzej Zawadzki //
///////////////////////////////

class W3Effect_WellRested extends CBaseGameplayEffect
{
	default effectType = EET_WellRested;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		var l_bed			: W3WitcherBed;
		
		l_bed = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );
		
		// Having the best quality bed (level 2) grants the buff doubled, that's why the ability is being applied here for the second time
		if( l_bed.GetBedLevel() == 2 )
		{
			target.AddAbility( abilityName, true );
		}
		theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "message_common_well_rested_buff_applied" ),, true );
		
		super.OnEffectAdded( customParams );	
	}	
	
	event OnEffectRemoved()
	{
		target.RemoveAbilityAll( abilityName );
		
		super.OnEffectRemoved();
	}
	
	protected function CalculateDuration( setInitialDuration : bool )
	{
		var l_bed				: W3WitcherBed;
		var l_min, l_max			: SAbilityAttributeValue;
		
		if( isOnPlayer )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( abilityName, 'duration', l_min, l_max );
			duration = l_min.valueAdditive;
			
			l_bed = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );
			
			if( l_bed.GetBedLevel() == 2 )
			{
				duration *= 2;
			}
		}
		
		super.CalculateDuration( true );
	}
}