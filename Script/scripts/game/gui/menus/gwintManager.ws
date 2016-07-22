/***********************************************************************/
/** Witcher Script file - gwint deck builder
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Jason Slama   
/***********************************************************************/

/*
C++
enum eGwintFaction
{
	GwintFaction_Neutral = 0,
	GwintFaction_NoMansLand,
	GwintFaction_Nilfgaard,
	GwintFaction_NothernKingdom,  
	GwintFaction_Scoiatael,
	GwintFaction_Skellige,

	GwintFaction_Max   
};

enum eGwintType
{
	GwintType_None = 0,
	GwintType_Melee = 1,
	GwintType_Ranged = 2,
	GwintType_Siege = 4,
	GwintType_Creature = 8,
	GwintType_Weather = 16,
	GwintType_Spell = 32,
	GwintType_RowModifier = 64,
	GwintType_Hero = 128,
	GwintType_Spy = 256,
	GwintType_FriendlyEffect = 512,
	GwintType_OffensiveEffect = 1024,
	GwintType_GlobalEffect = 2048
};

enum eGwintEffect
{
	GwintEffect_None = 0,

	GwintEffect_Bin2 = 5,

	// Leader abilities
	GwintEffect_MeleeScorch = 7, 
	GwintEffect_11thCard = 8,
	GwintEffect_ClearWeather = 9,
	GwintEffect_PickWeatherCard = 10,
	GwintEffect_PickRainCard = 11,
	GwintEffect_PickFogCard = 12,
	GwintEffect_PickFrostCard = 13,
	GwintEffect_View3EnemyCard = 14,
	GwintEffect_ResurectCard = 15,
	GwintEffect_ResurectFromEnemy = 16,
	GwintEffect_Bin2Pick1 = 17,
	GwintEffect_MeleeHorn = 18,
	GwintEffect_RangedHorn = 19,
	GwintEffect_SiegeHorn = 20,
	GwintEffect_SiegeScorch = 21,
	GwintEffect_CounterKingAbility = 22,

	// Regular Effects
	GwintEffect_Melee = 23,
	GwintEffect_Ranged = 24,
	GwintEffect_Siege = 25,
	GwintEffect_UnsummonDummy = 26,
	GwintEffect_Horn = 27,
	GwintEffect_Draw = 28,
	GwintEffect_Scorch = 29,
	GwintEffect_ClearSky = 30,
	GwintEffect_SummonClones = 31,
	GwintEffect_ImproveNeightbours = 32,
	GwintEffect_Nurse = 33,
	GwintEffect_Draw2 = 34,
	GwintEffect_SameTypeMorale = 35,
	
	// Episode 1 abilities
	GwintEffect_AgileReposition = 36,
	GwintEffect_RandomRessurect = 37,
	GwintEffect_DoubleSpy = 38,
	GwintEffect_RangedScorch = 39,
	GwintEffect_SuicideSummon = 40,

	// Episode 2 abilities
	GwintEffect_Mushroom = 41,
	GwintEffect_Morph = 42,
	GwintEffect_WeatherResistant = 43,
	GwintEffect_GraveyardShuffle = 44
};
*/

import struct SCardDefinition
{
	import var index			: int;
	import var title			: string;
	import var description		: string;
	import var power			: int;
	import var picture			: string;
	import var faction			: eGwintFaction;
	import var typeFlags		: int;
	import var effectFlags		: array< eGwintEffect >;
	import var summonFlags		: array< int >;
	
	// Used to determine if an alternate art should be used
	import var dlcPictureFlag	: name; 	
	import var dlcPicture		: string;
}

//#J using a struct for now so we can easily add more information to decks
import struct SDeckDefinition
{
	import var cardIndices				: array< int >;
	import var leaderIndex 				: int;
	import var unlocked  				: bool;
	import var specialCard				: int;
	import var dynamicCardRequirements	: array< int >;
	import var dynamicCards 			: array< int >;
};

import struct CollectionCard
{
	import var cardID 		: int;
	import var numCopies 	: int;
}

import class CR4GwintManager extends IGameSystem
{
	public var testMatch:bool; default testMatch = false;
	
	import final function GetCardDefs() : array<SCardDefinition>;
	import final function GetLeaderDefs() : array<SCardDefinition>;
	
	import final function GetFactionDeck(faction:eGwintFaction, out deck:SDeckDefinition) : bool;
	import final function SetFactionDeck(faction:eGwintFaction, deck:SDeckDefinition) : void;
	
	import final function GetPlayerCollection() : array<CollectionCard>;
	import final function GetPlayerLeaderCollection() : array<CollectionCard>;
	
	import final function GetSelectedPlayerDeck() : eGwintFaction;
	import final function SetSelectedPlayerDeck(index : eGwintFaction) : void;
	
	import final function UnlockDeck(index : eGwintFaction) : void;
	import final function IsDeckUnlocked(index : eGwintFaction) : bool;
	
	import final function AddCardToCollection(cardIndex : int) : void;
	import final function RemoveCardFromCollection(cardIndex : int) : void;
	import final function HasCardInCollection(cardIndex : int) : bool;
	import final function HasCardsOfFactionInCollection(faction : eGwintFaction, optional includeLeaders : bool) : bool;
	
	import final function AddCardToDeck(faction:eGwintFaction, cardIndex : int) : void;
	import final function RemoveCardFromDeck(faction:eGwintFaction, cardIndex : int) : void;
	
	import final function GetHasDoneTutorial() : bool;
	import final function SetHasDoneTutorial(value : bool) : void;
	
	import final function GetHasDoneDeckTutorial() : bool;
	import final function SetHasDoneDeckTutorial(value : bool) : void;
	
	public function HasLootedCard() : bool
	{
		return FactsDoesExist("Gwint_Card_Looted");
	}
	
	event /*c++*/ OnGwintSetupNewgame()
	{
		var northernPlayerDeck : SDeckDefinition;
		var nilfgardPlayerDeck : SDeckDefinition;
		var scotialPlayerDeck : SDeckDefinition;
		var nmlPlayerDeck : SDeckDefinition;
		var skePlayerDeck : SDeckDefinition;
	
		//northernPlayerDeck.deckName = "North";
		northernPlayerDeck.cardIndices.PushBack( 3 ); // frost; //frost
		northernPlayerDeck.cardIndices.PushBack( 3 ); // frost; //frost
		northernPlayerDeck.cardIndices.PushBack( 4 ); // fog //fog
		northernPlayerDeck.cardIndices.PushBack( 4 ); // fog //fog
		northernPlayerDeck.cardIndices.PushBack( 5 ); //rain
		northernPlayerDeck.cardIndices.PushBack( 5 ); //rain
		northernPlayerDeck.cardIndices.PushBack( 6 ); //clearsky
		northernPlayerDeck.cardIndices.PushBack( 6 ); //clearsky
		northernPlayerDeck.cardIndices.PushBack( 106 ); //  5  Ves
		northernPlayerDeck.cardIndices.PushBack( 111 ); //  5  Keira Metz 
		northernPlayerDeck.cardIndices.PushBack( 112 ); //  5  Sile de Tansarville
		northernPlayerDeck.cardIndices.PushBack( 113 ); //  4  Sabrina Glevissig 
		northernPlayerDeck.cardIndices.PushBack( 114 ); //  4  Sheldon Skaggs
		northernPlayerDeck.cardIndices.PushBack( 115 ); //  6  Dethmold
		northernPlayerDeck.cardIndices.PushBack( 116 ); //  5  Prince Stennis 
		northernPlayerDeck.cardIndices.PushBack( 120 ); //  6  Trebuchet
		northernPlayerDeck.cardIndices.PushBack( 121 ); //  6  Trebuchet
		northernPlayerDeck.cardIndices.PushBack( 125 ); //  2  Poor Fucking Infantry 
		northernPlayerDeck.cardIndices.PushBack( 125 ); //  2  Poor Fucking Infantry  
		northernPlayerDeck.cardIndices.PushBack( 135 ); //  1  Redanian Foot Soldier
		northernPlayerDeck.cardIndices.PushBack( 145 ); //  6  Ballista
		northernPlayerDeck.cardIndices.PushBack( 146 ); //  6  Ballista
		northernPlayerDeck.cardIndices.PushBack( 150 ); //  2  Kaedweni Siege Expert
		northernPlayerDeck.cardIndices.PushBack( 150 ); //  2  Kaedweni Siege Expert
		northernPlayerDeck.cardIndices.PushBack( 150 ); //  2  Kaedweni Siege Expert
		northernPlayerDeck.cardIndices.PushBack( 107 ); //  4  Siegfried
		northernPlayerDeck.cardIndices.PushBack( 160 ); //  4  Blue Stripes Commando
		northernPlayerDeck.cardIndices.PushBack( 160 ); //  4  Blue Stripes Commando
		northernPlayerDeck.cardIndices.PushBack( 175 ); //  0  Nurse
		AddCardToCollection(108); //  2  Yarpen Zigrin 
		AddCardToCollection(136); //  1  Redanian Foot Soldier
		
		
		northernPlayerDeck.leaderIndex = 1001;
		northernPlayerDeck.specialCard = -1; // DO NOT CHANGE THIS
		northernPlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_NothernKingdom, northernPlayerDeck);
		
		//nilfgardPlayerDeck.deckName = "Nilf";
		nilfgardPlayerDeck.leaderIndex = 2001;
		nilfgardPlayerDeck.specialCard = -1; // DO NOT CHANGE THIS
		nilfgardPlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_Nilfgaard, nilfgardPlayerDeck);
		
		//scotialPlayerDeck.deckName = "scotial";
		
		scotialPlayerDeck.leaderIndex = 3001;
		scotialPlayerDeck.specialCard = -1; // DO NOT CHANGE THIS
		scotialPlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_Scoiatael, scotialPlayerDeck);
		
		//nmlPlayerDeck.deckName = "nml";
		
		nmlPlayerDeck.leaderIndex = 4001;
		nmlPlayerDeck.specialCard = -1; // DO NOT CHANGE THIS
		nmlPlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_NoMansLand, nmlPlayerDeck);

		//skePlayerDeck.deckName = "ske";
		
		skePlayerDeck.leaderIndex = 5002;
		skePlayerDeck.specialCard = -1; // DO NOT CHANGE THIS
		skePlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_Skellige, skePlayerDeck);
		
		UnlockDeck(GwintFaction_NothernKingdom);
		UnlockDeck(GwintFaction_Nilfgaard);
		UnlockDeck(GwintFaction_Scoiatael);
		UnlockDeck(GwintFaction_NoMansLand);
		// Skellige intentionally missing - It's unlocked when the player acquires their first Skellige card.
		
		SetSelectedPlayerDeck(GwintFaction_NothernKingdom);
	}
	
	event /*c++*/ OnGwintSetupSkellige()
	{
		var skePlayerDeck : SDeckDefinition;
		
		skePlayerDeck.leaderIndex = 5002;
		skePlayerDeck.specialCard = -1; // DO NOT CHANGE THIS
		skePlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_Skellige, skePlayerDeck);
		
		// Unlock intentionally missing - It's unlocked when the player acquires their first Skellige card.
	}
	
	public function GetTutorialPlayerDeck() : SDeckDefinition
	{
		var tutorialDeck : SDeckDefinition;
		
		tutorialDeck.cardIndices.PushBack( 3 ); // frost
		tutorialDeck.cardIndices.PushBack( 3 ); // frost
		tutorialDeck.cardIndices.PushBack( 4 ); // fog
		tutorialDeck.cardIndices.PushBack( 4 ); // fog
		tutorialDeck.cardIndices.PushBack( 5 ); // rain
		tutorialDeck.cardIndices.PushBack( 6 ); // clearsky
		tutorialDeck.cardIndices.PushBack( 106 ); //  5  Ves
		tutorialDeck.cardIndices.PushBack( 111 ); //  5  Keira Metz 
		tutorialDeck.cardIndices.PushBack( 112 ); //  5  Sile de Tansarville
		tutorialDeck.cardIndices.PushBack( 113 ); //  4  Sabrina Glevissig 
		tutorialDeck.cardIndices.PushBack( 114 ); //  4  Sheldon Skaggs
		tutorialDeck.cardIndices.PushBack( 115 ); //  6  Dethmold
		tutorialDeck.cardIndices.PushBack( 116 ); //  5  Prince Stennis 
		tutorialDeck.cardIndices.PushBack( 120 ); //  6  Trebuchet
		tutorialDeck.cardIndices.PushBack( 121 ); //  6  Trebuchet
		tutorialDeck.cardIndices.PushBack( 126 ); //  2  Poor Fucking Infantry 
		tutorialDeck.cardIndices.PushBack( 127 ); //  2  Poor Fucking Infantry  
		tutorialDeck.cardIndices.PushBack( 135 ); //  1  Redanian Foot Soldier
		tutorialDeck.cardIndices.PushBack( 145 ); //  6  Ballista
		tutorialDeck.cardIndices.PushBack( 150 ); //  2  Kaedweni Siege Expert
		tutorialDeck.cardIndices.PushBack( 151 ); //  2  Kaedweni Siege Expert
		tutorialDeck.cardIndices.PushBack( 152 ); //  2  Kaedweni Siege Expert
		tutorialDeck.cardIndices.PushBack( 107 ); //  4  Siegfried
		tutorialDeck.cardIndices.PushBack( 160 ); //  4  Blue Stripes Commando
		tutorialDeck.cardIndices.PushBack( 160 ); //  4  Blue Stripes Commando
		tutorialDeck.cardIndices.PushBack( 175 ); //  0  Nurse
		tutorialDeck.leaderIndex = 1001;
		tutorialDeck.specialCard = -1; // DO NOT CHANGE THIS
		
		return tutorialDeck;
	}
	
	protected function setupEnemyDecks() : void
	{
		if (!enemyDecksSet)
		{
			enemyDecksSet = true;
			
			// Main Game
			SetupAIDeckDefinitions();			
			SetupAIDeckDefinitions1();
			SetupAIDeckDefinitions2();
			SetupAIDeckDefinitions3();
			SetupAIDeckDefinitions4();
			SetupAIDeckDefinitions5();
			SetupAIDeckDefinitions6();
			SetupAIDeckDefinitions7();
			SetupAIDeckDefinitionsNK();
			SetupAIDeckDefinitionsNilf();
			SetupAIDeckDefinitionsScoia();
			SetupAIDeckDefinitionsNML();
			SetupAIDeckDefinitionsPrologue();
			SetupAIDeckDefinitionsTournament1();
			SetupAIDeckDefinitionsTournament2();
			// EP1
			SetupAIDeckDefinitions8();
			SetupAIDeckDefinitions9();
			SetupAIDeckDefinitions10();
			// EP2
			SetupAIDeckDefinitionsSkel();
			SetupAIDeckDefinitionsTournament3();
			SetupAIDeckDefinitionsTournament4();

		}
	}
	
	// =================================================================================================
	// -------------------------------------------------------------------------------------------------
	// =================================================================================================
	
	private var enemyDecksSet : bool; default enemyDecksSet = false;
	private var enemyDecks : array< SDeckDefinition >;
	private var selectedEnemyDeck : int;
	private var forcePlayerFaction : eGwintFaction;
	
	private var difficulty : int;

	private var diff1 : int;
	private var diff2 : int;
	private var diff3 : int;
	private var diff4 : int;
	private var diff5 : int;
	private var diff6 : int;
	private var diff7 : int;
	private var diff8 : int;
	private var diff9 : int;
	private var diff10 : int;
	private var diff11 : int;
	private var diff12 : int;
	private var diff13 : int;
	private var diff14 : int;
	private var diff15 : int;
	
	private var doubleAIEnabled : bool;
	
	public var gameRequested : bool; default gameRequested = false;
	
	public function setDoubleAIEnabled(value:bool):void
	{
		doubleAIEnabled = value;
	}
	
	public function getDoubleAIEnabled():bool
	{
		return doubleAIEnabled;
	}
	
	public function GetForcedFaction():eGwintFaction
	{
		return forcePlayerFaction;
	}
	
	public function SetForcedFaction(faction : eGwintFaction):void
	{
		forcePlayerFaction = faction;
	}
	
	public function GetCurrentPlayerDeck() : SDeckDefinition
	{
		var selectedDeck : SDeckDefinition;
		
		if (forcePlayerFaction == GwintFaction_Neutral)
		{
			GetFactionDeck(GetSelectedPlayerDeck(), selectedDeck);
		}
		else
		{
			GetFactionDeck(forcePlayerFaction, selectedDeck);
		}
		
		return selectedDeck;
	}
	
	public function HasUnlockedDeck():bool
	{
		if (!IsDeckUnlocked(GwintFaction_NoMansLand) && !IsDeckUnlocked(GwintFaction_Nilfgaard) &&
			!IsDeckUnlocked(GwintFaction_NothernKingdom) && !IsDeckUnlocked(GwintFaction_Scoiatael))
		{
			return false;
		}
		
		return true;
	}
	
	public function SetEnemyDeckIndex(deckIndex:int):void
	{
		selectedEnemyDeck = deckIndex;
	}
	
	public function SetEnemyDeckByName(deckname:name):void
	{
		switch(deckname)
		{
		case 'CardProdigy':
			selectedEnemyDeck = 0;
			break;
		case 'Dijkstra':
			selectedEnemyDeck = 1;
			break;
		case 'Baron':
			selectedEnemyDeck = 2;
			break;
		case 'Roche':
			selectedEnemyDeck = 3;
			break;
		case 'Sjusta':
			selectedEnemyDeck = 4;
			break;
		case 'Stjepan':
			selectedEnemyDeck = 5;
			break;
		case 'CrossroadsInnkeeper':
			selectedEnemyDeck = 6;
			break;
		case 'BoatBuilder':
			selectedEnemyDeck = 7;
			break;
		case 'MarkizaSerenity':
			selectedEnemyDeck = 8;
			break;
		case 'Gremista':
			selectedEnemyDeck = 9;
			break;
		case 'Zoltan':
			selectedEnemyDeck = 10;
			break;
		case 'Lambert':
			selectedEnemyDeck = 11;
			break;
		case 'Thaler':
			selectedEnemyDeck = 12;
			break;
		case 'VimmeVivaldi':
			selectedEnemyDeck = 13;
			break;
		case 'ScoiaTrader':
			selectedEnemyDeck = 14;
			break;
		case 'Crach':
			selectedEnemyDeck = 15;
			break;
		case 'LugosTheMad':
			selectedEnemyDeck = 16;
			break;
		case 'Hermit':
			selectedEnemyDeck = 17;
			break;
		case 'Olivier':
			selectedEnemyDeck = 18;
			break;
		case 'Mousesack':
			selectedEnemyDeck = 19;
			break;
		case 'NKEasy':
			selectedEnemyDeck = 20;
			break;
		case 'NKNormal':
			selectedEnemyDeck = 21;
			break;
		case 'NKHard':
			selectedEnemyDeck = 22;
			break;
		case 'NilfEasy':
			selectedEnemyDeck = 23;
			break;
		case 'NilfNormal':
			selectedEnemyDeck = 24;
			break;
		case 'NilfHard':
			selectedEnemyDeck = 25;
			break;
		case 'ScoiaEasy':
			selectedEnemyDeck = 26;
			break;
		case 'ScoiaNormal':
			selectedEnemyDeck = 27;
			break;
		case 'ScoiaHard':
			selectedEnemyDeck = 28;
			break;
		case 'NMLEasy':
			selectedEnemyDeck = 29;
			break;
		case 'NMLNormal':
			selectedEnemyDeck = 30;
			break;
		case 'NMLHard':
			selectedEnemyDeck = 31;
			break;
		case 'NilfPrologue':
			selectedEnemyDeck = 32;
			break;
		case 'NKTournament':
			selectedEnemyDeck = 33;
			break;
		case 'NilfTournament':
			selectedEnemyDeck = 34;
			break;
		case 'ScoiaTournament':
			selectedEnemyDeck = 35;
			break;
		case 'NMLTournament':
			selectedEnemyDeck = 36;
			break;
		case 'Shani':
			selectedEnemyDeck = 37;
			break;
		case 'Olgierd':
			selectedEnemyDeck = 38;
			break;
		case 'Gambler':
			selectedEnemyDeck = 39;
			break;
		case 'Halflings':
			selectedEnemyDeck = 40;
			break;
		case 'CircusGwentAddict':
			selectedEnemyDeck = 41;
			break;
		case 'SkelEasy':
			selectedEnemyDeck = 42;
			break;
		case 'SkelNormal':
			selectedEnemyDeck = 43;
			break;
		case 'SkelHard':
			selectedEnemyDeck = 44;
			break;	
		case 'ScoiaTournament2':
			selectedEnemyDeck = 45;
			break;
		case 'NMLTournament2':
			selectedEnemyDeck = 46;
			break;		
		case 'NKTournament2':
			selectedEnemyDeck = 47;
			break;
		case 'NilfTournament2':
			selectedEnemyDeck = 48;
			break;
		case 'SkelTournament2':
			selectedEnemyDeck = 49;		
			break;
		default:
			selectedEnemyDeck = 23;
		}
	}
	
	public function GetCardDefinition(cardIndex:int) : SCardDefinition
	{
		var cardDefinitions : array<SCardDefinition>;
		var errorDefinition : SCardDefinition;
		var currentDefinition : SCardDefinition;
		var i:int;
		
		if (cardIndex >= 1000)
		{
			cardDefinitions = GetLeaderDefs();
		}
		else
		{
			cardDefinitions = GetCardDefs();
		}
		
		for (i = 0; i < cardDefinitions.Size(); i += 1)
		{
			currentDefinition = cardDefinitions[i];
			if (currentDefinition.index == cardIndex)
			{
				return currentDefinition;
			}
		}
		
		errorDefinition.index = -1;
		
		return errorDefinition;
	}
	
	public function GetCurrentAIDeck() : SDeckDefinition
	{
		GenerateDifficultyData();

		setupEnemyDecks(); // make sure the decks are setup
		
		return enemyDecks[selectedEnemyDeck];
	}
		
	private function GenerateDifficultyData()
	{
		var difficultyBalanceValue : int;
		difficultyBalanceValue = 0;

		difficulty = FactsQueryLatestValue("gwent_difficulty");

		if (difficulty)
		{
			// Easy
			if (difficulty == 1) 
			{ 
				difficultyBalanceValue += 80;
			}
			// Normal
			if (difficulty == 2) 
			{ 
				difficultyBalanceValue += 0;
			}
			// Hard
			if (difficulty == 3) 
			{ 
				difficultyBalanceValue -= 80;
			}
		}

		diff1 = 145 + difficultyBalanceValue;
		diff2 = 150 + difficultyBalanceValue;
		diff3 = 155 + difficultyBalanceValue;
		diff4 = 160 + difficultyBalanceValue;
		diff5 = 165 + difficultyBalanceValue;
		diff6 = 170 + difficultyBalanceValue;
		diff7 = 175 + difficultyBalanceValue;
		diff8 = 180 + difficultyBalanceValue;
		diff9 = 185 + difficultyBalanceValue;
		diff10 = 190 + difficultyBalanceValue;
		diff11 = 205 + difficultyBalanceValue;
		diff12 = 215 + difficultyBalanceValue;
		diff13 = 220 + difficultyBalanceValue;
		diff14 = 225 + difficultyBalanceValue;
		diff15 = 230 + difficultyBalanceValue;		
	}
		
	private function SetupAIDeckDefinitions()
	{
		var CardProdigyDeck		:SDeckDefinition;
		var DijkstraDeck		:SDeckDefinition;
		var BaronDeck			:SDeckDefinition;

		
		///////////////NORTHERN KINGDOMS//////////////////	
			
			//------------------------------------------------------------------//CardProdigyDeck.deckName = "CardProdigy";	

			// Northern Realm deck #0
			
			// Difficulty changing cards	
			if (difficulty == 1)
			{
				CardProdigyDeck.cardIndices.PushBack(1); //Horn	
				CardProdigyDeck.cardIndices.PushBack(4); //Impenetrable Fog
				CardProdigyDeck.cardIndices.PushBack(4); //Impenetrable Fog
				CardProdigyDeck.cardIndices.PushBack(6); //Clear Weather		
				CardProdigyDeck.cardIndices.PushBack(6); //Clear Weather
				CardProdigyDeck.cardIndices.PushBack(135); //Redanian Foot Soldier [1]	
				CardProdigyDeck.cardIndices.PushBack(136); //Redanian Foot Soldier [1]
				CardProdigyDeck.cardIndices.PushBack(107); //Siegfried of Denesle [5]
			}
			if (difficulty == 2)
			{
				CardProdigyDeck.cardIndices.PushBack(1); //Horn
				CardProdigyDeck.cardIndices.PushBack(1); //Horn
				CardProdigyDeck.cardIndices.PushBack(2); //Scorch	
				CardProdigyDeck.cardIndices.PushBack(4); //Impenetrable Fog
				CardProdigyDeck.cardIndices.PushBack(4); //Impenetrable Fog
				CardProdigyDeck.cardIndices.PushBack(6); //Clear Weather		
				CardProdigyDeck.cardIndices.PushBack(6); //Clear Weather	
				CardProdigyDeck.cardIndices.PushBack(107); //Siegfried of Denesle [5]		
			}
			if (difficulty == 3)
			{
				CardProdigyDeck.cardIndices.PushBack(1); //Horn
				CardProdigyDeck.cardIndices.PushBack(0); //Dummy
				CardProdigyDeck.cardIndices.PushBack(2); //Scorch	
				CardProdigyDeck.cardIndices.PushBack(4); //Impenetrable Fog		
				CardProdigyDeck.cardIndices.PushBack(6); //Clear Weather
				CardProdigyDeck.cardIndices.PushBack(140); // [8] Catapult
				CardProdigyDeck.cardIndices.PushBack(141); // [8] Catapult
				CardProdigyDeck.cardIndices.PushBack(9); //   [7] Yennefer
			}

			CardProdigyDeck.cardIndices.PushBack(125); //Poor Fucking Infantry [2] [TightBond] 	
			CardProdigyDeck.cardIndices.PushBack(126); //Poor Fucking Infantry [2] [TightBond] 	
			CardProdigyDeck.cardIndices.PushBack(127); //Poor Fucking Infantry [2] [TightBond] 	
			CardProdigyDeck.cardIndices.PushBack(130); //Crinfrid Reavers Dragon Hunter [4] [TightBond]	
			CardProdigyDeck.cardIndices.PushBack(131); //Crinfrid Reavers Dragon Hunter [4] [TightBond]	
			CardProdigyDeck.cardIndices.PushBack(132); //Crinfrid Reavers Dragon Hunter [4] [TightBond]	
			CardProdigyDeck.cardIndices.PushBack(140); //Catapult [5] [TightBond] 	
			CardProdigyDeck.cardIndices.PushBack(141); //Catapult [5] [TightBond] 		
			CardProdigyDeck.cardIndices.PushBack(145); //Ballista [6]	
			CardProdigyDeck.cardIndices.PushBack(146); //Ballista [6]	
			CardProdigyDeck.cardIndices.PushBack(160); //Blue Stripes Commando [4] [TightBond]	
			CardProdigyDeck.cardIndices.PushBack(160); //Blue Stripes Commando [4] [TightBond]	
			CardProdigyDeck.cardIndices.PushBack(160); //Blue Stripes Commando [4] [TightBond]

			//-------------------------------------------------------------//note: Gets scrorches and more powerful NR cards.-------------------------------------------

			CardProdigyDeck.dynamicCardRequirements.PushBack(diff5);
			CardProdigyDeck.dynamicCards.PushBack(2); //Scorch	
			CardProdigyDeck.dynamicCardRequirements.PushBack(diff7);
			CardProdigyDeck.dynamicCards.PushBack(2); //Scorch	
			CardProdigyDeck.dynamicCardRequirements.PushBack(diff9);
			CardProdigyDeck.dynamicCards.PushBack(103); // 10 Philippa HERO
			CardProdigyDeck.dynamicCardRequirements.PushBack(diff11);
			CardProdigyDeck.dynamicCards.PushBack(102); // 10 Esterad HERO
			CardProdigyDeck.dynamicCardRequirements.PushBack(diff11);
			CardProdigyDeck.dynamicCards.PushBack(109); // 4 Djikstra SPY
			CardProdigyDeck.dynamicCardRequirements.PushBack(diff14);
			CardProdigyDeck.dynamicCards.PushBack(101); // 10 Natalis HERO
			CardProdigyDeck.dynamicCardRequirements.PushBack(diff14);
			CardProdigyDeck.dynamicCards.PushBack(12); // Dandelion HORN

			CardProdigyDeck.specialCard = 100; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			CardProdigyDeck.leaderIndex = 1001;
			enemyDecks.PushBack(CardProdigyDeck);
			
			
			
			//------------------------------------------------------------------//DijkstraDeck.deckName = "Dijkstra";

			// Northern Realm deck #1	

			// Difficulty changing cards
			DijkstraDeck.cardIndices.PushBack(0); // Dummy	
			DijkstraDeck.cardIndices.PushBack(1); // Horn
			DijkstraDeck.cardIndices.PushBack(3); // Biting Frost	
			DijkstraDeck.cardIndices.PushBack(4); // Impenetrable Fog	
			DijkstraDeck.cardIndices.PushBack(6); // Clear Weather	
			
			if (difficulty == 1)
			{	
				DijkstraDeck.cardIndices.PushBack(3); // Biting Frost
				DijkstraDeck.cardIndices.PushBack(4); // Impenetrable Fog
				DijkstraDeck.cardIndices.PushBack(108); // [2] Yarpen	
				DijkstraDeck.cardIndices.PushBack(136); // [1] Readanian 
			}
			if (difficulty == 2)
			{
				DijkstraDeck.cardIndices.PushBack(2); // Scorch
				DijkstraDeck.cardIndices.PushBack(0); // Dummy
				DijkstraDeck.cardIndices.PushBack(3); // Biting Frost
				DijkstraDeck.cardIndices.PushBack(4); //Impenetrable Fog	
				DijkstraDeck.cardIndices.PushBack(6); //Clear Weather	
			}
			if (difficulty == 3)
			{
				DijkstraDeck.cardIndices.PushBack(0); // Dummy
				DijkstraDeck.cardIndices.PushBack(101); // [10] Vernon  [Hero]
				DijkstraDeck.cardIndices.PushBack(9); //   [7] Yennefer [Hero][Nurse]
			}

			DijkstraDeck.cardIndices.PushBack(14); //Emiel Regis Rohellec Terzieff [5]	
			DijkstraDeck.cardIndices.PushBack(105); //Thaler [1] [SPY]	
			DijkstraDeck.cardIndices.PushBack(111); //Keira Metz  [5]	
			DijkstraDeck.cardIndices.PushBack(120); //Trebuchet [6]	
			DijkstraDeck.cardIndices.PushBack(121); //Trebuchet [6]	
			DijkstraDeck.cardIndices.PushBack(140); //Catapult [5] [TightBond] 	
			DijkstraDeck.cardIndices.PushBack(141); //Catapult [5] [TightBond] 		
			DijkstraDeck.cardIndices.PushBack(145); //Ballista [6]	
			DijkstraDeck.cardIndices.PushBack(146); //Ballista [6]	
			DijkstraDeck.cardIndices.PushBack(150); //Kaedweni Siege Expert [2] [MoraleBoost]	
			DijkstraDeck.cardIndices.PushBack(160); //Blue Stripes Commando [4] [TightBond]	
			DijkstraDeck.cardIndices.PushBack(160); //Blue Stripes Commando [4] [TightBond]	
			DijkstraDeck.cardIndices.PushBack(170); //Siege Tower [6]	
			DijkstraDeck.cardIndices.PushBack(175); //Dun Banner Medic [0] [Nurse]

			//-------------------------------------------------------------//note: Scroches, nurse, spies!! (he is spy master after all)  -------------------------------------------

			DijkstraDeck.dynamicCardRequirements.PushBack(diff5);
			DijkstraDeck.dynamicCards.PushBack(2); //Scorch
			DijkstraDeck.dynamicCardRequirements.PushBack(diff7);
			DijkstraDeck.dynamicCards.PushBack(2); //Scorch
			DijkstraDeck.dynamicCardRequirements.PushBack(diff9);
			DijkstraDeck.dynamicCards.PushBack(16); // Avallach
			DijkstraDeck.dynamicCardRequirements.PushBack(diff11);
			DijkstraDeck.dynamicCards.PushBack(101); // 10 Natalis Hero
			DijkstraDeck.dynamicCardRequirements.PushBack(diff11);
			DijkstraDeck.dynamicCards.PushBack(109); // 4 Djikstra SPY
			DijkstraDeck.dynamicCardRequirements.PushBack(diff14);
			DijkstraDeck.dynamicCards.PushBack(116); // 5 Stennis SPY
			DijkstraDeck.dynamicCardRequirements.PushBack(diff14);
			DijkstraDeck.dynamicCards.PushBack(12); // Dandelion
			
			
			DijkstraDeck.specialCard = 102; // 10 Esterad HERO
			DijkstraDeck.leaderIndex = 1002; 
			enemyDecks.PushBack(DijkstraDeck);
			
			
			//------------------------------------------------------------------//BaronDeck.deckName = "Baron";	
			BaronDeck.cardIndices.PushBack(2); //Scorch	
			BaronDeck.cardIndices.PushBack(3); //Biting Frost	
			BaronDeck.cardIndices.PushBack(5); //Torrential Rain	
			BaronDeck.cardIndices.PushBack(5); //Torrential Rain

			if (difficulty == 1)
			{	
				BaronDeck.cardIndices.PushBack(108); // [2] Yarpen
				BaronDeck.cardIndices.PushBack(13); //  [5] Zoltan
				BaronDeck.cardIndices.PushBack(5); // Clear Sky
			}
			if (difficulty == 2)
			{
				BaronDeck.cardIndices.PushBack(2); //Scorch
			}
			if (difficulty == 3)
			{
				BaronDeck.cardIndices.PushBack(0); //Dummy
				BaronDeck.cardIndices.PushBack(0); //Dummy
				BaronDeck.cardIndices.PushBack(101); // [10] Natalis [HERO]
			}
			
			BaronDeck.cardIndices.PushBack(105); //Thaler [1] [SPY]	
			BaronDeck.cardIndices.PushBack(111); //Keira Metz  [5]	
			BaronDeck.cardIndices.PushBack(112); //Síle de Tansarville [5]	
			BaronDeck.cardIndices.PushBack(116); //Prince Stennis  [5] [SPY]	
			BaronDeck.cardIndices.PushBack(121); //Trebuchet [6]	
			BaronDeck.cardIndices.PushBack(125); //Poor Fucking Infantry [2] [TightBond] 	
			BaronDeck.cardIndices.PushBack(125); //Poor Fucking Infantry [2] [TightBond] 	
			BaronDeck.cardIndices.PushBack(125); //Poor Fucking Infantry [2] [TightBond] 	
			BaronDeck.cardIndices.PushBack(130); //Crinfrid Reavers Dragon Hunter [4] [TightBond]	
			BaronDeck.cardIndices.PushBack(131); //Crinfrid Reavers Dragon Hunter [4] [TightBond]	
			BaronDeck.cardIndices.PushBack(132); //Crinfrid Reavers Dragon Hunter [4] [TightBond]	
			BaronDeck.cardIndices.PushBack(140); //Catapult [5] [TightBond] 	
			BaronDeck.cardIndices.PushBack(145); //Ballista [6]	
			BaronDeck.cardIndices.PushBack(160); //Blue Stripes Commando [4] [TightBond]	
			BaronDeck.cardIndices.PushBack(160); //Blue Stripes Commando [4] [TightBond]	
			BaronDeck.cardIndices.PushBack(160); //Blue Stripes Commando [4] [TightBond]	
			BaronDeck.cardIndices.PushBack(170); //Siege Tower [6]

			//-------------------------------------------------------------//note: Powerful Neutrals -------------------------------------------

			BaronDeck.dynamicCardRequirements.PushBack(diff5);
			BaronDeck.dynamicCards.PushBack(1); // Horn
			BaronDeck.dynamicCardRequirements.PushBack(diff7);
			BaronDeck.dynamicCards.PushBack(8); // [6] Vesemir
			BaronDeck.dynamicCardRequirements.PushBack(diff9);
			BaronDeck.dynamicCards.PushBack(120); // [6] Trebuchet
			BaronDeck.dynamicCardRequirements.PushBack(diff11);
			BaronDeck.dynamicCards.PushBack(11); // [7] Triss
			BaronDeck.dynamicCardRequirements.PushBack(diff11);
			BaronDeck.dynamicCards.PushBack(12); // [2] Dandelion [HORN]
			BaronDeck.dynamicCardRequirements.PushBack(diff14);
			BaronDeck.dynamicCards.PushBack(15); // [7] Villen [SCORCH-MELEE]
			BaronDeck.dynamicCardRequirements.PushBack(diff14);
			BaronDeck.dynamicCards.PushBack(7); // [15] Geralt of Rivia

			BaronDeck.specialCard = 109; // [4] Djikstra [SPY]
			BaronDeck.leaderIndex = 1001;
			enemyDecks.PushBack(BaronDeck);
			
	}
	
	private function SetupAIDeckDefinitions1()
	{
		var RocheDeck			:SDeckDefinition;
		var SjustaDeck			:SDeckDefinition;


			//RocheDeck.deckName = "Roche";	
			RocheDeck.cardIndices.PushBack(0); // Dummy	
			RocheDeck.cardIndices.PushBack(1); // Horn
			RocheDeck.cardIndices.PushBack(4); // Impenetrable Fog
			RocheDeck.cardIndices.PushBack(6); // Clear Weather	
			
			if (difficulty == 1)
			{	
				RocheDeck.cardIndices.PushBack(6); // Clear Weather
				RocheDeck.cardIndices.PushBack(108); // [2] Yarpen
				RocheDeck.cardIndices.PushBack(136); //Redanian Foot Soldier [1]
			}
			if (difficulty == 2)
			{
				RocheDeck.cardIndices.PushBack(0); // Dummy	
				RocheDeck.cardIndices.PushBack(1); // Horn
				RocheDeck.cardIndices.PushBack(136); //Redanian Foot Soldier [1]
			}
			if (difficulty == 3)
			{
				RocheDeck.cardIndices.PushBack(0); // Dummy	
				RocheDeck.cardIndices.PushBack(1); // Horn
				RocheDeck.cardIndices.PushBack(9); // [7] Yennefer [HERO][NURSE]
			}
			
			RocheDeck.cardIndices.PushBack(101); //John Natalis [10] ***[HERO]***	
			RocheDeck.cardIndices.PushBack(120); //Trebuchet [6]	
			RocheDeck.cardIndices.PushBack(121); //Trebuchet [6]	
			RocheDeck.cardIndices.PushBack(125); //Poor Fucking Infantry [2] [TightBond] 	
			RocheDeck.cardIndices.PushBack(126); //Poor Fucking Infantry [2] [TightBond] 
			RocheDeck.cardIndices.PushBack(127); //Poor Fucking Infantry [2] [TightBond] 	
			RocheDeck.cardIndices.PushBack(135); //Redanian Foot Soldier [1]		
			RocheDeck.cardIndices.PushBack(140); //Catapult [5] [TightBond] 	
			RocheDeck.cardIndices.PushBack(141); //Catapult [5] [TightBond] 		
			RocheDeck.cardIndices.PushBack(145); //Ballista [6]	
			RocheDeck.cardIndices.PushBack(146); //Ballista [6]	
			RocheDeck.cardIndices.PushBack(150); //Kaedweni Siege Expert [2] [MoraleBoost]	
			RocheDeck.cardIndices.PushBack(151); //Kaedweni Siege Expert [2] [MoraleBoost]		
			RocheDeck.cardIndices.PushBack(170); //Siege Tower [6]	
			RocheDeck.cardIndices.PushBack(175); //Dun Banner Medic [0] [Nurse]


			RocheDeck.dynamicCardRequirements.PushBack(diff5);
			RocheDeck.dynamicCards.PushBack(15); // [7] Villen [MELEE-SCORCH]
			RocheDeck.dynamicCardRequirements.PushBack(diff7);
			RocheDeck.dynamicCards.PushBack(2); // Scorch	
			RocheDeck.dynamicCardRequirements.PushBack(diff9);
			RocheDeck.dynamicCards.PushBack(10); // [15] Ciri
			RocheDeck.dynamicCardRequirements.PushBack(diff11);
			RocheDeck.dynamicCards.PushBack(11); // [7] Triss [HERO]
			RocheDeck.dynamicCardRequirements.PushBack(diff11);
			RocheDeck.dynamicCards.PushBack(8); // [6] Vesemir
			RocheDeck.dynamicCardRequirements.PushBack(diff14);
			RocheDeck.dynamicCards.PushBack(12); // [2] Dandelion [HORN]
			RocheDeck.dynamicCardRequirements.PushBack(diff14);
			RocheDeck.dynamicCards.PushBack(7); // [15] Geralt of Rivia


			RocheDeck.specialCard = -1;
			RocheDeck.leaderIndex = 1003; 
			enemyDecks.PushBack(RocheDeck);
			
			
			//SjustaDeck.deckName = "Sjusta";	
			SjustaDeck.cardIndices.PushBack(0); // Dummy	
			SjustaDeck.cardIndices.PushBack(2); // Scorch

			if (difficulty == 1)
			{	
				SjustaDeck.cardIndices.PushBack(135); //Redanian Foot Soldier [1]	
				SjustaDeck.cardIndices.PushBack(136); //Redanian Foot Soldier [1]
				SjustaDeck.cardIndices.PushBack(108); //Yarpen Zigrin  [2]
			}
			if (difficulty == 2)
			{
				SjustaDeck.cardIndices.PushBack(0); // Dummy	
				SjustaDeck.cardIndices.PushBack(1); // Horn
				SjustaDeck.cardIndices.PushBack(135); //Redanian Foot Soldier [1]	
				SjustaDeck.cardIndices.PushBack(136); //Redanian Foot Soldier [1]
				SjustaDeck.cardIndices.PushBack(108); //Yarpen Zigrin  [2]
			}
			if (difficulty == 3)
			{
				SjustaDeck.cardIndices.PushBack(0); // Dummy	
				SjustaDeck.cardIndices.PushBack(1); // Horn
			}

			SjustaDeck.cardIndices.PushBack(12); //Dandelion [2] [MoraleBoost]	
			SjustaDeck.cardIndices.PushBack(13); //zoltan [5]	
			SjustaDeck.cardIndices.PushBack(106); //Ves [5]		
			SjustaDeck.cardIndices.PushBack(109); //Sigismund Dijkstra [SPY]
			SjustaDeck.cardIndices.PushBack(111); //Keira Metz  [5]	
			SjustaDeck.cardIndices.PushBack(112); //Síle de Tansarville [5]	
			SjustaDeck.cardIndices.PushBack(113); //Sabrina Glevissig [4]
			SjustaDeck.cardIndices.PushBack(116); //Prince Stennis  [SPY]
			SjustaDeck.cardIndices.PushBack(125); //Poor Fucking Infantry [2] [TightBond] 	
			SjustaDeck.cardIndices.PushBack(126); //Poor Fucking Infantry [2] [TightBond]  	
			SjustaDeck.cardIndices.PushBack(130); //Crinfrid Reavers Dragon Hunter [4] [TightBond] 	
			SjustaDeck.cardIndices.PushBack(131); //Crinfrid Reavers Dragon Hunter [4] [TightBond] 	
			SjustaDeck.cardIndices.PushBack(132); //Crinfrid Reavers Dragon Hunter [4] [TightBond]		
			SjustaDeck.cardIndices.PushBack(160); //Blue Stripes Commando [4] [TightBond]	
			SjustaDeck.cardIndices.PushBack(160); //Blue Stripes Commando [4] [TightBond]

			SjustaDeck.dynamicCardRequirements.PushBack(diff5);
			SjustaDeck.dynamicCards.PushBack(15);
			SjustaDeck.dynamicCardRequirements.PushBack(diff7);
			SjustaDeck.dynamicCards.PushBack(2); //Scorch	
			SjustaDeck.dynamicCardRequirements.PushBack(diff9);
			SjustaDeck.dynamicCards.PushBack(9);
			SjustaDeck.dynamicCardRequirements.PushBack(diff11);
			SjustaDeck.dynamicCards.PushBack(11);
			SjustaDeck.dynamicCardRequirements.PushBack(diff11);
			SjustaDeck.dynamicCards.PushBack(8);
			SjustaDeck.dynamicCardRequirements.PushBack(diff14);
			SjustaDeck.dynamicCards.PushBack(10);
			SjustaDeck.dynamicCardRequirements.PushBack(diff14);
			SjustaDeck.dynamicCards.PushBack(7); // [ 15 ] Geralt of Rivia

			SjustaDeck.specialCard = -1;
			SjustaDeck.leaderIndex = 1004; 
			enemyDecks.PushBack(SjustaDeck);


	}
	private function SetupAIDeckDefinitions2()
	{
		var StjepanDeck			:SDeckDefinition;
		var CrossroadsDeck		:SDeckDefinition;
		var BoatBuilderDeck		:SDeckDefinition;

		
		////////////////NILFGAARD/////////////////
			
			//StjepanDeck.deckName = "Stjepan";	
			StjepanDeck.cardIndices.PushBack(0); // Dummy
			StjepanDeck.cardIndices.PushBack(3); // Biting Frost	
			StjepanDeck.cardIndices.PushBack(4); // Impenetrable Fog	

			if (difficulty == 1)
			{	
				StjepanDeck.cardIndices.PushBack(3); // Biting Frost
				StjepanDeck.cardIndices.PushBack(5); // Torrential Rain	
				StjepanDeck.cardIndices.PushBack(215); // Sweers [2]
			}
			if (difficulty == 2)
			{
				StjepanDeck.cardIndices.PushBack(0); // Dummy
				StjepanDeck.cardIndices.PushBack(3); // Biting Frost	
				StjepanDeck.cardIndices.PushBack(5); // Torrential Rain	
				StjepanDeck.cardIndices.PushBack(215); // Sweers [2]
			}
			if (difficulty == 3)
			{
				StjepanDeck.cardIndices.PushBack(0); // Dummy
			}

			StjepanDeck.cardIndices.PushBack(206); // Assire var Anahid  [6]	
			StjepanDeck.cardIndices.PushBack(207); // Cynthia [4]
			StjepanDeck.cardIndices.PushBack(208); // Fringilla Vigo   [6]	
			StjepanDeck.cardIndices.PushBack(210); // Rainfarn [4]		
			StjepanDeck.cardIndices.PushBack(213); // Shilard Fitz-Oesterlen  [4] [SPY]	
			StjepanDeck.cardIndices.PushBack(214); // Stefan Skellen  [1] [SPY]
	
			StjepanDeck.cardIndices.PushBack(218); // Vattier de Rideaux Vattier [1] [SPY]	
			StjepanDeck.cardIndices.PushBack(235); // Black Archer [10]
			StjepanDeck.cardIndices.PushBack(236); // Black Archer [10]
			StjepanDeck.cardIndices.PushBack(240); // Heavy Zerri  [10]
			StjepanDeck.cardIndices.PushBack(241); // Zerri [5]
			StjepanDeck.cardIndices.PushBack(245); // Impera [3] [TIGHT]
			StjepanDeck.cardIndices.PushBack(246); // Impera [3] [TIGHT]
			StjepanDeck.cardIndices.PushBack(247); // Impera [3] [TIGHT]
			StjepanDeck.cardIndices.PushBack(230); // [1] Support [NURSE]
			StjepanDeck.cardIndices.PushBack(231); // [1] Support [NURSE]


			StjepanDeck.dynamicCardRequirements.PushBack(diff5);
			StjepanDeck.dynamicCards.PushBack(15);
			StjepanDeck.dynamicCardRequirements.PushBack(diff7);
			StjepanDeck.dynamicCards.PushBack(230);
			StjepanDeck.dynamicCardRequirements.PushBack(diff9);
			StjepanDeck.dynamicCards.PushBack(2); //Scorch	
			StjepanDeck.dynamicCardRequirements.PushBack(diff11);
			StjepanDeck.dynamicCards.PushBack(231);
			StjepanDeck.dynamicCardRequirements.PushBack(diff11);
			StjepanDeck.dynamicCards.PushBack(8);
			StjepanDeck.dynamicCardRequirements.PushBack(diff14);
			StjepanDeck.dynamicCards.PushBack(12);
			StjepanDeck.dynamicCardRequirements.PushBack(diff14);
			StjepanDeck.dynamicCards.PushBack(7); // [ 15 ] Geralt of Rivia


			StjepanDeck.specialCard = 9; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			StjepanDeck.leaderIndex = 2003; 
			enemyDecks.PushBack(StjepanDeck);
			
			//CrossroadsDeck.deckName = "Crossroads Innkeeper";	
			CrossroadsDeck.cardIndices.PushBack(1); //Horn
			CrossroadsDeck.cardIndices.PushBack(2); //Scorch
			CrossroadsDeck.cardIndices.PushBack(6); //Clear Weather	

			if (difficulty == 1)
			{	
				CrossroadsDeck.cardIndices.PushBack(4); //Impenetrable Fog
				CrossroadsDeck.cardIndices.PushBack(4); //Impenetrable Fog
				CrossroadsDeck.cardIndices.PushBack(6); //Clear Weather
				CrossroadsDeck.cardIndices.PushBack(209); // Morteisen [3]
				CrossroadsDeck.cardIndices.PushBack(212); //Rotten Mangonel [3]	
			}
			if (difficulty == 2)
			{
				CrossroadsDeck.cardIndices.PushBack(2); //Scorch
				CrossroadsDeck.cardIndices.PushBack(4); //Impenetrable Fog
				CrossroadsDeck.cardIndices.PushBack(4); //Impenetrable Fog
				CrossroadsDeck.cardIndices.PushBack(6); //Clear Weather
				CrossroadsDeck.cardIndices.PushBack(209); // Morteisen [3] 	
				CrossroadsDeck.cardIndices.PushBack(212); //Rotten Mangonel [3]	
			}
			if (difficulty == 3)
			{
				CrossroadsDeck.cardIndices.PushBack(2); //Scorch
				CrossroadsDeck.cardIndices.PushBack(4); //Impenetrable Fog
			}

			CrossroadsDeck.cardIndices.PushBack(211); //Renuald aep Matsen  [5] 
			CrossroadsDeck.cardIndices.PushBack(213); //Shilard Fitz-Oesterlen  [4] [SPY]	
			CrossroadsDeck.cardIndices.PushBack(230); // [1] Support [NURSE]
			CrossroadsDeck.cardIndices.PushBack(231); // [1] Support [NURSE]
			CrossroadsDeck.cardIndices.PushBack(235); // Black Archer [10]
			CrossroadsDeck.cardIndices.PushBack(236); // Black Archer [10]
			CrossroadsDeck.cardIndices.PushBack(240); // Heavy Zerri  [10]
			CrossroadsDeck.cardIndices.PushBack(241); // Zerri [5]
			CrossroadsDeck.cardIndices.PushBack(245); // Impera [3] [TIGHT]
			CrossroadsDeck.cardIndices.PushBack(246); // Impera [3] [TIGHT]
			CrossroadsDeck.cardIndices.PushBack(247); // Impera [3] [TIGHT]
			CrossroadsDeck.cardIndices.PushBack(248); // Impera [3] [TIGHT]
			CrossroadsDeck.cardIndices.PushBack(250); // [2] Nausicaa [TIGHT]
			CrossroadsDeck.cardIndices.PushBack(251); // [2] Nausicaa [TIGHT]
			CrossroadsDeck.cardIndices.PushBack(252); // [2] Nausicaa [TIGHT]
			CrossroadsDeck.cardIndices.PushBack(265); // [0] Support [NURSE]


			CrossroadsDeck.dynamicCardRequirements.PushBack(diff5);
			CrossroadsDeck.dynamicCards.PushBack(15);
			CrossroadsDeck.dynamicCardRequirements.PushBack(diff7);
			CrossroadsDeck.dynamicCards.PushBack(0);
			CrossroadsDeck.dynamicCardRequirements.PushBack(diff9);
			CrossroadsDeck.dynamicCards.PushBack(1);
			CrossroadsDeck.dynamicCardRequirements.PushBack(diff11);
			CrossroadsDeck.dynamicCards.PushBack(11);
			CrossroadsDeck.dynamicCardRequirements.PushBack(diff11);
			CrossroadsDeck.dynamicCards.PushBack(13);
			CrossroadsDeck.dynamicCardRequirements.PushBack(diff14);
			CrossroadsDeck.dynamicCards.PushBack(7); // [15] Geralt of Rivia
			CrossroadsDeck.dynamicCardRequirements.PushBack(diff14);
			CrossroadsDeck.dynamicCards.PushBack(10);

			CrossroadsDeck.specialCard = 201; // [10] Menno [HERO]
			CrossroadsDeck.leaderIndex = 2002; 
			enemyDecks.PushBack(CrossroadsDeck);
			
			//BoatBuilderDeck.deckName = "Boat Builder";	
			BoatBuilderDeck.cardIndices.PushBack(0); // Dummy
			BoatBuilderDeck.cardIndices.PushBack(2); //Scorch	
			BoatBuilderDeck.cardIndices.PushBack(3); //Biting Frost
			BoatBuilderDeck.cardIndices.PushBack(4); //Impenetrable Fog
			BoatBuilderDeck.cardIndices.PushBack(6); //Clear Weather	

			if (difficulty == 1)
			{	
				BoatBuilderDeck.cardIndices.PushBack(5); //Torrential Rain
				BoatBuilderDeck.cardIndices.PushBack(209); // Morteisen [3] 
			}
			if (difficulty == 2)
			{
				BoatBuilderDeck.cardIndices.PushBack(0); // Dummy	
				BoatBuilderDeck.cardIndices.PushBack(1); //Horn
				BoatBuilderDeck.cardIndices.PushBack(5); //Torrential Rain
				BoatBuilderDeck.cardIndices.PushBack(209); // Morteisen [3] 
			}
			if (difficulty == 3)
			{
				BoatBuilderDeck.cardIndices.PushBack(0); // Dummy	
				BoatBuilderDeck.cardIndices.PushBack(1); //Horn
			}

			BoatBuilderDeck.cardIndices.PushBack(202); // [10] Moorvan [HERO]
			BoatBuilderDeck.cardIndices.PushBack(206); // Assire var Anahid  [6]
			BoatBuilderDeck.cardIndices.PushBack(214); // Stefan Skellen  [1] [SPY]
			BoatBuilderDeck.cardIndices.PushBack(218); // Vattier de Rideaux Vattier [1] [SPY]	
			BoatBuilderDeck.cardIndices.PushBack(220); // [6] Cahir
			BoatBuilderDeck.cardIndices.PushBack(235); // Black Archer [10]
			BoatBuilderDeck.cardIndices.PushBack(236); // Black Archer [10]
			BoatBuilderDeck.cardIndices.PushBack(240); // Heavy Zerri  [10]
			BoatBuilderDeck.cardIndices.PushBack(241); // Zerri [5]
			BoatBuilderDeck.cardIndices.PushBack(245); // Impera [3] [TIGHT]
			BoatBuilderDeck.cardIndices.PushBack(246); // Impera [3] [TIGHT]
			BoatBuilderDeck.cardIndices.PushBack(250); // [2] Nausicaa [TIGHT]
			BoatBuilderDeck.cardIndices.PushBack(255); // [6] Engineer
			BoatBuilderDeck.cardIndices.PushBack(265); // [0] Support [NURSE]

			BoatBuilderDeck.dynamicCardRequirements.PushBack(diff5);
			BoatBuilderDeck.dynamicCards.PushBack(247);
			BoatBuilderDeck.dynamicCardRequirements.PushBack(diff7);
			BoatBuilderDeck.dynamicCards.PushBack(248);
			BoatBuilderDeck.dynamicCardRequirements.PushBack(diff9);
			BoatBuilderDeck.dynamicCards.PushBack(251);
			BoatBuilderDeck.dynamicCardRequirements.PushBack(diff11);
			BoatBuilderDeck.dynamicCards.PushBack(252);
			BoatBuilderDeck.dynamicCardRequirements.PushBack(diff11);
			BoatBuilderDeck.dynamicCards.PushBack(260);
			BoatBuilderDeck.dynamicCardRequirements.PushBack(diff14);
			BoatBuilderDeck.dynamicCards.PushBack(7); // [ 15 ] Geralt of Rivia
			BoatBuilderDeck.dynamicCardRequirements.PushBack(diff14);
			BoatBuilderDeck.dynamicCards.PushBack(12);

			BoatBuilderDeck.specialCard = 200; // [10] Letho [HERO]
			BoatBuilderDeck.leaderIndex = 2004; 
			enemyDecks.PushBack(BoatBuilderDeck);
			

	}
	
	
	private function SetupAIDeckDefinitions3()
	{

		var MarkizaDeck			:SDeckDefinition;
		var GremistaDeck		:SDeckDefinition;


			//MarkizaDeck.deckName = "Markiza Serenity";
			MarkizaDeck.cardIndices.PushBack(1); //Horn
			MarkizaDeck.cardIndices.PushBack(2); //Scorch
			MarkizaDeck.cardIndices.PushBack(4); //Impenetrable Fog
			MarkizaDeck.cardIndices.PushBack(6); //Clear Weather	

			if (difficulty == 1)
			{	
				MarkizaDeck.cardIndices.PushBack(3); //Biting Frost
				MarkizaDeck.cardIndices.PushBack(3); //Biting Frost	
				MarkizaDeck.cardIndices.PushBack(5); //Torrential Rain
				MarkizaDeck.cardIndices.PushBack(210); //Rainfarn [4]	
			}
			if (difficulty == 2)
			{
				MarkizaDeck.cardIndices.PushBack(3); //Biting Frost
				MarkizaDeck.cardIndices.PushBack(3); //Biting Frost	
				MarkizaDeck.cardIndices.PushBack(5); //Torrential Rain
				MarkizaDeck.cardIndices.PushBack(0); // Dummy	
				MarkizaDeck.cardIndices.PushBack(1); //Horn
				MarkizaDeck.cardIndices.PushBack(2); //Scorch
				MarkizaDeck.cardIndices.PushBack(210); //Rainfarn [4]	
			}
			if (difficulty == 3)
			{
				MarkizaDeck.cardIndices.PushBack(3); //Biting Frost	
				MarkizaDeck.cardIndices.PushBack(0); // Dummy	
				MarkizaDeck.cardIndices.PushBack(1); //Horn
				MarkizaDeck.cardIndices.PushBack(2); //Scorch	
			}

			MarkizaDeck.cardIndices.PushBack(200); //Letho of Gulet  [10] ***[HERO]***	
			MarkizaDeck.cardIndices.PushBack(206); //Assire var Anahid  [6]	
			MarkizaDeck.cardIndices.PushBack(208); //Fringilla Vigo   [6]	
			MarkizaDeck.cardIndices.PushBack(211); //Renuald aep Matsen  [5] 	
			MarkizaDeck.cardIndices.PushBack(213); //Shilard Fitz-Oesterlen  [4] [SPY]	
			MarkizaDeck.cardIndices.PushBack(214); //Stefan Skellen  [1] [SPY]
			MarkizaDeck.cardIndices.PushBack(220);	
			MarkizaDeck.cardIndices.PushBack(221);	
			MarkizaDeck.cardIndices.PushBack(230);	
			MarkizaDeck.cardIndices.PushBack(231);	
			MarkizaDeck.cardIndices.PushBack(245);	
			MarkizaDeck.cardIndices.PushBack(246);	
			MarkizaDeck.cardIndices.PushBack(250);	
			MarkizaDeck.cardIndices.PushBack(251);
			MarkizaDeck.cardIndices.PushBack(252);

			MarkizaDeck.dynamicCardRequirements.PushBack(diff5);
			MarkizaDeck.dynamicCards.PushBack(235);
			MarkizaDeck.dynamicCardRequirements.PushBack(diff7);
			MarkizaDeck.dynamicCards.PushBack(0);
			MarkizaDeck.dynamicCardRequirements.PushBack(diff9);
			MarkizaDeck.dynamicCards.PushBack(13);
			MarkizaDeck.dynamicCardRequirements.PushBack(diff11);
			MarkizaDeck.dynamicCards.PushBack(12);
			MarkizaDeck.dynamicCardRequirements.PushBack(diff11);
			MarkizaDeck.dynamicCards.PushBack(14);
			MarkizaDeck.dynamicCardRequirements.PushBack(diff14);
			MarkizaDeck.dynamicCards.PushBack(7); // [ 15 ] Geralt of Rivia
			MarkizaDeck.dynamicCardRequirements.PushBack(diff14);
			MarkizaDeck.dynamicCards.PushBack(10);

			MarkizaDeck.specialCard = 202; // [10] Moorvan [HERO]
			MarkizaDeck.leaderIndex = 2001; 
			enemyDecks.PushBack(MarkizaDeck);
			
			
			//GremistaDeck.deckName = "Gremista";	
			GremistaDeck.cardIndices.PushBack(3); //Biting Frost

			if (difficulty == 1)
			{			
				GremistaDeck.cardIndices.PushBack(4); //Impenetrable Fog 	
				GremistaDeck.cardIndices.PushBack(5); //Torrential Rain
				GremistaDeck.cardIndices.PushBack(6); //Clear Weather
				GremistaDeck.cardIndices.PushBack(215); //Sweers [2]
			}
			if (difficulty == 2)
			{
				GremistaDeck.cardIndices.PushBack(0); // Dummy	
				GremistaDeck.cardIndices.PushBack(0); // Dummy	
				GremistaDeck.cardIndices.PushBack(0); // Dummy
				GremistaDeck.cardIndices.PushBack(4); //Impenetrable Fog 	
				GremistaDeck.cardIndices.PushBack(5); //Torrential Rain
				GremistaDeck.cardIndices.PushBack(6); //Clear Weather
				GremistaDeck.cardIndices.PushBack(215); //Sweers [2]
			}
			if (difficulty == 3)
			{
				GremistaDeck.cardIndices.PushBack(0); // Dummy	
				GremistaDeck.cardIndices.PushBack(0); // Dummy
				GremistaDeck.cardIndices.PushBack(6); //Clear Weather
				GremistaDeck.cardIndices.PushBack(255); // [6] Engineer
				GremistaDeck.cardIndices.PushBack(203); // [10] Moorvan  [HERO]
			}

			GremistaDeck.cardIndices.PushBack(14); //Emiel Regis Rohellec Terzieff [5]
			GremistaDeck.cardIndices.PushBack(203); //Tibor Eggebracht [10] ***[HERO]***
			GremistaDeck.cardIndices.PushBack(205); //Albrich [2]
			GremistaDeck.cardIndices.PushBack(210); //Rainfarn [4]
			GremistaDeck.cardIndices.PushBack(217); //Vanhemar [4]
			GremistaDeck.cardIndices.PushBack(230);	// [0] Archer Support [NURSE]
			GremistaDeck.cardIndices.PushBack(231);	// [0] Archer Support [NURSE]
			GremistaDeck.cardIndices.PushBack(236);	// [10] Black Archer 
			GremistaDeck.cardIndices.PushBack(260);	// [5] Young Emissary [TIGHT]
			GremistaDeck.cardIndices.PushBack(261);	// [5] Young Emissary [TIGHT]
			GremistaDeck.cardIndices.PushBack(265); // [0] Support [NURSE]


			GremistaDeck.dynamicCardRequirements.PushBack(diff5);
			GremistaDeck.dynamicCards.PushBack(15);
			GremistaDeck.dynamicCardRequirements.PushBack(diff7);
			GremistaDeck.dynamicCards.PushBack(12);
			GremistaDeck.dynamicCardRequirements.PushBack(diff9);
			GremistaDeck.dynamicCards.PushBack(10);
			GremistaDeck.dynamicCardRequirements.PushBack(diff11);
			GremistaDeck.dynamicCards.PushBack(8);
			GremistaDeck.dynamicCardRequirements.PushBack(diff11);
			GremistaDeck.dynamicCards.PushBack(9);
			GremistaDeck.dynamicCardRequirements.PushBack(diff14);
			GremistaDeck.dynamicCards.PushBack(7); // [ 15 ] Geralt of Rivia
			GremistaDeck.dynamicCardRequirements.PushBack(diff14);
			GremistaDeck.dynamicCards.PushBack(16);


			GremistaDeck.specialCard = 11; // [7] Triss [HERO]
			GremistaDeck.leaderIndex = 2001; 
			enemyDecks.PushBack(GremistaDeck);

	}


	private function SetupAIDeckDefinitions4()
	{
	
		var ZoltanDeck			:SDeckDefinition;
		var LambertDeck			:SDeckDefinition;
		var ThalerDeck			:SDeckDefinition;

		
		////////////SCOIA'TAEL//////////////////
			
			//ZoltanDeck.deckName = "Zoltan";	
			ZoltanDeck.cardIndices.PushBack(2); //Scorch

			if (difficulty == 1)
			{
				ZoltanDeck.cardIndices.PushBack(3); //Biting Frost	
				ZoltanDeck.cardIndices.PushBack(4); //Impenetrable Fog
				ZoltanDeck.cardIndices.PushBack(5); //Torrential Rain
				ZoltanDeck.cardIndices.PushBack(342);	// [5] 
				ZoltanDeck.cardIndices.PushBack(355);	// [4] 
			}
			if (difficulty == 2)
			{
				ZoltanDeck.cardIndices.PushBack(1); //Horn
				ZoltanDeck.cardIndices.PushBack(1); //Horn
				ZoltanDeck.cardIndices.PushBack(2); //Scorch
				ZoltanDeck.cardIndices.PushBack(3); //Biting Frost	
				ZoltanDeck.cardIndices.PushBack(4); //Impenetrable Fog
				ZoltanDeck.cardIndices.PushBack(5); //Torrential Rain
				ZoltanDeck.cardIndices.PushBack(342);	// [5] 
				ZoltanDeck.cardIndices.PushBack(355);	// [4] 
			}
			if (difficulty == 3)
			{
				ZoltanDeck.cardIndices.PushBack(1); //Horn
				ZoltanDeck.cardIndices.PushBack(1); //Horn
				ZoltanDeck.cardIndices.PushBack(2); //Scorch
				ZoltanDeck.cardIndices.PushBack(302);	// [10] Saskia [HERO]
			}

			ZoltanDeck.cardIndices.PushBack(302);	// [10] Insegrim [HERO]
			ZoltanDeck.cardIndices.PushBack(307);	// [6] Ida
			ZoltanDeck.cardIndices.PushBack(320);	// [5] SUMMON
			ZoltanDeck.cardIndices.PushBack(321);	// [5] SUMMON
			ZoltanDeck.cardIndices.PushBack(325);	// [5] AGILE
			ZoltanDeck.cardIndices.PushBack(326);	// [5] AGILE
			ZoltanDeck.cardIndices.PushBack(335);	// [3] SUMMON
			ZoltanDeck.cardIndices.PushBack(336);	// [3] SUMMON
			ZoltanDeck.cardIndices.PushBack(337);	// [3] SUMMON
			ZoltanDeck.cardIndices.PushBack(340);	// [5] 
			ZoltanDeck.cardIndices.PushBack(341);	// [5] 
			ZoltanDeck.cardIndices.PushBack(365);	// [0] NURSE
			ZoltanDeck.cardIndices.PushBack(366);	// [0] NURSE


			ZoltanDeck.dynamicCardRequirements.PushBack(diff5);
			ZoltanDeck.dynamicCards.PushBack(15);
			ZoltanDeck.dynamicCardRequirements.PushBack(diff7);
			ZoltanDeck.dynamicCards.PushBack(8);
			ZoltanDeck.dynamicCardRequirements.PushBack(diff9);
			ZoltanDeck.dynamicCards.PushBack(9);
			ZoltanDeck.dynamicCardRequirements.PushBack(diff11);
			ZoltanDeck.dynamicCards.PushBack(11);
			ZoltanDeck.dynamicCardRequirements.PushBack(diff11);
			ZoltanDeck.dynamicCards.PushBack(14);
			ZoltanDeck.dynamicCardRequirements.PushBack(diff14);
			ZoltanDeck.dynamicCards.PushBack(7); // [ 15 ] Geralt of Rivia
			ZoltanDeck.dynamicCardRequirements.PushBack(diff14);
			ZoltanDeck.dynamicCards.PushBack(16);


			ZoltanDeck.specialCard = 300; // [10] Eithne [HERO]
			ZoltanDeck.leaderIndex = 3002; 
			enemyDecks.PushBack(ZoltanDeck);
			
			//LambertDeck.deckName = "Lambert";	
			LambertDeck.cardIndices.PushBack(0); // Dummy
			LambertDeck.cardIndices.PushBack(2); //Scorch
			LambertDeck.cardIndices.PushBack(3); //Biting Frost	
			LambertDeck.cardIndices.PushBack(6); //Clear Weather
			
			if (difficulty == 1)
			{
				LambertDeck.cardIndices.PushBack(310);	// [2] Toruviel
				LambertDeck.cardIndices.PushBack(311);	// [1] Riordain
			}
			if (difficulty == 2)
			{
				LambertDeck.cardIndices.PushBack(0); // Dummy	
				LambertDeck.cardIndices.PushBack(1); //Horn
				LambertDeck.cardIndices.PushBack(2); //Scorch
				LambertDeck.cardIndices.PushBack(2); //Scorch	

			}
			if (difficulty == 3)
			{
				LambertDeck.cardIndices.PushBack(0); // Dummy	
				LambertDeck.cardIndices.PushBack(1); //Horn
				LambertDeck.cardIndices.PushBack(2); //Scorch
				LambertDeck.cardIndices.PushBack(301);	// [10] Saskia [HERO]
			}

			LambertDeck.cardIndices.PushBack(9);	
			LambertDeck.cardIndices.PushBack(302);	
			LambertDeck.cardIndices.PushBack(308);	
			LambertDeck.cardIndices.PushBack(309);	
			LambertDeck.cardIndices.PushBack(320);	
			LambertDeck.cardIndices.PushBack(340);	
			LambertDeck.cardIndices.PushBack(341);	
			LambertDeck.cardIndices.PushBack(342);	
			LambertDeck.cardIndices.PushBack(343);	
			LambertDeck.cardIndices.PushBack(350);	
			LambertDeck.cardIndices.PushBack(351);	
			LambertDeck.cardIndices.PushBack(360);	
			LambertDeck.cardIndices.PushBack(365);	
			LambertDeck.cardIndices.PushBack(366);
			
			LambertDeck.dynamicCardRequirements.PushBack(diff5);
			LambertDeck.dynamicCards.PushBack(8);
			LambertDeck.dynamicCardRequirements.PushBack(diff7);
			LambertDeck.dynamicCards.PushBack(12);
			LambertDeck.dynamicCardRequirements.PushBack(diff9);
			LambertDeck.dynamicCards.PushBack(322); // Havcaaren Support [ 5 ] [SUMMON CLONES]
			LambertDeck.dynamicCardRequirements.PushBack(diff11);
			LambertDeck.dynamicCards.PushBack(2); //Scorch	
			LambertDeck.dynamicCardRequirements.PushBack(diff11);
			LambertDeck.dynamicCards.PushBack(13);
			LambertDeck.dynamicCardRequirements.PushBack(diff14);
			LambertDeck.dynamicCards.PushBack(15);
			LambertDeck.dynamicCardRequirements.PushBack(diff14);
			LambertDeck.dynamicCards.PushBack(10);


			
			LambertDeck.specialCard = 11; // Always has Triss Merigold has a card in his hand.
			LambertDeck.leaderIndex = 3001; 
			enemyDecks.PushBack(LambertDeck);
			
			//ThalerDeck.deckName = "Thaler";	
			ThalerDeck.cardIndices.PushBack(6); //Clear Weather
			
			if (difficulty == 1)
			{
				ThalerDeck.cardIndices.PushBack(3); //Biting Frost	
				ThalerDeck.cardIndices.PushBack(3); //Biting Frost	
				ThalerDeck.cardIndices.PushBack(4); //Impenetrable Fog
				ThalerDeck.cardIndices.PushBack(5); //Torrential Rain	
				ThalerDeck.cardIndices.PushBack(6); //Clear Weather
				ThalerDeck.cardIndices.PushBack(310); // [2] Toruviel
			}
			if (difficulty == 2)
			{
				ThalerDeck.cardIndices.PushBack(3); //Biting Frost	
				ThalerDeck.cardIndices.PushBack(3); //Biting Frost	
				ThalerDeck.cardIndices.PushBack(4); //Impenetrable Fog
				ThalerDeck.cardIndices.PushBack(5); //Torrential Rain	
				ThalerDeck.cardIndices.PushBack(6); //Clear Weather	
			}
			if (difficulty == 3)
			{
				ThalerDeck.cardIndices.PushBack(3); //Biting Frost
				ThalerDeck.cardIndices.PushBack(5); //Torrential Rain
				ThalerDeck.cardIndices.PushBack(0); //Dummy
				ThalerDeck.cardIndices.PushBack(0); //Dummy
				ThalerDeck.cardIndices.PushBack(1); //Horn
				ThalerDeck.cardIndices.PushBack(300); // [10] Eithne [HERO]
			}
			
			ThalerDeck.cardIndices.PushBack(307);	
			ThalerDeck.cardIndices.PushBack(308);	
			ThalerDeck.cardIndices.PushBack(309);	
			ThalerDeck.cardIndices.PushBack(312);	
			ThalerDeck.cardIndices.PushBack(313);	
			ThalerDeck.cardIndices.PushBack(320);	
			ThalerDeck.cardIndices.PushBack(321);	
			ThalerDeck.cardIndices.PushBack(325);	
			ThalerDeck.cardIndices.PushBack(326);	
			ThalerDeck.cardIndices.PushBack(330);	
			ThalerDeck.cardIndices.PushBack(331);	
			ThalerDeck.cardIndices.PushBack(332);	
			ThalerDeck.cardIndices.PushBack(335);	
			ThalerDeck.cardIndices.PushBack(336);	
			ThalerDeck.cardIndices.PushBack(355);	
			ThalerDeck.cardIndices.PushBack(360);	
			ThalerDeck.cardIndices.PushBack(365);


			ThalerDeck.dynamicCardRequirements.PushBack(diff5);
			ThalerDeck.dynamicCards.PushBack(337);
			ThalerDeck.dynamicCardRequirements.PushBack(diff7);
			ThalerDeck.dynamicCards.PushBack(15);
			ThalerDeck.dynamicCardRequirements.PushBack(diff9);
			ThalerDeck.dynamicCards.PushBack(322);
			ThalerDeck.dynamicCardRequirements.PushBack(diff11);
			ThalerDeck.dynamicCards.PushBack(11);
			ThalerDeck.dynamicCardRequirements.PushBack(diff11);
			ThalerDeck.dynamicCards.PushBack(14);
			ThalerDeck.dynamicCardRequirements.PushBack(diff14);
			ThalerDeck.dynamicCards.PushBack(306);
			ThalerDeck.dynamicCardRequirements.PushBack(diff14);
			ThalerDeck.dynamicCards.PushBack(13);

			ThalerDeck.specialCard = 7; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			ThalerDeck.leaderIndex = 3003; 
			enemyDecks.PushBack(ThalerDeck);

	}
	


	private function SetupAIDeckDefinitions5()
	{

		var VimmeDeck			:SDeckDefinition;
		var ScoiaTraderDeck		:SDeckDefinition;

			//VimmeDeck.deckName = "Vimme";	
			VimmeDeck.cardIndices.PushBack(6); //Clear Weather
			VimmeDeck.cardIndices.PushBack(4); //Impenetrable Fog
			VimmeDeck.cardIndices.PushBack(5); //Torrential Rain
			VimmeDeck.cardIndices.PushBack(1); //Horn

			if (difficulty == 1)
			{
				VimmeDeck.cardIndices.PushBack(4); //Impenetrable Fog
				VimmeDeck.cardIndices.PushBack(310); // [2] Toruviel
			}
			if (difficulty == 2)
			{
				VimmeDeck.cardIndices.PushBack(1); //Horn
				VimmeDeck.cardIndices.PushBack(4); //Impenetrable Fog
				
			}
			if (difficulty == 3)
			{
				VimmeDeck.cardIndices.PushBack(1); //Horn
				VimmeDeck.cardIndices.PushBack(302); // [10] Isengrim [HERO]
			}

			VimmeDeck.cardIndices.PushBack(301);	
			VimmeDeck.cardIndices.PushBack(305);	
			VimmeDeck.cardIndices.PushBack(325);	
			VimmeDeck.cardIndices.PushBack(326);	
			VimmeDeck.cardIndices.PushBack(335);	
			VimmeDeck.cardIndices.PushBack(336);	
			VimmeDeck.cardIndices.PushBack(337);	
			VimmeDeck.cardIndices.PushBack(340);	
			VimmeDeck.cardIndices.PushBack(341);	
			VimmeDeck.cardIndices.PushBack(342);	
			VimmeDeck.cardIndices.PushBack(343);	
			VimmeDeck.cardIndices.PushBack(344);	
			VimmeDeck.cardIndices.PushBack(365);	
			VimmeDeck.cardIndices.PushBack(366);	
			VimmeDeck.cardIndices.PushBack(367);


			VimmeDeck.dynamicCardRequirements.PushBack(diff5);
			VimmeDeck.dynamicCards.PushBack(0);
			VimmeDeck.dynamicCardRequirements.PushBack(diff7);
			VimmeDeck.dynamicCards.PushBack(12);
			VimmeDeck.dynamicCardRequirements.PushBack(diff9);
			VimmeDeck.dynamicCards.PushBack(0);
			VimmeDeck.dynamicCardRequirements.PushBack(diff11);
			VimmeDeck.dynamicCards.PushBack(16);
			VimmeDeck.dynamicCardRequirements.PushBack(diff11);
			VimmeDeck.dynamicCards.PushBack(11);
			VimmeDeck.dynamicCardRequirements.PushBack(diff14);
			VimmeDeck.dynamicCards.PushBack(7); // [15] Geralt of Rivia
			VimmeDeck.dynamicCardRequirements.PushBack(diff14);
			VimmeDeck.dynamicCards.PushBack(14);

			VimmeDeck.specialCard = 8; // [6] Vesemir
			VimmeDeck.leaderIndex = 3002; 
			enemyDecks.PushBack(VimmeDeck);
			
			
			//ScoiaTraderDeck.deckName = "ScoiaTrader";	
			ScoiaTraderDeck.cardIndices.PushBack(6); //Clear Weather	
			ScoiaTraderDeck.cardIndices.PushBack(1); //Horn
			
			if (difficulty == 1)
			{
				ScoiaTraderDeck.cardIndices.PushBack(3); //Biting Frost	
				ScoiaTraderDeck.cardIndices.PushBack(4); //Impenetrable Fog
				ScoiaTraderDeck.cardIndices.PushBack(5); //Torrential Rain
				VimmeDeck.cardIndices.PushBack(310); // [2] Toruviel
			}
			if (difficulty == 2)
			{
				ScoiaTraderDeck.cardIndices.PushBack(0); // Dummy	
				ScoiaTraderDeck.cardIndices.PushBack(1); //Horn
				ScoiaTraderDeck.cardIndices.PushBack(2); //Scorch		
				ScoiaTraderDeck.cardIndices.PushBack(3); //Biting Frost	
				ScoiaTraderDeck.cardIndices.PushBack(4); //Impenetrable Fog
				ScoiaTraderDeck.cardIndices.PushBack(5); //Torrential Rain
				
			}
			if (difficulty == 3)
			{
				ScoiaTraderDeck.cardIndices.PushBack(0); // Dummy
				ScoiaTraderDeck.cardIndices.PushBack(1); //Horn
				ScoiaTraderDeck.cardIndices.PushBack(5); //Torrential Rain
				ScoiaTraderDeck.cardIndices.PushBack(302); // [10] Isengrim [HERO]
				ScoiaTraderDeck.cardIndices.PushBack(301); // [10] Saskia [HERO]
			}

			ScoiaTraderDeck.cardIndices.PushBack(303);	
			ScoiaTraderDeck.cardIndices.PushBack(305);	
			ScoiaTraderDeck.cardIndices.PushBack(306);	
			ScoiaTraderDeck.cardIndices.PushBack(307);	
			ScoiaTraderDeck.cardIndices.PushBack(308);	
			ScoiaTraderDeck.cardIndices.PushBack(309);	
			ScoiaTraderDeck.cardIndices.PushBack(310);	
			ScoiaTraderDeck.cardIndices.PushBack(311);	
			ScoiaTraderDeck.cardIndices.PushBack(312);	
			ScoiaTraderDeck.cardIndices.PushBack(313);	
			ScoiaTraderDeck.cardIndices.PushBack(320);	
			ScoiaTraderDeck.cardIndices.PushBack(321);	
			ScoiaTraderDeck.cardIndices.PushBack(350);	
			ScoiaTraderDeck.cardIndices.PushBack(351);	
			ScoiaTraderDeck.cardIndices.PushBack(352);


			ScoiaTraderDeck.dynamicCardRequirements.PushBack(diff5);
			ScoiaTraderDeck.dynamicCards.PushBack(2);
			ScoiaTraderDeck.dynamicCardRequirements.PushBack(diff7);
			ScoiaTraderDeck.dynamicCards.PushBack(2);
			ScoiaTraderDeck.dynamicCardRequirements.PushBack(diff9);
			ScoiaTraderDeck.dynamicCards.PushBack(8);
			ScoiaTraderDeck.dynamicCardRequirements.PushBack(diff11);
			ScoiaTraderDeck.dynamicCards.PushBack(11);
			ScoiaTraderDeck.dynamicCardRequirements.PushBack(diff11);
			ScoiaTraderDeck.dynamicCards.PushBack(14);
			ScoiaTraderDeck.dynamicCardRequirements.PushBack(diff14);
			ScoiaTraderDeck.dynamicCards.PushBack(15);
			ScoiaTraderDeck.dynamicCardRequirements.PushBack(diff14);
			ScoiaTraderDeck.dynamicCards.PushBack(16);


			ScoiaTraderDeck.specialCard = 10; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			ScoiaTraderDeck.leaderIndex = 3001; 
			enemyDecks.PushBack(ScoiaTraderDeck);
	}
	
	private function SetupAIDeckDefinitions6()
	{
		var CrachDeck			:SDeckDefinition;
		var LugosDeck			:SDeckDefinition;
		var HermitDeck			:SDeckDefinition;

		
		/////////////NO MAN'S LAND//////////////
			
			
			//CrachDeck.deckName = "Crach";	
			CrachDeck.cardIndices.PushBack(1); //Horn
			CrachDeck.cardIndices.PushBack(4); //Impenetrable Fog

			if (difficulty == 1)
			{
				CrachDeck.cardIndices.PushBack(3); //Biting Frost	
				CrachDeck.cardIndices.PushBack(4); //Impenetrable Fog 
				CrachDeck.cardIndices.PushBack(5); //Torrential Rain
				CrachDeck.cardIndices.PushBack(420); // [4] Botchling
				CrachDeck.cardIndices.PushBack(427); // [2] Endrega
			}
			if (difficulty == 2)
			{
				CrachDeck.cardIndices.PushBack(1); //Horn
				CrachDeck.cardIndices.PushBack(2); //Scorch	
				CrachDeck.cardIndices.PushBack(2); //Scorch	
				CrachDeck.cardIndices.PushBack(3); //Biting Frost	
				CrachDeck.cardIndices.PushBack(4); //Impenetrable Fog 
				CrachDeck.cardIndices.PushBack(5); //Torrential Rain
				CrachDeck.cardIndices.PushBack(420); // [4] Botchling
				CrachDeck.cardIndices.PushBack(427); // [2] Endrega
			}
			if (difficulty == 3)
			{
				CrachDeck.cardIndices.PushBack(1); //Horn
				CrachDeck.cardIndices.PushBack(0); //Dummy
				CrachDeck.cardIndices.PushBack(5); //Torrential Rain
				CrachDeck.cardIndices.PushBack(6); //Clear Sky
				CrachDeck.cardIndices.PushBack(403); // [10] Leshen [HERO]
				CrachDeck.cardIndices.PushBack(443); // [6] Fire Elemental
			}

			CrachDeck.cardIndices.PushBack(407);	
			CrachDeck.cardIndices.PushBack(410);	
			CrachDeck.cardIndices.PushBack(415);	
			CrachDeck.cardIndices.PushBack(417);	
			CrachDeck.cardIndices.PushBack(423);	
			CrachDeck.cardIndices.PushBack(425);	
			CrachDeck.cardIndices.PushBack(435);	
			CrachDeck.cardIndices.PushBack(440);	
			CrachDeck.cardIndices.PushBack(443);	
			CrachDeck.cardIndices.PushBack(447);	
			CrachDeck.cardIndices.PushBack(450);	
			CrachDeck.cardIndices.PushBack(451);


			CrachDeck.dynamicCardRequirements.PushBack(diff5);
			CrachDeck.dynamicCards.PushBack(452);
			CrachDeck.dynamicCardRequirements.PushBack(diff7);
			CrachDeck.dynamicCards.PushBack(453);
			CrachDeck.dynamicCardRequirements.PushBack(diff9);
			CrachDeck.dynamicCards.PushBack(8);
			CrachDeck.dynamicCardRequirements.PushBack(diff11);
			CrachDeck.dynamicCards.PushBack(11);
			CrachDeck.dynamicCardRequirements.PushBack(diff11);
			CrachDeck.dynamicCards.PushBack(14);
			CrachDeck.dynamicCardRequirements.PushBack(diff14);
			CrachDeck.dynamicCards.PushBack(7); // [ 15 ] Geralt of Rivia
			CrachDeck.dynamicCardRequirements.PushBack(diff14);
			CrachDeck.dynamicCards.PushBack(10);


			CrachDeck.specialCard = 400; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			CrachDeck.leaderIndex = 4001; 
			enemyDecks.PushBack(CrachDeck);

			
			//LugosDeck.deckName = "Lugos";	
			LugosDeck.cardIndices.PushBack(0); // Dummy	
	
			if (difficulty == 1)
			{
				LugosDeck.cardIndices.PushBack(3); //Biting Frost
				LugosDeck.cardIndices.PushBack(4); //Impenetrable Fog
				LugosDeck.cardIndices.PushBack(4); //Impenetrable Fog
				LugosDeck.cardIndices.PushBack(5); //Torrential Rain		
				LugosDeck.cardIndices.PushBack(5); //Torrential Rain
				LugosDeck.cardIndices.PushBack(420); // [4] Botchling
				LugosDeck.cardIndices.PushBack(427); // [2] Endrega
			}
			if (difficulty == 2)
			{
				LugosDeck.cardIndices.PushBack(0); // Dummy
				LugosDeck.cardIndices.PushBack(3); //Biting Frost
				LugosDeck.cardIndices.PushBack(4); //Impenetrable Fog
				LugosDeck.cardIndices.PushBack(4); //Impenetrable Fog
				LugosDeck.cardIndices.PushBack(5); //Torrential Rain		
				LugosDeck.cardIndices.PushBack(5); //Torrential Rain
				LugosDeck.cardIndices.PushBack(420); // [4] Botchling
			}
			if (difficulty == 3)
			{
				LugosDeck.cardIndices.PushBack(4); //Impenetrable Fog		
				LugosDeck.cardIndices.PushBack(5); //Torrential Rain
				LugosDeck.cardIndices.PushBack(0); //Dummy
				LugosDeck.cardIndices.PushBack(6); //Clear Sky
				LugosDeck.cardIndices.PushBack(403); // [10] Leshen [HERO]
				LugosDeck.cardIndices.PushBack(443); // [6] Fire Elemental
			}

			LugosDeck.cardIndices.PushBack(401);	
			LugosDeck.cardIndices.PushBack(413);	
			LugosDeck.cardIndices.PushBack(417);	
			LugosDeck.cardIndices.PushBack(407);	
			LugosDeck.cardIndices.PushBack(415);	
			LugosDeck.cardIndices.PushBack(417);	
			LugosDeck.cardIndices.PushBack(423);	
			LugosDeck.cardIndices.PushBack(423);	
			LugosDeck.cardIndices.PushBack(433);	
			LugosDeck.cardIndices.PushBack(440);	
			LugosDeck.cardIndices.PushBack(445);	
			LugosDeck.cardIndices.PushBack(455);	
			LugosDeck.cardIndices.PushBack(455);	
			LugosDeck.cardIndices.PushBack(456);	
			LugosDeck.cardIndices.PushBack(457);	
			LugosDeck.cardIndices.PushBack(460);	
			LugosDeck.cardIndices.PushBack(461);	
			LugosDeck.cardIndices.PushBack(463);


			LugosDeck.dynamicCardRequirements.PushBack(diff5);
			LugosDeck.dynamicCards.PushBack(462);
			LugosDeck.dynamicCardRequirements.PushBack(diff7);
			LugosDeck.dynamicCards.PushBack(2); //Scorch
			LugosDeck.dynamicCardRequirements.PushBack(diff9);
			LugosDeck.dynamicCards.PushBack(1); // Horn
			LugosDeck.dynamicCardRequirements.PushBack(diff11);
			LugosDeck.dynamicCards.PushBack(11);
			LugosDeck.dynamicCardRequirements.PushBack(diff11);
			LugosDeck.dynamicCards.PushBack(8);
			LugosDeck.dynamicCardRequirements.PushBack(diff14);
			LugosDeck.dynamicCards.PushBack(2); //Scorch
			LugosDeck.dynamicCardRequirements.PushBack(diff14);
			LugosDeck.dynamicCards.PushBack(10);


			LugosDeck.specialCard = 464; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			LugosDeck.leaderIndex = 4002; 
			enemyDecks.PushBack(LugosDeck);


			//HermitDeck.deckName = "Hermit";	

			if (difficulty == 1)
			{
				HermitDeck.cardIndices.PushBack(3); //Frost
				HermitDeck.cardIndices.PushBack(4); //Impenetrable Fog
				HermitDeck.cardIndices.PushBack(5); //Torrential Rain	
				HermitDeck.cardIndices.PushBack(6); //Clear Weather	
				HermitDeck.cardIndices.PushBack(6); //Clear Weather	
				HermitDeck.cardIndices.PushBack(420); // [4] Botchling
				HermitDeck.cardIndices.PushBack(427); // [2] Endrega
			}
			if (difficulty == 2)
			{
				HermitDeck.cardIndices.PushBack(2); //Scorch	
				HermitDeck.cardIndices.PushBack(2); //Scorch	
				HermitDeck.cardIndices.PushBack(4); //Impenetrable Fog
				HermitDeck.cardIndices.PushBack(5); //Torrential Rain	
				HermitDeck.cardIndices.PushBack(6); //Clear Weather	
				HermitDeck.cardIndices.PushBack(6); //Clear Weather	
				HermitDeck.cardIndices.PushBack(0); // Dummy
			}
			if (difficulty == 3)
			{
				HermitDeck.cardIndices.PushBack(0); //Dummy	
				HermitDeck.cardIndices.PushBack(1); //Horn	
				HermitDeck.cardIndices.PushBack(4); //Impenetrable Fog	
				HermitDeck.cardIndices.PushBack(6); //Clear Weather	
				HermitDeck.cardIndices.PushBack(6); //Clear Weather	
				HermitDeck.cardIndices.PushBack(403); // [10] Leshen [HERO]
				HermitDeck.cardIndices.PushBack(443); // [6] Fire Elemental
			}

			HermitDeck.cardIndices.PushBack(400);	
			HermitDeck.cardIndices.PushBack(450);	
			HermitDeck.cardIndices.PushBack(451);	
			HermitDeck.cardIndices.PushBack(452);	
			HermitDeck.cardIndices.PushBack(453);	
			HermitDeck.cardIndices.PushBack(455);	
			HermitDeck.cardIndices.PushBack(456);	
			HermitDeck.cardIndices.PushBack(457);	
			HermitDeck.cardIndices.PushBack(460);	
			HermitDeck.cardIndices.PushBack(461);	
			HermitDeck.cardIndices.PushBack(462);
			HermitDeck.cardIndices.PushBack(463);		
			HermitDeck.cardIndices.PushBack(470);	
			HermitDeck.cardIndices.PushBack(471);	
			HermitDeck.cardIndices.PushBack(472);	
			HermitDeck.cardIndices.PushBack(475);		
			HermitDeck.cardIndices.PushBack(477);


			HermitDeck.dynamicCardRequirements.PushBack(diff5);
			HermitDeck.dynamicCards.PushBack(464);
			HermitDeck.dynamicCardRequirements.PushBack(diff7);
			HermitDeck.dynamicCards.PushBack(443);
			HermitDeck.dynamicCardRequirements.PushBack(diff9);
			HermitDeck.dynamicCards.PushBack(2); //Scorch
			HermitDeck.dynamicCardRequirements.PushBack(diff11);
			HermitDeck.dynamicCards.PushBack(11);
			HermitDeck.dynamicCardRequirements.PushBack(diff11);
			HermitDeck.dynamicCards.PushBack(14);
			HermitDeck.dynamicCardRequirements.PushBack(diff14);
			HermitDeck.dynamicCards.PushBack(7); // [ 15 ] Geralt of Rivia
			HermitDeck.dynamicCardRequirements.PushBack(diff14);
			HermitDeck.dynamicCards.PushBack(12);

			HermitDeck.specialCard = 476; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			HermitDeck.leaderIndex = 4002; 
			enemyDecks.PushBack(HermitDeck);
		
			
	}

	private function SetupAIDeckDefinitions7()
	{

		var OlivierDeck			:SDeckDefinition;
		var MousesackDeck		:SDeckDefinition;

			//OlivierDeck.deckName = "Olivier";	
			OlivierDeck.cardIndices.PushBack(4); //Impenetrable Fog
			OlivierDeck.cardIndices.PushBack(5); //Torrential Rain	

			if (difficulty == 1)
			{
				OlivierDeck.cardIndices.PushBack(3); //Biting Frost	
				OlivierDeck.cardIndices.PushBack(4); //Impenetrable Fog	
				OlivierDeck.cardIndices.PushBack(5); //Torrential Rain	
				OlivierDeck.cardIndices.PushBack(420); // [4] Botchling
				OlivierDeck.cardIndices.PushBack(427); // [2] Endrega
				OlivierDeck.cardIndices.PushBack(447);
			}
			if (difficulty == 2)
			{
				OlivierDeck.cardIndices.PushBack(3); //Biting Frost	
				OlivierDeck.cardIndices.PushBack(4); //Impenetrable Fog
				OlivierDeck.cardIndices.PushBack(5); //Torrential Rain
				OlivierDeck.cardIndices.PushBack(420); // [4] Botchling
				OlivierDeck.cardIndices.PushBack(427); // [2] Endrega
				OlivierDeck.cardIndices.PushBack(447);
			}
			if (difficulty == 3)
			{	
				OlivierDeck.cardIndices.PushBack(1); //Horn	
				OlivierDeck.cardIndices.PushBack(1); //Horn	
				OlivierDeck.cardIndices.PushBack(6); //Clear Weather	
				OlivierDeck.cardIndices.PushBack(401); // [8] Kayran [HERO][+1]
				OlivierDeck.cardIndices.PushBack(400); // [10] Draug [HERO]
			}

			OlivierDeck.cardIndices.PushBack(403);	
			OlivierDeck.cardIndices.PushBack(407);	
			OlivierDeck.cardIndices.PushBack(410);
			OlivierDeck.cardIndices.PushBack(413);
			OlivierDeck.cardIndices.PushBack(415);	
			OlivierDeck.cardIndices.PushBack(425);	
			OlivierDeck.cardIndices.PushBack(440);	
			OlivierDeck.cardIndices.PushBack(443);
			OlivierDeck.cardIndices.PushBack(450);	
			OlivierDeck.cardIndices.PushBack(451);	
			OlivierDeck.cardIndices.PushBack(452);	
			OlivierDeck.cardIndices.PushBack(453);	
			OlivierDeck.cardIndices.PushBack(470);	
			OlivierDeck.cardIndices.PushBack(471);	
			OlivierDeck.cardIndices.PushBack(472);


			OlivierDeck.dynamicCardRequirements.PushBack(diff5);
			OlivierDeck.dynamicCards.PushBack(15);
			OlivierDeck.dynamicCardRequirements.PushBack(diff7);
			OlivierDeck.dynamicCards.PushBack(0);
			OlivierDeck.dynamicCardRequirements.PushBack(diff9);
			OlivierDeck.dynamicCards.PushBack(0);
			OlivierDeck.dynamicCardRequirements.PushBack(diff11);
			OlivierDeck.dynamicCards.PushBack(11);
			OlivierDeck.dynamicCardRequirements.PushBack(diff11);
			OlivierDeck.dynamicCards.PushBack(8);
			OlivierDeck.dynamicCardRequirements.PushBack(diff14);
			OlivierDeck.dynamicCards.PushBack(7); // [15] Geralt of Rivia
			OlivierDeck.dynamicCardRequirements.PushBack(diff14);
			OlivierDeck.dynamicCards.PushBack(12);

			OlivierDeck.specialCard = -1;
			OlivierDeck.leaderIndex = 4002; 
			enemyDecks.PushBack(OlivierDeck);


			//MousesackDeck.deckName = "Mousesack";
			if (difficulty == 1)
			{
				MousesackDeck.cardIndices.PushBack(0); // Dummy	
				MousesackDeck.cardIndices.PushBack(0); // Dummy	
				MousesackDeck.cardIndices.PushBack(1); //Horn
				MousesackDeck.cardIndices.PushBack(1); //Horn
				MousesackDeck.cardIndices.PushBack(2); //Scorch	
				MousesackDeck.cardIndices.PushBack(3); //Biting Frost	
				MousesackDeck.cardIndices.PushBack(4); //Impenetrable Fog
				MousesackDeck.cardIndices.PushBack(5); //Torrential Rain	
				MousesackDeck.cardIndices.PushBack(6); //Clear Weather
				MousesackDeck.cardIndices.PushBack(420); // [4] Botchling
				MousesackDeck.cardIndices.PushBack(427); // [2] Endrega
			}
			if (difficulty == 2)
			{
				MousesackDeck.cardIndices.PushBack(0); // Dummy	
				MousesackDeck.cardIndices.PushBack(0); // Dummy	
				MousesackDeck.cardIndices.PushBack(1); //Horn
				MousesackDeck.cardIndices.PushBack(1); //Horn
				MousesackDeck.cardIndices.PushBack(2); //Scorch	
				MousesackDeck.cardIndices.PushBack(3); //Biting Frost	
				MousesackDeck.cardIndices.PushBack(4); //Impenetrable Fog
				MousesackDeck.cardIndices.PushBack(5); //Torrential Rain	
				MousesackDeck.cardIndices.PushBack(6); //Clear Weather
			}
			if (difficulty == 3)
			{	
				MousesackDeck.cardIndices.PushBack(0); // Dummy	
				MousesackDeck.cardIndices.PushBack(0); // Dummy	
				MousesackDeck.cardIndices.PushBack(1); //Horn
				MousesackDeck.cardIndices.PushBack(1); //Horn
				MousesackDeck.cardIndices.PushBack(4); //Impenetrable Fog	
				MousesackDeck.cardIndices.PushBack(6); //Clear Weather
				MousesackDeck.cardIndices.PushBack(401); // [8] Kayran [HERO][+1]
				MousesackDeck.cardIndices.PushBack(443); // [6] Fire Elemental
			}
	
			MousesackDeck.cardIndices.PushBack(407);	
			MousesackDeck.cardIndices.PushBack(415);	
			MousesackDeck.cardIndices.PushBack(417);
			MousesackDeck.cardIndices.PushBack(423);
			MousesackDeck.cardIndices.PushBack(450);	
			MousesackDeck.cardIndices.PushBack(451);	
			MousesackDeck.cardIndices.PushBack(452);	
			MousesackDeck.cardIndices.PushBack(455);	
			MousesackDeck.cardIndices.PushBack(456);	
			MousesackDeck.cardIndices.PushBack(457);	
			MousesackDeck.cardIndices.PushBack(460);	
			MousesackDeck.cardIndices.PushBack(461);	
			MousesackDeck.cardIndices.PushBack(462);	
			MousesackDeck.cardIndices.PushBack(463);	
			MousesackDeck.cardIndices.PushBack(470);	
			MousesackDeck.cardIndices.PushBack(471);	
			MousesackDeck.cardIndices.PushBack(472);	
			MousesackDeck.cardIndices.PushBack(476);	
			MousesackDeck.cardIndices.PushBack(477);


			MousesackDeck.dynamicCardRequirements.PushBack(diff5);
			MousesackDeck.dynamicCards.PushBack(15);
			MousesackDeck.dynamicCardRequirements.PushBack(diff7);
			MousesackDeck.dynamicCards.PushBack(12);
			MousesackDeck.dynamicCardRequirements.PushBack(diff9);
			MousesackDeck.dynamicCards.PushBack(13);
			MousesackDeck.dynamicCardRequirements.PushBack(diff11);
			MousesackDeck.dynamicCards.PushBack(11);
			MousesackDeck.dynamicCardRequirements.PushBack(diff11);
			MousesackDeck.dynamicCards.PushBack(14);
			MousesackDeck.dynamicCardRequirements.PushBack(diff14);
			MousesackDeck.dynamicCards.PushBack(2); //Scorch
			MousesackDeck.dynamicCardRequirements.PushBack(diff14);
			MousesackDeck.dynamicCards.PushBack(7);


			MousesackDeck.specialCard = 403; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			MousesackDeck.leaderIndex = 4004; 
			enemyDecks.PushBack(MousesackDeck);

	}
	
	
		private function SetupAIDeckDefinitions8()
	{

		var ShaniDeck			:SDeckDefinition;
		var OlgierdDeck		    :SDeckDefinition;

			// #########################################################
			// Shani	
			// #########################################################	
			ShaniDeck.cardIndices.PushBack(2); //Scorch	
			ShaniDeck.cardIndices.PushBack(0); //Dummy
			ShaniDeck.cardIndices.PushBack(0); //Dummy
			
			// Difficulty changing cards	
			if (difficulty == 1)
			{
				ShaniDeck.cardIndices.PushBack(310);	// 2 Toruviel 
				ShaniDeck.cardIndices.PushBack(312);	// 3 Ciaran 
				ShaniDeck.cardIndices.PushBack(336);	// 3 Dwarf  SUMMON
				ShaniDeck.cardIndices.PushBack(337);	// 3 Dwarf  SUMMON ^
			}
			if (difficulty >= 2)
			{
				ShaniDeck.cardIndices.PushBack(0); //Dummy
				ShaniDeck.cardIndices.PushBack(1); //Horn
				ShaniDeck.cardIndices.PushBack(302);	// 10 Isengrim Faoiltiarna  
				ShaniDeck.cardIndices.PushBack(303);	// 10 ioveth HERO
				ShaniDeck.cardIndices.PushBack(9); 		// 7 Yennefer NURSE
				ShaniDeck.cardIndices.PushBack(16); 	// 0 Avallac'hh  [SPY]
			}
			if (difficulty == 3)
			{
				ShaniDeck.cardIndices.PushBack(2); //Scorch	
				ShaniDeck.cardIndices.PushBack(10); 	// 15 Ciri
				ShaniDeck.cardIndices.PushBack(300);	// 10 Eithné
				ShaniDeck.cardIndices.PushBack(301);	// 10 Saskia/Saesenthessis
			}

			ShaniDeck.cardIndices.PushBack(305);	// 6 dennis
			ShaniDeck.cardIndices.PushBack(306);	// 10 milva
			ShaniDeck.cardIndices.PushBack(308);	// 6 filavandrel AGILE
			ShaniDeck.cardIndices.PushBack(309);	// 6 Yaevin AGILE
			ShaniDeck.cardIndices.PushBack(313);	// 6 barclay AGILE
			ShaniDeck.cardIndices.PushBack(320);	// 0 Hav'caaren Medic
			ShaniDeck.cardIndices.PushBack(321);	// 0 Hav'caaren Medic
			ShaniDeck.cardIndices.PushBack(322);	// 0 Hav'caaren Medic
			ShaniDeck.cardIndices.PushBack(325);	// 5 Vrihed AGILE
			ShaniDeck.cardIndices.PushBack(326);	// 5 Vrihed AGILE
			ShaniDeck.cardIndices.PushBack(365);	// 5 Hav'caaren Support 
			ShaniDeck.cardIndices.PushBack(366);	// 5 Hav'caaren Support ^
			ShaniDeck.cardIndices.PushBack(367);	// 5 Hav'caaren Support ^
			
			
			ShaniDeck.dynamicCardRequirements.PushBack(diff5);
			ShaniDeck.dynamicCards.PushBack(1); //Horn
			ShaniDeck.dynamicCardRequirements.PushBack(diff7);
			ShaniDeck.dynamicCards.PushBack(8); // 6 Vesemir
			ShaniDeck.dynamicCardRequirements.PushBack(diff11);
			ShaniDeck.dynamicCards.PushBack(11); // 7 Triss HERO
			ShaniDeck.dynamicCardRequirements.PushBack(diff11);
			ShaniDeck.dynamicCards.PushBack(12); // 2 Dandelion HORN
			ShaniDeck.dynamicCardRequirements.PushBack(diff14);
			ShaniDeck.dynamicCards.PushBack(15); // 7 Villen MELEE SCORCH
			ShaniDeck.dynamicCardRequirements.PushBack(diff14);
			ShaniDeck.dynamicCards.PushBack(7); // 15 Geralt

			ShaniDeck.specialCard = 17; // 6 Olgierd AGILE +1 
			ShaniDeck.leaderIndex = 3005; 
			enemyDecks.PushBack(ShaniDeck);
			

			// #########################################################
			// Olgierd	
			// #########################################################
			OlgierdDeck.cardIndices.PushBack(2); //Scorch	

			// Difficulty changing cards	
			if (difficulty == 1)
			{
				OlgierdDeck.cardIndices.PushBack(4); //Impenetrable Fog
				OlgierdDeck.cardIndices.PushBack(415);	// 5 griffin
				OlgierdDeck.cardIndices.PushBack(423);	// 5 frightener
				OlgierdDeck.cardIndices.PushBack(455);	// 2 nekker SUMMON
				OlgierdDeck.cardIndices.PushBack(456);	// 2 nekker SUMMON
				OlgierdDeck.cardIndices.PushBack(457);	// 2 nekker SUMMON
			}
			if (difficulty >= 2)
			{
				OlgierdDeck.cardIndices.PushBack(0); // Dummy
				OlgierdDeck.cardIndices.PushBack(5); //Torrential Rain	
				OlgierdDeck.cardIndices.PushBack(6); //Clear Weather	
				OlgierdDeck.cardIndices.PushBack(453);	 // 4 arachas SUMMON
				OlgierdDeck.cardIndices.PushBack(475); 	 // 6 brewess SUMMON
				OlgierdDeck.cardIndices.PushBack(16); 	 // 0 Avallach SPY
				OlgierdDeck.cardIndices.PushBack(400);   // 10 Draug
				OlgierdDeck.cardIndices.PushBack(403);   // 10 Leshen
			}
			if (difficulty == 3)
			{
				OlgierdDeck.cardIndices.PushBack(0); // Dummy	
				OlgierdDeck.cardIndices.PushBack(1); // Horn
				OlgierdDeck.cardIndices.PushBack(10);   // 15 Ciri
			}

			OlgierdDeck.cardIndices.PushBack(401);	// 8 Kayran +1
			OlgierdDeck.cardIndices.PushBack(407);	// 6 earth_elemental
			OlgierdDeck.cardIndices.PushBack(450);	// 6 arachas_behemoth SUMMON
			OlgierdDeck.cardIndices.PushBack(451);	// 4 arachas SUMMON
			OlgierdDeck.cardIndices.PushBack(452);	// 4 arachas SUMMON
			OlgierdDeck.cardIndices.PushBack(460);	// 4 ekkima SUMMON
			OlgierdDeck.cardIndices.PushBack(461);	// 4 fleder SUMMON
			OlgierdDeck.cardIndices.PushBack(462);	// 4 garkain SUMMON
			OlgierdDeck.cardIndices.PushBack(463);	// 4 bruxa SUMMON
			OlgierdDeck.cardIndices.PushBack(476);	// 6 weavess SUMMON
			OlgierdDeck.cardIndices.PushBack(477);  // 6 whispess SUMMON

			OlgierdDeck.dynamicCardRequirements.PushBack(diff5);
			OlgierdDeck.dynamicCards.PushBack(15); // 7 Villen SCORCH MELEE
			OlgierdDeck.dynamicCardRequirements.PushBack(diff7);
			OlgierdDeck.dynamicCards.PushBack(12); // 2 Dandelion HORN
			OlgierdDeck.dynamicCardRequirements.PushBack(diff9);
			OlgierdDeck.dynamicCards.PushBack(13); // 5 Zoltan
			OlgierdDeck.dynamicCardRequirements.PushBack(diff11);
			OlgierdDeck.dynamicCards.PushBack(9); // 7 Yennefer NURSE Hero
			OlgierdDeck.dynamicCardRequirements.PushBack(diff11);
			OlgierdDeck.dynamicCards.PushBack(14); // 5 Emiel
			OlgierdDeck.dynamicCardRequirements.PushBack(diff14);
			OlgierdDeck.dynamicCards.PushBack(2); // Scorch
			OlgierdDeck.dynamicCardRequirements.PushBack(diff14);
			OlgierdDeck.dynamicCards.PushBack(7); // 15 Geralt of Rivia

			OlgierdDeck.specialCard = 478; // 7 Toad MELEE SCORCH
			OlgierdDeck.leaderIndex = 4005;
			enemyDecks.PushBack(OlgierdDeck);

	}
	
	
	private function SetupAIDeckDefinitions9()
	{
		var GamblerDeck			:SDeckDefinition;
		var HalflingsDeck		:SDeckDefinition;

			// #########################################################
			// GamblerDeck	
			// #########################################################
			GamblerDeck.cardIndices.PushBack(2); // Scorch

			// Difficulty changing cards	
			if (difficulty == 1)
			{
				GamblerDeck.cardIndices.PushBack(245); // [3] Impera brigade            [BOND]
				GamblerDeck.cardIndices.PushBack(250); // [2] Nausicaa                  [BOND]
				GamblerDeck.cardIndices.PushBack(221); // [3] Puttkramer
			}
			if (difficulty >= 2)
			{
				GamblerDeck.cardIndices.PushBack(6); // Clear Weather
				GamblerDeck.cardIndices.PushBack(0); // Dummy
				GamblerDeck.cardIndices.PushBack(0); // Dummy
				GamblerDeck.cardIndices.PushBack(200); // [10] Letho of Gulet   ***[HERO]***
				GamblerDeck.cardIndices.PushBack(214); // [1] Stefan Skellen   		     [SPY]
				GamblerDeck.cardIndices.PushBack(19);  // [4] MrMirror's Foglet 	  [SUMMON]
				GamblerDeck.cardIndices.PushBack(260); // [5] Young Emissary 			[BOND]
				GamblerDeck.cardIndices.PushBack(240); // [10] Heavy Zerri
				GamblerDeck.cardIndices.PushBack(202); // [10] Morvran Voorhis  ***[HERO]***
			}
			if (difficulty == 3)
			{
				GamblerDeck.cardIndices.PushBack(0); // Dummy
				GamblerDeck.cardIndices.PushBack(1); // Horn
				GamblerDeck.cardIndices.PushBack(1); // Horn
				GamblerDeck.cardIndices.PushBack(2); // Scorch
				GamblerDeck.cardIndices.PushBack(201); // [10] Menno Coehoorn   ***[HERO]***
				GamblerDeck.cardIndices.PushBack(218); // [1] Vattier de Rideaux Vattier [SPY]
				GamblerDeck.cardIndices.PushBack(19); //  [4] MrMirror's Foglet 	  [SUMMON]
				GamblerDeck.cardIndices.PushBack(9); //   [7] Yennefer 	  			   [NURSE]
				GamblerDeck.cardIndices.PushBack(265); // [0] Siege Support 	  	   [NURSE]
			}

			GamblerDeck.cardIndices.PushBack(236); // [10] Black Archer
			GamblerDeck.cardIndices.PushBack(203); // [10] Tibor Eggebracht ***[HERO]***
			GamblerDeck.cardIndices.PushBack(208); // [6] Fringilla Vigo 
			GamblerDeck.cardIndices.PushBack(213); // [4] Shilard Fitz-Oesterlen     [SPY]
			GamblerDeck.cardIndices.PushBack(230); // [1] Archer Support 		   [NURSE]
			GamblerDeck.cardIndices.PushBack(231); // [1] Archer Support           [NURSE]
			GamblerDeck.cardIndices.PushBack(235); // [10] Black Archer
			GamblerDeck.cardIndices.PushBack(241); // [5] Zerri
			GamblerDeck.cardIndices.PushBack(261); // [5] Young Emissary 			[BOND]
			GamblerDeck.cardIndices.PushBack(19); //  [4] MrMirror's Foglet 	  [SUMMON]

			// Autobalance
			GamblerDeck.dynamicCardRequirements.PushBack(diff1);
			GamblerDeck.dynamicCards.PushBack(15); // 7 Villen MELEE SCORCH
			GamblerDeck.dynamicCardRequirements.PushBack(diff4);
			GamblerDeck.dynamicCards.PushBack(16); // 0 Avallah SPY
			GamblerDeck.dynamicCardRequirements.PushBack(diff4);
			GamblerDeck.dynamicCards.PushBack(12); // 2 Dandelion
			GamblerDeck.dynamicCardRequirements.PushBack(diff6);
			GamblerDeck.dynamicCards.PushBack(248); // 3 impera_brigade [BOND]
			GamblerDeck.dynamicCardRequirements.PushBack(diff6);
			GamblerDeck.dynamicCards.PushBack(11); // 7 Triss HERO
			GamblerDeck.dynamicCardRequirements.PushBack(diff8);
			GamblerDeck.dynamicCards.PushBack(7); // [ 15 ] Geralt of Rivia

			GamblerDeck.specialCard = 18; // [2] Mr Mirror   			  [SUMMON]
			GamblerDeck.leaderIndex = 2005;
			enemyDecks.PushBack(GamblerDeck);


			// #########################################################
			// HalflingsDeck	
			// #########################################################
			HalflingsDeck.cardIndices.PushBack(2); //Scorch
			HalflingsDeck.cardIndices.PushBack(1); //Horn	
			HalflingsDeck.cardIndices.PushBack(3); //Biting Frost	
			HalflingsDeck.cardIndices.PushBack(4); //Impenetrable Fog

			// Difficulty changing cards	
			if (difficulty == 1)
			{
				HalflingsDeck.cardIndices.PushBack(3); //Biting Frost
				HalflingsDeck.cardIndices.PushBack(152);	// [1] kaedweni_siege      [+1]
			}
			if (difficulty >= 2)
			{
				HalflingsDeck.cardIndices.PushBack(152);	// [1] kaedweni_siege      [+1]
				HalflingsDeck.cardIndices.PushBack(2); //Scorch
				HalflingsDeck.cardIndices.PushBack(0); //Dummy
				HalflingsDeck.cardIndices.PushBack(100);	// [10] Vernon             [ HERO ]
				HalflingsDeck.cardIndices.PushBack(103);	// [10] philippa           [ HERO ]
				HalflingsDeck.cardIndices.PushBack(105); 	// [4] Thaler  			      [SPY]
				HalflingsDeck.cardIndices.PushBack(109);	// [4] Sigismund Dijkstra     [SPY]
				HalflingsDeck.cardIndices.PushBack(160);	// [4] Blue Stripes     [TightBond]
				HalflingsDeck.cardIndices.PushBack(160); 	// [4] Blue Stripes     [TightBond]
			}
			if (difficulty == 3)
			{
				HalflingsDeck.cardIndices.PushBack(1); //Horn	
				HalflingsDeck.cardIndices.PushBack(102);	// [10] esterad            [ HERO ]
				HalflingsDeck.cardIndices.PushBack(101);	// [10] Natalis            [ HERO ]
				HalflingsDeck.cardIndices.PushBack(10);		// [15] Ciri
			}

			HalflingsDeck.cardIndices.PushBack(116); 	// [5] Stennis                [SPY]
			HalflingsDeck.cardIndices.PushBack(120); 	// [6] Trebuchet 
			HalflingsDeck.cardIndices.PushBack(140); 	// [8] Catapult         [TightBond]
			HalflingsDeck.cardIndices.PushBack(141); 	// [8] Catapult         [TightBond]
			HalflingsDeck.cardIndices.PushBack(145); 	// [6] Ballista
			HalflingsDeck.cardIndices.PushBack(160); 	// [4] Blue Stripes     [TightBond]
			HalflingsDeck.cardIndices.PushBack(170); 	// [6] Siege Tower
			HalflingsDeck.cardIndices.PushBack(175);	// [0] dun_banner_medic     [NURSE]
			
			HalflingsDeck.dynamicCardRequirements.PushBack(diff2);	
			HalflingsDeck.dynamicCards.PushBack(13);				
			HalflingsDeck.dynamicCardRequirements.PushBack(diff5);	
			HalflingsDeck.dynamicCards.PushBack(151); 				// [ 1 ] kaedweni_siege [ +1 ]
			HalflingsDeck.dynamicCardRequirements.PushBack(diff6);	
			HalflingsDeck.dynamicCards.PushBack(12); 				// [ 2 ] Dangelion [HORN]
			HalflingsDeck.dynamicCardRequirements.PushBack(diff8);	
			HalflingsDeck.dynamicCards.PushBack(11); 				// [ 7 ] Triss HERO
			HalflingsDeck.dynamicCardRequirements.PushBack(diff8);	
			HalflingsDeck.dynamicCards.PushBack(7); 				// [ 15 ] Geralt HORN
			HalflingsDeck.dynamicCardRequirements.PushBack(diff8);	
			HalflingsDeck.dynamicCards.PushBack(15); 				// [ 7 ] Villen Scorch 				
			HalflingsDeck.dynamicCardRequirements.PushBack(diff10);	
			HalflingsDeck.dynamicCards.PushBack(9); 				// [ 7 ] Yennefer [NURSE]
			
			HalflingsDeck.specialCard = 16;	// [0] Avallach [SPY]
			HalflingsDeck.leaderIndex = 1004; 
			enemyDecks.PushBack(HalflingsDeck);
	}

	private function SetupAIDeckDefinitions10()
	{
		var CircusGwentAddictDeck   :SDeckDefinition;

			// #########################################################
			// CircusGwentAddictDeck	
			// #########################################################
			CircusGwentAddictDeck.cardIndices.PushBack(3); //Frost
			CircusGwentAddictDeck.cardIndices.PushBack(1); //Horn
			CircusGwentAddictDeck.cardIndices.PushBack(2); //Scorch	

			// Difficulty changing cards	
			if (difficulty == 1)
			{
				CircusGwentAddictDeck.cardIndices.PushBack(6); //Clear Sky	
				CircusGwentAddictDeck.cardIndices.PushBack(4); //Fog
				CircusGwentAddictDeck.cardIndices.PushBack(310); // 2 Toruviel
				CircusGwentAddictDeck.cardIndices.PushBack(311); // 1 Riordain
			}
			if (difficulty >= 2)
			{
				CircusGwentAddictDeck.cardIndices.PushBack(0); //Dummy
				CircusGwentAddictDeck.cardIndices.PushBack(2); //Scorch	
				CircusGwentAddictDeck.cardIndices.PushBack(367);	// 5 Hav'caaren Support ^
				CircusGwentAddictDeck.cardIndices.PushBack(300);	// 10 Eithné
				CircusGwentAddictDeck.cardIndices.PushBack(10); 	// 15 Ciri
			}
			if (difficulty == 3)
			{
				CircusGwentAddictDeck.cardIndices.PushBack(0); //Dummy
				CircusGwentAddictDeck.cardIndices.PushBack(301);	// 10 Saskia/Saesenthessis
				CircusGwentAddictDeck.cardIndices.PushBack(302);	// 10 Isengrim Faoiltiarna
			}

			CircusGwentAddictDeck.cardIndices.PushBack(16); 	// 0 Avallac'hh  [SPY]
			CircusGwentAddictDeck.cardIndices.PushBack(303);	// 10 ioveth HERO
			CircusGwentAddictDeck.cardIndices.PushBack(305);	// 6 dennis
			CircusGwentAddictDeck.cardIndices.PushBack(306);	// 10 milva
			CircusGwentAddictDeck.cardIndices.PushBack(308);	// 6 filavandrel AGILE
			CircusGwentAddictDeck.cardIndices.PushBack(309);	// 6 Yaevin AGILE
			CircusGwentAddictDeck.cardIndices.PushBack(313);	// 6 barclay AGILE
			CircusGwentAddictDeck.cardIndices.PushBack(320);	// 4 havekar support SUMMON CLONES
			CircusGwentAddictDeck.cardIndices.PushBack(321);	// 4 havekar support ^
			CircusGwentAddictDeck.cardIndices.PushBack(322);	// 4 havekar support ^
			CircusGwentAddictDeck.cardIndices.PushBack(325);	// 5 Vrihed AGILE
			CircusGwentAddictDeck.cardIndices.PushBack(326);	// 5 Vrihed AGILE
			CircusGwentAddictDeck.cardIndices.PushBack(365);	// 5 Hav'caaren Support 
			CircusGwentAddictDeck.cardIndices.PushBack(366);	// 5 Hav'caaren Support ^

			CircusGwentAddictDeck.dynamicCardRequirements.PushBack(diff5);
			CircusGwentAddictDeck.dynamicCards.PushBack(15); // 7 Villen SCORCH MELEE
			CircusGwentAddictDeck.dynamicCardRequirements.PushBack(diff7);
			CircusGwentAddictDeck.dynamicCards.PushBack(12); // 2 Dandelion HORN
			CircusGwentAddictDeck.dynamicCardRequirements.PushBack(diff9);
			CircusGwentAddictDeck.dynamicCards.PushBack(13); // 5 Zoltan
			CircusGwentAddictDeck.dynamicCardRequirements.PushBack(diff11);
			CircusGwentAddictDeck.dynamicCards.PushBack(9); // 7 Yennefer NURSE Hero
			CircusGwentAddictDeck.dynamicCardRequirements.PushBack(diff11);
			CircusGwentAddictDeck.dynamicCards.PushBack(14); // 5 Emiel
			CircusGwentAddictDeck.dynamicCardRequirements.PushBack(diff14);
			CircusGwentAddictDeck.dynamicCards.PushBack(2); // Scorch
			CircusGwentAddictDeck.dynamicCardRequirements.PushBack(diff14);
			CircusGwentAddictDeck.dynamicCards.PushBack(7); // 15 Geralt of Rivia

			CircusGwentAddictDeck.specialCard = 368; // 8 Schirru RANGED SCORCH
			CircusGwentAddictDeck.leaderIndex = 3005;
			enemyDecks.PushBack(CircusGwentAddictDeck);
	}
	
	private function SetupAIDeckDefinitionsNK()
	{
		var NKEasy				:SDeckDefinition;
		var NKNormal			:SDeckDefinition;
		var NKHard				:SDeckDefinition;
		
			//NKEasy.deckName = "NKEasy";
			NKEasy.cardIndices.PushBack(3); //Biting Frost
			NKEasy.cardIndices.PushBack(4); //Impenetrable Fog 
			NKEasy.cardIndices.PushBack(5); //Torrential Rain
			NKEasy.cardIndices.PushBack(6); //Clear Weather

			if (difficulty == 3)
			{
				NKEasy.cardIndices.PushBack(100); // [10] Vernon [HERO]
				NKEasy.cardIndices.PushBack(9); // [7] Yennefer [NURSE][HERO]
			}

			NKEasy.cardIndices.PushBack(13); //zoltan [5]
			NKEasy.cardIndices.PushBack(105); //Thaler [4] [SPY]
			NKEasy.cardIndices.PushBack(106); //Ves [5]
			NKEasy.cardIndices.PushBack(107); //Siegfried of Denesle [5]
			NKEasy.cardIndices.PushBack(108); //Yarpen Zigrin  [2]
			NKEasy.cardIndices.PushBack(109);//Dijkstra
			NKEasy.cardIndices.PushBack(111); //Keira Metz  [5]
			NKEasy.cardIndices.PushBack(112); //Síle de Tansarville [5]
			NKEasy.cardIndices.PushBack(113); //Sabrina
			NKEasy.cardIndices.PushBack(114); //Sheldon
			NKEasy.cardIndices.PushBack(120); //Trebuchet [6]2
			NKEasy.cardIndices.PushBack(125); //Poor Fucking Infantry [2] [TightBond] 
			NKEasy.cardIndices.PushBack(126); //Poor Fucking Infantry [2] [TightBond]
			NKEasy.cardIndices.PushBack(130); //Crinfrid Reavers Dragon Hunter [4] [TightBond]
			NKEasy.cardIndices.PushBack(135); //Redanian Foot Soldier [1]
			NKEasy.cardIndices.PushBack(136); //Redanian Foot Soldier [1]
			NKEasy.cardIndices.PushBack(141); //Catapult [5] [TightBond]
			NKEasy.cardIndices.PushBack(145); //Ballista [6]
			NKEasy.cardIndices.PushBack(150); //Kaedweni Siege Expert [2] [MoraleBoost]
			NKEasy.cardIndices.PushBack(150); //Kaedweni Siege Expert [2] [MoraleBoost]
			NKEasy.cardIndices.PushBack(175);//Dun banner medic
			NKEasy.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			NKEasy.leaderIndex = 1001;
			enemyDecks.PushBack(NKEasy);

			
			//NKNormal.deckName = "NKNormal";
			NKNormal.cardIndices.PushBack(4); //Impenetrable Fog
			NKNormal.cardIndices.PushBack(1); //Horn
			NKNormal.cardIndices.PushBack(0); //Dummy
			NKNormal.cardIndices.PushBack(2); //Scorch
			NKNormal.cardIndices.PushBack(6); //Clear Weather

			if (difficulty == 1)
			{
				NKNormal.cardIndices.PushBack(4); //Impenetrable Fog
				NKNormal.cardIndices.PushBack(3); //Frost
			}
			if (difficulty == 2)
			{
				NKNormal.cardIndices.PushBack(4); //Impenetrable Fog
				NKNormal.cardIndices.PushBack(1); //Horn
				NKNormal.cardIndices.PushBack(100); // [10] Vernon [HERO]
			}
			if (difficulty == 3)
			{
				NKNormal.cardIndices.PushBack(100); // [10] Vernon [HERO]
				NKNormal.cardIndices.PushBack(9); // [7] Yennefer [NURSE][HERO]
			}

			NKNormal.cardIndices.PushBack(101); //John Natalis  [10] [HERO]
			NKNormal.cardIndices.PushBack(105); //Thaler [4] [SPY]
			NKNormal.cardIndices.PushBack(106); //Ves [5]
			NKNormal.cardIndices.PushBack(107); //Siegfried of Denesle [5]
			NKNormal.cardIndices.PushBack(109); //Dijkstra [SPY]
			NKNormal.cardIndices.PushBack(113); //Sabrina
			NKNormal.cardIndices.PushBack(114); //Sheldon
			NKNormal.cardIndices.PushBack(121); //Trebuchet [6]1
			NKNormal.cardIndices.PushBack(120); //Trebuchet [6]2
			NKNormal.cardIndices.PushBack(130); //Crinfrid Reavers Dragon Hunter [4] [TightBond]
			NKNormal.cardIndices.PushBack(131); //Crinfrid Reavers Dragon Hunter [4] [TightBond]
			NKNormal.cardIndices.PushBack(140); //Catapult [5] [TightBond] 
			NKNormal.cardIndices.PushBack(141); //Catapult [5] [TightBond]
			NKNormal.cardIndices.PushBack(145); //Ballista [6]
			NKNormal.cardIndices.PushBack(146); //Ballista [6]
			NKNormal.cardIndices.PushBack(150); //Kaedweni Siege Expert [2] [MoraleBoost]
			NKNormal.cardIndices.PushBack(151); //Kaedweni Siege Expert [2] [MoraleBoost]	//Siege Expert
			NKNormal.cardIndices.PushBack(175); //Dun banner medic

			NKNormal.dynamicCardRequirements.PushBack(diff12);
			NKNormal.dynamicCards.PushBack(12); //Dandelion
			NKNormal.dynamicCardRequirements.PushBack(diff13);
			NKNormal.dynamicCards.PushBack(11); //Triss Merigold  [10] ***[HERO]***		
			NKNormal.dynamicCardRequirements.PushBack(diff15);
			NKNormal.dynamicCards.PushBack(10); //Ciri

			NKNormal.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			NKNormal.leaderIndex = 1002;
			enemyDecks.PushBack(NKNormal);
			
			//NKHard.deckName = "NKHard";
			NKHard.cardIndices.PushBack(0); //Dummy
			NKHard.cardIndices.PushBack(1); //Horn
			NKHard.cardIndices.PushBack(2); //Scorch
			NKHard.cardIndices.PushBack(3); //Biting Frost
			NKHard.cardIndices.PushBack(4); //Impenetrable Fog  
			NKHard.cardIndices.PushBack(6); //Clear Weather

			if (difficulty == 1)
			{
				NKHard.cardIndices.PushBack(4); //Impenetrable Fog
				NKHard.cardIndices.PushBack(3); //Frost
			}
			if (difficulty == 2)
			{
				NKHard.cardIndices.PushBack(1); //Horn
				NKHard.cardIndices.PushBack(2); //Scorch
				NKHard.cardIndices.PushBack(7); //Geralt
				NKHard.cardIndices.PushBack(9); //Yennefer of Vengerberg 
				NKHard.cardIndices.PushBack(10); //Cirilla Fiona Elen Rianno
			}
			if (difficulty == 3)
			{
				NKHard.cardIndices.PushBack(1); //Horn
				NKHard.cardIndices.PushBack(2); //Scorch
				NKHard.cardIndices.PushBack(7);  //Geralt
				NKHard.cardIndices.PushBack(15); // [7] Villen [MELEE-SCORCH]
				NKHard.cardIndices.PushBack(9); //Yennefer of Vengerberg 
				NKHard.cardIndices.PushBack(10); //Cirilla Fiona Elen Rianno
			}

			NKHard.cardIndices.PushBack(11); //Triss Merigold 
			NKHard.cardIndices.PushBack(12); //Dandelion
			NKHard.cardIndices.PushBack(100); //Vernon Roche 
			NKHard.cardIndices.PushBack(101); //John Natalis
			NKHard.cardIndices.PushBack(102); //Esterad Thyssen 
			NKHard.cardIndices.PushBack(103); //Philippa
			NKHard.cardIndices.PushBack(105); //Thaler [4] [SPY]]
			NKHard.cardIndices.PushBack(109); //Dijkstra [SPY]
			NKHard.cardIndices.PushBack(116); //Prince Stennis [SPY] 
			NKHard.cardIndices.PushBack(111); //Keira Metz  [5]
			NKHard.cardIndices.PushBack(121); //Trebuchet [6]
			NKHard.cardIndices.PushBack(120); //Trebuchet [6]
			NKHard.cardIndices.PushBack(140); //Catapult [5] [TightBond] 
			NKHard.cardIndices.PushBack(141); //Catapult [5] [TightBond]
			NKHard.cardIndices.PushBack(145); //Ballista [6]
			NKHard.cardIndices.PushBack(146); //Ballista [6]
			NKHard.cardIndices.PushBack(150); //Kaedweni Siege Expert [2] [MoraleBoost]
			NKHard.cardIndices.PushBack(175);//Dun banner medic
			NKHard.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			NKHard.leaderIndex = 1003;
			enemyDecks.PushBack(NKHard);
	}
	private function SetupAIDeckDefinitionsNilf()
	{
		var NilfEasy				:SDeckDefinition;
		var NilfNormal				:SDeckDefinition;
		var NilfHard				:SDeckDefinition;
			
			//NilfEasy.deckName = "NilfEasy";
			NilfEasy.cardIndices.PushBack(3); //Biting Frost
			NilfEasy.cardIndices.PushBack(4); //Impenetrable Fog 
			NilfEasy.cardIndices.PushBack(5); //Torrential Rain
			NilfEasy.cardIndices.PushBack(6); //Clear Weather

			if (difficulty == 3)
			{
				NilfEasy.cardIndices.PushBack(1); //Horn
				NilfEasy.cardIndices.PushBack(0); //Dummy
				NilfEasy.cardIndices.PushBack(15); // [7] Villen [MELEE-SCORCH]
				NilfEasy.cardIndices.PushBack(9); //Yennefer of Vengerberg 
			}

			NilfEasy.cardIndices.PushBack(205); //Albrich [2]
			NilfEasy.cardIndices.PushBack(207); //Cynthia [4]
			NilfEasy.cardIndices.PushBack(209); // Morteisen [3]
			NilfEasy.cardIndices.PushBack(210); //Rainfarn [4]
			NilfEasy.cardIndices.PushBack(211); //Renuald aep Matsen  [5] 
			NilfEasy.cardIndices.PushBack(212); //Rotten Mangonel [3]
			NilfEasy.cardIndices.PushBack(213); //Shilard Fitz-Oesterlen  [4] [SPY]
			NilfEasy.cardIndices.PushBack(215); //Sweers [2]
			NilfEasy.cardIndices.PushBack(217); //Vanhemar [4]
			NilfEasy.cardIndices.PushBack(218); //Vattier de Rideaux Vattier [1]
			NilfEasy.cardIndices.PushBack(219);//Vreemde
			NilfEasy.cardIndices.PushBack(221);//Puttkammer
			NilfEasy.cardIndices.PushBack(241);//Zerri
			NilfEasy.cardIndices.PushBack(245);//Impera
			NilfEasy.cardIndices.PushBack(250);//Nausicaa	
			NilfEasy.cardIndices.PushBack(251);//Nausicaa
			NilfEasy.specialCard = 260; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			NilfEasy.leaderIndex = 2001;
			enemyDecks.PushBack(NilfEasy);
			
			
			//NilfNormal.deckName = "NilfNormal";
			if (difficulty == 1)
			{
				NilfNormal.cardIndices.PushBack(4); //Impenetrable Fog
				NilfNormal.cardIndices.PushBack(3); //Frost
			}
			if (difficulty == 2)
			{
				NilfNormal.cardIndices.PushBack(0); //Dummy
				NilfNormal.cardIndices.PushBack(1); //Horn
				NilfNormal.cardIndices.PushBack(1); //Horn
				NilfNormal.cardIndices.PushBack(2); //Scorch
				NilfNormal.cardIndices.PushBack(2); //Scorch
				NilfNormal.cardIndices.PushBack(3); //Biting Frost
				NilfNormal.cardIndices.PushBack(3); //Biting Frost
				NilfNormal.cardIndices.PushBack(6); //Clear Weather
				NilfNormal.cardIndices.PushBack(200); //Letho of Gulet  [10] ***[HERO]***
				NilfNormal.cardIndices.PushBack(230);//Archer Support [NURSE]
				NilfNormal.cardIndices.PushBack(218); //Vattier de Rideaux Vattier [4] [SPY]
			}
			if (difficulty == 3)
			{
				NilfNormal.cardIndices.PushBack(0); //Dummy
				NilfNormal.cardIndices.PushBack(1); //Horn
				NilfNormal.cardIndices.PushBack(1); //Horn
				NilfNormal.cardIndices.PushBack(2); //Scorch
				NilfNormal.cardIndices.PushBack(3); //Biting Frost
				NilfNormal.cardIndices.PushBack(6); //Clear Weather
				NilfNormal.cardIndices.PushBack(9); // [7] Yennefer [HERO][NURSE]
				NilfNormal.cardIndices.PushBack(200); //Letho of Gulet  [10] ***[HERO]***
				NilfNormal.cardIndices.PushBack(230);//Archer Support [NURSE]
				NilfNormal.cardIndices.PushBack(218); //Vattier de Rideaux Vattier [4] [SPY]
			}

			NilfNormal.cardIndices.PushBack(201); //Menno Coehoorn [10] ***[HERO]***
			NilfNormal.cardIndices.PushBack(203); //Tibor Eggebracht [10] ***[HERO]***
			NilfNormal.cardIndices.PushBack(207); //Cynthia [4]
			NilfNormal.cardIndices.PushBack(209); //Morteisen [3]
			NilfNormal.cardIndices.PushBack(210); //Rainfarn [4]
			NilfNormal.cardIndices.PushBack(208); //Fringilla Vigo 
			NilfNormal.cardIndices.PushBack(213); //Shilard Fitz-Oesterlen  [4] [SPY]
			NilfNormal.cardIndices.PushBack(235);//Siege Support [NURSE]
			NilfNormal.cardIndices.PushBack(236);//Black Infantry Archer [10]
			NilfNormal.cardIndices.PushBack(240);//Heavy Zerri [10]
			NilfNormal.cardIndices.PushBack(245);//Impera
			NilfNormal.cardIndices.PushBack(246);//Impera
			NilfNormal.cardIndices.PushBack(247);//Impera
			NilfNormal.cardIndices.PushBack(250);//Nausicaa	
			NilfNormal.cardIndices.PushBack(251);//Nausicaa
			NilfNormal.cardIndices.PushBack(252);//Nausicaa
			NilfNormal.cardIndices.PushBack(260);//Young Emissary
			NilfNormal.cardIndices.PushBack(261);//Young Emissary


			NilfNormal.dynamicCardRequirements.PushBack(diff12);
			NilfNormal.dynamicCards.PushBack(15);//Villentretenmerth  [7] 
			NilfNormal.dynamicCardRequirements.PushBack(diff13);
			NilfNormal.dynamicCards.PushBack(202);//Morvran Voorhis [10] ***[HERO]***			
			NilfNormal.dynamicCardRequirements.PushBack(diff15);
			NilfNormal.dynamicCards.PushBack(7); //Geralt

			NilfNormal.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			NilfNormal.leaderIndex = 2002;
			enemyDecks.PushBack(NilfNormal);


			//NilfHard.deckName = "NilfHard";
			if (difficulty == 1)
			{
				NilfHard.cardIndices.PushBack(4); //Impenetrable Fog
				NilfHard.cardIndices.PushBack(3); //Frost
			}
			if (difficulty == 2)
			{
				NilfHard.cardIndices.PushBack(0); //Dummy
				NilfHard.cardIndices.PushBack(1); //Horn
				NilfHard.cardIndices.PushBack(1); //Horn
				NilfHard.cardIndices.PushBack(2); //Scorch
				NilfHard.cardIndices.PushBack(2); //Scorch
				NilfHard.cardIndices.PushBack(218); //Vattier de Rideaux Vattier [4] [SPY]
				NilfHard.cardIndices.PushBack(200); //Letho of Gulet  [10] ***[HERO]***
				NilfHard.cardIndices.PushBack(231); //Archer Support [NURSE]
				NilfHard.cardIndices.PushBack(235); //Siege Support [NURSE]
			}
			if (difficulty == 3)
			{
				NilfHard.cardIndices.PushBack(0); //Dummy
				NilfHard.cardIndices.PushBack(0); //Dummy
				NilfHard.cardIndices.PushBack(1); //Horn
				NilfHard.cardIndices.PushBack(1); //Horn
				NilfHard.cardIndices.PushBack(2); //Scorch
				NilfHard.cardIndices.PushBack(2); //Scorch
				NilfHard.cardIndices.PushBack(218); //Vattier de Rideaux Vattier [4] [SPY]
				NilfHard.cardIndices.PushBack(200); //Letho of Gulet  [10] ***[HERO]***
				NilfHard.cardIndices.PushBack(231); //Archer Support [NURSE]
				NilfHard.cardIndices.PushBack(235); //Siege Support [NURSE]
				NilfHard.cardIndices.PushBack(9);   //Yennefer [NURSE][HERO]
			}

			NilfHard.cardIndices.PushBack(15); //Villentretenmerth  [7] 
			NilfHard.cardIndices.PushBack(16); //Avallac'hh  [SPY] 
			NilfHard.cardIndices.PushBack(201); //Menno Coehoorn 
			NilfHard.cardIndices.PushBack(202); //Morvran Voorhis
			NilfHard.cardIndices.PushBack(203); //Tibor Eggebracht [10] ***[HERO]***
			NilfHard.cardIndices.PushBack(208); //Fringilla Vigo 
			NilfHard.cardIndices.PushBack(213); //Shilard Fitz-Oesterlen  [7] [SPY]
			NilfHard.cardIndices.PushBack(214); //Stefan Skellen   [9] [SPY]
			NilfHard.cardIndices.PushBack(230); //Archer Support [NURSE]
			NilfHard.cardIndices.PushBack(236); //Black Infantry Archer [10]
			NilfHard.cardIndices.PushBack(240); //Heavy Zerri [10]
			NilfHard.cardIndices.PushBack(241); //Zerri
			NilfHard.cardIndices.PushBack(245); //Impera
			NilfHard.cardIndices.PushBack(246); //Impera
			NilfHard.cardIndices.PushBack(247); //Impera
			NilfHard.cardIndices.PushBack(250); //Nausicaa	
			NilfHard.cardIndices.PushBack(251); //Nausicaa
			NilfHard.cardIndices.PushBack(252); //Nausicaa

			NilfHard.specialCard = 261; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			NilfHard.leaderIndex = 2003;
			enemyDecks.PushBack(NilfHard);
		
	}
	
	private function SetupAIDeckDefinitionsScoia()
	{
		var ScoiaEasy				:SDeckDefinition;
		var ScoiaNormal				:SDeckDefinition;
		var ScoiaHard				:SDeckDefinition;
		
			//ScoiaEasy.deckName = "ScoiaEasy";
			ScoiaEasy.cardIndices.PushBack(3); //Biting Frost
			ScoiaEasy.cardIndices.PushBack(4); //Impenetrable Fog 
			ScoiaEasy.cardIndices.PushBack(5); //Torrential Rain
			ScoiaEasy.cardIndices.PushBack(6); //Clear Weather

			if (difficulty == 3)
			{
				ScoiaEasy.cardIndices.PushBack(0); //Dummy
				ScoiaEasy.cardIndices.PushBack(1); //Horn
				ScoiaEasy.cardIndices.PushBack(300); // [10] Eithne [HERO]
				ScoiaEasy.cardIndices.PushBack(9); // [10] Yennefer [NURSE][HERO]
			}

			ScoiaEasy.cardIndices.PushBack(306);//Milva
			ScoiaEasy.cardIndices.PushBack(307);//Ida
			ScoiaEasy.cardIndices.PushBack(308);//Filavandrel
			ScoiaEasy.cardIndices.PushBack(309);//Yaevinn
			ScoiaEasy.cardIndices.PushBack(310);//Toruviel
			ScoiaEasy.cardIndices.PushBack(311);//Riordain
			ScoiaEasy.cardIndices.PushBack(312);//Ciaran
			ScoiaEasy.cardIndices.PushBack(320);//Hav'caaren Support
			ScoiaEasy.cardIndices.PushBack(325);//Vrihedd Brigade
			ScoiaEasy.cardIndices.PushBack(330);//Dol Blathanna Infantry
			ScoiaEasy.cardIndices.PushBack(331);//Dol Blathanna Infantry
			ScoiaEasy.cardIndices.PushBack(335);//Dwarf Skirmisher
			ScoiaEasy.cardIndices.PushBack(336);//Dwarf Skirmisher
			ScoiaEasy.cardIndices.PushBack(337);//Dwarf Skirmisher
			ScoiaEasy.cardIndices.PushBack(340);//Mahakam
			ScoiaEasy.cardIndices.PushBack(350);//Elf Skirmisher
			ScoiaEasy.cardIndices.PushBack(351);//Elf Skirmisher
			ScoiaEasy.cardIndices.PushBack(355);//Vrihedd Cadet 
			ScoiaEasy.cardIndices.PushBack(360);//Dol Blathanna Archer
			ScoiaEasy.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			ScoiaEasy.leaderIndex = 3001;
			enemyDecks.PushBack(ScoiaEasy);

			
			//ScoiaNormal.deckName = "ScoiaNormal";
 			if (difficulty == 1)
			{
				ScoiaNormal.cardIndices.PushBack(0); //Dummy
				ScoiaNormal.cardIndices.PushBack(1); //Horn
				ScoiaNormal.cardIndices.PushBack(3); //Biting Frost
				ScoiaNormal.cardIndices.PushBack(4); //Fog
				ScoiaNormal.cardIndices.PushBack(5); //Torrential Rain
				ScoiaNormal.cardIndices.PushBack(6); //Clear Weather
			}
			if (difficulty == 2)
			{
				ScoiaNormal.cardIndices.PushBack(0); //Dummy
				ScoiaNormal.cardIndices.PushBack(1); //Horn
				ScoiaNormal.cardIndices.PushBack(2); //Scorch
				ScoiaNormal.cardIndices.PushBack(2); //Scorch
				ScoiaNormal.cardIndices.PushBack(3); //Biting Frost
				ScoiaNormal.cardIndices.PushBack(6); //Clear Weather
				ScoiaNormal.cardIndices.PushBack(5); //Torrential Rain
				ScoiaNormal.cardIndices.PushBack(301);	// Saskia/Saesenthessis [10] ***[HERO]***
				ScoiaNormal.cardIndices.PushBack(302);	// Isengrim Faoiltiarna   [10] ***[HERO]***
			}
			if (difficulty == 3)
			{
				ScoiaNormal.cardIndices.PushBack(0); //Dummy
				ScoiaNormal.cardIndices.PushBack(0); //Dummy
				ScoiaNormal.cardIndices.PushBack(1); //Horn
				ScoiaNormal.cardIndices.PushBack(2); //Scorch
				ScoiaNormal.cardIndices.PushBack(6); //Clear Weather
				ScoiaNormal.cardIndices.PushBack(5); //Torrential Rain
				ScoiaNormal.cardIndices.PushBack(301);	// Saskia/Saesenthessis [10] ***[HERO]***
				ScoiaNormal.cardIndices.PushBack(302);	// Isengrim Faoiltiarna   [10] ***[HERO]***
			}
 
			ScoiaNormal.cardIndices.PushBack(16);   // 0 Avallac'h  [SPY]
			ScoiaNormal.cardIndices.PushBack(303);	// Iorveth [10] ***[HERO]***
			ScoiaNormal.cardIndices.PushBack(305);	// 6 dennis
			ScoiaNormal.cardIndices.PushBack(306);	// 10 milva
			ScoiaNormal.cardIndices.PushBack(307);  // 6 Ida
			ScoiaNormal.cardIndices.PushBack(308);	// 6 filavandrel AGILE
			ScoiaNormal.cardIndices.PushBack(309);	// 6 Yaevin AGILE
			ScoiaNormal.cardIndices.PushBack(313);	// 6 barclay AGILE
			ScoiaNormal.cardIndices.PushBack(320);	// 4 havekar support SUMMON CLONES
			ScoiaNormal.cardIndices.PushBack(321);	// 4 havekar support ^
			ScoiaNormal.cardIndices.PushBack(322);	// 4 havekar support ^	
			ScoiaNormal.cardIndices.PushBack(325);	// 5 Vrihed AGILE
			ScoiaNormal.cardIndices.PushBack(326);	// 5 Vrihed AGILE
			ScoiaNormal.cardIndices.PushBack(330);  // 6 Dol Blathanna Infantry
			ScoiaNormal.cardIndices.PushBack(331);  // 6 Dol Blathanna Infantry
			ScoiaNormal.cardIndices.PushBack(335);	// 3 Dwarf Skirmisher SUMMON CLONES
			ScoiaNormal.cardIndices.PushBack(336);	// 3 Dwarf Skirmisher ^
			ScoiaNormal.cardIndices.PushBack(337);	// 3 Dwarf Skirmisher ^
			ScoiaNormal.cardIndices.PushBack(365);	// 0 Hav'caaren Support [NURSE]
			ScoiaNormal.cardIndices.PushBack(366);	// 0 Hav'caaren Support [NURSE]
			ScoiaNormal.cardIndices.PushBack(367);	// 0 Hav'caaren Support [NURSE]


			ScoiaNormal.dynamicCardRequirements.PushBack(diff12);
			ScoiaNormal.dynamicCards.PushBack(12); //Dandelion
			ScoiaNormal.dynamicCardRequirements.PushBack(diff13);
			ScoiaNormal.dynamicCards.PushBack(15); //Villentretenmerth
			ScoiaNormal.dynamicCardRequirements.PushBack(diff15);
			ScoiaNormal.dynamicCards.PushBack(10); //Ciri

			ScoiaNormal.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			ScoiaNormal.leaderIndex = 3002;
			enemyDecks.PushBack(ScoiaNormal);


			//ScoiaHard.deckName = "ScoiaHard";
			ScoiaHard.cardIndices.PushBack(3); //Frost
			ScoiaHard.cardIndices.PushBack(1); //Horn
			ScoiaHard.cardIndices.PushBack(1); //Horn
			ScoiaHard.cardIndices.PushBack(2); //Scorch	
			ScoiaHard.cardIndices.PushBack(2); //Scorch	
			ScoiaHard.cardIndices.PushBack(0); //Dummy	

 			if (difficulty == 1)
			{
				ScoiaHard.cardIndices.PushBack(4); //Fog
			}
			if (difficulty == 2)
			{
				ScoiaHard.cardIndices.PushBack(7);  //Geralt
				ScoiaHard.cardIndices.PushBack(10); //Ciri
				ScoiaHard.cardIndices.PushBack(301);	// 10 Saskia/Saesenthessis
				ScoiaHard.cardIndices.PushBack(302);	// 10 Isengrim Faoiltiarna  
			}
			if (difficulty == 3)
			{
				ScoiaHard.cardIndices.PushBack(7);  //Geralt
				ScoiaHard.cardIndices.PushBack(10); //Ciri
				ScoiaHard.cardIndices.PushBack(301);	// 10 Saskia/Saesenthessis
				ScoiaHard.cardIndices.PushBack(302);	// 10 Isengrim Faoiltiarna 
				ScoiaHard.cardIndices.PushBack(9); //Yennefer
			}

			ScoiaHard.cardIndices.PushBack(15); //Villentretenmerth  [7] 
			ScoiaHard.cardIndices.PushBack(16); //Avallac'hh  [SPY]
			ScoiaHard.cardIndices.PushBack(12); //Dandelion
			ScoiaHard.cardIndices.PushBack(300);	// 10 Eithné
			ScoiaHard.cardIndices.PushBack(303);	// 10 ioveth HERO
			ScoiaHard.cardIndices.PushBack(305);	// 6 dennis
			ScoiaHard.cardIndices.PushBack(306);	// 10 milva
			ScoiaHard.cardIndices.PushBack(308);	// 6 filavandrel AGILE
			ScoiaHard.cardIndices.PushBack(309);	// 6 Yaevin AGILE
			ScoiaHard.cardIndices.PushBack(313);	// 6 barclay AGILE
			ScoiaHard.cardIndices.PushBack(320);	// 4 havekar support SUMMON CLONES
			ScoiaHard.cardIndices.PushBack(321);	// 4 havekar support ^
			ScoiaHard.cardIndices.PushBack(322);	// 4 havekar support ^	
			ScoiaHard.cardIndices.PushBack(325);	// 5 Vrihed AGILE
			ScoiaHard.cardIndices.PushBack(326);	// 5 Vrihed AGILE
			ScoiaHard.cardIndices.PushBack(365);	// 5 Hav'caaren Support 
			ScoiaHard.cardIndices.PushBack(366);	// 5 Hav'caaren Support ^
			ScoiaHard.cardIndices.PushBack(367);	// 5 Hav'caaren Support ^

			ScoiaHard.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			ScoiaHard.leaderIndex = 3003;
			enemyDecks.PushBack(ScoiaHard);
			
	}
	
	private function SetupAIDeckDefinitionsNML()
	{
		var NMLEasy				:SDeckDefinition;
		var NMLNormal			:SDeckDefinition;
		var NMLHard				:SDeckDefinition;
		
			//NMLEasy.deckName = "NMLEasy";
			NMLEasy.cardIndices.PushBack(3); //Biting Frost
			NMLEasy.cardIndices.PushBack(4); //Impenetrable Fog 
			NMLEasy.cardIndices.PushBack(5); //Torrential Rain
			NMLEasy.cardIndices.PushBack(6); //Clear Weather

			if (difficulty == 3)
			{
				NMLEasy.cardIndices.PushBack(476); // [ 6 ] Weavess ^
				NMLEasy.cardIndices.PushBack(9); //Yennefer
			}

			NMLEasy.cardIndices.PushBack(405); //Forktail
			NMLEasy.cardIndices.PushBack(407); //Earth Elemental
			NMLEasy.cardIndices.PushBack(410); //Fiend
			NMLEasy.cardIndices.PushBack(413); //Plague Maiden
			NMLEasy.cardIndices.PushBack(415); //Griffin
			NMLEasy.cardIndices.PushBack(417); //Werewolf
			NMLEasy.cardIndices.PushBack(420); //Botchling
			NMLEasy.cardIndices.PushBack(423); //Frightener
			NMLEasy.cardIndices.PushBack(425); //Ice Giant
			NMLEasy.cardIndices.PushBack(427); //Endrega
			NMLEasy.cardIndices.PushBack(430); // Harpy
			NMLEasy.cardIndices.PushBack(433); //Cockatrice
			NMLEasy.cardIndices.PushBack(435); //Gargoyle
			NMLEasy.cardIndices.PushBack(437); //Celaeno Harpy
			NMLEasy.cardIndices.PushBack(450); //Arachas Behemoth
			NMLEasy.cardIndices.PushBack(455); //Nekker
			NMLEasy.cardIndices.PushBack(456); //Nekker
			NMLEasy.cardIndices.PushBack(460); //Ekkimma
			NMLEasy.cardIndices.PushBack(470); //Ghoul
			NMLEasy.cardIndices.PushBack(475); //Crone Brewess
			NMLEasy.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			NMLEasy.leaderIndex = 4001;
			enemyDecks.PushBack(NMLEasy);

			
			//NMLNormal.deckName = "NMLNormal";
			NMLNormal.cardIndices.PushBack(4); //Impenetrable Fog 
			NMLNormal.cardIndices.PushBack(5); //Torrential Rain		
			NMLNormal.cardIndices.PushBack(6); 	//Clear Weather
			NMLNormal.cardIndices.PushBack(0); 	//Dummy	

 			if (difficulty == 1)
			{
				NMLNormal.cardIndices.PushBack(4); //Fog
				NMLNormal.cardIndices.PushBack(1); 	//Horn		
				NMLNormal.cardIndices.PushBack(2); 	//Scorch
			}
			if (difficulty == 2)
			{
				NMLNormal.cardIndices.PushBack(1); 	//Horn	
				NMLNormal.cardIndices.PushBack(1); 	//Horn		
				NMLNormal.cardIndices.PushBack(2); 	//Scorch		
				NMLNormal.cardIndices.PushBack(2); 	//Scorch
				NMLNormal.cardIndices.PushBack(400); //Draug 10 [Hero]
			}
			if (difficulty == 3)
			{
				NMLNormal.cardIndices.PushBack(1); 	//Horn	
				NMLNormal.cardIndices.PushBack(1); 	//Horn		
				NMLNormal.cardIndices.PushBack(2); 	//Scorch		
				NMLNormal.cardIndices.PushBack(0); 	//Dummy
				NMLNormal.cardIndices.PushBack(0); 	//Dummy
				NMLNormal.cardIndices.PushBack(7);  //Geralt
				NMLNormal.cardIndices.PushBack(9);  //Yennefer
				NMLNormal.cardIndices.PushBack(400); //Draug 10 [Hero]
			}

			NMLNormal.cardIndices.PushBack(402); //Imlerith 10 [Hero]
			NMLNormal.cardIndices.PushBack(403); //Leshen 10
			NMLNormal.cardIndices.PushBack(407); //Earth Elemental 6
			NMLNormal.cardIndices.PushBack(410); //Fiend 6
			NMLNormal.cardIndices.PushBack(415); //Griffin 5
			NMLNormal.cardIndices.PushBack(417); //Werewolf 5
			NMLNormal.cardIndices.PushBack(423); //Frightener 5 
			NMLNormal.cardIndices.PushBack(425); //Ice Giant 5
			NMLNormal.cardIndices.PushBack(450); //Arachas Behemoth
			NMLNormal.cardIndices.PushBack(451); //Arachas ^
			NMLNormal.cardIndices.PushBack(452); //Arachas ^
			NMLNormal.cardIndices.PushBack(453); //Arachas ^
			NMLNormal.cardIndices.PushBack(460); // [ 4 ] Ekkima Summon 5x
			NMLNormal.cardIndices.PushBack(463); // [ 4 ] Bruxa ^
			NMLNormal.cardIndices.PushBack(461); // [ 4 ] Fleder ^
			NMLNormal.cardIndices.PushBack(462); // [ 4 ] Garkain ^
			NMLNormal.cardIndices.PushBack(464); // [ 4 ] Katakan ^
			NMLNormal.cardIndices.PushBack(475); // [ 6 ] Brewess Summon 3x
			NMLNormal.cardIndices.PushBack(476); // [ 6 ] Weavess ^
			NMLNormal.cardIndices.PushBack(477); // [ 6 ] Whispess ^


			NMLNormal.dynamicCardRequirements.PushBack(diff12);
			NMLNormal.dynamicCards.PushBack(401); //Kayran
			NMLNormal.dynamicCardRequirements.PushBack(diff13);
			NMLNormal.dynamicCards.PushBack(16); //Avallah
			NMLNormal.dynamicCardRequirements.PushBack(diff15);
			NMLNormal.dynamicCards.PushBack(15); //Villentretenmerth

			NMLNormal.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			NMLNormal.leaderIndex = 4002;
			enemyDecks.PushBack(NMLNormal);

			
			//NMLHard.deckName = "NMLHard";	
			NMLHard.cardIndices.PushBack(1); 		//Horn	
			NMLHard.cardIndices.PushBack(2); 		//Scorch
			NMLHard.cardIndices.PushBack(0); 		//Dummy	

 			if (difficulty == 1)
			{
				NMLHard.cardIndices.PushBack(4); 	//Fog
				NMLHard.cardIndices.PushBack(3); 	//Frost		
				NMLHard.cardIndices.PushBack(2); 	//Scorch
			}
			if (difficulty == 2)
			{
				NMLHard.cardIndices.PushBack(1); 	//Horn		
				NMLHard.cardIndices.PushBack(2); 	//Scorch
				NMLHard.cardIndices.PushBack(15);	// Villentretenmerth [7]
				NMLHard.cardIndices.PushBack(402);	// [ 10 ] Imlerith HERO
				NMLHard.cardIndices.PushBack(476);	// [ 6 ] Weavess ^
				NMLHard.cardIndices.PushBack(451);	// [ 4 ] Arachas ^
			}
			if (difficulty == 3)
			{
				NMLHard.cardIndices.PushBack(1); 	//Horn		
				NMLHard.cardIndices.PushBack(2); 	//Scorch
				NMLHard.cardIndices.PushBack(0); 	//Dummy	
				NMLHard.cardIndices.PushBack(15);	// Villentretenmerth [7]
				NMLHard.cardIndices.PushBack(402);	// [ 10 ] Imlerith HERO
				NMLHard.cardIndices.PushBack(476);	// [ 6 ] Weavess ^
				NMLHard.cardIndices.PushBack(451);	// [ 4 ] Arachas ^
				NMLHard.cardIndices.PushBack(9);  //Yennefer
			}

		
			NMLHard.cardIndices.PushBack(16);	// Avallac'h		
			NMLHard.cardIndices.PushBack(401);	// [ 10 ] Kayran HERO
			NMLHard.cardIndices.PushBack(403);	// [ 10 ] Leshen HERO
			NMLHard.cardIndices.PushBack(407);	// [ 6 ] Earth Elem
			NMLHard.cardIndices.PushBack(450);	// [ 6 ] Behemoth  Summon 4x
			NMLHard.cardIndices.PushBack(452);	// [ 4 ] Arachas ^
			NMLHard.cardIndices.PushBack(455);	// [ 2 ] Nekker Summon 3x
			NMLHard.cardIndices.PushBack(456);	// [ 2 ] Nekker ^
			NMLHard.cardIndices.PushBack(457);	// [ 2 ] Nekker ^
			NMLHard.cardIndices.PushBack(460);	// [ 4 ] Ekkima Summon 5x
			NMLHard.cardIndices.PushBack(463);	// [ 4 ] Bruxa ^
			NMLHard.cardIndices.PushBack(461);	// [ 4 ] Fleder ^
			NMLHard.cardIndices.PushBack(462);	// [ 4 ] Garkain ^
			NMLHard.cardIndices.PushBack(464);	// [ 4 ] Katakan ^
			NMLHard.cardIndices.PushBack(470);	// [ 1 ] Ghoul Summon 3x
			NMLHard.cardIndices.PushBack(471);	// [ 1 ] Ghoul ^
			NMLHard.cardIndices.PushBack(472);	// [ 1 ] Ghoul ^
			NMLHard.cardIndices.PushBack(475);	// [ 6 ] Brewess Summon 3x
			NMLHard.cardIndices.PushBack(477);	// [ 6 ] Whispess ^

			NMLHard.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			NMLHard.leaderIndex = 4003;
			enemyDecks.PushBack(NMLHard);
	}
	
			////////////////SKELLIGE/////////////////
	
private function SetupAIDeckDefinitionsSkel()
	{
		var SkelEasy				:SDeckDefinition;
		var SkelNormal				:SDeckDefinition;
		var SkelHard				:SDeckDefinition;
		
			//SkelEasy.deckName = "SkelEasy";
			SkelEasy.cardIndices.PushBack(3); //Biting Frost
			SkelEasy.cardIndices.PushBack(3); //Biting Frost
			SkelEasy.cardIndices.PushBack(23); //Skellige Storm
			SkelEasy.cardIndices.PushBack(23); //Skellige Storm

			if (difficulty == 3)
			{
				SkelEasy.cardIndices.PushBack(22); // Mushroom
				SkelEasy.cardIndices.PushBack(503); // Ermion
				SkelEasy.cardIndices.PushBack(515);	// Young Berserker
				SkelEasy.cardIndices.PushBack(515);	// Young Berserker
				SkelEasy.cardIndices.PushBack(515);	// Young Berserker
				SkelEasy.cardIndices.PushBack(9); // [10] Yennefer [NURSE][HERO]
				SkelEasy.cardIndices.PushBack(502); // Cery
				SkelEasy.cardIndices.PushBack(16); //Avallac'hh  [SPY]
			}

			SkelEasy.cardIndices.PushBack(504);//Draig Bon-Dhu
			SkelEasy.cardIndices.PushBack(505);//Holger Blackhand
			SkelEasy.cardIndices.PushBack(506);//Madman Lugos
			SkelEasy.cardIndices.PushBack(507);//Donar an Hindar
			SkelEasy.cardIndices.PushBack(510);//Blueboy Lugos
			SkelEasy.cardIndices.PushBack(511);//Svanrige
			SkelEasy.cardIndices.PushBack(513);//Berserker 
			SkelEasy.cardIndices.PushBack(515);//Young Berserker
			SkelEasy.cardIndices.PushBack(517);//Clan An Craite warrior
			SkelEasy.cardIndices.PushBack(517);//Clan An Craite warrior
			SkelEasy.cardIndices.PushBack(517);//DClan An Craite warrior
			SkelEasy.cardIndices.PushBack(522);//Clan Brokvar archer
			SkelEasy.cardIndices.PushBack(522);//Clan Brokvar archer
			SkelEasy.cardIndices.PushBack(524);//Clan Dimun pirate
			SkelEasy.cardIndices.PushBack(16);// Mysterious elf
			SkelEasy.cardIndices.PushBack(18);// Mr Shadows
			SkelEasy.cardIndices.PushBack(19);// Mr Shadows shadows
			SkelEasy.cardIndices.PushBack(19);// Mr Shadows shadows
			SkelEasy.cardIndices.PushBack(20);//Cow
			
			SkelEasy.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			SkelEasy.leaderIndex = 5001;
			enemyDecks.PushBack(SkelEasy);

			
			//SkelNormal.deckName = "SkelNormal";
			
 			if (difficulty == 1)
			{
				SkelNormal.cardIndices.PushBack(0); //Dummy
				SkelNormal.cardIndices.PushBack(1); //Horn
				SkelNormal.cardIndices.PushBack(1); //Horn				
				SkelNormal.cardIndices.PushBack(6); //Clear Weather
				SkelNormal.cardIndices.PushBack(525);	// Cockerel
			}
			if (difficulty == 2)
			{
				SkelNormal.cardIndices.PushBack(0); //Dummy
				SkelNormal.cardIndices.PushBack(2); //Scorch
				SkelNormal.cardIndices.PushBack(503); //Ermion
				SkelNormal.cardIndices.PushBack(502); //Cery
				SkelNormal.cardIndices.PushBack(16); //	Avallac'h  [SPY]
			}
			if (difficulty == 3)
			{
				SkelNormal.cardIndices.PushBack(7);  //Geralt
				SkelNormal.cardIndices.PushBack(502); // Cery
				SkelNormal.cardIndices.PushBack(17); // Olgierd
				SkelNormal.cardIndices.PushBack(509); // Birna			
				SkelNormal.cardIndices.PushBack(16); //Avallac'hh  [SPY]
			}
			SkelNormal.cardIndices.PushBack(9);		// Yennefer
			SkelNormal.cardIndices.PushBack(15); 	// Villentretenmerth  [7] 
			SkelNormal.cardIndices.PushBack(504); 	// Draig Bon-Dhu
			SkelNormal.cardIndices.PushBack(12); 	// Dandelion
			SkelNormal.cardIndices.PushBack(513);	// Berserker
			SkelNormal.cardIndices.PushBack(515);	// Young Berserker
			SkelNormal.cardIndices.PushBack(515);	// Young Berserker
			SkelNormal.cardIndices.PushBack(515);	// Young Berserker
			SkelNormal.cardIndices.PushBack(520);	// Light Drakkar
			SkelNormal.cardIndices.PushBack(520);	// Light Drakkar
			SkelNormal.cardIndices.PushBack(520);	// Light Drakkar
			SkelNormal.cardIndices.PushBack(521);	// War Drakkar
			SkelNormal.cardIndices.PushBack(521);	// War Drakkar
			SkelNormal.cardIndices.PushBack(521);	// War Drakkar
			SkelNormal.cardIndices.PushBack(523);	// ShieldMaiden
			SkelNormal.cardIndices.PushBack(523);	// ShieldMaiden
			SkelNormal.cardIndices.PushBack(523);	// ShieldMaiden

			SkelNormal.dynamicCardRequirements.PushBack(diff12);
			SkelNormal.dynamicCards.PushBack(12); //Dandelion
			SkelNormal.dynamicCardRequirements.PushBack(diff13);
			SkelNormal.dynamicCards.PushBack(15); //Villentretenmerth
			SkelNormal.dynamicCardRequirements.PushBack(diff15);
			SkelNormal.dynamicCards.PushBack(10); //Ciri

			SkelNormal.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			SkelNormal.leaderIndex = 5002;
			enemyDecks.PushBack(SkelNormal);


			//SkelHard.deckName = "SkelHard";
			SkelHard.cardIndices.PushBack(22); //Mushroom
			SkelHard.cardIndices.PushBack(22); //Mushroom
			SkelHard.cardIndices.PushBack(1); //Horn
			SkelHard.cardIndices.PushBack(1); //Horn
			SkelHard.cardIndices.PushBack(2); //Scorch	
			SkelHard.cardIndices.PushBack(2); //Scorch	


 			if (difficulty == 1)
			{
				SkelHard.cardIndices.PushBack(4); //Fog
			}
			if (difficulty == 2)
			{
				SkelHard.cardIndices.PushBack(7);  //Geralt
				SkelHard.cardIndices.PushBack(10); //Ciri
				SkelHard.cardIndices.PushBack(20);	// Cow
			}
			if (difficulty == 3)
			{
				SkelHard.cardIndices.PushBack(17);	// Olgierd
				SkelHard.cardIndices.PushBack(504); // Draig Bon-Dhu
				SkelHard.cardIndices.PushBack(509);	// Birna

			}
			
			SkelHard.cardIndices.PushBack(9);	// Yennefer
			SkelHard.cardIndices.PushBack(15); //Villentretenmerth  [7] 
			SkelHard.cardIndices.PushBack(16); //Avallac'hh  [SPY]
			SkelHard.cardIndices.PushBack(12); //Dandelion
			SkelHard.cardIndices.PushBack(502);	// Cerys
			SkelHard.cardIndices.PushBack(513);	// Berserker
			SkelHard.cardIndices.PushBack(515);	// Young Berserker
			SkelHard.cardIndices.PushBack(515);	// Young Berserker
			SkelHard.cardIndices.PushBack(515);	// Young Berserker
			SkelHard.cardIndices.PushBack(520);	// Light Drakkar
			SkelHard.cardIndices.PushBack(520);	// Light Drakkar
			SkelHard.cardIndices.PushBack(520);	// Light Drakkar
			SkelHard.cardIndices.PushBack(521);	// War Drakkar
			SkelHard.cardIndices.PushBack(521);	// War Drakkar
			SkelHard.cardIndices.PushBack(521);	// War Drakkar
			SkelHard.cardIndices.PushBack(523);	// ShieldMaiden
			SkelHard.cardIndices.PushBack(523);	// ShieldMaiden
			SkelHard.cardIndices.PushBack(523);	// ShieldMaiden


			SkelHard.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			SkelHard.leaderIndex = 5002;
			enemyDecks.PushBack(SkelHard);
			
	}
	
	private function SetupAIDeckDefinitionsPrologue()
	{
		var NilfPrologue		: SDeckDefinition;
			
			//NilfPrologue.deckName = "NilfPrologue";
			NilfPrologue.cardIndices.PushBack(3); //Biting Frost
			NilfPrologue.cardIndices.PushBack(4); //Impenetrable Fog 
			NilfPrologue.cardIndices.PushBack(5); //Torrential Rain
			NilfPrologue.cardIndices.PushBack(6); //Clear Weather

			NilfPrologue.cardIndices.PushBack(205); //Albrich [2]
			NilfPrologue.cardIndices.PushBack(207);//Cynthia
			NilfPrologue.cardIndices.PushBack(209); // Morteisen [3]
			NilfPrologue.cardIndices.PushBack(210); //Rainfarn [4]
			NilfPrologue.cardIndices.PushBack(211); //Renuald aep Matsen  [5] 
			NilfPrologue.cardIndices.PushBack(212); //Rotten Mangonel [3]
			NilfPrologue.cardIndices.PushBack(215); //Sweers [2]
			NilfPrologue.cardIndices.PushBack(215); //Sweers [2]
			NilfPrologue.cardIndices.PushBack(217); //Vanhemar [4]
			NilfPrologue.cardIndices.PushBack(221);//Puttkammer
			NilfPrologue.cardIndices.PushBack(221);//Puttkammer
			NilfPrologue.cardIndices.PushBack(241);//Zerri
			NilfPrologue.cardIndices.PushBack(245);//Impera
			NilfPrologue.cardIndices.PushBack(250);//Nausicaa
			NilfPrologue.cardIndices.PushBack(251);//Nausicaa
			NilfPrologue.specialCard = 219; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			NilfPrologue.leaderIndex = 2001;
			enemyDecks.PushBack(NilfPrologue);
	}
	private function SetupAIDeckDefinitionsTournament1()
	{
		var NKTournament		: SDeckDefinition;
		var NilfTournament		: SDeckDefinition;

			//NKTournament.deckName = "NKTournament";	
			NKTournament.cardIndices.PushBack(2); //Scorch
			NKTournament.cardIndices.PushBack(0); //Dummy
			NKTournament.cardIndices.PushBack(1); //Horn	
			NKTournament.cardIndices.PushBack(3); //Biting Frost	
			NKTournament.cardIndices.PushBack(3); //Biting Frost
			NKTournament.cardIndices.PushBack(4); //Impenetrable Fog

 			if (difficulty == 1)
			{	
				NKTournament.cardIndices.PushBack(6); // Clear Sky
				NKTournament.cardIndices.PushBack(108); // 2 Yarpen
				NKTournament.cardIndices.PushBack(113); // 4 Sabrina
				NKTournament.cardIndices.PushBack(114); // 4 Sheldon
			}
			else
			{
				NKTournament.cardIndices.PushBack(2); //Scorch
				NKTournament.cardIndices.PushBack(1); //Horn
				NKTournament.cardIndices.PushBack(105); //Thaler [4] [SPY]
			}

			NKTournament.cardIndices.PushBack(102);	// esterad [ 10 ][ HERO ][ MELEE ]
			NKTournament.cardIndices.PushBack(103);	// philippa [ 10 ][ RANGED ][ HERO ]
			NKTournament.cardIndices.PushBack(109);	// Sigismund Dijkstra  [4] [SPY]
			NKTournament.cardIndices.PushBack(116); //Stennis [5] [SPY]
			NKTournament.cardIndices.PushBack(120); //Trebuchet [6]
			NKTournament.cardIndices.PushBack(140); //Catapult [5] [TightBond]
			NKTournament.cardIndices.PushBack(141); //Catapult [5] [TightBond]
			NKTournament.cardIndices.PushBack(145); //Ballista [6]
			NKTournament.cardIndices.PushBack(160);	//Blue Stripes Commando [4] [TightBond]
			NKTournament.cardIndices.PushBack(160); //Blue Stripes Commando [4] [TightBond]
			NKTournament.cardIndices.PushBack(170); //Siege Tower [6]
			NKTournament.cardIndices.PushBack(175);	// dun_banner_medic [ 0 ][ SIEGE ][ EFFECT_NURSE ]
			
			NKTournament.dynamicCardRequirements.PushBack(diff2);	
			NKTournament.dynamicCards.PushBack(13);				
			NKTournament.dynamicCardRequirements.PushBack(diff5);	
			NKTournament.dynamicCards.PushBack(151); 				// kaedweni_siege [ 1 ][ SIEGE ][ EFFECT_IMPROVE_NEIGHBOURS ]
			NKTournament.dynamicCardRequirements.PushBack(diff6);	
			NKTournament.dynamicCards.PushBack(12); 				// [ 2 ] Dangelion 2x Boost
			NKTournament.dynamicCardRequirements.PushBack(diff8);	
			NKTournament.dynamicCards.PushBack(11); 				// [ 7 ] Triss HERO
			NKTournament.dynamicCardRequirements.PushBack(diff8);	
			NKTournament.dynamicCards.PushBack(7); 				// [ 15 ] Geralt of Rivia
			NKTournament.dynamicCardRequirements.PushBack(diff8);	
			NKTournament.dynamicCards.PushBack(15); 				// [ 7 ] Villen Scorch 				
			NKTournament.dynamicCardRequirements.PushBack(diff10);	
			NKTournament.dynamicCards.PushBack(10);
			NKTournament.dynamicCardRequirements.PushBack(diff10);	
			NKTournament.dynamicCards.PushBack(9); 				// [ 7 ] Yennefer RESSURECT
			
			NKTournament.specialCard = 16;	// Avallach [ 0 ][ EFFECT_DRAW_X2 ]
			NKTournament.leaderIndex = 1004; 
			enemyDecks.PushBack(NKTournament);

			
			//NilfTournament.deckName = "NilfTournament";
			NilfTournament.cardIndices.PushBack(0); // Dummy
			NilfTournament.cardIndices.PushBack(1); //Horn
			NilfTournament.cardIndices.PushBack(2); //Scorch
			NilfTournament.cardIndices.PushBack(2); //Scorch
			NilfTournament.cardIndices.PushBack(6); //Clear Weather

 			if (difficulty == 1)
			{	
				NilfTournament.cardIndices.PushBack(6); // Clear Sky
				NilfTournament.cardIndices.PushBack(205); // 2 Albrich
				NilfTournament.cardIndices.PushBack(209); // 3 Morstein
				NilfTournament.cardIndices.PushBack(212); // 3 Rotten
			}
			else
			{
				NilfTournament.cardIndices.PushBack(0); // Dummy
				NilfTournament.cardIndices.PushBack(0); // Dummy
				NilfTournament.cardIndices.PushBack(1); //Horn
				NilfTournament.cardIndices.PushBack(218); //Vattier de Rideaux Vattier [1] [SPY]
				NilfTournament.cardIndices.PushBack(200); //Letho of Gulet  [10] ***[HERO]***
				NilfTournament.cardIndices.PushBack(230);//Archer Support [NURSE]
			}

			NilfTournament.cardIndices.PushBack(201);//Menno Coehoorn 
			NilfTournament.cardIndices.PushBack(202);//Morvran Voorhis
			NilfTournament.cardIndices.PushBack(203); //Tibor Eggebracht [10] ***[HERO]***//Tibor Eggebracht
			NilfTournament.cardIndices.PushBack(208); //Fringilla Vigo 
			NilfTournament.cardIndices.PushBack(213); //Shilard Fitz-Oesterlen  [4] [SPY]
			NilfTournament.cardIndices.PushBack(214); //Stefan Skellen  [1] [SPY]
			NilfTournament.cardIndices.PushBack(231);//Archer Support [NURSE]
			NilfTournament.cardIndices.PushBack(235);//Siege Support [NURSE]
			NilfTournament.cardIndices.PushBack(236);//Black Infantry Archer
			NilfTournament.cardIndices.PushBack(240);//Heavy Zerri
			NilfTournament.cardIndices.PushBack(241);//Zerri
			NilfTournament.cardIndices.PushBack(260);//Young Emissary
			NilfTournament.cardIndices.PushBack(261);//Young Emissary

			// Autobalance
			NilfTournament.dynamicCardRequirements.PushBack(diff1);
			NilfTournament.dynamicCards.PushBack(15);
			NilfTournament.dynamicCardRequirements.PushBack(diff4);
			NilfTournament.dynamicCards.PushBack(16);
			NilfTournament.dynamicCardRequirements.PushBack(diff4);
			NilfTournament.dynamicCards.PushBack(12);
			NilfTournament.dynamicCardRequirements.PushBack(diff6);
			NilfTournament.dynamicCards.PushBack(248);
			NilfTournament.dynamicCardRequirements.PushBack(diff6);
			NilfTournament.dynamicCards.PushBack(11);
			NilfTournament.dynamicCardRequirements.PushBack(diff8);
			NilfTournament.dynamicCards.PushBack(7); // [ 15 ] Geralt of Rivia
			NilfTournament.dynamicCardRequirements.PushBack(diff10);
			NilfTournament.dynamicCards.PushBack(9);


			NilfTournament.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			NilfTournament.leaderIndex = 2004;
			enemyDecks.PushBack(NilfTournament);
		

	}

	private function SetupAIDeckDefinitionsTournament2()
	{
		var NMLTournament		: SDeckDefinition;
		var ScoiaTournament		: SDeckDefinition;

			//ScoiaTournament.deckName = "ScoiaTournament";
			ScoiaTournament.cardIndices.PushBack(0); //Dummy	
			ScoiaTournament.cardIndices.PushBack(1); //Horn
			ScoiaTournament.cardIndices.PushBack(2); //Scorch		
			ScoiaTournament.cardIndices.PushBack(3); //Biting Frost	
			ScoiaTournament.cardIndices.PushBack(4); //Impenetrable Fog 
			ScoiaTournament.cardIndices.PushBack(5); //Torrential Rain

 			if (difficulty == 1)
			{	
				ScoiaTournament.cardIndices.PushBack(310); // 2 Toruviel
				ScoiaTournament.cardIndices.PushBack(312); // 3 Ciaran
				ScoiaTournament.cardIndices.PushBack(335); // 3 Dwarf
			}
			else
			{
				ScoiaTournament.cardIndices.PushBack(2); //Scorch
				ScoiaTournament.cardIndices.PushBack(301);	// 10 Eithné
				ScoiaTournament.cardIndices.PushBack(302);	// 10 Isengrim Faoiltiarna 
				ScoiaTournament.cardIndices.PushBack(366);	// 5 Hav'caaren Support ^
			}
 
			ScoiaTournament.cardIndices.PushBack(303);	// 10 ioveth HERO
			ScoiaTournament.cardIndices.PushBack(305);	// 6 dennis
			ScoiaTournament.cardIndices.PushBack(306);	// 10 milva
			ScoiaTournament.cardIndices.PushBack(307);	// 6 ida
			ScoiaTournament.cardIndices.PushBack(308);	// 6 filavandrel AGILE
			ScoiaTournament.cardIndices.PushBack(309);	// 6 Yaevin AGILE
			ScoiaTournament.cardIndices.PushBack(313);	// 6 barclay AGILE
			ScoiaTournament.cardIndices.PushBack(320);	// 4 havekar support SUMMON CLONES
			ScoiaTournament.cardIndices.PushBack(321);	// 4 havekar support ^
			ScoiaTournament.cardIndices.PushBack(322);	// 4 havekar support ^	
			ScoiaTournament.cardIndices.PushBack(365);	// 5 Hav'caaren Support 
			ScoiaTournament.cardIndices.PushBack(367);	// 5 Hav'caaren Support ^
			// Autobalance
			ScoiaTournament.dynamicCardRequirements.PushBack(diff1);
			ScoiaTournament.dynamicCards.PushBack(15);
			ScoiaTournament.dynamicCardRequirements.PushBack(diff2);
			ScoiaTournament.dynamicCards.PushBack(12);
			ScoiaTournament.dynamicCardRequirements.PushBack(diff6);
			ScoiaTournament.dynamicCards.PushBack(300);
			ScoiaTournament.dynamicCardRequirements.PushBack(diff8);
			ScoiaTournament.dynamicCards.PushBack(11);
			ScoiaTournament.dynamicCardRequirements.PushBack(diff8);
			ScoiaTournament.dynamicCards.PushBack(14);
			ScoiaTournament.dynamicCardRequirements.PushBack(diff10);
			ScoiaTournament.dynamicCards.PushBack(7); // [ 15 ] Geralt of Rivia
			ScoiaTournament.dynamicCardRequirements.PushBack(diff10);
			ScoiaTournament.dynamicCards.PushBack(10);


			ScoiaTournament.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			ScoiaTournament.leaderIndex = 3004; 
			enemyDecks.PushBack(ScoiaTournament);

			//NMLTournament.deckName = "NMLTournament";	
			NMLTournament.cardIndices.PushBack(0); 		//Dummy
			NMLTournament.cardIndices.PushBack(1); 		//Horn	
			NMLTournament.cardIndices.PushBack(5);		//Torrential Rain	
			NMLTournament.cardIndices.PushBack(5);		//Torrential Rain	
			NMLTournament.cardIndices.PushBack(6);		//Clear Weather		
			NMLTournament.cardIndices.PushBack(6);		//Clear Weather

 			if (difficulty == 1)
			{	
				NMLTournament.cardIndices.PushBack(420);	// [ 4 ] Botchling
				NMLTournament.cardIndices.PushBack(420);	// [ 2 ] Endrega
			}
			else
			{
				NMLTournament.cardIndices.PushBack(0); 		// Dummy		
				NMLTournament.cardIndices.PushBack(1); 		//Horn	
				NMLTournament.cardIndices.PushBack(403);	// [ 10 ] Leshen HERO
				NMLTournament.cardIndices.PushBack(477);	// [ 6 ] Whispess ^
			}

			NMLTournament.cardIndices.PushBack(402);	// [ 10 ] Imlerith HERO
			NMLTournament.cardIndices.PushBack(407);	// [ 6 ] Earth Elem
			NMLTournament.cardIndices.PushBack(450);	// [ 6 ] Behemoth  Summon 4x
			NMLTournament.cardIndices.PushBack(451);	// [ 4 ] Arachas ^
			NMLTournament.cardIndices.PushBack(452);	// [ 4 ] Arachas ^
			NMLTournament.cardIndices.PushBack(460);	// [ 4 ] Ekkima Summon 5x
			NMLTournament.cardIndices.PushBack(463);	// [ 4 ] Bruxa ^
			NMLTournament.cardIndices.PushBack(461);	// [ 4 ] Fleder ^
			NMLTournament.cardIndices.PushBack(462);	// [ 4 ] Garkain ^
			NMLTournament.cardIndices.PushBack(464);	// [ 4 ] Katakan ^
			NMLTournament.cardIndices.PushBack(475);	// [ 6 ] Brewess Summon 3x
			NMLTournament.cardIndices.PushBack(476);	// [ 6 ] Weavess ^
			
			// Autobalance
			NMLTournament.dynamicCardRequirements.PushBack(diff1);	
			NMLTournament.dynamicCards.PushBack(1);				// Horn
			NMLTournament.dynamicCardRequirements.PushBack(diff3);	
			NMLTournament.dynamicCards.PushBack(11); 				// [ 7 ] Triss HERO
			NMLTournament.dynamicCardRequirements.PushBack(diff4);	
			NMLTournament.dynamicCards.PushBack(12); 				// [ 2 ] Dangelion 2x Boost
			NMLTournament.dynamicCardRequirements.PushBack(diff4);	
			NMLTournament.dynamicCards.PushBack(2); 				// [ 15 ] Ciri HERO
			NMLTournament.dynamicCardRequirements.PushBack(diff6);	
			NMLTournament.dynamicCards.PushBack(15); 				// [ 7 ] Villen Scorch
			NMLTournament.dynamicCardRequirements.PushBack(diff7);	
			NMLTournament.dynamicCards.PushBack(14); 				// [ 5 ] Emiel 
			NMLTournament.dynamicCardRequirements.PushBack(diff8);	
			NMLTournament.dynamicCards.PushBack(13); 				// [ 5 ] Zoltan
			NMLTournament.dynamicCardRequirements.PushBack(diff10);	
			NMLTournament.dynamicCards.PushBack(7); 				// [ 15 ] Geralt
			NMLTournament.dynamicCardRequirements.PushBack(diff10);	
			NMLTournament.dynamicCards.PushBack(16); 				// [ 0 ] Avallach			
			
			NMLTournament.specialCard = 401; 	// [ 8 ] Kayran HERO
			NMLTournament.leaderIndex = 4004; 
			enemyDecks.PushBack(NMLTournament);
	}
	
	
	

	private function SetupAIDeckDefinitionsTournament3()
	{

		var ScoiaTournament2		: SDeckDefinition;		
		var NMLTournament2			: SDeckDefinition;

			//NMLTournament2.deckName = "NMLTournament2";
			ScoiaTournament2.cardIndices.PushBack(2); //Scorch	
			ScoiaTournament2.cardIndices.PushBack(2); //Scorch	
			ScoiaTournament2.cardIndices.PushBack(1); //Horn
			ScoiaTournament2.cardIndices.PushBack(2); //Scorch		
			ScoiaTournament2.cardIndices.PushBack(3); //Biting Frost
			ScoiaTournament2.cardIndices.PushBack(3); //Biting Frost
			ScoiaTournament2.cardIndices.PushBack(5); //Torrential Rain

 			if (difficulty == 1)
			{	
				ScoiaTournament2.cardIndices.PushBack(310); // 2 Toruviel
				ScoiaTournament2.cardIndices.PushBack(312); // 3 Ciaran
				ScoiaTournament2.cardIndices.PushBack(335); // 3 Dwarf
			}
			else
			{
				ScoiaTournament2.cardIndices.PushBack(301);	// 10 Eithné
				ScoiaTournament2.cardIndices.PushBack(302);	// 10 Isengrim Faoiltiarna 
				ScoiaTournament2.cardIndices.PushBack(366);	// 5 Hav'caaren Support ^
				ScoiaTournament2.cardIndices.PushBack(368);	// 8 Schirru				
			}
 
			ScoiaTournament2.cardIndices.PushBack(303);	// 10 ioveth HERO
			ScoiaTournament2.cardIndices.PushBack(305);	// 6 dennis
			ScoiaTournament2.cardIndices.PushBack(306);	// 10 milva
			ScoiaTournament2.cardIndices.PushBack(307);	// 6 ida
			ScoiaTournament2.cardIndices.PushBack(308);	// 6 filavandrel AGILE
			ScoiaTournament2.cardIndices.PushBack(309);	// 6 Yaevin AGILE
			ScoiaTournament2.cardIndices.PushBack(313);	// 6 barclay AGILE
			ScoiaTournament2.cardIndices.PushBack(320);	// 4 havekar support SUMMON CLONES
			ScoiaTournament2.cardIndices.PushBack(321);	// 4 havekar support ^
			ScoiaTournament2.cardIndices.PushBack(322);	// 4 havekar support ^	
			ScoiaTournament2.cardIndices.PushBack(365);	// 5 Hav'caaren Support 
			ScoiaTournament2.cardIndices.PushBack(367);	// 5 Hav'caaren Support ^
			
			// Autobalance
			ScoiaTournament2.dynamicCardRequirements.PushBack(diff1);
			ScoiaTournament2.dynamicCards.PushBack(15);
			ScoiaTournament2.dynamicCardRequirements.PushBack(diff2);
			ScoiaTournament2.dynamicCards.PushBack(12);
			ScoiaTournament2.dynamicCardRequirements.PushBack(diff6);
			ScoiaTournament2.dynamicCards.PushBack(300);
			ScoiaTournament2.dynamicCardRequirements.PushBack(diff8);
			ScoiaTournament2.dynamicCards.PushBack(11);
			ScoiaTournament2.dynamicCardRequirements.PushBack(diff8);
			ScoiaTournament2.dynamicCards.PushBack(14);
			ScoiaTournament2.dynamicCardRequirements.PushBack(diff10);
			ScoiaTournament2.dynamicCards.PushBack(7); // [ 15 ] Geralt of Rivia
			ScoiaTournament2.dynamicCardRequirements.PushBack(diff10);
			ScoiaTournament2.dynamicCards.PushBack(10);


			ScoiaTournament2.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			ScoiaTournament2.leaderIndex = 3004; 
			enemyDecks.PushBack(ScoiaTournament2);
			
			
			//NMLTournament2.deckName = "NMLTournament2";	
			NMLTournament2.cardIndices.PushBack(0); 		//Dummy
			NMLTournament2.cardIndices.PushBack(0); 		//Dummy
			NMLTournament2.cardIndices.PushBack(1); 		//Horn	
			NMLTournament2.cardIndices.PushBack(6);		//Clear Weather		
			NMLTournament2.cardIndices.PushBack(23);	//Skellige Storm	
			NMLTournament2.cardIndices.PushBack(23);	//Skellige Storm

 			if (difficulty == 1)
			{	
				NMLTournament2.cardIndices.PushBack(420);	// [ 4 ] Botchling
				NMLTournament2.cardIndices.PushBack(420);	// [ 2 ] Endrega
			}
			else
			{		
				NMLTournament2.cardIndices.PushBack(1); 		//Horn	
				NMLTournament2.cardIndices.PushBack(403);	// [ 10 ] Leshen HERO
				NMLTournament2.cardIndices.PushBack(477);	// [ 6 ] Whispess ^
				NMLTournament2.cardIndices.PushBack(16);	// [ 0 ] Avalla'ch
			}

			NMLTournament2.cardIndices.PushBack(402);	// [ 10 ] Imlerith HERO
			NMLTournament2.cardIndices.PushBack(407);	// [ 6 ] Earth Elem
			NMLTournament2.cardIndices.PushBack(450);	// [ 6 ] Behemoth  Summon 4x
			NMLTournament2.cardIndices.PushBack(451);	// [ 4 ] Arachas ^
			NMLTournament2.cardIndices.PushBack(452);	// [ 4 ] Arachas ^
			NMLTournament2.cardIndices.PushBack(460);	// [ 4 ] Ekkima Summon 5x
			NMLTournament2.cardIndices.PushBack(463);	// [ 4 ] Bruxa ^
			NMLTournament2.cardIndices.PushBack(461);	// [ 4 ] Fleder ^
			NMLTournament2.cardIndices.PushBack(462);	// [ 4 ] Garkain ^
			NMLTournament2.cardIndices.PushBack(464);	// [ 4 ] Katakan ^
			NMLTournament2.cardIndices.PushBack(475);	// [ 6 ] Brewess Summon 3x
			NMLTournament2.cardIndices.PushBack(476);	// [ 6 ] Weavess ^
			
			// Autobalance
			NMLTournament2.dynamicCardRequirements.PushBack(diff1);	
			NMLTournament2.dynamicCards.PushBack(1);				// Horn
			NMLTournament2.dynamicCardRequirements.PushBack(diff3);	
			NMLTournament2.dynamicCards.PushBack(11); 				// [ 7 ] Triss HERO
			NMLTournament2.dynamicCardRequirements.PushBack(diff4);	
			NMLTournament2.dynamicCards.PushBack(12); 				// [ 2 ] Dangelion 2x Boost
			NMLTournament2.dynamicCardRequirements.PushBack(diff4);	
			NMLTournament2.dynamicCards.PushBack(2); 				// [ 15 ] Ciri HERO
			NMLTournament2.dynamicCardRequirements.PushBack(diff6);	
			NMLTournament2.dynamicCards.PushBack(15); 				// [ 7 ] Villen Scorch
			NMLTournament2.dynamicCardRequirements.PushBack(diff10);	
			NMLTournament2.dynamicCards.PushBack(7); 				// [ 15 ] Geralt		
			
			NMLTournament2.specialCard = 401; 	// [ 8 ] Kayran HERO
			NMLTournament2.leaderIndex = 4004; 
			enemyDecks.PushBack(NMLTournament2);
	}

	private function SetupAIDeckDefinitionsTournament4()
	{
		var NKTournament2		: SDeckDefinition;
		var NilfTournament2		: SDeckDefinition;
		var SkelTournament2		: SDeckDefinition;
		
	
			//NKTournament.deckName = "NKTournament";	
			NKTournament2.cardIndices.PushBack(2); //Scorch
			NKTournament2.cardIndices.PushBack(0); //Dummy
			NKTournament2.cardIndices.PushBack(1); //Horn	
			NKTournament2.cardIndices.PushBack(3); //Biting Frost	
			NKTournament2.cardIndices.PushBack(3); //Biting Frost
			NKTournament2.cardIndices.PushBack(4); //Impenetrable Fog

 			if (difficulty == 1)
			{	
				NKTournament2.cardIndices.PushBack(6); // Clear Sky
				NKTournament2.cardIndices.PushBack(108); // 2 Yarpen
				NKTournament2.cardIndices.PushBack(113); // 4 Sabrina
				NKTournament2.cardIndices.PushBack(114); // 4 Sheldon
			}
			else
			{
				NKTournament2.cardIndices.PushBack(2); //Scorch
				NKTournament2.cardIndices.PushBack(1); //Horn
				NKTournament2.cardIndices.PushBack(105); //Thaler [4] [SPY]
			}

			NKTournament2.cardIndices.PushBack(102);	// esterad [ 10 ][ HERO ][ MELEE ]
			NKTournament2.cardIndices.PushBack(103);	// philippa [ 10 ][ RANGED ][ HERO ]
			NKTournament2.cardIndices.PushBack(109);	// Sigismund Dijkstra  [4] [SPY]
			NKTournament2.cardIndices.PushBack(116); //Stennis [5] [SPY]
			NKTournament2.cardIndices.PushBack(120); //Trebuchet [6]
			NKTournament2.cardIndices.PushBack(140); //Catapult [5] [TightBond]
			NKTournament2.cardIndices.PushBack(141); //Catapult [5] [TightBond]
			NKTournament2.cardIndices.PushBack(145); //Ballista [6]
			NKTournament2.cardIndices.PushBack(160);	//Blue Stripes Commando [4] [TightBond]
			NKTournament2.cardIndices.PushBack(160); //Blue Stripes Commando [4] [TightBond]
			NKTournament2.cardIndices.PushBack(170); //Siege Tower [6]
			NKTournament2.cardIndices.PushBack(175);	// dun_banner_medic [ 0 ][ SIEGE ][ EFFECT_NURSE ]
			
			NKTournament2.dynamicCardRequirements.PushBack(diff2);	
			NKTournament2.dynamicCards.PushBack(13);				
			NKTournament2.dynamicCardRequirements.PushBack(diff5);	
			NKTournament2.dynamicCards.PushBack(151); 				// kaedweni_siege [ 1 ][ SIEGE ][ EFFECT_IMPROVE_NEIGHBOURS ]
			NKTournament2.dynamicCardRequirements.PushBack(diff6);	
			NKTournament2.dynamicCards.PushBack(12); 				// [ 2 ] Dangelion 2x Boost
			NKTournament2.dynamicCardRequirements.PushBack(diff8);	
			NKTournament2.dynamicCards.PushBack(11); 				// [ 7 ] Triss HERO
			NKTournament2.dynamicCardRequirements.PushBack(diff8);	
			NKTournament2.dynamicCards.PushBack(7); 				// [ 15 ] Geralt of Rivia
			NKTournament2.dynamicCardRequirements.PushBack(diff8);	
			NKTournament2.dynamicCards.PushBack(15); 				// [ 7 ] Villen Scorch 				
			NKTournament2.dynamicCardRequirements.PushBack(diff10);	
			NKTournament2.dynamicCards.PushBack(10);
			NKTournament2.dynamicCardRequirements.PushBack(diff10);	
			NKTournament2.dynamicCards.PushBack(9); 				// [ 7 ] Yennefer RESSURECT
			
			NKTournament2.specialCard = 16;	// Avallach [ 0 ][ EFFECT_DRAW_X2 ]
			NKTournament2.leaderIndex = 1004; 
			enemyDecks.PushBack(NKTournament2);

			
			//NilfTournament.deckName = "NilfTournament";
			NilfTournament2.cardIndices.PushBack(0); // Dummy
			NilfTournament2.cardIndices.PushBack(1); //Horn
			NilfTournament2.cardIndices.PushBack(2); //Scorch
			NilfTournament2.cardIndices.PushBack(2); //Scorch
			NilfTournament2.cardIndices.PushBack(6); //Clear Weather

 			if (difficulty == 1)
			{	
				NilfTournament2.cardIndices.PushBack(6); // Clear Sky
				NilfTournament2.cardIndices.PushBack(205); // 2 Albrich
				NilfTournament2.cardIndices.PushBack(209); // 3 Morstein
				NilfTournament2.cardIndices.PushBack(212); // 3 Rotten
			}
			else
			{
				NilfTournament2.cardIndices.PushBack(0); // Dummy
				NilfTournament2.cardIndices.PushBack(0); // Dummy
				NilfTournament2.cardIndices.PushBack(1); //Horn
				NilfTournament2.cardIndices.PushBack(218); //Vattier de Rideaux Vattier [1] [SPY]
				NilfTournament2.cardIndices.PushBack(200); //Letho of Gulet  [10] ***[HERO]***
				NilfTournament2.cardIndices.PushBack(230);//Archer Support [NURSE]
			}

			NilfTournament2.cardIndices.PushBack(201);//Menno Coehoorn 
			NilfTournament2.cardIndices.PushBack(202);//Morvran Voorhis
			NilfTournament2.cardIndices.PushBack(203); //Tibor Eggebracht [10] ***[HERO]***//Tibor Eggebracht
			NilfTournament2.cardIndices.PushBack(208); //Fringilla Vigo 
			NilfTournament2.cardIndices.PushBack(213); //Shilard Fitz-Oesterlen  [4] [SPY]
			NilfTournament2.cardIndices.PushBack(214); //Stefan Skellen  [1] [SPY]
			NilfTournament2.cardIndices.PushBack(231);//Archer Support [NURSE]
			NilfTournament2.cardIndices.PushBack(235);//Siege Support [NURSE]
			NilfTournament2.cardIndices.PushBack(236);//Black Infantry Archer
			NilfTournament2.cardIndices.PushBack(240);//Heavy Zerri
			NilfTournament2.cardIndices.PushBack(241);//Zerri
			NilfTournament2.cardIndices.PushBack(260);//Young Emissary
			NilfTournament2.cardIndices.PushBack(261);//Young Emissary

			// Autobalance
			NilfTournament2.dynamicCardRequirements.PushBack(diff1);
			NilfTournament2.dynamicCards.PushBack(15);
			NilfTournament2.dynamicCardRequirements.PushBack(diff4);
			NilfTournament2.dynamicCards.PushBack(16);
			NilfTournament2.dynamicCardRequirements.PushBack(diff4);
			NilfTournament2.dynamicCards.PushBack(12);
			NilfTournament2.dynamicCardRequirements.PushBack(diff6);
			NilfTournament2.dynamicCards.PushBack(248);
			NilfTournament2.dynamicCardRequirements.PushBack(diff6);
			NilfTournament2.dynamicCards.PushBack(11);
			NilfTournament2.dynamicCardRequirements.PushBack(diff8);
			NilfTournament2.dynamicCards.PushBack(7); // [ 15 ] Geralt of Rivia
			NilfTournament2.dynamicCardRequirements.PushBack(diff10);
			NilfTournament2.dynamicCards.PushBack(9);
			NilfTournament2.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			NilfTournament2.leaderIndex = 2004;
			enemyDecks.PushBack(NilfTournament2);
			
			

			//SkelTournament2.deckName = "SkelTournament2";
			SkelTournament2.cardIndices.PushBack(3); //Frost
			SkelTournament2.cardIndices.PushBack(1); //Horn
			SkelTournament2.cardIndices.PushBack(1); //Horn
			SkelTournament2.cardIndices.PushBack(2); //Scorch	
			SkelTournament2.cardIndices.PushBack(2); //Scorch	
			SkelTournament2.cardIndices.PushBack(0); //Dummy	

 			if (difficulty == 1)
			{
				SkelTournament2.cardIndices.PushBack(4); //Fog
			}
			else
			{
				SkelTournament2.cardIndices.PushBack(10); //Ciri
				SkelTournament2.cardIndices.PushBack(7);  //Geralt
				SkelTournament2.cardIndices.PushBack(17);	// Olgierd
				SkelTournament2.cardIndices.PushBack(504); // Draig Bon-Dhu
				SkelTournament2.cardIndices.PushBack(509);	// Birna
			}
			
			SkelTournament2.cardIndices.PushBack(9);	// Yennefer
			SkelTournament2.cardIndices.PushBack(15); //Villentretenmerth  [7] 
			SkelTournament2.cardIndices.PushBack(16); //Avallac'hh  [SPY]
			SkelTournament2.cardIndices.PushBack(12); //Dandelion
			SkelTournament2.cardIndices.PushBack(502);	// Cerys
			SkelTournament2.cardIndices.PushBack(513);	// Berserker
			SkelTournament2.cardIndices.PushBack(515);	// Young Berserker
			SkelTournament2.cardIndices.PushBack(515);	// Young Berserker
			SkelTournament2.cardIndices.PushBack(515);	// Young Berserker
			SkelTournament2.cardIndices.PushBack(520);	// Light Drakkar
			SkelTournament2.cardIndices.PushBack(520);	// Light Drakkar
			SkelTournament2.cardIndices.PushBack(520);	// Light Drakkar
			SkelTournament2.cardIndices.PushBack(521);	// War Drakkar
			SkelTournament2.cardIndices.PushBack(521);	// War Drakkar
			SkelTournament2.cardIndices.PushBack(521);	// War Drakkar
			SkelTournament2.cardIndices.PushBack(523);	// ShieldMaiden
			SkelTournament2.cardIndices.PushBack(523);	// ShieldMaiden
			SkelTournament2.cardIndices.PushBack(523);	// ShieldMaiden

			SkelTournament2.specialCard = -1; // Change this to a card ID to always have it be in the AI's hand when drawing cards
			SkelTournament2.leaderIndex = 5002;
			enemyDecks.PushBack(SkelTournament2);
		
	}




	public function GwentLeadersNametoInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_foltest_bronze':		return 1002; 
			case 'gwint_card_foltest_silver':		return 1003; 
			case 'gwint_card_foltest_gold':			return 1004; 
			case 'gwint_card_foltest_platinium':	return 1005;
 
			case 'gwint_card_emhyr_bronze':			return 2002; 
			case 'gwint_card_emhyr_silver':			return 2003; 
			case 'gwint_card_emhyr_gold':			return 2004; 
			case 'gwint_card_emhyr_platinium':		return 2005;
 
			case 'gwint_card_francesca_bronze':		return 3002; 
			case 'gwint_card_francesca_silver':		return 3003; 
			case 'gwint_card_francesca_gold':		return 3004;
			case 'gwint_card_francesca_platinium':	return 3005;
				
			case 'gwint_card_eredin_bronze':		return 4002; 
			case 'gwint_card_eredin_silver':		return 4003; 
			case 'gwint_card_eredin_gold':			return 4004; 
			case 'gwint_card_eredin_platinium':		return 4005; 
			
			case 'gwint_card_king_bran_bronze':		return 5001; 
			case 'gwint_card_king_bran_copper':		return 5002; 
			default: return	0;
		}
	}
	
	public function GwentNrkdNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_vernon':			return 100; 
			case 'gwint_card_natalis':			return 101; 
			case 'gwint_card_esterad':			return 102; 
			case 'gwint_card_philippa':			return 103; 
			case 'gwint_card_thaler':			return 105; 
			case 'gwint_card_dijkstra':			return 109; 
			case 'gwint_card_trebuchet':		return 121; 
			case 'gwint_card_siege_tower':		return 170; 
			case 'gwint_card_ballista':			return 146; 
			case 'gwint_card_siegfried':		return 107; 
			case 'gwint_card_blue_stripes':		return 160; 
			case 'gwint_card_blue_stripes2':	return 160; 
			case 'gwint_card_blue_stripes3':	return 160; 
			case 'gwint_card_crinfrid':			return 130; 
			case 'gwint_card_crinfrid2':		return 130; 
			case 'gwint_card_crinfrid3':		return 130; 
			case 'gwint_card_catapult':			return 140; 
			case 'gwint_card_catapult2':		return 140; 
			case 'gwint_card_stennis':			return 116; 
			case 'gwint_card_poor_infantry':	return 125;
			case 'gwint_card_poor_infantry2':	return 126;
			case 'gwint_card_poor_infantry3':	return 127;
 			case 'gwint_card_kaedwen':			return 150; 
			case 'gwint_card_kaedwen2':			return 151; 
			case 'gwint_card_dun_banner_medic':	return 175; 
			default: return 0;
		}
	}
	
	public function GwentNlfgNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_letho':				return 200; 
			case 'gwint_card_black_archer':			return 235;
			case 'gwint_card_black_archer2':		return 236;
			case 'gwint_card_menno':				return 201; 
			case 'gwint_card_moorvran':				return 202; 
			case 'gwint_card_tibor':				return 203; 
			case 'gwint_card_albrich':				return 205; 
			case 'gwint_card_combat_engineer':		return 255;	
			case 'gwint_card_assire':				return 206; 
			case 'gwint_card_fringilla':			return 208;	
			case 'gwint_card_cynthia':				return 207; 
			case 'gwint_card_morteisen':			return 209; 
			case 'gwint_card_rainfarn':				return 210; 
			case 'gwint_card_renuald':				return 211; 
			case 'gwint_card_rotten':				return 212; 
			case 'gwint_card_shilard':				return 213; 
			case 'gwint_card_sweers':				return 215; 
			case 'gwint_card_vanhemar':				return 217; 
			case 'gwint_card_vattier':				return 218; 
			case 'gwint_card_vreemde':				return 219; 
			case 'gwint_card_cahir':				return 220; 
			case 'gwint_card_puttkammer':			return 221; 
			case 'gwint_card_heavy_zerri':			return 240; 
			case 'gwint_card_zerri':				return 241; 
			case 'gwint_card_impera_brigade':		return 245;	
			case 'gwint_card_impera_brigade2':		return 245;	
			case 'gwint_card_impera_brigade3':		return 245;	
			case 'gwint_card_impera_brigade4':		return 245;	
			case 'gwint_card_archer_support':		return 230;	
			case 'gwint_card_archer_support2':		return 231;	
			case 'gwint_card_siege_support':		return 265;	
			case 'gwint_card_nausicaa':             return 250;	
			case 'gwint_card_nausicaa2':            return 250;	
			case 'gwint_card_nausicaa3':            return 250;	
			case 'gwint_card_stefan':				return 214; 
			case 'gwint_card_young_emissary':		return 260; 
			case 'gwint_card_young_emissary2':		return 261; 
			default: return 0;
			
		}
	}
	
	public function GwentSctlNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_eithne':				return 300;	
			case 'gwint_card_saskia':				return 301;	
			case 'gwint_card_isengrim':				return 302; 
			case 'gwint_card_iorveth':				return 303;	
			case 'gwint_card_milva':				return 306;	
			case 'gwint_card_dennis':				return 305;	
			case 'gwint_card_ida':					return 307;	
			case 'gwint_card_filavandrel':			return 308;	
			case 'gwint_card_yaevinn':				return 309;	
			case 'gwint_card_toruviel':				return 310;	
			case 'gwint_card_riordain':				return 311;	
			case 'gwint_card_ciaran':				return 312;	
			case 'gwint_card_barclay':				return 313;	
			case 'gwint_card_havekar_support':		return 320;	
			case 'gwint_card_havekar_support2':		return 321;	
			case 'gwint_card_havekar_support3':		return 322;	
			case 'gwint_card_vrihedd_brigade':		return 325;	
			case 'gwint_card_vrihedd_brigade2':		return 326;
			case 'gwint_card_dol_infantry':			return 330;	
			case 'gwint_card_dol_infantry2':		return 331;	
			case 'gwint_card_dol_infantry3':		return 332;	
			case 'gwint_card_dol_dwarf':			return 335;	
			case 'gwint_card_dol_dwarf2':			return 336;	
			case 'gwint_card_dol_dwarf3':			return 337;	
			case 'gwint_card_mahakam':				return 340;	
			case 'gwint_card_mahakam2':				return 341;	
			case 'gwint_card_mahakam3':				return 342;	
			case 'gwint_card_mahakam4':				return 343;	
			case 'gwint_card_mahakam5':				return 344;	
			case 'gwint_card_elf_skirmisher':		return 350;	
			case 'gwint_card_elf_skirmisher2':		return 351;	
			case 'gwint_card_elf_skirmisher3':		return 352;	
			case 'gwint_card_vrihedd_cadet':		return 355;	
			case 'gwint_card_dol_archer':			return 360;	
			case 'gwint_card_havekar_nurse':		return 365;	
			case 'gwint_card_havekar_nurse2':		return 366;	
			case 'gwint_card_havekar_nurse3':		return 367;
			case 'gwint_card_schirru':				return 368;	
			default: return 0;
		}
	}
	
	public function GwentMstrNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_draug':				return 400; 
			case 'gwint_card_kayran':				return 401; 
			case 'gwint_card_imlerith':				return 402; 
			case 'gwint_card_leshen':				return 403; 
			case 'gwint_card_forktail':				return 405; 
			case 'gwint_card_earth_elemental':		return 407; 
			case 'gwint_card_fiend':				return 410; 
			case 'gwint_card_plague_maiden':		return 413; 
			case 'gwint_card_griffin':				return 415; 
			case 'gwint_card_werewolf':				return 417; 
			case 'gwint_card_botchling':			return 420; 
			case 'gwint_card_frightener':			return 423; 
			case 'gwint_card_ice_giant':			return 425; 
			case 'gwint_card_endrega':				return 427; 
			case 'gwint_card_harpy':				return 430; 
			case 'gwint_card_cockatrice':			return 433; 
			case 'gwint_card_gargoyle':				return 435; 
			case 'gwint_card_celaeno_harpy':		return 437; 
			case 'gwint_card_grave_hag':			return 440;	
			case 'gwint_card_fire_elemental':		return 443;	
			case 'gwint_card_fogling':				return 445; 
			case 'gwint_card_wyvern':				return 447; 
			case 'gwint_card_arachas_behemoth':		return 450; 
			case 'gwint_card_arachas':				return 451; 
			case 'gwint_card_arachas2':				return 452; 
			case 'gwint_card_arachas3':				return 453; 
			case 'gwint_card_nekker':				return 455; 
			case 'gwint_card_nekker2':				return 456; 
			case 'gwint_card_nekker3':				return 457; 
			case 'gwint_card_ekkima':				return 460; 
			case 'gwint_card_fleder':				return 461; 
			case 'gwint_card_garkain':				return 462; 
			case 'gwint_card_bruxa':				return 463; 
			case 'gwint_card_katakan':				return 464; 
			case 'gwint_card_ghoul':				return 470; 
			case 'gwint_card_ghoul2':				return 471; 
			case 'gwint_card_ghoul3':				return 472; 
			case 'gwint_card_crone_brewess':		return 475;	
			case 'gwint_card_crone_weavess':		return 476;	
			case 'gwint_card_crone_whispess':		return 477;	
			case 'gwint_card_toad':					return 478;	
			default: return 0;
		}
	}

	public function GwentSkeNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_crach_an_craite':				return 500;
			case 'gwint_card_hjalmar':						return 501;
			case 'gwint_card_cerys':						return 502;
			case 'gwint_card_ermion':						return 503;
			case 'gwint_card_draig':						return 504;
			case 'gwint_card_holger_blackhand':				return 505;
			case 'gwint_card_madman_lugos':					return 506;
			case 'gwint_card_donar_an_hindar':				return 507;
			case 'gwint_card_udalryk':						return 508;
			case 'gwint_card_birna_bran':					return 509;
			case 'gwint_card_blueboy_lugos':				return 510;
			case 'gwint_card_svanrige':						return 511;
			case 'gwint_card_olaf':							return 512;
			case 'gwint_card_berserker':					return 513;
			case 'gwint_card_young_berserker':				return 515;
			case 'gwint_card_clan_an_craite_warrior':		return 517;
			case 'gwint_card_clan_tordarroch_armorsmith':	return 518;
			case 'gwint_card_clan_heymaey_skald':			return 519;
			case 'gwint_card_light_drakkar':				return 520;
			case 'gwint_card_war_drakkar':					return 521;
			case 'gwint_card_clan_brokvar_archer':			return 522;
			case 'gwint_card_clan_drummond_shieldmaiden':	return 523;
			case 'gwint_card_clan_drummond_shieldmaiden2':	return 526;
			case 'gwint_card_clan_drummond_shieldmaiden3':	return 527;
			case 'gwint_card_clan_dimun_pirate':			return 524;
			case 'gwint_card_cock':							return 525;
			default: return 0;
		}
	}
	
	public function GwentNeutralNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_geralt':				return 7 ; 	
			case 'gwint_card_vesemir':				return 8 ; 	
			case 'gwint_card_yennefer':				return 9 ; 	
			case 'gwint_card_ciri':					return 10; 	
			case 'gwint_card_triss':				return 11; 	
			case 'gwint_card_dandelion':			return 12;	
			case 'gwint_card_zoltan':				return 13; 	
			case 'gwint_card_emiel':				return 14; 	
			case 'gwint_card_villen':				return 15; 	
			case 'gwint_card_avallach':				return 16;
			case 'gwint_card_olgierd':				return 17;
			case 'gwint_card_mrmirror':				return 18;
			case 'gwint_card_mrmirror_foglet':		return 19;
			case 'gwint_card_cow':					return 20;
			case 'gwint_card_lady_of_the_lake':		return 24;
			case 'gwint_card_visenna':				return 25;
			default: return 0;
		}
	}
	
	public function GwentSpecialNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_dummy':				return 0 ; 
			case 'gwint_card_horn':					return 1 ; 
			case 'gwint_card_scorch':				return 2 ; 
			case 'gwint_card_frost':				return 3 ; 
			case 'gwint_card_fog':					return 4 ; 
			case 'gwint_card_rain':					return 5 ; 
			case 'gwint_card_clear_sky':			return 6 ;
			case 'gwint_card_mushroom':				return 22 ;
			case 'gwint_card_skellige_storm':		return 23 ;
			default: return 0;
		}
	}
}
