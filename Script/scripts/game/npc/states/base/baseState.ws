// States from C++
import state Base in CNewNPC
{
	event OnEnterState( prevStateName : name )
	{	
		parent.ActionCancelAll();
	}
};

// Base state supporting reactions
import state ReactingBase in CNewNPC extends Base
{	
};