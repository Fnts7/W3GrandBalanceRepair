/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/
/*        The minigame is removed. I leave the code since there were some tricky things addresses here like paired animations
          with the use of items attached from NPC to npc, etc.
			REMOVED_DRINKING  - search for this string to find all commented out pieces of code

//	Possible minigame results
enum EMinigameDrinkingRoundResult
{
	EDMRR_Assert,						//something foobar happened - check the ASSERT channel. The minigame will break midgame
	EDMRR_NothingHappened,				//no one won this round
	EDMRR_PlayerWon,					//player won
	EDMRR_PlayerLostNoMoney,			//player lost due to lack of money
	EDMRR_PlayerLostDrunk				//player lost due to getting drunk like a log	
}

enum EGamePhases
{
	EGP_DealingCards,
	EGP_PlayingCards,
	EGP_Results,
	EGP_Drinking	
}

enum EDrinkingVesselType
{
	EDCT_Mug,
	EDCT_Cup,
	EDCT_Shot,	
	EDCT_Food	
}

enum EHolderType
{
	EHT_Opponent,
	EHT_Player,
	EHT_Operator
}


class W3DrinkingManager
{	
	public var oppAceCards,playerAceCards : array<W3DrinkingCard>;		//available (unused so far) ace cards
	private var nonDealtCards : array<W3DrinkingCard>;					//cards remaining in the deck (not dealt so far)
	private var deck : W3DrinkingDeck;									//all cards in the deck
	private var isInitialized : bool;									//set to true when the minigame is started, prevents multiple starts
	private var isOnTheHouse : bool;									//if true, player doesn't pay for the minigame ever
	private var round : int;											//round counter
	private var drinkingCost : int;										//total cost of the drinks
	private var playerLastRoundConsumableType, opponentLastRoundConsumableType : EDrinkingCardType;		//type of consumables from previous round(to decide about the multiplier increase)
	public  var playerMultiplier,oppMultiplier : int;					//drunkenness multipliers 
	private var tableCardsCount : int;									//amount of cards on the table
	public var cardsOnTheTable : array<W3DrinkingCard>;					//cards currently laying on the table. needed for deck shuffling
	private var bartender, opponent : CNewNPC;							//npc objects (needed for animations)
	private var isStoryMode : bool;										//in story mode player pays for all, otherwise pays for himself only
	private var barPos : Vector;										// initial position of a bartender (PROTOTYPE PLACEHOLDER)
	private var barRot : EulerAngles;									// initial rotation of a bartender (PROTOTYPE PLACEHOLDER)		
	private var opponentDisplayName : string;	
	public var isPlayerRound : bool;
	public var playedForPlayer : W3DrinkingCard;
	public var playedForOpponent : W3DrinkingCard;
	public var aiPlayedForPlayerIdx : int;
	public var aiPlayedForAiIdx : int;
	public var isPlayerAce	: bool;
	public var isOpponentAce : bool;
	public var oppDrunkenness : int;
	public var oppMaxDrunkenness : int;	
	public var minigamePhase : EGamePhases;
	public var banterArray : array< string >;
	private var lastBanterIndex : int;
	private var playerHandicap : float;
	private var finishGame : bool;
	private var finalResult : EMinigameDrinkingRoundResult;
	private var opponentVessel, playerVessel : CEntity;
	private var twoPairsBeforeThreeKind : bool;
	private var bSkipGame : bool; //#B
	
	default playerHandicap = 0.0f;		
	default isInitialized = false;
	default minigamePhase = EGP_DealingCards;
	default bSkipGame = false; //#B
			
	/ *
		Initializes the manager.
		
		@params
		oStartingDrunkenness - opponent drunkenness level at the start of the minigame,
		oMaxDrunkenness - opponent max drunkenness,
		oAces - array of opponent ace cards names
		onHouse - is the game on the house (player will never pay for it)
		deckName - name of the deck used
		playerStarts - is player starting the first round
		
		@returns
		true if initialized properly, false if there were some errors (check ASSERT logs)
	* /
	public function Initialize(bar, opp : CNewNPC, oStartingDrunkenness, oMaxDrunkenness : int, oAces : array<name>, onHouse : bool, deckName : name, playerStarts, story : bool) : bool
	{
		var i,j : int;
		var oppAceCardNames,playerAceCardNames : array<name>;
		var card : W3DrinkingCard;
		
		if(isInitialized)
		{
			LogAssert(false, "DrinkingManager.Initialize: trying to initialize already initialized DrinkingManager - aborting. Initialize can be called only once per object!");
			return false;
		}
		
		//npcs
		bartender = bar;
		opponent = opp;
		
		//the game itself
		round = 1;		
		GetGameDataFromXML();
		isOnTheHouse = onHouse;
		isPlayerRound = playerStarts;
		SetStatesOnMinigameStart();
		isStoryMode = story;
		
		//opponent data	
		opp.SetStatMax(BCS_Drunkenness, oMaxDrunkenness);
		opp.UpdateStatMax(BCS_Drunkenness);
		opp.GainStat(BCS_Drunkenness, oStartingDrunkenness);
		oppAceCardNames = oAces;		
		oppAceCards = GetCardsDataFromXML(oppAceCardNames);
		opponentLastRoundConsumableType = EDCT_Undefined;		
		oppMultiplier = 1;
		oppDrunkenness = oStartingDrunkenness;
		oppMaxDrunkenness = oMaxDrunkenness;
		
		//player data
		playerAceCardNames = ((W3PlayerWitcher)thePlayer).GetDrinkingAceCards();
		playerAceCards = GetCardsDataFromXML(playerAceCardNames);
		playerLastRoundConsumableType = EDCT_Undefined;
		playerMultiplier = 1;
		
		//deck
		GetDeckDataFromXML(deckName, deck);
						
		//non-dealt cards
		if(deck.cards.Size() < tableCardsCount)
		{
			LogAssert(false, "DrinkingManager.Initialize: Drinking cards deck must have at least "+tableCardsCount+" cards");
			return false;
		}
		nonDealtCards = GetCardsDataFromXML(deck.cards);
		//money
		drinkingCost = 0;
		
		//starting round belong to player or not
		isInitialized = true;
		
		opponent.PauseDrunkennessDecay();
		thePlayer.PauseDrunkennessDecay();
		theUI().OpenMinigameDrinking();
		LogChannel( 'DrinkingManager', "Switching to Drinking Minigame GUI" );
			
		return true;
	}
	
	public latent function PlayDrinkingGame( player : CStoryScenePlayer, optional roundCounter : int, optional playerWins : bool ) : bool
	{
		finishGame = false;
		
		player.ActivateSceneCamera( 'minigame_setting' );
		((CActor)opponent).SignalGameplayEvent( 'StartDrinkingMinigame' );
		//Sleep( 1.f );
		//theGame.FadeOut( 0.5f );
		//theGame.FadeOutAsync( 0.5f );
		theGame.FadeIn( 1.0f );
		//theGame.FadeInAsync( 0.5f );
		
		while( !finishGame )
		{
			SetMinigamePhase( EGP_DealingCards );
			
			// PHASE 1 - New round
			if( theUI().tempDrinkingGame )
			{
				Sleep( 1.0f );
				theUI().tempDrinkingGame.NewRound();
			}
			while( minigamePhase == EGP_DealingCards )
			{
				Sleep( 0.5f );
			}	
			Sleep( 0.5f );
			// PHASE 2 - Choosing Cards
			if( theUI().tempDrinkingGame )
			{
				if( GetIsPlayerRound() ) // PLAYER ROUND
				{
					theUI().tempDrinkingGame.PlayerMoveForOpp();				
					while( minigamePhase == EGP_PlayingCards ) 
					{
						Sleep(0.5f );
						if(bSkipGame)
						{
							return true; // auto win
						}
					}
				}
				else	// AI ROUND
				{
					if( theUI().tempDrinkingGame )
					{
						theUI().tempDrinkingGame.OpponentMove();
						while( minigamePhase == EGP_PlayingCards )
						{
							Sleep(0.5f );
							//PlayBanters();
						}
					}
				}
			}
			// PHASE 3 - Round Summary
			if( theUI().tempDrinkingGame )
			{
				theUI().tempDrinkingGame.RoundSummary();
				while( minigamePhase == EGP_Results )
				{
					Sleep(0.5f );
				}
				if(bSkipGame)
				{
					continue;
				}
				finalResult = theUI().tempDrinkingGame.roundResult;
			}
			Sleep( 0.5f );
		
			// PHASE 4 - Drinking
			if( theUI().tempDrinkingGame )
			{
				theUI().tempDrinkingGame.StartDrinking();
				
				// DRINKING SEQUENCE
				StartDrinkingSequence( player );				
			}
			
			// PHASE 5 - Updating Game Data	
			theUI().tempDrinkingGame.UpdateGameData();		
			
			switch( finalResult )
			{
				case EDMRR_NothingHappened :
				{
					break;
				}
				case EDMRR_Assert :
				{
					LogChannel('',"");
				}
				case EDMRR_PlayerWon :
				case EDMRR_PlayerLostNoMoney :
				case EDMRR_PlayerLostDrunk :
				{
					finishGame = true;
					break;
				}
			}

			if( roundCounter > 0 )
			{
				if( GetRound() == roundCounter )	{		finishGame = true;	}
			}
			isPlayerRound = GetIsPlayerRound();
			SetIsPlayerRound( !GetIsPlayerRound() );
			round += 1;
		}
		LogChannel( 'Minigame Drinking', "finishGame = " + finishGame );
		
		if( finishGame )
		{
			theGame.FadeOutAsync( 1.f );
			Sleep( 1.0f );
			return EndMinigame(roundCounter,playerWins);
		}
	}
	
		
	public function GetRound() : int {return round;}
	public function GetOpponentMultiplier() : int {return oppMultiplier;}
	public function GetPlayerMultiplier() : int {return playerMultiplier;}
	public function GetOpponentDrunkenness() : float {return opponent.target.GetStat(BCS_Drunkenness);}
	public function GetOpponentMaxDrunkenness() : float {return opponent.target.GetStatMax(BCS_Drunkenness);}
	public function GetOpponentName() : string {return opponent.GetName();}
	public function GetTabTotal() : int 		{ return drinkingCost; }
	public function GetIsPlayerRound() : bool 		{ return isPlayerRound; }
	public function SetIsPlayerRound( isOn : bool )	{ isPlayerRound = isOn; }	
	public function GetDrinkingCost() : int 		{ return drinkingCost; }
	public function SetDrinkingCost( value : int )	{ drinkingCost = value; }
	public function GetOpponentDisplayName() : string 		{ return opponentDisplayName; }
	public function SetOpponentDisplayName( value : string )	{ opponentDisplayName = value; }
	public function GetBanterArray() : array< string > 		{ return banterArray; }
	public function SetBanterArray( value : array< string > )	{ banterArray = value; }
	public function SetMinigamePhase( phase : EGamePhases ) 	{ minigamePhase = phase; }
	
	public function EndMinigame(optional roundCounter : int, optional playerWins : bool) : bool
	{
		//Clearing up behaviors
		CleanUp();
		((CActor)bartender).SignalGameplayEvent( 'StopDrinkingMinigame' );
		((CActor)opponent).SignalGameplayEvent( 'StopDrinkingMinigame' );
		bSkipGame = true;
		// wrap up and exit minigame
		theUI().DestroyHackDrinkingPanel();
			
		if( roundCounter > 0 )
		{
			if( playerWins )	
			{		
				return true;		
			}	
			else
			{		
				return false;		
			}	
		}
		else
		{			
			// game results
			switch(finalResult)
			{
				case EDMRR_Assert:
				case EDMRR_PlayerWon:
					return true;
				case EDMRR_PlayerLostNoMoney:
					FactsAdd( "drinking_lost_no_money", 1 );
				case EDMRR_PlayerLostDrunk:
					return false;
			}
		}	
	}
	
	
	public function FillTableCards()
	{
		var i : int;
	
		if( RandRange( 2 ) == 0 ) 	twoPairsBeforeThreeKind = false;
		if( RandRange( 2 ) == 1 ) 	twoPairsBeforeThreeKind = true;
		LogChannel('MinigameDrinking', "twoPairsBeforeThreeKind =  " +twoPairsBeforeThreeKind ); 
		
		for(i=cardsOnTheTable.Size(); i<tableCardsCount; i+=1)
		{
			DealNewCard();
		}
	}
	
	public function PlayBanters()
	{
		var banter : string;
		var playBanter : bool;
		var rand : int;
		
		if( RandRange( 20 ) == 0 )		{	playBanter = true; LogChannel('MinigameDrinking', "RandRange(20) =  0" );  	}
		else						{	playBanter = false;	}
		
		if( playBanter )
		{
			rand = RandRange( 6 );
			
			if( rand == lastBanterIndex )
			{
				rand = lastBanterIndex+1;
				
				if( rand > 5 )		{	rand = 0;	}
			}
			lastBanterIndex = rand;
			
			switch( rand )
			{
				case 0 : 
				{
					banter = "insult_one";
					break;
				}
				case 1 : 
				{
					banter = "insult_two";
					break;
				}
				case 2 : 
				{
					banter = "insult_three";
					break;
				}
				case 3 : 
				{
					banter = "banter_one";
					break;
				}
				case 4 : 
				{
					banter = "banter_two";
					break;
				}
				case 5 : 
				{
					banter = "banter_three";
					break;
				}
				/ * 				
				banter = "banter_" +IntToString( rand+1 );
				* /
			}
			opponent.PlayVoiceset( 100, banter );
		}	
	}
	
	public function SetAcePlayed( idx : int, isForPlayer : bool ) : void
	{
		if( isForPlayer ) 	{ playedForPlayer = playerAceCards[idx]; isPlayerAce = true; }
		else				{ playedForOpponent = playerAceCards[idx]; isOpponentAce = true; }
	}
	
	public function SetCardPlayed( idx : int, isForPlayer : bool ) : void
	{
		if( isForPlayer )
		{
			playedForPlayer = cardsOnTheTable[idx];
			LogChannel('Minigame Drinking AI'," SetCardPlayed playedForPlayer card "+playedForPlayer.cardName);
		}
		else
		{
			playedForOpponent = cardsOnTheTable[idx];
			LogChannel('Minigame Drinking AI',"SetCardPlayed playedForOpponent card "+playedForOpponent.cardName);
		}
	}
	
	/ **
		Returns remaining available (not used) player ace cards
	* /
	public function GetPlayerAvailableAceCards() : array<W3DrinkingCard> {return playerAceCards;}
	
	//for debug only
	public function GetOpponentAvailableAceCards() : array<W3DrinkingCard> {return oppAceCards;}
		
		/ **
		Deals new cards on the table. Use when player has no move to make (but NOT due to lack of money).
		
		@returns
		array of cards picked
	* /
	public function NoMovesDealNewCards() : array<W3DrinkingCard>
	{
		var i : int;
		var cards : array<W3DrinkingCard>;
		
		if( RandRange( 2 ) == 0 ) 	{ twoPairsBeforeThreeKind = false; }
		if( RandRange( 2 ) == 1 ) 	{ twoPairsBeforeThreeKind = true; }
		LogChannel('MinigameDrinking', "twoPairsBeforeThreeKind =  " +twoPairsBeforeThreeKind ); 
	
		cardsOnTheTable.Clear();
		for(i=0; i<tableCardsCount; i+=1)
			cards.PushBack(DealNewCard());
			
		return cards;
	}
		
	/ **
		Returns cards for the new round.
	* /
	public function DealNewCard() : W3DrinkingCard
	{
		var i,rnd,x : int;
		var rndF : float;
		var pickedCard : W3DrinkingCard;
		var shouldReDraw : bool;
		
		//for( i=1; i>0; i+=1 )
		for( i=0; i<50; i+=1 )
		{
			LogChannel('MinigameDrinking', "Dealing new card" );
			
			if(cardsOnTheTable.Size() == tableCardsCount)
				return pickedCard;			//as in: return NULL
				
			//shuffle the deck
			if(nonDealtCards.Size() == 0)
			{
				nonDealtCards = GetCardsDataFromXML(deck.cards);
				
				//but not those on the table at the moment
				for(i=0; i<cardsOnTheTable.Size(); i+=1)
				{
					nonDealtCards.Remove(cardsOnTheTable[i]);
				}
			}
			
			rnd = RandRange(nonDealtCards.Size());
			pickedCard = nonDealtCards[rnd];
			LogChannel( 'MinigameDrinking', "pickedCard name = " +pickedCard.cardName );			
			LogChannel( 'MinigameDrinking', "pickedCard quality = " +pickedCard.quality );			
			
			// check dealing conditions
			if( CheckDealingConditions( pickedCard, twoPairsBeforeThreeKind ) )
			{
				LogChannel( 'MinigameDrinking', "Found card meeting set conditions - adding to table" );
				break;
			}
			else
			{
				LogChannel( 'MinigameDrinking', "Card doesn't meet set conditions - dealing new one" );
				continue;
			}			
		}
		
		nonDealtCards.Erase(rnd);	
		
		//save card on the table
		cardsOnTheTable.PushBack(pickedCard);		
			
		LogChannel('MinigameDrinking', "Dealt new card: <<"+pickedCard.cardName+">>");
		LogChannel('MinigameDrinking', "Cards on the table size = " +cardsOnTheTable.Size() );
				
		return pickedCard;
	}
	
	public function CheckDealingConditions( pickedCard : W3DrinkingCard, goForTwoPairs : bool ) : bool
	{
		var i : int;
		var noDoubleFoodCards: bool;
		var noLessThreeChoices : bool;
		var twoPairsAvailable : bool;
		var largestQualityCount, mostDrawnQuality, pairsFound : int;
		var rand : int;
		
		// Dealing Conditions
		
		// 1) no more than 1 appetizer card		
		if( pickedCard.type == EDCT_Food )
		{
			for( i=0; i<cardsOnTheTable.Size(); i+=1 )
			{
				if( cardsOnTheTable[i].type == EDCT_Food )	{ 	noDoubleFoodCards = false; 	}
				else 										{	noDoubleFoodCards = true;	}				
			}	
			LogChannel('MinigameDrinking', "NO DOUBLE FOOD CONDITION, noDoubleFoodCards = " +noDoubleFoodCards );	
		}
		else	{	noDoubleFoodCards = true; LogChannel('MinigameDrinking', "No Food card, carry on!" );	}
		
		// 2)  if no 3 same cost selected, there should be 2 pairs
		if( twoPairsBeforeThreeKind )
		{			
			GetCardsQualityCountByRank( pickedCard, 1, largestQualityCount, mostDrawnQuality, pairsFound );
			
			if( cardsOnTheTable.Size() == 1 ) // making sure we have first pair in place (1 on table + picked)
			{
				if( pairsFound == 1 )	{	twoPairsAvailable = true; 	LogChannel('MinigameDrinking', "We have first pair" );	}
				else					{	twoPairsAvailable = false;	LogChannel('MinigameDrinking', "First pair not set" );	}
			}
			else if( cardsOnTheTable.Size() == 3 ) // if we have at least one pair, look for second pair (3 on table + picked) 
			{
				if( pairsFound == 2 )	{	twoPairsAvailable = true; LogChannel('MinigameDrinking', "We have two pairs - as requested" );	}
				else					{	twoPairsAvailable = false;	}				
			}
			else
				twoPairsAvailable = true;
				
			LogChannel('MinigameDrinking', "TWO PAIRS CONDITION, twoPairsAvailable = " +twoPairsAvailable );	
		}
		else
		{	// 3) no less than 3 same cost cards / consider only when at least 3 cards are already dealt	
			if( cardsOnTheTable.Size() >= 3 )
			{
				GetCardsQualityCountByRank( pickedCard, 1, largestQualityCount, mostDrawnQuality, pairsFound );
				
				if( largestQualityCount >= 3 )	{	noLessThreeChoices = true;	} 
				else
				{
					if( pickedCard.quality == mostDrawnQuality )	{	noLessThreeChoices = true;	} 
					else											{	noLessThreeChoices = false;		} 
				}
			}
			else
			{
				noLessThreeChoices = true; 
				LogChannel('MinigameDrinking', "Less than 3 cards on the table, carry on!" );
			}
			LogChannel('MinigameDrinking', "NO LESS THAN THREE CHOICES CONDITION, noLessThreeChoices = " +noLessThreeChoices );		
		}		
		if( twoPairsBeforeThreeKind )	return noDoubleFoodCards && twoPairsAvailable;
		else							return noDoubleFoodCards && noLessThreeChoices;
	}
	
	// returns quantity ( requestedQualityCount ) of cards of a given quality count rank ( 1 = highiest count, 2 = second highest, 3 = third place )
	// if there are any 2 pairs, returns requestedQualityCount = -1;
	// returns most numerous quantity ( requestedQuality )
	// returns info about found pairs
	private function GetCardsQualityCountByRank( pickedCard : W3DrinkingCard, rank : int, out requestedQualityCount : int, out requestedQuality : int, out pairsFound : int )  
	{
		var qualityLowCount, qualityMediumCount, qualityHighCount : int = 0;
		var i, minIndex, maxIndex : int;
		var pool : array< int >;
		var counters : array< int >;
		
		for( i=0; i< cardsOnTheTable.Size(); i+=1 )
		{
			if( cardsOnTheTable[i].quality == 0 )		{	qualityLowCount += 1;		}
			if( cardsOnTheTable[i].quality == 1 )		{	qualityMediumCount += 1;	}
			if( cardsOnTheTable[i].quality == 2 )		{	qualityHighCount += 1;		}
		}
		
		if( pickedCard.quality == 0 )		{	qualityLowCount += 1;		}
		if( pickedCard.quality == 1 )		{	qualityMediumCount += 1;	}
		if( pickedCard.quality == 2 )		{	qualityHighCount += 1;		}
		
		LogChannel('MinigameDrinking', "qualityLowCount = " 	+qualityLowCount );
		LogChannel('MinigameDrinking', "qualityMediumCount = " 	+qualityMediumCount );
		LogChannel('MinigameDrinking', "qualityHighCount = " 	+qualityHighCount );
		
		counters.PushBack( qualityLowCount );
		counters.PushBack( qualityMediumCount );
		counters.PushBack( qualityHighCount );
		
		//check for pairs
		if( (counters[0] == counters[1]) || (counters[0] == counters[2]) || (counters[1] == counters[2]) )	
		{
			if( counters[0] == 2 || counters[1] == 2 || counters[2] == 2 )
			{
				pairsFound = 1;
				LogChannel('MinigameDrinking', "1 pair found, returning "+pairsFound );
			}
			else if ( (counters[0] == 2 && counters[1] == 2) || (counters[0] == 2 && counters[2] == 2) || (counters[1] == 2 && counters[2] == 2) )
			{
				pairsFound = 2;
				LogChannel('MinigameDrinking', "2 pairs found, returning " +pairsFound );				
			}
			else
			{
				pairsFound = 0;
				LogChannel('MinigameDrinking', "NO pairs found, returning " +pairsFound );
			}			
		}
		
		//get count for most same quantity cards
		LogChannel('MinigameDrinking', "requested rank = " +rank );
		if( rank == 1 )
		{
			maxIndex = ArrayFindMaxInt( counters );
			requestedQuality = maxIndex;
			requestedQualityCount = counters[ maxIndex ];
		}
		else if( rank == 2 )
		{
			if( counters.Size() <= 2 )	
			{	
				minIndex = ArrayFindMinIndexInt( counters );
				requestedQuality = minIndex;
				requestedQualityCount = counters[ minIndex ];				
			}	
			else
			{
				minIndex = ArrayFindMinIndexInt( counters );
				maxIndex = ArrayFindMinIndexInt( counters );
				
				for( i=0; i<counters.Size(); i+=0 )
				{
					if( i!= minIndex && i!= maxIndex )
					{
						requestedQualityCount = counters[i];
						requestedQuality = i;
						break;
					}					
				}
			}			
		}
		else if( rank == 3 )
		{
			minIndex = ArrayFindMinIndexInt( counters );
			requestedQuality = minIndex;
			requestedQualityCount = counters[ minIndex ];
		}
		LogChannel('MinigameDrinking', "requestedQuality = " +requestedQuality );		
		LogChannel('MinigameDrinking', "requestedQualityCount = " 	+requestedQualityCount );
	}
	
	public function IsItemAlcohol(type : EDrinkingCardType) : bool
	{
		return (type != EDCT_Food && type != EDCT_Undefined);
	}
	
	private function GetAlcoholStrengthDifference(old, nw : EDrinkingCardType) : int
	{
		var alcoholStrength, as : int;
		switch(old)
		{
			case EDCT_Beer:
				alcoholStrength = 1;
				break;
			case EDCT_Wine :
			case EDCT_Mead : 
				alcoholStrength = 2;
				break;
			case EDCT_Vodka :
			case EDCT_Spirit :
				alcoholStrength = 3;
				break;				
		}
		switch(nw)
		{
			case EDCT_Beer:
				as = 1;
				break;
			case EDCT_Wine :
			case EDCT_Mead : 
				as = 2;
				break;
			case EDCT_Vodka :
			case EDCT_Spirit :
				as = 3;
				break;				
		}
		
		return as-alcoholStrength;
	}
		
	/ **
		Handles new round after the cards were chosen
		
		@params
		playerCard - card chosen for the player,
		oppCard - card chosen for the opponent,
		isPlayerCardAce - is the card assigned to player an ace
		isOppCardAce - is the card assigned to opponent an ace
		isPlayerTurn - is it the player's turn
		
		@returns
		EMinigameDrinkingRoundResult - result of this round
	* /
	private function ProcessNextRound(playerCard, oppCard : W3DrinkingCard, isPlayerCardAce, isOppCardAce, isPlayerTurn : bool) : EMinigameDrinkingRoundResult
	{
		var alcoholStrengthDifference : int;
		
		//advance round counter
		
		LogChannel('MinigameDrinking', "Processing round "+round+" (isPlayer="+isPlayerTurn+"). Using <<"+playerCard.cardName+">> for the player and <<"+oppCard.cardName+">> for the AI");
		
		//PLAYER
		if(playerCard.type == EDCT_Food)
			playerMultiplier = Max(1, playerMultiplier - playerCard.value);
		
		if(IsItemAlcohol(playerCard.type))
		{			
			//add drunkenness
			LogChannel('MinigameDrinking', "Increasing player drunkenness from "+thePlayer.target.GetStat(BCS_Drunkenness)+"/"+GetPlayerDrunknessMaxLevel()+" by "+playerMultiplier * playerCard.value);
			thePlayer.GainStat(BCS_Drunkenness,playerMultiplier * playerCard.value);	
			thePlayer.PauseDrunkennessDecay();
			
			if( IsItemAlcohol(playerLastRoundConsumableType) )
			{
				alcoholStrengthDifference = GetAlcoholStrengthDifference(playerLastRoundConsumableType, playerCard.type );
				//add multiplier
				if(alcoholStrengthDifference > 0)
					playerMultiplier += alcoholStrengthDifference;
				else if(alcoholStrengthDifference < 0)
					playerMultiplier += 2*(-alcoholStrengthDifference);
			}
		}
		
		playerLastRoundConsumableType = playerCard.type;
		
		//OPPONNENT
		if(oppCard.type == EDCT_Food)
			oppMultiplier = Max(1, oppMultiplier - oppCard.value);
		
		if(IsItemAlcohol(oppCard.type))
		{			
			//add drunkenness
			LogChannel('MinigameDrinking', "Increasing opponent drunkenness from "+opponent.target.GetStat(BCS_Drunkenness)+"/"+opponent.target.GetStatMax(BCS_Drunkenness)+" by "+oppMultiplier * oppCard.value);
			opponent.GainStat(BCS_Drunkenness,oppMultiplier * oppCard.value);		
			opponent.PauseDrunkennessDecay();	
			
			if( IsItemAlcohol(opponentLastRoundConsumableType) )
			{
				alcoholStrengthDifference = GetAlcoholStrengthDifference(opponentLastRoundConsumableType, oppCard.type );
				//add multiplier
				if(alcoholStrengthDifference > 0)
					oppMultiplier += alcoholStrengthDifference;
				else if(alcoholStrengthDifference < 0)
					oppMultiplier += 2*(-alcoholStrengthDifference);
			}
		}
		
		opponentLastRoundConsumableType = oppCard.type;
		
		//remove aces
		if(isPlayerCardAce)
		{
			if(isPlayerTurn)
				playerAceCards.Remove(playerCard);
			else
				oppAceCards.Remove(playerCard);
		}
		if(isOppCardAce)
		{
			if(isPlayerTurn)
				playerAceCards.Remove(oppCard);
			else
				oppAceCards.Remove(oppCard);
		}
		
		//add cost
		if(isStoryMode)
			drinkingCost += playerCard.price + oppCard.price;
				
		//check drunkenness
		if(thePlayer.GetDrunkennessStage() == EDS_Wasted)
		{
			if(!isOnTheHouse)
				thePlayer.RemoveMoney(drinkingCost);
			return EDMRR_PlayerLostDrunk;
		}
		if(opponent.GetDrunkennessStage() == EDS_Wasted)
			return EDMRR_PlayerWon;
		
		//check gold
		if(!isOnTheHouse)
		{
			if( 
				(isStoryMode && (thePlayer.GetMoney() < drinkingCost)) ||
				(!isStoryMode && isPlayerTurn && (thePlayer.GetMoney() < (playerCard.price + oppCard.price)))
			  )
			{
				thePlayer.RemoveMoney(drinkingCost);
				return EDMRR_PlayerLostNoMoney;
			}
		}
		
		//update drawn cards
		if(!isPlayerCardAce)
			cardsOnTheTable.Remove(playerCard);
		if(!isOppCardAce)
			cardsOnTheTable.Remove(oppCard);
		
		return EDMRR_NothingHappened;
	}
	
	/ **
		Processes next round with player being the one dealing cards this round
		
		@params
		playerCard - card chosen for the player,
		oppCard - card chosen for the opponent,
		isPlayerCardAce - is the card assigned to player an ace
		isOppCardAce - is the card assigned to opponent an ace
		
		@returns
		EMinigameDrinkingRoundResult - result of this round
	* /
	public function ProcessNextRoundPlayer(playerCard, oppCard : W3DrinkingCard, isPlayerCardAce, isOppCardAce : bool) : EMinigameDrinkingRoundResult
	{
		return ProcessNextRound(playerCard,oppCard,isPlayerCardAce,isOppCardAce,true);
	}
	
	/ **
		Function gets the AI to make a choice of his move in the given situation.
		
		@params
		forOpCards - cards available to be played on the opponent
		forPlayerCards - cards available to be played on the player
		isDefensive - is AI defensive. Defensive minimizes it's own drunkenness first, offensive maximizes player'd drunkenness first
		opChosenCard - card chosen by the AI for itself
		isOpCardAce - is the card chosen for the AI an ace
		playerChosenCard - card chosen by the AI for the player
		isPlayerCardAce - is the card chosen for the player an ace
	* /
	private function GetAIChoice(forOpCards, forPlayerCards : array<W3DrinkingCard>, isDefensive : bool, out opChosenCard : W3DrinkingCard, out isOpCardAce : bool, out playerChosenCard : W3DrinkingCard, out isPlayerCardAce : bool) : bool
	{
		var i : int;
		var bForcedFirstAi : bool;
		
		LogChannel('Minigame Drinking AI', "GetAIChoice - starting");
		bForcedFirstAi = false;
		
		//first if there is some food take it!
		if(IsAnyFoodCardOnTableForTheTaking())
			bForcedFirstAi = true;
		
		if(isDefensive || bForcedFirstAi)
		{
			do
			{
				LogChannel('Minigame Drinking AI', "GetAIChoice !!! 482");
				opChosenCard = aiChooseCardForSelf(forOpCards,EDCT_Undefined,0);
				
				if( IsNameValid(opChosenCard.cardName) )
				{
					forPlayerCards.Remove(opChosenCard);
					playerChosenCard = aiChooseCardForPlayer(forPlayerCards,opChosenCard.type,opChosenCard.quality);
					
					if( !IsNameValid(playerChosenCard.cardName) )
					{
						//if either card was not chosen then rollback and remove the first chosen card from available choices
						forPlayerCards.PushBack(opChosenCard);
						forOpCards.Remove(opChosenCard);
						if(forOpCards.Size() == 0)
						{
							LogChannel('Minigame Drinking', "DrinkingManager.GetAIChoice: AI has no moves, please deal new hand");
							return false;
						}
						continue;
					}
				}
				else
				{
					LogAssert(false, "DrinkingManager.GetAIChoice: impossible situation - AI has no move in first card");
					return false;
				}				
				
				break;
			}while(true);
		}
		else
		{
			do
			{
				LogChannel('Minigame Drinking AI', "GetAIChoice !!! 515");
				playerChosenCard = aiChooseCardForPlayer(forPlayerCards,EDCT_Undefined,0);
				LogChannel('Minigame Drinking AI', "After AI for player !!! playerChosenCard "+playerChosenCard.cardName);
				if( IsNameValid(playerChosenCard.cardName) )
				{
					forOpCards.Remove(playerChosenCard);
					opChosenCard = aiChooseCardForSelf(forOpCards,playerChosenCard.type,playerChosenCard.quality);
					LogChannel('Minigame Drinking AI', "After AI for AI !!! opChosenCard "+opChosenCard.cardName);
					if( !IsNameValid(opChosenCard.cardName) )
					{
						//if either card was not chosen then rollback and remove the first chosen card from available choices
						forOpCards.PushBack(playerChosenCard);
						forPlayerCards.Remove(playerChosenCard);
						if(forPlayerCards.Size() == 0)
						{
							LogChannel('Minigame Drinking', "DrinkingManager.GetAIChoice: AI has no moves, please deal new hand");
							return false;
						}
						continue;
					}
				}
				else
				{
					LogAssert(false, "DrinkingManager.GetAIChoice: impossible situation - AI has no move in first card");
					return false;
				}				
				
				break;
			}while(true);
		}
		
		isOpCardAce = false;
		isPlayerCardAce = false;
		
		for(i=0; i<oppAceCards.Size(); i+=1)
		{
			if(oppAceCards[i].cardName == opChosenCard.cardName)	
				isOpCardAce = true;
			if(oppAceCards[i].cardName == playerChosenCard.cardName)	
				isPlayerCardAce = true;
		}
		
		//the chosen card can be both an ace and in the random cards -> then we use it from random ones
		if(isOpCardAce)
		{
			for(i=0; i<cardsOnTheTable.Size(); i+=1)
			{
				if(cardsOnTheTable[i].cardName == opChosenCard.cardName)
				{
					isOpCardAce = false;								
					break;
				}
			}
		}
		
		if(isPlayerCardAce)
		{
			for(i=0; i<cardsOnTheTable.Size(); i+=1)
			{
				if(cardsOnTheTable[i].cardName == playerChosenCard.cardName)
				{
					isPlayerCardAce = false;
					break;
				}
			}
		}
		
		return true;
	}
	
	/ **
		(AI) Chooses card for the player
		
		@params
		availableCards - list of possible cards to choose from
		otherCardType - type of other card selected this round (or EDCT_Undefined if no card chosen). Both cards need to have same type or quality
		otherCardQuality - quality of other card selected this round (or whatever if no card chosen). Both cards need to have same type or quality
	* /
	private function aiChooseCardForPlayer(availableCards : array<W3DrinkingCard>, otherCardType : EDrinkingCardType, otherCardQuality : int) : W3DrinkingCard
	{
		var currentCard,null : W3DrinkingCard;
		var intCards : array<W3DrinkingCard>;
		var i,pickedCardIndex,score,bestScore,alcStrDiff : int;
		var intCardsCosts : array<int>;
		var retCard : W3DrinkingCard;
		bestScore = -1000;
		
		LogChannel('MinigameDrinking AI PlayerCard', "aiChooseCardForPlayer !!! start" +availableCards.Size());
		
		for(i=0; i<availableCards.Size(); i+=1)
		{
			currentCard = availableCards[i];
			LogChannel('MinigameDrinking AI PlayerCard', i+" availableCards[i] " +availableCards[i].cardName);
			if(otherCardType != EDCT_Undefined && currentCard.quality != otherCardQuality)
				continue;
			
			score = 0;
			
			//calculate card 'score'
			// -food gets negative values,
			// -multipliers increase score in hundreds
			// -alcohol points are simply added to the score			
			if(currentCard.type == EDCT_Food)
			{
				score = -currentCard.value;
			}
			else
			{
				//if current card gets win then pick it and exit immediately			
				if(thePlayer.target.GetStat(BCS_Drunkenness) + currentCard.value >= GetPlayerDrunknessMaxLevel())
					return currentCard;
				
				if(IsItemAlcohol(playerLastRoundConsumableType) && IsItemAlcohol(currentCard.type))
				{
					//if this round's is alcohol and previous was an alcohol
					alcStrDiff = GetAlcoholStrengthDifference(playerLastRoundConsumableType, currentCard.type);
					
					//if higher 4-5, if same 1, if lower 2-3
					if(alcStrDiff > 0)
						score = 3+alcStrDiff;
					else if(alcStrDiff < 0)
						score = 1-alcStrDiff;
					else if(alcStrDiff == 0)
						score = 1;
				}
				else if(IsItemAlcohol(currentCard.type))
				{
					//if this round's is alcohol and previous was food
					switch(currentCard.type)
					{
						case EDCT_Beer: score = 1; break;
						case EDCT_Wine:
						case EDCT_Mead: score = 2; break;
						case EDCT_Vodka:
						case EDCT_Spirit: score = 3; break;
					}
				}
				
				score *= 100;				
				score += currentCard.value;
			}
			
			//if current score is not lower than current then add to interesting cards
			if(score > bestScore)
			{
				intCards.Clear();
				intCards.PushBack(currentCard);
				bestScore = score;
			}
			else if(score == bestScore)
			{
				intCards.PushBack(currentCard);
			}
		}
		
		LogChannel('MinigameDrinking AI PlayerCard', "intCard size " + intCards.Size());
		for(i = 0; i < intCards.Size(); i+=1)
		{
			LogChannel('MinigameDrinking AI PlayerCard', i+" intCard " + intCards[i].cardName );
		}
		
		if(intCards.Size() == 0)
		{
			LogChannel('MinigameDrinking AI PlayerCard', "DrinkingManager.aiChooseCardForPlayer: no available cards to choose from");
			return null;			//as in: return NULL
		}
		
		if(intCards.Size() == 1)
		{
			LogChannel('MinigameDrinking AI PlayerCard', "aiChooseCardForPlayer ic == 1 " + intCards[0].cardName );
			return intCards[0];
		}
		//if scores are the same
		for(i=0; i<intCards.Size(); i+=1)
		{
			intCardsCosts.PushBack(intCards[i].price);
		}
		if(isStoryMode)
		{
			pickedCardIndex = ArrayFindMaxInt(intCardsCosts);		//most expensive in story
		}
		else
		{
			pickedCardIndex = ArrayFindMinIndexInt(intCardsCosts);		//least expensive in the other
		}
		
		retCard = intCards[pickedCardIndex];
		LogChannel('MinigameDrinking AI PlayerCard', "AI Chooses card index for player and returns " + retCard.cardName );
		
		return intCards[pickedCardIndex];
	}
	
	/ **
		(AI) Chooses card for self
		
		@params
		availableCards - list of possible cards to choose from
	* /
	private function aiChooseCardForSelf(availableCards : array<W3DrinkingCard>, otherCardType : EDrinkingCardType, otherCardQuality : int) : W3DrinkingCard
	{
		var currentCard,null : W3DrinkingCard;
		var intCards : array<W3DrinkingCard>;
		var pickedCardIndex,i,score,bestScore,alcStrDiff : int;
		var intCardsCosts : array<int>;
	
		LogChannel('Minigame Drinking AI', "aiChooseCardForSelf "+availableCards.Size() );
	
		bestScore = 1000000;		
		for(i=0; i<availableCards.Size(); i+=1)
		{
			currentCard = availableCards[i];
			
			if(otherCardType != EDCT_Undefined && currentCard.quality != otherCardQuality)
				continue;
			
			score = 0;
			LogChannel('Minigame Drinking AI', i+" availableCards "+availableCards[i].cardName );
			//calculate card 'score'
			// -food gets negative values,
			// -multipliers increase score in hundreds
			// -alcohol points are simply added to the score
			if(currentCard.type == EDCT_Food)
			{
				score = -currentCard.value;
			}
			else
			{
				if(IsItemAlcohol(opponentLastRoundConsumableType) && IsItemAlcohol(currentCard.type))
				{
					//if this round's is alcohol and previous was an alcohol
					alcStrDiff = GetAlcoholStrengthDifference(opponentLastRoundConsumableType, currentCard.type);
					
					if(alcStrDiff > 0)
						score = 3;
					else if(alcStrDiff < 0)
						score = 2;
					else if(alcStrDiff == 0)
						score = 1;
				}
				else if(IsItemAlcohol(currentCard.type))
				{
					//if this round's is alcohol and previous was food
					switch(currentCard.type)
					{
						case EDCT_Beer: score = 1; break;
						case EDCT_Wine:
						case EDCT_Mead: score = 2; break;
						case EDCT_Vodka:
						case EDCT_Spirit: score = 3; break;
					}
				}
				
				score *= 100;				
				score += currentCard.value;
			}
			
			if(score < bestScore)
			{
				intCards.Clear();
				intCards.PushBack(currentCard);
				bestScore = score;
			}
			else if(score == bestScore)
			{
				intCards.PushBack(currentCard);
			}
		}
		
				
		LogChannel('MinigameDrinking AI AiCard', "intCard size " + intCards.Size());
		for(i = 0; i < intCards.Size(); i+=1)
		{
			LogChannel('MinigameDrinking AI AiCard', i+" intCard " + intCards[i].cardName );
		}
		
		
		if(intCards.Size() == 0)
		{
			LogChannel('MinigameDrinking AI', "DrinkingManager.aiChooseCardForSelf: no available cards to choose from");
			return null;			//as in: return NULL
		}
		
		if(intCards.Size() == 1)
		{
			LogChannel('Minigame Drinking AI', "aiChooseCardForSelf 788 ic == 1" + intCards[0].cardName );
			return intCards[0];
		}
		//if scores are the same pick the most expensive card
		for(i=0; i<intCards.Size(); i+=1)
			intCardsCosts.PushBack(intCards[i].price);
			
		if(isStoryMode)
			pickedCardIndex = ArrayFindMaxInt(intCardsCosts);		//most expensive in story
		else
			pickedCardIndex = ArrayFindMinIndexInt(intCardsCosts);		//least expensive in the other
		
		LogChannel('MinigameDrinking AI', "AI Chooses card index for self and returns " + intCards[pickedCardIndex].cardName );
		LogChannel('MinigameDrinking AI', "pickedCardIndex " + pickedCardIndex );

		return intCards[pickedCardIndex];
	}
	
	/ **
		Processes next round with opponent being the one dealing cards this round
		
		@out params
		playerCard - card chosen by AI for the player
		oppCard - card chosen by AI for self
		isPlayerAce - is card chosen for AI an ace
		isOppAce - is card chosen for the player an ace
		
		@returns
		EMinigameDrinkingRoundResult - result of this round
	* /
	
	protected function GetAISelectedCardIndex( forPlayer : bool) : int
	{
		var cardIndex, i : int;
		var skipped : bool;
		var table : array< W3DrinkingCard >;
		
		//LogChannel( 'Minigame Drinking', "Getting Indices for AI selected cards" );
		
		if( isOpponentAce )		{ table = oppAceCards; }
		else if( isPlayerAce )	{ table = oppAceCards; }
		else					{ table = cardsOnTheTable; }
		
		//LogChannel( 'Minigame Drinking', "Card deck selected for AI, Size = " +table.Size() );
		
		cardIndex = -1;
		skipped = false;
			
		for( i=0; i< table.Size(); i+=1 )
		{
			if( forPlayer )
			{
				LogChannel( 'Minigame Drinking', i +" FOR PLAYER : Card Name = " + table[i].cardName + " vs playedForPlayer.cardName "+playedForPlayer.cardName );
				if( table[i] == playedForPlayer )
				{
					cardIndex = i; 
					LogChannel( 'Minigame Drinking', "FOR PLAYER : Card Name = " + table[i].cardName +" has index = " +cardIndex );
					return cardIndex;
				}
			}	
			else
			{
				LogChannel( 'Minigame Drinking', i +" FOR AI : Card Name = " + table[i].cardName + " vs playedForPlayer.cardName "+playedForOpponent.cardName );
				if( table[i] == playedForOpponent )	
				{
					if(playedForOpponent == playedForPlayer && !skipped)
					{
						skipped = true;
						continue;			//it its the same card, pick the next instance
					}
					LogChannel( 'Minigame Drinking', "FOR AI : Card Name = " + table[i].cardName +" has index = " +cardIndex );
					cardIndex = i; 
					return cardIndex;
				}
			}
		}
	}	
	
	/ **
		return false if opponent has no move -> need to redeal all cards on the table
	* /
	public function GetOpponentChosenCards(out playerCard : W3DrinkingCard, out oppCard : W3DrinkingCard, out isPlayerAce : bool, out isOppAce : bool) : bool
	{
		var forOpCards, forPlayerCards : array<W3DrinkingCard>;
		var isDefensive, madeMove, prevIsOpCardAce, prevIsPlayerCardAce : bool;
		var prevOppChosenCard, prevPlayerChosenCard : W3DrinkingCard;
		var i : int;
				
		LogChannel('MinigameDrinking AI', "GetOpponentChosenCards !!!");		
		
		forOpCards = cardsOnTheTable;
		forPlayerCards = cardsOnTheTable;
		
		for(i = 0; i < cardsOnTheTable.Size(); i += 1)
		{
			LogChannel('MinigameDrinking AI', i+" cardsOnTheTable "+cardsOnTheTable[i].cardName);
		}
		
		
		for(i=0; i<oppAceCards.Size(); i+=1)
		{
			forOpCards.PushBack(oppAceCards[i]);
			forPlayerCards.PushBack(oppAceCards[i]);
		}
		
		isDefensive	= RandRange(1);
		LogChannel('MinigameDrinking', "Opponent (isDefensive=="+isDefensive+") has "+forOpCards.Size()+" cards to choose from.");
		madeMove = GetAIChoice(forOpCards, forPlayerCards, isDefensive, oppCard, isOppAce, playerCard, isPlayerAce);
		
		playedForPlayer = playerCard;
		
		playedForOpponent = oppCard;
		
		LogChannel('MinigameDrinking AI', "GetOpponentChosenCards !!! here !!!!!!!");
		if(!madeMove)
			return false;
		
		/ *
		//DDDD
		//difficulty level handling TODO
		//TK_TODO
		if(gameDifficulty < hard)
		{
			prevOppChosenCard = oppCard;
			prevIsOpCardAce = isOppAce;
			prevPlayerChosenCard = playerCard;
			prevIsPlayerCardAce = isPlayerAce;
			
			forOpCards.Remove(opChosenCard);
			forPlayerCards.Remove(playerChosenCard);
			madeMove = GetAIChoice(forOpCards, forPlayerCards, isDefensive, oppCard, isOppAce, playerCard, isPlayerAce);
		}
		if(madeMove && gameDifficulty < medium)
		{
			prevOppChosenCard = oppCard;
			prevIsOpCardAce = isOppAce;
			prevPlayerChosenCard = playerCard;
			prevIsPlayerCardAce = isPlayerAce;
			
			forOpCards.Remove(opChosenCard);
			forPlayerCards.Remove(playerChosenCard);
			madeMove = GetAIChoice(forOpCards, forPlayerCards, isDefensive, oppCard, isOppAce, playerCard, isPlayerAce);
		}* /
		
		//if couldn't make move in some attempt, use cards chosen in a previous attempt
		if(!madeMove)
		{
			oppCard = prevOppChosenCard;
			isOppAce = prevIsOpCardAce;
			playerCard = prevPlayerChosenCard;
			isPlayerAce = prevIsPlayerCardAce;
		}
		
		aiPlayedForPlayerIdx = GetAISelectedCardIndex( true );
		aiPlayedForAiIdx = GetAISelectedCardIndex( false );
		LogChannel('MinigameDrinking',"AI chooses card index : "+aiPlayedForAiIdx+" for self and card index : "+aiPlayedForPlayerIdx+" for the player");

		if( (aiPlayedForPlayerIdx == aiPlayedForAiIdx) && (isOppAce == isPlayerAce) )
		{ 
			LogAssert(false, "ASSERT - Both indices are the same! ERROR!" ); 
		}
	
		LogChannel('MinigameDrinking',"AI chooses "+oppCard.cardName+" for self (ace: "+isOppAce+" ) and "+playerCard.cardName+" for the player (ace: "+isPlayerAce+" )");
		return true;
	}

	public function ProcessNextRoundOpponent(playerCard : W3DrinkingCard, oppCard : W3DrinkingCard, isPlayerAce : bool, isOppAce : bool) : EMinigameDrinkingRoundResult	
	{
		return ProcessNextRound(playerCard, oppCard,isPlayerAce,isOppAce,false);
	}
	
	/ **
		Plays animations on all characters after a round of drinking minigame is finished.
	* /
	public latent function PlayerBanter( banterDuration : float, playAtRandomMoment : bool ) // PLACEHOLDER BANTER FUNCTIONALITY for Player
	{
		var source : CEntity;
		var banter : string;
		var banterIndex : int;
		var playBanter : bool;
			
		source = (CEntity)thePlayer;
		
		if( playAtRandomMoment )
		{  
			if( RandRange( 20 ) == 0 )	{	playBanter = true; LogChannel('MinigameDrinking', "RandRange(20) =  0" );	}
			else					{	playBanter = false;	}
		}
		else	{	playBanter = true;	}
		
		
		if( playBanter )
		{
			banterIndex = lastBanterIndex + 1;
			if( banterIndex > 5 ) banterIndex = 1;
			
			switch( banterIndex )
			{
				case 1 :
				{
					banter = "Cheers!";
					break;
				}
				case 2 :
				{
					banter = "Here's to your ugly face!";
					break;
				}
				case 3 :
				{
					banter = "You drink like a little girl!";
					break;
				}
				case 4 :
				{
					banter = "Your head is weak like an kitten!";
					break;
				}
				case 5 :
				{
					banter = "I once knew a girl who lived on a hill. What she won't do, her sister will. So here's to her sister!";
					break;
				}
			}
			lastBanterIndex = banterIndex;
			LogChannel('MinigameDrinking', "banterIndex = " +banterIndex );
			theUI().ShowOneliner( banter, source );
			Sleep( banterDuration );
			theUI().HideOneliner( source );
		}	
	}
	
	private latent function StartDrinkingSequence( player : CStoryScenePlayer )
	{
		player.ActivateSceneCamera( 'operator_view' );
		PlayBartenderSetGoods();
		Sleep( 1.5f );
		if( GetIsPlayerRound() )
		{
			Sleep( 1.f );
			//player.ActivateSceneCamera( 'opponent_drinks' );				
			PlayOpponentDrinking();
			Sleep( 1.5f );
			//player.ActivateSceneCamera( 'minigame_setting' );
			Sleep( 0.5f );
			PlayPlayerDrinking();
		}
		else	
		{
			Sleep( 1.0f );
			//player.ActivateSceneCamera( 'geralt_drinks' );
			PlayPlayerDrinking();
			Sleep( 1.5f );
			//player.ActivateSceneCamera( 'opponent_drinks' );
			Sleep( 0.5f );
			PlayOpponentDrinking();	
		}			
		Sleep( 2.5f );
		player.ActivateSceneCamera( 'minigame_setting' );
		Sleep( 4.5f );			
		PlayBartenderGetGoods();
	}

	public function SetBartenderPosition()
	{
		var table : CEntity = theGame.GetEntityByTag( 'minigame_drinking_table' );
		var loc2World : Matrix;
		var tableHeading, yaw : float;
		var operatorSpotWorldPos, operatorSpotLocPos : Vector;
		var operatorSpotWorldRot : EulerAngles;

		barPos = bartender.GetWorldPosition();
		barRot = bartender.GetWorldRotation();		
		
		loc2World = table.GetLocalToWorld();
		yaw = table.GetHeading();
		operatorSpotLocPos = Vector( 0.35f, 1.28f, 0.f );
		operatorSpotWorldPos = VecTransform( loc2World, operatorSpotLocPos );
		operatorSpotWorldRot = EulerAngles( 0.f, yaw - 180.0f , 0.f );
		barPos = operatorSpotWorldPos;
		barRot = operatorSpotWorldRot;
		
		bartender.EnableCharacterCollisions( false ); //off character-character collision
		bartender.EnablePhysicalMovement( false ); //turn on entity rep
		bartender.TeleportWithRotation( barPos, barRot );
		
		((CActor)bartender).SignalGameplayEvent( 'StartDrinkingMinigame' );
	}
	
	public latent function PlayBartenderSetGoods()
	{		
		var tmpActor : CActor;

		tmpActor = (CActor)bartender;
		tmpActor.SignalGameplayEvent( 'DrinkingPutGoods' );
		//bartender.WaitForBehaviorNodeDeactivation( 'DrinkingPutGoodsEnd' );  //DDDD send the event from animation this is fake for now
	}
	
	public latent function PlayBartenderGetGoods()
	{
		var tmpActor : CActor;
		
		tmpActor = (CActor)bartender;
		tmpActor.SignalGameplayEvent( 'DrinkingHideCrockery' );
		//bartender.WaitForBehaviorNodeDeactivation( 'DrinkingHideCrockeryEnd' );
	}
	
	public latent function PlayPlayerDrinking()
	{
		var res : bool;

		thePlayer.SetBehaviorVariable('MinigameDrinkingConsumableType',(float)(int)playerLastRoundConsumableType);
		thePlayer.RaiseForceEvent('DrinkingConsumeGoods');
		//thePlayer.WaitForBehaviorNodeDeactivation( 'DrinkingConsumeGoodsEnd' );
	}
	
	public latent function PlayOpponentDrinking()
	{
		var res : bool;
		var tmpActor : CActor;
		
		opponent.SetBehaviorVariable('MinigameDrinkingConsumableType',(float)(int)opponentLastRoundConsumableType);
		//opponent.WaitForBehaviorNodeDeactivation( 'DrinkingConsumeGoodsEnd' );
		tmpActor = (CActor)opponent;
		tmpActor.SignalGameplayEvent( 'DrinkingConsumeGoods' );
	}	
	/ **
				+++++ Vessel Attachments ++++++++++
	* /
	
	public function CreateVesselEntities()
	{
		var barInv : CInventoryComponent = bartender.GetInventory();
		var oppVesseltype, playerVesselType : EDrinkingVesselType;
		var itemsIds : array<SItemUniqueId>;
		var vessel : CEntity;
		var vesselPos : Vector;
		var vesselTag : name;
		
		oppVesseltype = GetVesselType( playedForOpponent );
		playerVesselType = GetVesselType( playedForPlayer );
				
		//Opponent Vessel
		switch( oppVesseltype )
		{
			case EDCT_Mug :
			{
				itemsIds = barInv.GetItemsIds( 'BeerMugOpponent' );
				break;
			}
			case EDCT_Cup :
			{
				itemsIds = barInv.GetItemsIds( 'WineCupOpponent' );
				break;
			}
			case EDCT_Shot :
			{
				itemsIds = barInv.GetItemsIds( 'VodkaShotOpponent' );
				break;
			}
			case EDCT_Food :
			{
				itemsIds = barInv.GetItemsIds( 'AppetizerOpponent' );
				break;
			}
		}
		opponentVessel = barInv.GetDeploymentItemEntity( itemsIds[0] );

		opponentVessel.CreateAttachment( (CEntity)bartender, 'drinking_vessel_opponent' );
		vesselPos = opponentVessel.GetWorldPosition();
		
		//player Vessel
		switch( playerVesselType )
		{
			case EDCT_Mug :
			{
				itemsIds = barInv.GetItemsIds( 'BeerMugPlayer' );
				break;
			}
			case EDCT_Cup :
			{
				itemsIds = barInv.GetItemsIds( 'WineCupPlayer' );
				break;
			}
			case EDCT_Shot :
			{
				itemsIds = barInv.GetItemsIds( 'VodkaShotPlayer' );
				break;
			}
			case EDCT_Food :
			{
				itemsIds = barInv.GetItemsIds( 'AppetizerPlayer' );
				break;
			}
		}
		playerVessel = barInv.GetDeploymentItemEntity( itemsIds[0] );
		playerVessel.CreateAttachment( (CEntity)bartender, 'drinking_vessel' );
	}

	public function TakeAwayVesselEntities( isLeftHand : bool )
	{
		var barInv : CInventoryComponent = bartender.GetInventory();
		var itemId : SItemUniqueId;
		var vessel : CEntity;
		var vesselTag : name;
		
		if( isLeftHand )
		{
			opponentVessel.BreakAttachment();
			opponentVessel.CreateAttachment( (CEntity)bartender, 'drinking_vessel_opponent' );
		}
		else
		{
			playerVessel.BreakAttachment();
			playerVessel.CreateAttachment( (CEntity)bartender, 'drinking_vessel' );
		}	
	}	
	
	public function AttachVesselEntity( holder : CActor )
	{
		var vessel, holderEntity : CEntity;
		var barInv : CInventoryComponent = bartender.GetInventory();
		var itemId : SItemUniqueId;
		
		if( (CPlayer)holder )			vessel = playerVessel;
		else							vessel = opponentVessel;
		
		holderEntity = (CEntity)holder;
		vessel.BreakAttachment();
		vessel.CreateAttachment( holderEntity, 'drinking_vessel' ); 
	}
	
	public function DetachVesselEntity( holder : CActor )
	{
		var table : CEntity = theGame.GetEntityByTag( 'minigame_drinking_table' );
		var holderType : EHolderType;
		
		if( holder == (CActor)opponent )	holderType = EHT_Opponent;
		else								holderType = EHT_Player;
		
		switch( holderType )
		{
			case EHT_Opponent :
			{
				opponentVessel.BreakAttachment();
				opponentVessel.CreateAttachment( table, 'opponent_vessel' );
				break;
			}
			case EHT_Player :
			{
				playerVessel.BreakAttachment();
				playerVessel.CreateAttachment( table, 'player_vessel' );
				break;
			}
		}
	}
	
	public function LayDownVesselEntity( isLeftHand : bool )
	{
		var table : CEntity = theGame.GetEntityByTag( 'minigame_drinking_table' );
		
		if( isLeftHand )
		{
			opponentVessel.BreakAttachment();
			opponentVessel.CreateAttachment( table, 'opponent_vessel' );
		}
		else
		{
			playerVessel.BreakAttachment();
			playerVessel.CreateAttachment( table, 'player_vessel' );
		}	
	}	
	
	public function DestroyVesselEntities()
	{
		playerVessel.BreakAttachment();
		opponentVessel.BreakAttachment();
		playerVessel.Destroy();
		opponentVessel.Destroy();
	}

	/ **
			Vessel type selection based on coaster selection
	* /
	
	private function GetVesselType( playedCard : W3DrinkingCard ) : EDrinkingVesselType
	{
		var type : EDrinkingVesselType;
		
		switch( playedCard.type )
		{
			case EDCT_Beer : 	type = EDCT_Mug; break;
			case EDCT_Mead : 	type = EDCT_Cup; break;
			case EDCT_Wine : 	type = EDCT_Cup; break;
			case EDCT_Vodka : 	type = EDCT_Shot; break;
			case EDCT_Spirit : 	type = EDCT_Shot; break;
			case EDCT_Food : 	type = EDCT_Food; break;
		}
		return type;
	}	
	
	
	/ **
		Changes actors' states on starting the minigame.
	* /
	private function SetStatesOnMinigameStart()
	{
		bartender.PushState('DrinkingBartender');
		opponent.PushState('DrinkingNPCContestant');
		thePlayer.PushState('DrinkingPlayerContestant');
		SetBartenderPosition();	
	}
	
	/ **
		Always call when ending the minigame.
	* /
	public function CleanUp()
	{
		DestroyVesselEntities();
		bartender.EnableCharacterCollisions( true );
		bartender.EnablePhysicalMovement( true );
		
		bartender.PopState();
		opponent.PopState();		
		thePlayer.PopState();
		
		opponent.ResumeDrunkennessDecay();
		thePlayer.ResumeDrunkennessDecay();
			
		//bartender.TeleportWithRotation( barPos, barRot );		
	}
	
	/ **
		Returns array of cards that the player can affor to play.
		
		@params
		tableIn - array of 'table' cards currently selected by the player, may be empty
		acesIn - array of ace cards currently selected by the player, may be empty
		
		tableOut - array of bools representing 'table' cards that the player can afford to play, may be empty
		acesOut - array of bools representing ace cards that the player can afford to play, may be empty
	* /
	public function GetPlayerAffordableTableCards(tableIn, acesIn : array<W3DrinkingCard>, out tableOut : array<bool>, out acesOut : array<bool>)
	{
		var i,remainingCash : int;
				
		if(isOnTheHouse && isStoryMode)
		{
			for(i=0; i<tableIn.Size(); i+=1)
				tableOut[i] = true;
			for(i=0; i<acesIn.Size(); i+=1)
				acesOut[i] = true;
			return;
		}
		
		//calculate remaining cash
		if(isStoryMode)
			remainingCash = thePlayer.GetMoney() - drinkingCost;
		else
			remainingCash = thePlayer.GetMoney();
		
		for(i=0; i<tableIn.Size(); i+=1)
		{
			remainingCash -= tableIn[i].price;
		}
		for(i=0; i<acesIn.Size(); i+=1)
		{
			remainingCash -= acesIn[i].price;
		}
		
		//check availability
		if(remainingCash < 0)
		{
			for(i=0; i<tableIn.Size(); i+=1)
				tableOut[i] = false;
			for(i=0; i<acesIn.Size(); i+=1)
				acesOut[i] = false;
			return;				//cant afford anything
		}
		
		for(i=0; i<cardsOnTheTable.Size(); i+=1)
		{
			if(remainingCash - cardsOnTheTable[i].price >= 0)
				tableOut[i] = true;
			else
				tableOut[i] = false;
		}
		
		for(i=0; i<playerAceCards.Size(); i+=1)
		{
			if(remainingCash - playerAceCards[i].price >= 0)
				acesOut[i] = true;
			else
				acesOut[i] = false;
		}
	}
	
	// Returns true if there is a food card on the table and it can be selected as a valid move
	private function IsAnyFoodCardOnTableForTheTaking() : bool
	{
		var i,j : int;
		var qualities, otherCardsQualities : array<int>;
	
		for(i=0; i<cardsOnTheTable.Size(); i+=1)
		{
			if(cardsOnTheTable[i].type == EDCT_Food)
				qualities.PushBack(cardsOnTheTable[i].quality);
			else
				otherCardsQualities.PushBack(cardsOnTheTable[i].quality);
		}
		
		if(qualities.Size() == 0)
			return false;		//no food at all
		
		for(i=0; i<otherCardsQualities.Size(); i+=1)
		{
			for(j=0; j<qualities.Size(); j+=1)
			{
				if(qualities[j] == otherCardsQualities[i])
					return true;
			}
		}
		
		return false;
	}
	
	public function GetCardTypeStringByTypeEnum( enumType : EDrinkingCardType ) : string
	{
		var type : string;
		
		switch( enumType )
		{
			case EDCT_Beer : 
			{
				type = "weak";
				break;
			}
			case EDCT_Wine : 
			case EDCT_Mead : 
			{
				type = "medium";
				break;
			}
			case EDCT_Spirit : 
			case EDCT_Vodka : 
			{
				type = "strong";
				break;
			}
			case EDCT_Food : 
			{
				type = "food";
				break;
			}
			case EDCT_Undefined : 
			{
				type = "cover";
				break;
			}
		}
		return type;
	}
	
	public function SetPlayerHandicap( value : float )
	{
		playerHandicap = value * 0.01f;
	}
	
	public function GetPlayerHandicap() : float
	{
		return playerHandicap;
	}
	
	public function GetPlayerDrunknessMaxLevel() : int
	{
		var maxDrunkenness : int;
		
		maxDrunkenness = RoundMath( thePlayer.target.GetStatMax(BCS_Drunkenness) - (thePlayer.target.GetStatMax(BCS_Drunkenness) * GetPlayerHandicap()) );
		
		return maxDrunkenness;
	}
	
	private function GetGameDataFromXML() 
	{
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;		
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('minigame_drinking');
		
		dm.GetCustomNodeAttributeValueInt(main, 'tableCardsCount', tableCardsCount);
	}
	
	private function GetDeckDataFromXML(reqDeck : name, out d : W3DrinkingDeck)
	{
		var dm : CDefinitionsManagerAccessor;
		var main,decks,deck : SCustomNode;		
		var count,i,j : int;
		var cardName : name;
		var reqDeckName, temp : string;
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('minigame_drinking');
		decks = dm.GetCustomDefinitionSubNode(main, 'decks');
		
		//find actual deck name
		reqDeckName = NameToString(reqDeck);
		for(i=0; i<decks.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueString(decks.subNodes[i], 'name', temp);
			if(reqDeckName == temp)			
			{
				d.deckName = reqDeck;
				deck = decks.subNodes[i];
				break;
			}
		}
		
		if(!IsNameValid(d.deckName))	//if deck not found use default
		{
			for(i=0; i<decks.subNodes.Size(); i+=1)
			{
				dm.GetCustomNodeAttributeValueString(decks.subNodes[i], 'name', temp);
				if(temp == "default")
				{
					d.deckName = 'default';
					deck = decks.subNodes[i];
					break;
				}
			}
		}
		for(i=0; i<deck.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueInt(deck.subNodes[i], 'count', count);
			for(j=0; j<count; j+=1)
			{
				dm.GetCustomNodeAttributeValueName(deck.subNodes[i], 'name_name', cardName);
				if(IsNameValid(cardName))
					d.cards.PushBack(cardName);
			}
		}
	}
	
	private function GetCardsDataFromXML(cardNames : array<name>) : array<W3DrinkingCard>
	{
		var dm : CDefinitionsManagerAccessor;
		var main,cards,qualityIcons,card,typeIcons : SCustomNode;	
		var ret : array<W3DrinkingCard>;
		var i,k, tmpInt : int;
		var c : W3DrinkingCard;
		var bCardFound : bool;
		var tmpStr : string;
		var tmpName : name;
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('minigame_drinking');
		cards = dm.GetCustomDefinitionSubNode(main, 'cards');
		qualityIcons = dm.GetCustomDefinitionSubNode(main, 'card_quality_icons');
		typeIcons = dm.GetCustomDefinitionSubNode(main, 'card_types_icons');		
		
		for(i=0; i<cardNames.Size(); i+=1)
		{
			bCardFound = false;
			for(k=0; k<cards.subNodes.Size(); k+=1)
			{
				dm.GetCustomNodeAttributeValueName(cards.subNodes[k], 'name_name', tmpName);
				if(tmpName == cardNames[i])
				{
					card = cards.subNodes[k];
					bCardFound = true;
					break;
				}
			}			
			
			if(!bCardFound)
			{
				LogAssert(false, "DrinkingManager.GetCardsDataFromXML: cannot find card definition in XML for name <<" + cardNames[i] + ">>");
				continue;				//card does not exist
			}
			
			dm.GetCustomNodeAttributeValueString(card, 'cardIcon', tmpStr);
			c.cardIcon = tmpStr;
			c.cardName = cardNames[i];
			dm.GetCustomNodeAttributeValueString( card, 'stringId', tmpStr);
			c.displayName = GetLocStringByKeyExt( tmpStr );
			dm.GetCustomNodeAttributeValueInt(card, 'price', tmpInt);
			c.price = tmpInt;
			dm.GetCustomNodeAttributeValueInt(card, 'quality', tmpInt);
			c.quality = tmpInt;
			dm.GetCustomNodeAttributeValueInt(card, 'type', tmpInt);
			c.type = tmpInt;
			dm.GetCustomNodeAttributeValueInt(card, 'value', tmpInt);
			c.value = tmpInt;
			
			//set quality icon
			for(k=0; k<qualityIcons.subNodes.Size(); k+=1)
			{
				dm.GetCustomNodeAttributeValueInt(qualityIcons.subNodes[k], 'quality', tmpInt);
				if( tmpInt == c.quality)
				{
					dm.GetCustomNodeAttributeValueString(qualityIcons.subNodes[k], 'icon', tmpStr);
					c.qualityIcon = tmpStr;
					break;
				}
			}
			
			//set type icon
			for(k=0; k<typeIcons.subNodes.Size(); k+=1)
			{
				dm.GetCustomNodeAttributeValueInt(typeIcons.subNodes[k], 'type', tmpInt);
				if( tmpInt == c.type)
				{
					dm.GetCustomNodeAttributeValueString(typeIcons.subNodes[k], 'icon', tmpStr);
					c.typeIcon = tmpStr;
					break;
				}
			}
				
			ret.PushBack(c);
		}
		
		return ret;
	}
}
*/