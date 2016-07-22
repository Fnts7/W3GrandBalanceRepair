class W3Effect_GryphonSetBonus extends CBaseGameplayEffect
{
	protected var m_whichSignForFree : W3SignEntity;
	
	default effectType = EET_GryphonSetBonus;
	default isPositive = true;
	
	public function SetWhichSignForFree( s : W3SignEntity )
	{
		m_whichSignForFree = s;
	}
	
	public function GetWhichSignForFree() : W3SignEntity
	{
		return m_whichSignForFree;
	}
}