/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** String processing functions
/** Copyright © 2009 Dexio's Late Night R&D Home Center
/***********************************************************************/

/////////////////////////////////////////////
// String processing functions
/////////////////////////////////////////////

// Get string length
import function StrLen( str : string ) : int;

// Compare strings
import function StrCmp( str, with : string, optional length : int, optional noCase : bool ) : int;

// Find substring, from left
import function StrFindFirst( str, match : string ) : int;

// Find substring, from right
import function StrFindLast( str, match : string ) : int;

// Divide string using splitter
import function StrSplitFirst( str, divider : string, out left, right : string ) : bool;

// Divide string using splitter
import function StrSplitLast( str, divider : string, out left, right : string ) : bool;

// Replate pattern with something else (only the first find)
import function StrReplace( str, match, with : string ) : string;

// Replate pattern with something else
import function StrReplaceAll( str, match, with : string ) : string;

// Get string part starting from i-th char (j is the length)
import function StrMid( str : string, first : int, optional length : int ) : string;

//*length* first chars of string
import function StrLeft( str : string, length : int ) : string;

//Last *length* chars from string
import function StrRight( str : string, length : int ) : string;

// Get string before first occurence of given substring
import function StrBeforeFirst( str, match : string ) : string;

// Get string before last occurence of given substring
import function StrBeforeLast( str, match : string ) : string;

// Get string after first occurence of given substring
import function StrAfterFirst( str, match : string ) : string;

// Get string after last occurence of given substring
import function StrAfterLast( str, match : string ) : string;

// Check if string starts with given substring
import function StrBeginsWith( str, match  : string ) : bool;

// Check if string ends with given substring
import function StrEndsWith( str, match  : string ) : bool;

// Convert string to upper case
import function StrUpper( str  : string ) : string;

// Convert string to lower case
import function StrLower( str  : string ) : string;

// Create string for single char 
import function StrChar( i : int ) : string;

// Convert name to string 
import function NameToString( n : name ) : string;

// Convert float to string
import function FloatToString( value : float ) : string;

// Convert float to string with precision
import function FloatToStringPrec( value : float, precision : int ) : string;

// Convert int to string
import function IntToString( value : int ) : string;

// Convert string to int
import function StringToInt( value : string, optional defValue : int) : int;

// Convert string to float
import function StringToFloat( value : string, optional defValue : float ) : float;

// Convert string to upper case including diacritic characters 
import function StrUpperUTF( str : string ) : string;

// Convert string to lower case including diacritic characters
import function StrLowerUTF( str : string ) : string;

// Converts name to int
function NameToInt(n : name) : int
{
	return StringToInt(NameToString(n));
}

// Converts name to float
function NameToFloat(n : name) : float
{
	return StringToFloat(NameToString(n));
}

//removes all trailing zeros from given number and converts to float, e.g. 2.540000 will be shown as 2.54
function NoTrailZeros(f : float) : string
{
	var tmp : string;
	
	tmp = FloatToString(f);	
	if(StrFindFirst(tmp, ",") >= 0 || StrFindFirst(tmp, ".") >= 0)
		while(StrEndsWith(tmp, "0"))
			tmp = StrLeft(tmp, StrLen(tmp)-1);
	if(StrEndsWith(tmp, ",") || StrEndsWith(tmp, "."))
		tmp = StrLeft(tmp, StrLen(tmp)-1);
	
	return tmp;
}

//hack to workaround lack of name concat
function GetRandomName() : name
{
	switch(RandRange(20))
	{
		case 0 : return '0';
		case 1 : return '1';
		case 2 : return '2';
		case 3 : return '3';
		case 4 : return '4';
		case 5 : return '5';
		case 6 : return '6';
		case 7 : return '7';
		case 8 : return '8';
		case 9 : return '9';
		case 10 : return '10';
		case 11 : return '11';
		case 12 : return '12';
		case 13 : return '13';
		case 14 : return '14';
		case 15 : return '15';
		case 16 : return '16';
		case 17 : return '17';
		case 18 : return '18';
		case 19 : return '19';
		default : return '20';
	}
}

enum ESpaceFillMode
{
	ESFM_JustifyLeft,
	ESFM_JustifyRight
}

//Fills string to always be 'length' chars long, adding extra spaces based on 'mode'.
//Does nothing if string's length is greater or equal to 'length'.
function SpaceFill(str : string, length : int, optional mode : ESpaceFillMode) : string
{
	var strLen, i : int;
	
	strLen = StrLen(str);
	if(strLen >= length)
		return str;
		
	if(mode == ESFM_JustifyLeft)
	{
		for(i=0; i<length - strLen; i+=1)
		{
			str += " ";
		}
	}
	else if(mode == ESFM_JustifyRight)
	{
		for(i=0; i<length - strLen; i+=1)
		{
			str = " " + str;
		}
	}
	
	return str;
}

function StrStartsWith(str : string, subStr : string) : bool
{
	return StrFindFirst(str, subStr) == 0;
}

function StrContains(str : string, subStr : string) : bool
{
	return StrFindFirst(str, subStr) >= 0;
}