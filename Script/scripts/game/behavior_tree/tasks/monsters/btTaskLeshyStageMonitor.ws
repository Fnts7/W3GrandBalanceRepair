/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2013
/** Author : Andrzej Kwiatkowski
/***********************************************************************/

class CBTTaskLeshyStageMonitor extends IBehTreeTask
{
	latent function Main() : EBTNodeStatus
	{
		var owner : CNewNPC = GetNPC();
		var combatStage : ENPCFightStage;
		
		combatStage = owner.GetCurrentFightStage();
		
		while ( true )
		{
			if ( MinionNumberCheck() && owner.GetStatPercents( BCS_Essence ) > 0.2 )
			{
				owner.ChangeFightStage( NFS_Stage1 );
				//owner.SetImmortalityMode( AIM_Invulnerable ); 
			}
			else
			{
				owner.ChangeFightStage( NFS_Stage2 );
				//owner.SetImmortalityMode( AIM_None ); 
			}
			Sleep(2.0);
		}
		return BTNS_Active;
	}
	
	function MinionNumberCheck() : bool
	{
		var npc : CNewNPC = GetNPC();
		var i : int;
		var minion : CEntity;
		var minions : array< CNode >;
		
		// AK : shitty way of finding npcs
		// fix when filtering by tag in FindGameplayEntitiesInRange starts working
		theGame.GetNodesByTag( 'leshy_minion', minions );
		for ( i = 0 ; i < minions.Size() ; i += 1 )
		{
			if ( VecDistance( npc.GetWorldPosition(), minions[i].GetWorldPosition() ) < 50 )
			{
				return true;
			}
		}
		return false;
	}
};

class CBTTaskLeshyStageMonitorDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskLeshyStageMonitor';
};



/***********************************************************************/
/** Cond
/***********************************************************************/

class CBTCondLeshyStage extends IBehTreeTask
{
	var activeInStage 				: ENPCFightStage;
	var equalHigherThanStage		: bool;
	
	function IsAvailable() 	: bool
	{
		var npc : CNewNPC = GetNPC();
		var combatStage : int;
		
		combatStage = (int)npc.GetCurrentFightStage();
		
		if ( equalHigherThanStage && combatStage >= (int)activeInStage )
		{
			return true;
		}
		else if ( combatStage == (int)activeInStage )
		{
			return true;
		}
		return false;
	}
};

class CBTCondLeshyStageDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondLeshyStage';

	editable	var equalHigherThanStage	: bool;
	editable	var activeInStage 			: ENPCFightStage;
	
	default activeInStage = NFS_Stage1;
	default equalHigherThanStage = false;
};
