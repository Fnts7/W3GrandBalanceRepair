/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Copyright © 2013-2014 CDProjektRed
/** Author : Radosław Grabowski
/***********************************************************************/

//component for anything that is floating on water
import statemachine class CBoatBodyComponent extends CRigidMeshComponent
{
	default autoState = 'Idle';

	//import var drowningTime : float;
    //import var drowningForce : float;
    //import var drowningFallofPropagation : float;
    
    // Event called when component is attached
    event OnComponentAttached()
	{
		GotoStateAuto();
	}
	
	// Cutscene events
	event OnCutsceneStarted(){}
	event OnCutsceneEnded(){}
	
	// Switches cutscene mode on/off
	import function TriggerCutsceneStart();
	import function TriggerCutsceneEnd();
}