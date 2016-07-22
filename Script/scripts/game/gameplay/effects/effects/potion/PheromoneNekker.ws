//>--------------------------------------------------------------------------
// W3Potion_PheromoneNekker
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// Pheromone to make Nekkers friendly
//---------------------------------------------------------------------------
//>--------------------------------------------------------------------------
// R.Pergent - 02-March-2015
// Copyright © 2015 CD Projekt RED
//---------------------------------------------------------------------------
class  W3Potion_PheromoneNekker extends W3Potion_Pheromone
{
	default effectType = EET_PheromoneNekker;

	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		theGame.SetGlobalAttitude( 'AG_nekker', 'player', AIA_Friendly );
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		theGame.SetGlobalAttitude( 'AG_nekker', 'player', AIA_Hostile );
	}
}