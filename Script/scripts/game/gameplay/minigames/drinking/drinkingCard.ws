/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Tomasz Kozera
/***********************************************************************/
/*        The minigame is removed. I leave the code since there were some tricky things addresses here like paired animations
          with the use of items attached from NPC to npc, etc.
			REMOVED_DRINKING
			
enum EDrinkingCardType
{
	EDCT_Undefined,
	EDCT_Beer,
	EDCT_Wine,
	EDCT_Mead,
	EDCT_Vodka,
	EDCT_Spirit,
	EDCT_Food	
}

struct W3DrinkingCard
{
	var cardName : name;				//card name 
	var displayName : string;			//card name displayed in GUI
	var cardIcon : string;				//card icon - GUI : string name of a path to specific alcohol icon ( i.e. temerian hooch)
	var typeIcon : string;				//card type icon - GUI : string name of a path to general beverage type (i.e. wine)
	var qualityIcon : string;			//card quality icon - GUI : string name of a path of an amount of coins (alcohol value)
	var value : int;					//value of the card's effect - GUI : int value of alcohol potency (number of drunkenness points)
	var price : int;					//price of playing the card during the minigame - GUI : int value of money that given alcohol costs (deducted from player's amount)
	var type : EDrinkingCardType;		//card type - GUI : n/a
	var quality : int;					//card quality - GUI : n/a 
};
*/