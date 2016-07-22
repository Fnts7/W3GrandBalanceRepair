
struct SIdleAEntryGeneratorParam
{
	editable var creatureEntry 		: SCreatureEntryEntryGeneratorNodeParam;
	editable inlined var idleTree 	: CAIIdleTree;
	editable var guartArea			: SGuardAreaEntryGeneratorNodeParam;
}

class CIdleAIEntryGenerator extends CSpawnTreeBaseEntryGenerator
{
	function GetFriendlyName() : string { return "Idle AI Entries"; }
	
	editable var commonSpawnParams	: SCreatureEntrySpawnerParams;	
	editable var entries			: array< SIdleAEntryGeneratorParam >;
	
	function GenerateEntries()
	{
		var i, size 	: int;
		var entryNode 	: CCreatureEntry;
		var idleInit	: CSpawnTreeInitializerIdleAI;
		var guardInit	: CSpawnTreeInitializerGuardArea;
		
		size = entries.Size();
		
		for( i = 0; i<size; i+=1 )
		{
			entryNode = new CCreatureEntry in this;			
			AddNodeToTree( entryNode, NULL );
			entryNode.nodeName = nodeName;
			AplyCreatureSpawnerParams( entryNode, commonSpawnParams );
			AplyCreatureEntryParams( entryNode, entries[i].creatureEntry );
			
			idleInit = new CSpawnTreeInitializerIdleAI in entryNode;
			AddInitializerToNode( idleInit, entryNode );
			ApplyIdleInitializerCfg( idleInit, entries[i].idleTree );
			
			guardInit = new CSpawnTreeInitializerGuardArea in entryNode;
			AddInitializerToNode( guardInit, entryNode );
			ApplyGuardAreaCfg( guardInit, entries[i].guartArea );
			
		}
	}
	
	function ApplyIdleInitializerCfg( init : CSpawnTreeInitializerIdleAI, idleTree : CAIIdleTree )
	{		
		init.ai.idleTree = idleTree;	
	}
	
	
	function ApplyGuardAreaCfg( init : CSpawnTreeInitializerGuardArea, cfg : SGuardAreaEntryGeneratorNodeParam )
	{
		init.guardAreaTag 	= cfg.guardAreaTag;
		init.pursuitAreaTag = cfg.pursuitAreaTag;
		init.pursuitRange 	= cfg.pursuitRange;
	}
}