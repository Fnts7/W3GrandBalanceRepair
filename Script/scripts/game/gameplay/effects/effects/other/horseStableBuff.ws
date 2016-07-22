///////////////////////////////
//  Copyright © 2016		 //
//	Author: Andrzej Zawadzki //
///////////////////////////////
class W3Effect_HorseStableBuff extends CBaseGameplayEffect
{
	var m_ownerHorse		: CNewNPC;
	
	default effectType = EET_HorseStableBuff;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams)
	{		
		m_ownerHorse = GetWitcherPlayer().GetHorseWithInventory();
		
		if( m_ownerHorse && !m_ownerHorse.HasAbility( 'HorseStableBuff' ) )
		{
			m_ownerHorse.AddAbility( 'HorseStableBuff' );
		}
		theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "message_common_stables_buff_buff_applied" ),, true );
		
		super.OnEffectAdded( customParams );
	}
	
	event OnEffectRemoved()
	{
		var abs		: array<name>;
		
		if( m_ownerHorse )
		{
			m_ownerHorse.RemoveAbility( 'HorseStableBuff' );
		}
		
		super.OnEffectRemoved();
	}
}