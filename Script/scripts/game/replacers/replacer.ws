/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2012-2014 CDProjektRed
/** Author : ?
/**   		 Tomek Kozera
/***********************************************************************/

class W3Replacer extends CR4Player 
{
	var level : int;
	
	public function GetLevel() : int
	{
		return level;
	}
	
	public function SetLevel( lev : int )
	{
		level = lev;
	}
}


function GetReplacerPlayer() : W3Replacer
{
	return (W3Replacer)thePlayer;
}
