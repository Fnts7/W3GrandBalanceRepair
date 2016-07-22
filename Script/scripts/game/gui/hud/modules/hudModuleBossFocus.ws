//Description: 	Displays boss status indicator (name, health bar) on top of the screen
//Author:		Shadi Dadenji


class CR4HudModuleBossFocus extends CR4HudModuleBase
{	
	//>-----------------------------------------------------------------------------------------------------------------	
	// VARIABLES
	//------------------------------------------------------------------------------------------------------------------
	
	private var m_bossEntity				: CActor;
	private var m_bossName					: string;

	private	var m_fxSetBossName				: CScriptedFlashFunction;
	private	var m_fxSetBossHealth			: CScriptedFlashFunction;
	private	var m_fxSetEssenceDamage		: CScriptedFlashFunction;
	private var m_lastHealthPercentage		: int;
	
	private var m_delay						: float; default m_delay = 1;

	//>-----------------------------------------------------------------------------------------------------------------	
	//------------------------------------------------------------------------------------------------------------------
	/* flash */ event OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorBossFocus";
		
		super.OnConfigUI();
		
		flashModule 			= GetModuleFlash();
		
		m_fxSetBossName			= flashModule.GetMemberFlashFunction( "setBossName" );
		m_fxSetBossHealth		= flashModule.GetMemberFlashFunction( "setBossHealth" );
		m_fxSetEssenceDamage	= flashModule.GetMemberFlashFunction( "setEssenceDamage" );
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if (hud)
		{
			hud.UpdateHudConfig('BossFocusModule', true);
		}
	}
	//>-----------------------------------------------------------------------------------------------------------------
	//------------------------------------------------------------------------------------------------------------------
	
	public function ShowBossIndicator( enable : bool, bossTag : name, optional bossEntity : CActor )
	{
		if ( enable )
		{
			if( bossEntity )
			{
				m_bossEntity = bossEntity;
				UpdateNameAndHealth( true );
			}
			else
			{
				thePlayer.SetBossTag( bossTag ); // it's saved in player so it can be restored after load
				UpdateNameAndHealth( true );
			}

		}
		else
		{
			thePlayer.SetBossTag( '' ); // it's saved in player so it can be restored after load
			
			OnHide();
			
			m_bossEntity = NULL;
			m_bossName = "";
		}
	}

	private function OnShow()
	{
		ShowElement( true ); //#B OnDemand
			
		if ( m_bossEntity )
		{
			m_bossEntity.AddTag( 'HideHealthBarModule' );
		}
	}
	
	private  function OnHide()
	{
		ShowElement(false); //#B OnDemand
		
		if ( m_bossEntity )
		{
			m_bossEntity.RemoveTag( 'HideHealthBarModule' );
			m_bossEntity = NULL;
			m_bossName = "";
		}
	}
	
	private function UpdateNameAndHealth( onShow : bool )
	{
		var bossName : string;
		var bossTag : name;
		var l_currentHealthPercentage : int;
		
		if ( !m_bossEntity )
		{
			bossTag = thePlayer.GetBossTag(); // it's saved in player so it can be restored after load
			if ( IsNameValid( bossTag ) )
			{
				m_bossEntity = theGame.GetActorByTag( bossTag );
				if ( m_bossEntity )
				{
					OnShow();
				}
			}
		}
		else
		{
			if( onShow )
			{
				OnShow();
			}
		}
		
		if ( m_bossEntity )
		{
			bossName = m_bossEntity.GetDisplayName();
			if ( onShow || m_bossName != bossName )
			{
				m_bossName = bossName;
				m_fxSetBossName.InvokeSelfOneArg( FlashArgString( m_bossEntity.GetDisplayName() ) );
			}
			if ( onShow )
			{
				m_fxSetEssenceDamage.InvokeSelfOneArg( FlashArgBool( m_bossEntity.UsesEssence()) );
			}
			
			l_currentHealthPercentage = CeilF( 100 * m_bossEntity.GetHealthPercents() );	//ceiling so that if he has 0.2% it won't show as 0 while he'll be alive
			if ( m_lastHealthPercentage != l_currentHealthPercentage )
			{
				m_fxSetBossHealth.InvokeSelfOneArg( FlashArgInt( l_currentHealthPercentage ) );
				m_lastHealthPercentage = l_currentHealthPercentage;
			}			
		}
	}

	//>-----------------------------------------------------------------------------------------------------------------
	//------------------------------------------------------------------------------------------------------------------
	event OnTick(timeDelta : float)
	{
		if ( m_delay > 0 )
		{
			// lame way to fix TT 120356
			m_delay -= timeDelta;
			return true;
		}
		
		if ( !m_bossEntity )
		{
			// update name & health and show module if there's a tag and no entity
			UpdateNameAndHealth( true );
		}
		else
		{
			// update only health
			UpdateNameAndHealth( false );
		}
	}
	
	//>-----------------------------------------------------------------------------------------------------------------
	//------------------------------------------------------------------------------------------------------------------	

}
