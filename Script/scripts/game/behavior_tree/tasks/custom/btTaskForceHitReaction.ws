//>--------------------------------------------------------------------------
// BTTaskForceHitReaction
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Force a specific type of hit reaction on hit
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 24-May-2014
// Copyright © 2014 CD Projekt RED
//---------------------------------------------------------------------------
class BTTaskForceHitReaction extends IBehTreeTask
{
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	var hitReactionType			: EHitReactionType;
	var hitReactionSide			: EHitReactionSide;
	var hitReactionDirection	: EHitReactionDirection;
	var hitSwingType			: EAttackSwingType;
	var hitSwingDirection		: EAttackSwingDirection;
	//>--------------------------------------------------------------------------
	//---------------------------------------------------------------------------
	function OnActivate() : EBTNodeStatus
	{
		var l_npc	: CNewNPC = GetNPC();
		
		l_npc.SetBehaviorVariable( 'HitReactionType', (int) hitReactionType );
		l_npc.SetBehaviorVariable( 'HitReactionSide', (int) hitReactionSide );
		l_npc.SetBehaviorVariable( 'HitReactionDirection', (int) hitReactionDirection );
		l_npc.SetBehaviorVariable( 'HitSwingType', (int) hitSwingType );
		l_npc.SetBehaviorVariable( 'HitSwingDirection', (int) hitSwingDirection );
		
		return BTNS_Active;
	}
	
}
//>--------------------------------------------------------------------------
//---------------------------------------------------------------------------
class BTTaskForceHitReactionDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskForceHitReaction';
	//>--------------------------------------------------------------------------
	// VARIABLES
	//---------------------------------------------------------------------------
	editable inlined var hitReactionType		: CBTEnumHitReactionType;
	editable inlined var hitReactionSide		: CBTEnumHitReactionSide;
	editable inlined var hitReactionDirection	: CBTEnumHitReactionDirection;
	editable inlined var hitSwingType			: CBTEnumAttackSwingType;
	editable inlined var hitSwingDirection		: CBTEnumAttackSwingDriection;
}
