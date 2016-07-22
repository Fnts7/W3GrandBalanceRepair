/***********************************************************************/
/** Witcher Script file - Container controll class for herbs containers
/***********************************************************************/
/** Copyright © 2014
/** Author : Tomek Kozera
/***********************************************************************/

// Class to handle herb containers (bushes, shrubs etc.) - kept for backward compatibility
class W3Herb extends W3RefillableContainer //@FIXME Bidon - apply loot window mechanics
{
	protected optional autobind foliageComponent : CSwitchableFoliageComponent = single;
	protected var isEmptyAppearance : bool;
	
	// DO NOT DELETE, CALLED FROM C++
	function /* C++ */ GetStaticMapPinTag( out tag : name )
	{
		var items : array< SItemUniqueId >;
		
		tag = '';
		
		// MOVED TO C++
		/*
		if( thePlayer.IsInCombat() )
		{
			return;
		}
		if( FactsQuerySum( "disable_herbs_on_minimap" ) >= 1 )
		{
			return;
		}
		*/
		
		// this is wrong
		// but I can't rely on contents of W3RefillableContainer and need to check both CSwitchableFoliageComponent and current appearance
		// this all should be rewritted, but not at this point
		if ( foliageComponent )
		{
			if ( foliageComponent.GetEntry() == 'empty' )
			{
				return;
			}
		}
		else if ( isEmptyAppearance )
		{
			return;
		}
		if ( IsEmpty() )
		{
			return;
		}
		if ( !inv )
		{
			return;
		}
		if ( inv.GetItemCount() == 0 )
		{
			return;
		}
		inv.GetAllItems( items );
		tag = inv.GetItemName( items[ 0 ] );
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnStreamIn();
		
		if( inv.IsEmpty() )
		{
			AddTimer( 'Refill', 20, true );
		}
	
		if(lootInteractionComponent)
			lootInteractionComponent.SetEnabled( !inv || !inv.IsEmpty() ) ;
			
		if ( foliageComponent )
		{
			if ( inv.IsEmpty() )
			{
				foliageComponent.SetAndSaveEntry( 'empty' );
			}
			else
			{
				foliageComponent.SetAndSaveEntry( 'full' );
			}
		}
	}	

	function ApplyAppearance( appearanceName : string )
	{
		if ( appearanceName == "2_empty" )
		{
			isEmptyAppearance = true;
		}
		else
		{
			isEmptyAppearance = false;
		}
		super.ApplyAppearance( appearanceName );
	}
	
	protected function PreRefillContainer()
	{
		inv.ResetContainerData();
	}
}