// Gameplay mimics mode
enum EGameplayMimicMode
{
	GMM_Default,
	GMM_Combat,
	GMM_Work,
	GMM_Death,
	PGMM_Sleep,
	GMM_Tpose
}

enum EPlayerGameplayMimicMode
{
	PGMM_None,
	PGMM_Default,
	PGMM_Combat,
	PGMM_Inventory,
}

// How to set gameplay mimics mode?
// Npc:
// parent.SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)GMM_Combat )
// Player:
// parent.SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)PGMM_Combat )