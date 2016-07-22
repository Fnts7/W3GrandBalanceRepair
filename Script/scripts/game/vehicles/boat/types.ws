/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2013-2014 CDProjektRed
/** Author : Radosław Grabowski
/**   		 Tomek Kozera
/***********************************************************************/

import struct SBoatDestructionVolume
{
	import var volumeCorners : Vector;
    import var volumeLocalPosition : Vector;
    import var areaHealth : Float;
};

struct SBoatPartsConfig
{
	editable var destructionVolumeIndex : int;						//index of the destruction volume connects to these parts
	editable saved var parts : array<SBoatDesctructionPart>;		//array of parts mapped to given destruction volume
};

struct SBoatDesctructionPart
{
	editable var hpFalloffThreshold : float;		//threshold when to drop parts
	editable var componentName : string;				//name of the component to drop
	saved var isPartDropped : bool;					//set to true once the part has fallen off	
};