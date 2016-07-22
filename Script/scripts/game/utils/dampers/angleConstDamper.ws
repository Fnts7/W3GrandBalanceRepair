
class AngleConstDamper extends ConstDamper
{
	public function Update( dt : float )
	{
		var dist, diff : float;
		
		diff = AngleDistance( destValue, currValue );
		
		if ( diff > 0.f )
		{
			dist = MinF( dt * deltaValue, diff );
		}
		else
		{
			dist = MaxF( -dt * deltaValue, diff );
		}
		
		currValue = currValue + dist;
		
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
