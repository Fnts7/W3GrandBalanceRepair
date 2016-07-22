/***********************************************************************/
/** Copyright © 2013
/** Author : Tomek Kozera, Andrzej Kwiatkowski
/***********************************************************************/

enum EMerchantMapPinType
{
	EMMPT_Shopkeeper,
	EMMPT_Blacksmith,
	EMMPT_Armorer,
	EMMPT_BoatBuilder,
	EMMPT_Hairdresser,
	EMMPT_Herbalist,
	EMMPT_Alchemist,
	EMMPT_Innkeeper,
	EMMPT_Enchanter,
	EMMPT_DyeTrader,
	EMMPT_WineTrader,
	EMMPT_Cammerlengo
}

class W3MerchantComponent extends CScriptedComponent
{
	editable var mapPinType : EMerchantMapPinType;
	default mapPinType = EMMPT_Shopkeeper;

	public function GetMapPinType() : name
	{
		switch( mapPinType )
		{
			case EMMPT_Shopkeeper:
				return 'Shopkeeper';
			case EMMPT_Blacksmith:
				return 'Blacksmith';
			case EMMPT_Armorer:
				return 'Armorer';
			case EMMPT_BoatBuilder:
				return 'BoatBuilder';
			case EMMPT_Hairdresser:
				return 'Hairdresser';
			case EMMPT_Alchemist:
				return 'Alchemic';
			case EMMPT_Herbalist:
				return 'Herbalist';
			case EMMPT_Innkeeper:
				return 'Innkeeper';
			case EMMPT_Enchanter:
				return 'Enchanter';
			case EMMPT_DyeTrader:
				return 'DyeMerchant';
			case EMMPT_WineTrader:
				return 'WineMerchant';
			case EMMPT_Cammerlengo:
				return 'Cammerlengo';
		}
		return '';
	}

	// do not delete or modify, called from C++
	public function /* C++ */ GetScriptInfo( type : name, cacheable : bool )
	{
		var merchantNPC : W3MerchantNPC;

		merchantNPC = (W3MerchantNPC)GetEntity();

		// type
		type = GetMapPinType();
		
		// cacheable
		cacheable = merchantNPC.cacheMerchantMappin;
	}
};
