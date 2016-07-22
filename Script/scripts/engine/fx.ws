/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2014
/** Author : Kamil Nowakowski
/***********************************************************************/

// Enables Cat Effect - it'll fade in
import function EnableDrunkFx( optional fadeIn : float );

// Disables Cat Effect - it'll fade out
import function DisableDrunkFx( optional fadeout: float );

// Disables Cat Effect - it'll fade out
import function ScaleDrunkFx( scale: float );

// Testing thing
exec function Drunk( optional enabled : bool )
{
	if( enabled )
	{
		EnableDrunkFx( 1.0f );	// enable effect and blend it in over 1 sec
	}
	else
	{
		DisableDrunkFx( 1.0f );	// Disable effect and blend it out over 1 sec
	}
}



// Enables Cat Effect - it'll fade in
import function EnableCatViewFx( optional fadeIn : float );

// Disables Cat Effect - it'll fade out
import function DisableCatViewFx( optional fadeout: float );

// Sets reference position for effect - should be player position
// Updated every frame
// Can be called once with autoPositioning = true - then effect will track players position by itselfe
// When passing true, position may be whatever, It wont be used anyway
import function SetPositionCatViewFx( position: Vector, optional autoPositioning /* = false */: bool );

// Changes color tinting on near and far range
import function SetTintColorsCatViewFx( tintNear: Vector, tintFar: Vector, optional desaturaion: float );

// Changes brightness of the effect
import function SetBrightnessCatViewFx( optional brightStrength: float );

// Range of the near range [m]
import function SetViewRangeCatViewFx( optional viewRanger: float );

// Sets higthlight params 
// - coloring (where alpha is intensivity), 
// - hightlightInterior (how the interior of the object is hightlighted)
// - blurSize (bluring of the higthlight)
import function SetHightlightCatViewFx( color: Vector, optional hightlightInterior /* = 0.05*/ : float, optional blurSize /* = 1.5 */: float );

// Changes density and start dystans of fog
// - density , 1.0 - default fog, 0.02 - almost turned off
import function SetFogDensityCatViewFx( density : float, optional startOffset: float );

// Testing thing
exec function Cat( optional enabled : bool )
{
	if( enabled )
	{
		EnableCatViewFx( 1.0f );	// enable effect and blend it in over 1 sec
		SetPositionCatViewFx( Vector(0,0,0,0) , true );	// Set auto poistioning 
	}
	else
	{
		DisableCatViewFx( 1.0f );	// Disable effect and blend it out over 1 sec
	}
}