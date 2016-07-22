class CR4Test2Popup extends CR4Popup
{
	event /*flash*/ OnConfigUI()
	{	
		LogChannel( 'TestPopup', "OnConfigUI" );
	}
	
	event /*C++*/ OnClosingPopup()
	{
		LogChannel( 'TestPopup', "OnClosingPopup" );
	}

	event /*flash*/ OnClosePopup()
	{
		ClosePopup();
		LogChannel( 'TestPopup', "OnClosePopup" );
	}

}

exec function test2popup()
{
	theGame.RequestPopup( 'Test2Popup' );
}

exec function test2popup2()
{
	theGame.ClosePopup( 'Test2Popup' );
}