class CR4TestPopup extends CR4Popup
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

exec function testpopup()
{
	theGame.RequestPopup( 'TestPopup' );
}

exec function testpopup2()
{
	theGame.ClosePopup( 'TestPopup' );
}