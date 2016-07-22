// States from C++
import state Base in CPlayer 
{
	// Createe no save lock for state
	import final function CreateNoSaveLock();
	
	function CanAccesFastTravel( target : W3FastTravelEntity ) : bool
	{
		return true;
	}
}