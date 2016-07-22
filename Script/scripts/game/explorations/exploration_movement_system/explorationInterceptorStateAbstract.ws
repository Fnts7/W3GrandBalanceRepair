// CExplorationInterceptorStateAbstract
//------------------------------------------------------------------------------------------------------------------
// Eduard Lopez Plans	( 12/02/2014 )	 
//------------------------------------------------------------------------------------------------------------------


//>-----------------------------------------------------------------------------------------------------------------
// Base class for all exploration Interceptor states
//------------------------------------------------------------------------------------------------------------------
class CExplorationInterceptorStateAbstract extends CExplorationStateTransitionAbstract
{
	protected	editable	var			m_InterceptStateN	: name;


	//>-----------------------------------------------------------------------------------------------------------------
	public function IsMachForThisStates( _FromN, _ToN : name ) : bool
	{
		return m_InterceptStateN == _ToN;
	}
}