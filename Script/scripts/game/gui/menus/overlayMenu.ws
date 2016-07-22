/***********************************************************************/
/** Witcher Script file - Base class 
/***********************************************************************/
/** Copyright © 2014 CDProjektRed
/** Author : Yaroslav Getsevich
/***********************************************************************/

class CR4OverlayMenu extends CR4MenuBase
{
	var m_BlurBackground : bool;
	var m_PauseGame		 : bool;

	event /*flash*/ OnConfigUI()
	{
		super.OnConfigUI();
		
		if (m_BlurBackground)
		{
			BlurBackground(this, true);
		}
	}
	
	event /*flash*/ OnCloseMenu()
	{
		RequestClose();
	}
	
	event /* C++ */ OnClosingMenu()
	{
		if (m_BlurBackground)
		{
			BlurBackground(this, false);
		}
		super.OnClosingMenu();
	}
	
	public function RequestClose():void
	{
		CloseMenu();
	}
	
	protected function BlurBackground(firstLayer : CR4MenuBase, value : bool) : void
	{
		if (firstLayer.m_parentMenu)
		{
			BlurBackground(firstLayer.m_parentMenu, value);
			firstLayer.m_parentMenu.BlurLayer(value);
		}
	}

}