/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Job system classes
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// Job tree node
/////////////////////////////////////////////

import class CJobTree extends CResource
{
}

enum EJobTreeType
{
	EJTT_NothingSpecial,
	EJTT_Praying, //if you change this, change code also ( just search EJTT_Praying )
	EJTT_InfantInHand,
	EJTT_Sitting,
	EJT_PlayingMusic,
	EJTT_CatOnLap,
}


/*
/////////////////////////////////////////////
// Job action
/////////////////////////////////////////////

import class CJobAction
{
	// Get the category of animation at this action node
	import final function GetAnimCategory() : string;
	
	// Get the name of the animation at this action node
	import final function GetAnimName() : string;
	
	// Get name of the place ( entity's waypoint ) at which this action should occur
	import final function GetPlace() : name;
	
	// Shoud path engine agent be disabled in this action
	import final function IsNoPathAgent() : bool;
}*/
