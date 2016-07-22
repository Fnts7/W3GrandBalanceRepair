/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

import class CR4InteriorAreaComponent extends CTriggerAreaComponent
{
	editable var isDarkPlace : bool;	
		default isDarkPlace = false;
		hint isDarkPlace = "If set area is considered a dark place (player should use torch / cat potion)";
	
	editable var allowHorseInThisInterior : bool;
		default allowHorseInThisInterior = false;
		hint allowHorseInThisInterior = "If left at false Geralt won't be able to mount, summon or ride horse inside this area and will be automatically dismount on enter";
	
	// Movement locking
	editable var movementLock : EPlayerMovementLockType;	default movementLock	= PMLT_NoSprint;
	
	//------------------------------------------------------------------------------------------------------------------
	event OnPlayerEntered( entered : bool )
	{
		switch( movementLock )
		{
			case PMLT_NoSprint :
				thePlayer.interiorTracker.LockSprint( entered );
			break;
			case PMLT_NoRun :
				thePlayer.interiorTracker.LockRun( entered );
			break;
		}
		
		/*
		if ( entered && !allowHorseInThisInterior )
		{
			if (  thePlayer.IsUsingHorse() )
			{
				thePlayer.GetUsedHorseComponent().OnForceStop();
				thePlayer.GetUsedHorseComponent().OnSmartDismount();
				thePlayer.interiorTracker.SetCurrentInterior((CNode)this);
				((CActor)thePlayer.GetUsedVehicle()).SignalGameplayEvent('PlayerEnteredInterior');
			}
			
			thePlayer.BlockAction(EIAB_MountVehicle,	'InteriorArea', true);
			thePlayer.BlockAction(EIAB_CallHorse,		'InteriorArea', true);
		}
		else
		{
			thePlayer.UnblockAction(EIAB_MountVehicle,	'InteriorArea');
			thePlayer.UnblockAction(EIAB_CallHorse,		'InteriorArea');
		}
		*/
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if(activator.GetEntity() != thePlayer)
			return false;
			
		//fact for dark places tutorial if trigger/entity has 'dark place' tag
		if(isDarkPlace)
			FactsAdd("tut_in_dark_place");
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		if(activator.GetEntity() != thePlayer)
			return false;
		
		//fact for dark places tutorial if trigger/entity has 'dark place' tag
		if(isDarkPlace)
		{
			FactsSubstract("tut_in_dark_place");
			
			//mutation adding cat fx
			if( FactsQuerySum( "tut_in_dark_place" ) <= 0 )
			{
				thePlayer.RemoveBuff( EET_Mutation12Cat );
			}
		}
	}
}