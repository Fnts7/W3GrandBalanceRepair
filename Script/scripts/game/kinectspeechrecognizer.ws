/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for CR4KinectSpeechRecognizerListenerScriptProxy
/** Copyright © 2014
/***********************************************************************/

import class CR4KinectSpeechRecognizerListenerScriptProxy extends CObject
{

	import final function IsSupported() : bool;
	import final function IsEnabled() : bool;
	import final function SetEnabled( enable: bool );

	private function OnListenerRegistered() : void
	{
		LogChannel( 'Kinect', "Kinect - CR4KinectSpeechRecognizerListenerScriptProxy registered" );
		if( (IsSupported() == false) && (IsEnabled() == true) )
		{
			SetEnabled( false );
		}
	}
	
	private function OnAudioProblem( audioProblem: int ) : void
	{
		//0 - NoSignal,
		//1 - TooFast,
		//2 - TooLoud,
		//3 - TooNoisy,
		//4 - TooQuiet,
		//5 - TooSlow
		
		LogChannel( 'Kinect', "Audio problem: " + audioProblem );
	}
	
	private function OnRecognizedCommand( recognizedCommand: int, semanticNames : array< string >, semanticValues: array< string >, confidenceScore: float ) : void
	{
	    var i, s : int;     
	    
		if ( theGame )
		{
			if ( theGame.IsDialogOrCutscenePlaying() || IsKinectBlocked() )
			{
				return;
			}
		}
	        
		//recognizedCommand
		//0 - TopLevel,		//! quick save, quick load
		//1 - Magic,		//! select sign
		//2 - Inventory,	//! use item/potion form inventory
		//3 - Menu			//! open map/inventory/etc...
						      
        //confidenceScore - from 0.0 to 1.0
        
		LogChannel( 'Kinect', "Recognized command: " + recognizedCommand );
		LogChannel( 'Kinect', "Recognized command confidence: " + confidenceScore );
				
		//semanticNames - semanticValues		
		//
		// (typos are on purpose for phonetic recognization reasons)
		//for use "cast_type" :
		//  "cast_type" - "ard"
		//  "cast_type" - "igni"
		//  "cast_type" - "quen"
		//  "cast_type" - "yren"
		//  "cast_type" - "axi"
		//		
		//for give me "type" "slot"
		//       "slot" - "1"
		//       "slot" - "2"
		//       "slot" - "3"
		//       "slot" - "4"
		//       "type" - "potion"
		//       "type" - "item"
		//
		//for open "manu"
		//       "menu" - "map"
		//       "menu" - "journal"
		//       "menu" - "inventory"
		//       "menu" - "character"
		//       "menu" - "preparation"
        //       "menu" - "alchemy"
		if( confidenceScore > 0.6 )
		{
			switch ( recognizedCommand )
			{
				//top level commands
				case 0:
					break;

				//signs 
				case 1:
					if ( semanticValues[0] == "aard" ) GetWitcherPlayer().SetEquippedSign(SignStringToEnum( 'Aard' ));
			   else if ( semanticValues[0] == "axii" ) GetWitcherPlayer().SetEquippedSign(SignStringToEnum( 'Axii' ));
			   else if ( semanticValues[0] == "quen" ) GetWitcherPlayer().SetEquippedSign(SignStringToEnum( 'Quen' ));
			   else if ( semanticValues[0] == "igni" ) GetWitcherPlayer().SetEquippedSign(SignStringToEnum( 'Igni' ));
			   else if ( semanticValues[0] == "yrden" ) GetWitcherPlayer().SetEquippedSign(SignStringToEnum( 'Yrden' ));
					break;
		   
				//inventory
				case 2:
					break;
					
				//menus
				case 3:
					if ( semanticValues[0] == "map" ) GetWitcherPlayer().GetInputHandler().PushMapScreen();
			   else if ( semanticValues[0] == "quests" ) GetWitcherPlayer().GetInputHandler().PushJournalScreen();
			   else if ( semanticValues[0] == "inventory" ) GetWitcherPlayer().GetInputHandler().PushInventoryScreen();
			   else if ( semanticValues[0] == "character" ) GetWitcherPlayer().GetInputHandler().PushCharacterScreen();
			   else if ( semanticValues[0] == "glossary" ) GetWitcherPlayer().GetInputHandler().PushGlossaryScreen();		   	   
			}
		}
        s = semanticNames.Size();
		for( i=0; i<s; i+=1 )
		{
			LogChannel( 'Kinect', "Name: " + semanticNames[i] + " - Value: " + semanticValues[i] );		
		}
		
	}
	
	private function OnHypothesisAvailable( hypothesis: string ) : void
	{
		LogChannel( 'Kinect', "Hypothesis available: " + hypothesis );		
	}


	private function IsKinectBlocked() : bool
	{
		var result : bool;
		result = false;

		//we can place as many Kinect blockers as needed here	
		if ( theGame.GetGuiManager().IsModalPopupShown() )
		{
			//if we have any popup messages that require a control input
			result = true;
		}
		
		return result;
	}
}

exec function testVoiceMap()
{
	GetWitcherPlayer().GetInputHandler().PushMapScreen();
}

exec function testVoiceJournal()
{
	GetWitcherPlayer().GetInputHandler().PushJournalScreen();
}

exec function testVoiceInventory()
{
	GetWitcherPlayer().GetInputHandler().PushInventoryScreen();
}

exec function testVoiceCharacter()
{
	GetWitcherPlayer().GetInputHandler().PushCharacterScreen();
}

exec function testVoiceAlchemy()
{
	GetWitcherPlayer().GetInputHandler().PushAlchemyScreen();
}
