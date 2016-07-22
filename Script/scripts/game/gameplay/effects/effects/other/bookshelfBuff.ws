///////////////////////////////
//  Copyright © 2016		 //
//	Author: Andrzej Zawadzki //
///////////////////////////////

class W3Effect_BookshelfBuff extends CBaseGameplayEffect
{
	default effectType = EET_BookshelfBuff;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "message_common_bookshelf_buff_applied" ),, true );
		super.OnEffectAdded( customParams );
	}
	
	protected function CumulateWith( effect : CBaseGameplayEffect )
	{
		theGame.GetGuiManager().ShowNotification( GetLocStringByKeyExt( "message_common_bookshelf_buff_applied" ),, true );
		super.CumulateWith( effect );
	}
}