
import struct SSoundInfoMapping
{
	import var soundTypeIdentification 	: name;
	import var soundSizeIdentification 	: name;
	import var boneIndexes 				: array< int >;
	import var isDefault				: bool;
}

import class CR4HumanoidCombatComponent extends CComponent
{
	import final function UpdateSoundInfo(  ) 																	: void;
	
	import final function GetSoundTypeIdentificationForBone( boneIndex : int  ) 								: name;
	
	import final function GetBoneClosestToEdge( a : Vector, b : Vector, optional preciseSearch : bool ) 		: int;
	
	import final function GetDefaultSoundInfoMapping( ) 														: SSoundInfoMapping;
}
