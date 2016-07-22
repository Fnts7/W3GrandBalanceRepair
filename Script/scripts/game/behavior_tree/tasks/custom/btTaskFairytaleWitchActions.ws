class CBTTaskFairytaleWitchActions extends IBehTreeTask
{
	private var action : EFairytaleWitchAction;
	private var npc : CNewNPC;

	function OnActivate() : EBTNodeStatus
	{
		npc = GetNPC();
		Execute();
		
		return BTNS_Active;
	}
	
	private function Execute()
	{
		switch( action )
		{
			case EFWA_GoBackToFlight:
			{
				SetBroomAsVisible();
				npc.AddAbility( 'FairytaleWitchDelay', false );
				
				
				/*if( npc.GetBehaviorVariable( 'transitionSecondDone' ) == 0.0 && ( npc.GetBehaviorVariable( 'transitionFirstDone' ) == 1.0 || npc.GetStatPercents( BCS_Essence ) < 0.33 ) )
				{	
					npc.SetBehaviorVariable( 'transitionSecondDone', 1.0 );
				}
				
				if( npc.GetBehaviorVariable( 'transitionFirstDone' ) == 0.0 )
				{
					npc.SetBehaviorVariable( 'transitionFirstDone', 1.0 );
				}*/
				
				break;
			}
			
			default:
			{
				break;
			}
		}
	}
	
	private function SetBroomAsVisible()
	{
		var broom : SItemUniqueId;
		var broomEntity : CEntity;
		var drawableComp : CDrawableComponent;

		broom = npc.GetInventory().GetItemFromSlot( 'broom_slot' );
		broomEntity = npc.GetInventory().GetItemEntityUnsafe( broom );
		if( broomEntity )
		{
			drawableComp = (CDrawableComponent)broomEntity.GetComponentByClassName( 'CDrawableComponent' );
			if( drawableComp )
			{
				drawableComp.SetVisible( true );
			}
		}
	}
}

class CBTTaskFairytaleWitchActionsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskFairytaleWitchActions';
	
	editable var action : EFairytaleWitchAction;
}

enum EFairytaleWitchAction
{
	EFWA_GoBackToFlight
};