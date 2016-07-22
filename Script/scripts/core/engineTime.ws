/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for EngineTime
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// Engine time
/////////////////////////////////////////////

import struct EngineTime {};

/////////////////////////////////////////////
// Engine time functions
/////////////////////////////////////////////

// Create EngineTime from float (seconds)
import function EngineTimeFromFloat( seconds : float ) : EngineTime;

// Convert EngineTime to float (seconds)
import function EngineTimeToFloat( time : EngineTime ) : float;

// Convert EngineTime to string (seconds)
import function EngineTimeToString( time : EngineTime ) : string;