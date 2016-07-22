import struct SMultiValue
{
	import var floats		: array< float >; 
	import var bools 		: array< bool >; 
	import var enums 		: array< SEnumVariant >	;
	import var names		: array<name>;
};
// event OnParryStartEvent( eventName : name, properties : SEnumVariant, type : EAnimationEventType, duration : Float );

// Custom anim events structures

import struct SSlideToTargetEventProps
{
	import var	minSlideDist				: float;
	import var	maxSlideDist				: float;
	import var	slideToMaxDistIfTargetSeen	: bool;
	import var	slideToMaxDistIfNoTarget	: bool;
};

// Event called when 'SlideToTarget' anim event executed:
// event OnSlideToTargetAnimEvent( eventName : name, properties : SSlideToTargetEventProps, type : EAnimationEventType, duration : Float, sourceAnim : CSkeletalAnimationSetEntry, localAnimTime : float, eventEndsAtTime : float );


//////////////////////////////////////////////
//////////////////////////////////////////////


import struct SEnumVariant
{
	import var	enumType	: name;
	import var	enumValue	: int;
};

// Event called when 'Enum' anim event executed:
// event OnEnumAnimEvent( eventName : name, variant : SEnumVariant, type : EAnimationEventType, duration : Float, sourceAnim : CSkeletalAnimationSetEntry, localAnimTime : float, eventEndsAtTime : float );


import struct SAnimationEventAnimInfo
{
};

// extract animation name from animation event anim info
import function GetAnimNameFromEventAnimInfo( eventAnimInfo : SAnimationEventAnimInfo ) : name;

// extract local time from animation event anim info
import function GetLocalAnimTimeFromEventAnimInfo( eventAnimInfo : SAnimationEventAnimInfo ) : float;

// extract event duration from animation event anim info
import function GetEventDurationFromEventAnimInfo( eventAnimInfo : SAnimationEventAnimInfo ) : float;

// extract event duration end local timn from animation event anim info
import function GetEventEndsAtTimeFromEventAnimInfo( eventAnimInfo : SAnimationEventAnimInfo ) : float;
