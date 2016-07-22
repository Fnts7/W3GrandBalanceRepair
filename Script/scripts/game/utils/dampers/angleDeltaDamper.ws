
class AngleDeltaDamper extends DeltaDamper
{
	public function Update( dt : float )
	{
		currValue = currValue + ClampF( dt * dampFactor, 0.f, 1.f ) * AngleDistance( destValue, currValue );
		
		if( currValue < -180.0f ) 
		{
			currValue += 360.0f;
		}
		else if( currValue  > 180.0f )
		{
			currValue -= 360.0f;
		}
	}
}
