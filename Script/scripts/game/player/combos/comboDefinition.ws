
/*
enum EAttackDirection
{
	AD_Front,
	AD_Left,
	AD_Right,
	AD_Back
};

enum EAttackDistance
{
	ADIST_Small,
	ADIST_Medium,
	ADIST_Large
};
*/

import class CComboString extends CObject
{
	import final function AddAttack( animationName : name, optional distance : EAttackDistance );
	
	import final function AddDirAttack( animationName : name, direction: EAttackDirection, distance : EAttackDistance );
	import final function AddDirAttacks( animationNameFront : name, animationNameBack : name, animationNameLeft : name, animationNameRight : name, distance : EAttackDistance );
}

import class CComboAspect extends CObject
{
	import final function CreateComboString( optional leftSide : bool ) : CComboString;

	import final function AddLinks( animationName : name, connections : array< name > );
	import final function AddLink( animationName : name, linkedAnimationName: name );

	import final function AddHit( animationName : name, hitAnimationName : name );
}

import class CComboDefinition extends CObject
{
	import final function CreateComboAspect( comboAspect : name ) : CComboAspect;
	import final function DeleteComboAspect( comboAspect : name ) : bool;
	import final function FindComboAspect( comboAspect : name ) : CComboAspect;
}
