class W3Effect_AutoPanicRegen extends W3AutoRegenEffect
{
	default effectType = EET_AutoPanicRegen;
	default regenStat = CRS_Panic;
	
	event OnUpdate(dt : float)
	{
		super.OnUpdate( dt );
		
		if( target.GetStatPercents( BCS_Panic ) >= 1.0f )
		{
			target.StopPanicRegen();
		}
	}
}