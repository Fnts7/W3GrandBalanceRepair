// Component that can receive a tick from the engine every frame

// ***********  HOW TO USE IT  ***********
// Set in the properties ( in editor ) to be ticked as soon as the component exists. (by default it won't be ticked)
// or call StartTicking()
// to start getting a call each frame at the event 
// event OnComponentTick()
// also in the properties ( in the editor ) you can also select the tick group

// For any questions ask Ed

import abstract class CSelfUpdatingComponent extends CScriptedComponent
{
	import final function StartTicking();
	import final function StopTicking();
	import final function GetIsTicking() : bool;
	
	/*
	event OnComponentTick()
	{
	}
	*/
}