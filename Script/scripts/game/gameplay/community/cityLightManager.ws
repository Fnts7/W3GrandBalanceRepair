/***********************************************************************/
/** gameplayLightComponent - City lights turn on/off based on TOD
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Shadi Dadenji
/***********************************************************************/


import class CCityLightManager extends IGameSystem
{
	import function SetEnabled		(toggle:bool) 	: void;
	import function IsEnabled		() 				: bool;
	import function ForceUpdate		() 				: void;
	import function SetUpdateEnabled(value:bool) 	: void;
	import function DebugToggleAll	(toggle:bool) 	: void;	

}

exec function ToggleAll(toggle:bool)
{
	theGame.GetCityLightManager().DebugToggleAll(toggle);
}

