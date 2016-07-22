/***********************************************************************/
/** Witcher Script file - Main Menu
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Bartosz Bigaj
/***********************************************************************/

class CR4CommonMainMenu extends CR4CommonMainMenuBase
{
}

exec function mainmenu():void
{
	theGame.RequestMenu('CommonMainMenu');
}