import struct SItemReward
{
	import var item		: name;
	import var amount	: int;
};

import struct SReward
{
	import var experience	: int;
	import var gold			: int;
	import var items		: array< SItemReward >;
	import var achievement	: int;
	import var level		: int;
};