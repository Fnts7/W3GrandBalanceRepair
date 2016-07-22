import abstract class IAIParameters extends IScriptable 
{
	import function LoadSteeringGraph( fileName : string ) : CMoveSteeringBehavior;
	import function OnManualRuntimeCreation();
	
	function OnCreated() { Init(); }
	function Init(){}
};
import abstract  class CAIParameters 	extends IAIParameters	{};
import abstract class CAIDefaults 	extends IAIParameters 	{};

import abstract class IAITree extends IAIParameters 
{
	import protected var aiTreeName : string;

	import final function OnCreated();
	
	function Init(){}

	// editable inlined var params : CAIParameters; //! Should include editable, inlined variable params of type CAIDefaults or CAIParameters (or their descendants)	
	// function Init()								//! Include custom Init() function for parameter set specific initialisation
};
import abstract class CAITree extends IAITree {};
import abstract class CAIBaseTree extends IAITree {};
//import abstract class CAIPerformCustomWorkTree extends IAITree {};

import abstract class ICustomValAIParameters extends CAIRedefinitionParameters
{
	function SetCNameValue( value : name ){} 
}

class CHorseTagAIParameters extends ICustomValAIParameters
{
	editable var preferedHorseTag : name;
	function SetCNameValue( value : name )
	{ 
		preferedHorseTag = value; 
	} 
}