//>---------------------------------------------------------------
//----------------------------------------------------------------
class CR4Component extends CScriptedComponent
{
	// Function will be called if the component is added as a listener in the CActor it is attached to
	public function IgniHit()
	{
		OnIgniHit();
	}
	public function AardHit ()
	{
		OnAardHit();
	}
	
	event OnIgniHit()
	{
		//LogAssert(false,"CR4Component hit by Igni");
	}
	
	event OnAardHit()
	{
		//LogAssert(false,"CR4Component hit by Aard");
	}
}