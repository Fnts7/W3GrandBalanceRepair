
// Global event name for combo state: 'ComboSlot'
// Name of the manual slot inside combo state: 'ComboSlot'
// Name of the variable for control blend out transition form combo state: 'ComboAllowBlend'
// Combat state has to have function OnComboAttackCallback( out callbackInfo : SComboAttackCallbackInfo )

/*enum EComboAttackType
{
	ComboAT_Normal,
	ComboAT_Directional,
	ComboAT_Restart,
	ComboAT_Stop,
}*/

import struct SComboAttackCallbackInfo
{
	import var outDirection : EAttackDirection;
	import var outDistance : EAttackDistance;
	
	import var outRotateToEnemyAngle : float;
	import var outSlideToPosition : Vector;
	import var outShouldTranslate : bool;
	import var outShouldRotate : bool;
	
	import var outAttackType : EComboAttackType;
	import var outLeftString : bool;

	import var inAspectName : name;
	import var inGlobalAttackCounter : int;
	import var inStringAttackCounter : int;
	import var prevDirAttack : bool;
	import var inAttackId : int;
}

import class CComboPlayer extends CObject
{
	import final function Build( definition: CComboDefinition, entity : CEntity ) : bool;
	
	import final function Init() : bool;
	import final function Deinit();
	
	import final function Update( timeDelta : float ) : bool;
	
	import final function Pause();
	import final function Unpause();
	import final function IsPaused() : bool;
	
	import final function PauseSlider();
	import final function UnpauseSlider();
	import final function IsSliderPaused() : bool;
	
	import final function PlayAttack( comboAspect : name ) : bool;
	import final function StopAttack();

	//plays different animation for end of the swing for attacker (instead of continuing the swing, the hand 'stops' to visually indicate that a hit landed)
	import final function PlayHit() : bool;
	
	import final function SetDurationBlend( timeDelta : float );
	
	import final function UpdateTarget( attackId : int, pos : Vector, rot : float, optional deltaRotationPolicy : bool, optional useRotationScaling : bool );
}
