/***********************************************************************/
/** Copyright © 2009-2014
/** Author : Danisz Markiewicz
/***********************************************************************/

struct genericSceneDefinition
{ 	
	editable var voicesTag       : name;
	editable var storyScene		 : CStoryScene;
	editable var input			 : name;
}

class W3GenericSceneArea extends CGameplayEntity 
{

	editable var scenes 		  : array<genericSceneDefinition>;
	editable var forbiddenFact 	  : string;
	editable var requiredFact	  : string;	
	editable var npcSearchRange   : float;
	editable var ignoreReplacers  : bool;
	editable var includeEnemyNPCs : bool;
	editable var includeQuestNPCs : bool;
	editable var sceneDelay       : float;	
	
	var firstPlaySceneDelay : float;
	var currentSceneDelay   : float;

	default npcSearchRange  		= 5.0f;
	default ignoreReplacers 		= true;
	default firstPlaySceneDelay 	= 6.0f;
	default sceneDelay 				= 180.0f;

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		// Just be sure that only player can trigger it
		if ( activator.GetEntity() != thePlayer )
		{
			return false;
		}
		
		RestartSceneTimer( firstPlaySceneDelay );
	}	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		// Just be sure that only player can trigger it
		if ( activator.GetEntity() != thePlayer )
		{
			return false;
		}
		
		RemoveTimer( 'PlaySceneTimer' );
	}	
	
	//Search for all potential scene speakers around the player
	private function SearchForSceneSpeakers()	: array<CNewNPC>
	{
		var entities    : array<CGameplayEntity>;
		var returnNPCs  : array<CNewNPC>;
		var targetNPC   : CNewNPC;
		var i           : int;
		

		FindGameplayEntitiesInRange( entities, thePlayer, npcSearchRange, 100000,'', FLAG_ExcludePlayer + FLAG_OnlyActors);
		
		for(i=0; i < entities.Size(); i+=1 )
		{
			targetNPC = ( CNewNPC ) entities[i];
			
			if( targetNPC )
			{
				if( GetIsNPCGroupValid(targetNPC) && targetNPC.IsAlive() && !targetNPC.IsInDanger() && !targetNPC.IsInCombat() && !GetIsTargetAsleep(targetNPC) && !targetNPC.IsSpeaking() )
				{
					returnNPCs.PushBack( targetNPC );
				}
			}
			
		}
		
		return returnNPCs;
	}
	
	//Check if NPCs group is allowed as scene speaker
	private function GetIsNPCGroupValid( target : CNewNPC ) : bool
	{ 
		var npcGroup : ENPCGroupType;
		npcGroup = target.GetNPCType();
		
		switch ( npcGroup )
		{
			case ENGT_Enemy:
			{
				if( includeEnemyNPCs ) 
					return true;
				else
					return false;
			}
			break;
			
			case ENGT_Quest:
			{
				if( includeQuestNPCs ) 
					return true;
				else
					return false;
			}
			break;
			
		}
		
		return true;
	}
	
	//Check if NPC is asleep and should speak
	private function GetIsTargetAsleep( target : CNewNPC ) : bool
	{
		var atWork : bool;
		var atWorkConscious : bool;
		
		atWork = target.IsAtWork();
		atWorkConscious = target.IsConsciousAtWork();
		
		if( atWork == false )
		{
			return false;
		}
		else
		{
			if( atWorkConscious )
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		
	}

	//Search for valid scenes for provided voicetag
	private function GetValidScenes( npcVoiceTag : name ) : array<genericSceneDefinition>
	{
		var i : int;
		var matchingScenes : array<genericSceneDefinition>;
		
		for( i = 0; i < scenes.Size(); i+=1 )
		{
			if( scenes[i].voicesTag  == npcVoiceTag )
			{
				matchingScenes.PushBack( scenes[i] );
			}
			
		}
		
		return matchingScenes;
	}
	
	//Timer function for scene playing
	timer function PlaySceneTimer( time : float , id : int )
	{
		var isGeralt : bool;
		
		if( CheckAreaValidity() )
		{
			if( !theGame.IsCurrentlyPlayingNonGameplayScene() )
			{
				if( FactsQuerySum(forbiddenFact) == 0 && ( requiredFact == ""  || FactsQuerySum(requiredFact) >= 1 ) )
				{
					if( ignoreReplacers == true )
					{
						isGeralt = (W3PlayerWitcher)thePlayer;
						
						if( isGeralt )
						{
							if( thePlayer.IsAlive() )
							{
								if( TryToPlayScene() )
								{
									RestartSceneTimer( sceneDelay );
									return;
								}
							}
						}
					}
					else
					{
						if( TryToPlayScene() )
						{
							RestartSceneTimer( sceneDelay );
							return;
						}
					}
					
				}
			}
			
			RestartSceneTimer( firstPlaySceneDelay );
		}
		else
		{
			RemoveTimer( 'PlaySceneTimer' );
		}
	}
	
	//Safeguard to check if the area really should still be active or not
	private function CheckAreaValidity() : bool
	{
		var comp : CTriggerAreaComponent;
		
		comp = (CTriggerAreaComponent) this.GetComponentByClassName( 'CTriggerAreaComponent' );
		
		if(comp)
		{
			if( comp.TestEntityOverlap( thePlayer ) )
				return true;
			else
				return false;
		}
		else
		{
			return false;
		}
		
	}
	
	//Modifies current scene delay timer and activates it
	function RestartSceneTimer( optional delay : float )
	{
		if( currentSceneDelay != delay && delay != 0)
		{
			currentSceneDelay = delay;
		}
		
		AddTimer( 'PlaySceneTimer', currentSceneDelay, false );
	}
	
	//Selects actors and scenes for playing base on provided set of scenes
	function TryToPlayScene(): bool
	{
		var speakers : array<CNewNPC>;
		var selectedSpeaker : CNewNPC;
		var scenes : array<genericSceneDefinition>;
		var selectedScene : genericSceneDefinition;
		var i : int;
		
		speakers = SearchForSceneSpeakers();
		if( speakers.Size()	== 0)
		{
			return false;
		}
		
		for( i=0; i < speakers.Size(); i+=1 )
		{
			selectedSpeaker  = speakers[i];
			scenes = GetValidScenes( selectedSpeaker.GetVoicetag() );
			
			if( scenes.Size() >= 1 )
			{
				selectedScene = scenes[ RandRange(scenes.Size() - 1) ];
				theGame.GetStorySceneSystem().PlayScene( selectedScene.storyScene, selectedScene.input );
				return true;
			}
			
		}
		
		return false;
	}

}
