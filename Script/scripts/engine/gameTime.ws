/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Exports for the time manager
/** Copyright © 2009
/***********************************************************************/

/////////////////////////////////////////////
// Game time
/////////////////////////////////////////////

import struct GameTime {};

import struct GameTimeWrapper
{
	import editable var gameTime : GameTime;
};

/////////////////////////////////////////////
// Game time functions
/////////////////////////////////////////////

// Create game time from given amount of seconds, minutes, etc. See notes on the bottom of the page.
import function GameTimeCreate( optional days, hours, minutes, seconds : int ) : GameTime;

// Extract number of seconds from the given game time
import function GameTimeSeconds( time : GameTime ) : int;

// Extract number of minutes from the given game time
import function GameTimeMinutes( time : GameTime ) : int;

// Extract number of hours from the given game time
import function GameTimeHours( time : GameTime ) : int;

// Extract number of days from the given game time
import function GameTimeDays( time : GameTime ) : int;

// Convert game time to string
import function GameTimeToString( time : GameTime ) : string;

// Count total number of seconds represented by this game time
import function GameTimeToSeconds( time : GameTime ) : int;

// Count total number of seconds represented by this game time
import function ScheduleTimeEvent( context : IScriptable, functionWithParams : string, date : GameTime, optional relative : bool, optional period : GameTime, optional limit : int );

//Checks if at least dt realtime seconds have passed between two GameTimes. Takes into consideration the fact that GameTime can wrap around
function GameTimeDTAtLeastRealSecs( timeOld : GameTime, timeNew : GameTime, dt : float ) : bool
{
	var difference : float;
	
	if( timeOld > timeNew )
	{
		return true;
	}
	
	difference = ConvertGameSecondsToRealTimeSeconds( GameTimeToSeconds( timeNew ) - GameTimeToSeconds( timeOld ) );
	
	return difference >= dt;
}

function Have24HoursPassed( time1 : GameTime, time2 : GameTime ) : bool
{
	var difference : int;

	difference = GameTimeToSeconds( time1 ) - GameTimeToSeconds( time2 );
	return ( Abs(difference/3600) >= 24 );
}


function ConvertRealTimeSecondsToGameSeconds( s : float) : float
{
	return s * theGame.GetHoursPerMinute() * 60;
}

function ConvertGameSecondsToRealTimeSeconds( s : float) : float
{
	return s / (theGame.GetHoursPerMinute() * 60);
}
	
function GameTimeCreateFromGameSeconds(seconds : int) : GameTime
{
	var days, hours, minutes : int;

	days = FloorF( ((float)seconds) / (24 * 60 * 60));
	seconds -= days * 24 * 60 * 60;
	
	hours = FloorF( ((float)seconds) / (60 * 60));
	seconds -= hours * 60 * 60;
	
	minutes = FloorF( ((float)seconds) / 60);
	seconds -= minutes * 60;
	
	return GameTimeCreate(days, hours, minutes, seconds);
}

function GetDayPart(time : GameTime) : EDayPart
{
	var hrs : int;

	hrs = GameTimeHours(time);
	
	if(hrs < 4 || hrs >= 22)	return EDP_Midnight;
	if(hrs >= 4 && hrs < 10)	return EDP_Dawn;
	if(hrs >= 10 && hrs < 16)	return EDP_Noon;
	if(hrs >= 16 && hrs < 22)	return EDP_Dusk;
	
	return EDP_Undefined;
}

function GetHourForDayPart(dp : EDayPart) : int
{
	switch(dp)
	{
		case EDP_Dawn : return 6;
		case EDP_Noon : return 12;
		case EDP_Dusk : return 18;
		case EDP_Midnight : return 0;
		default : return 0;
	}
}

enum EDayPart
{
	EDP_Undefined,
	EDP_Dawn,
	EDP_Noon,
	EDP_Dusk,
	EDP_Midnight
}
/////////////////////////////////////////////
// Game time operators
/////////////////////////////////////////////

// operator ( GameTime + GameTime ) : GameTime
// operator ( GameTime + int ) : GameTime
// operator ( GameTime - GameTime ) : GameTime
// operator ( GameTime - int ) : GameTime
// operator ( GameTime * float ) : GameTime
// operator ( GameTime / float ) : GameTime
// operator ( GameTime += GameTime ) : GameTime
// operator ( GameTime += int ) : GameTime
// operator ( GameTime -= GameTime ) : GameTime
// operator ( GameTime -= int ) : GameTime
// operator ( GameTime *= float ) : GameTime
// operator ( GameTime /= float ) : GameTime
// operator ( GameTime == GameTime ) : bool
// operator ( GameTime != GameTime ) : bool
// operator ( GameTime < GameTime ) : bool
// operator ( GameTime > GameTime ) : bool
// operator ( GameTime >= GameTime ) : bool
// operator ( GameTime <= GameTime ) : bool

//
// Using GameTimeCreate:
//
//  GameTimeCreate() - now
//  GameTimeCreate( 10 ) - 10 seconds
//  GameTimeCreate( 1, 30 ) - 1 minute, 30 seconds
//  GameTimeCreate( 2, 45, 0 ) - 2 hours, 45 minutes, 0 seconds
//  GameTimeCreate( 1, 8, 30, 15 ) - 1 day, 8 hours, 30 minutes, 15 seconds

exec function GameTimeTest()
{
	var a,b : GameTime;
	
	a = GameTimeCreate();
	Log( GameTimeToString( a ) + ", " + GameTimeToSeconds(a) );

	a = GameTimeCreate(10);
	Log( GameTimeToString( a ) + ", " + GameTimeToSeconds(a) );

	a = GameTimeCreate(2,10);
	Log( GameTimeToString( a ) + ", " + GameTimeToSeconds(a) );

	a = GameTimeCreate(5,2,10);
	Log( GameTimeToString( a ) + ", " + GameTimeToSeconds(a) );

	a = GameTimeCreate(1,5,2,10);
	Log( GameTimeToString( a ) + ", " + GameTimeToSeconds(a) );

	a /= 2.0;
	
	Log( GameTimeToString( a ) + ", " + GameTimeToSeconds(a) );

}

exec function settime(day : int, optional hour : int, optional minute : int, optional second : int )
{
	var newTime : GameTime;
	newTime = GameTimeCreate(day, hour, minute, second );
	theGame.SetGameTime( newTime, true );
	
	LogTime("Setting game time to : "+GameTimeToString(newTime));
}

exec function wait(days : int, optional hours : int, optional minutes : int, optional seconds : int )
{
	theGame.SetGameTime( theGame.GetGameTime() + GameTimeCreate(days, hours, minutes, seconds), true);
	LogTime("Waiting " + days + " days, " + hours + " hours, " + minutes + " minutes, " + seconds + " seconds");
}

exec function telltime()
{
	LogTime("Current game time : "+GameTimeToString( theGame.GetGameTime() ));
}
