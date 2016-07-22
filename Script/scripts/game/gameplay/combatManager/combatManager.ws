/***********************************************************************/
/** 
/***********************************************************************/
/** Copyright © 2012
/** Author : Patryk Fiutowski
/***********************************************************************/

//no longer used, i'm keeping it commented. just for now. PF
/*
enum CombatTicketType
{
	CTT_Attack,
	CTT_Charge,
	CTT_StepIn,
	CTT_StepOut,
	CTT_Strafe,
	CTT_BattleCry,
	CTT_Leader,
	CTT_TestDoNotUse,
	CTT_WaveAttack,
	CTT_Flying,
	CTT_Shoot,
}

struct W3CombatTicket
{
	var npc			:	CNewNPC;
	var assignTime	: 	float;
	var type		:	CombatTicketType;
	var weight		:	int;
	var priority	:	int;
}


struct W3CombatRequest
{
	var npc			:	CNewNPC;
	var requestTime	:	float;
	var type		:	CombatTicketType;
	var weight		:	int;
	var priority	:	int;
}

struct W3TicketPool
{
	var type				:	CombatTicketType;
	var currVal				:	int;
	var defaultVal			:	int;
	var giveAwayFreq		:	float;
	var ticketValidityTime	:	float;
	var requestValidityTime	:	float;
	var lastGiveAwayTime	:	float;
	var allowInstantGiveAway: 	bool;
	
	default allowInstantGiveAway = false;
}

class W3CombatManager
{
	private var	owner					: CActor;
	
	private var TicketPools				: array< W3TicketPool >;
	private var	Tickets					: array< W3CombatTicket >;
	private var Requests				: array< W3CombatRequest >;
	
	function Initialize( actor : CActor )
	{
		owner = actor;
		PoolInit();
	}
	
	function RequestTicket( npc : CNewNPC, type : CombatTicketType, optional instant : bool )
	{
		
		if ( instant && TicketPools[type].allowInstantGiveAway )
		{
			InstantTicketRequest( npc, type );
		}
		else if ( CanRequestTicket( npc, type ) )
		{
			CreateNewRequest( npc, type );
		}
	}
	
	function CancelTicketRequest( npc : CNewNPC, type : CombatTicketType )
	{
		var i : int;
		
		for ( i = 0; i < Requests.Size() ; i+=1 )
		{
			if ( Requests[i].npc == npc && Requests[i].type == type)
			{
				RemoveRequest(i);
				break;
			}
		}
	}
	
	function HasTicket( npc : CNewNPC, type : CombatTicketType ) : bool
	{
		var i : int;

		for ( i = 0; i < Tickets.Size() ; i+=1 )
		{
			if ( Tickets[i].npc == npc && Tickets[i].type == type)
			{
				return true;
			}
		}
		return false;
	}
	
	function ReleaseTicket( npc : CNewNPC , type : CombatTicketType )
	{
		var i : int;
		
		for ( i = 0; i < Tickets.Size() ; i+=1 )
		{
			if ( Tickets[i].npc == npc && Tickets[i].type == type)
			{
				GiveBackTicket(i);
				break;
			}
		}
	}
	
	function ReleaseAllTickets( npc: CNewNPC )
	{
		var i : int;
		
		for ( i = 0; i < Tickets.Size() ; i+=1 )
		{
			if ( Tickets[i].npc == npc )
			{
				GiveBackTicket(i);
			}
		}
	}
	
	function Update()
	{
		var currTime  : float;
		var i	: int;
		var sortNeeded : bool;
		
		if ( this.Requests.Size() <= 0 )
		{
			return;
		}
		
		sortNeeded = true;
		
		//step1. check if current Tickets and Requests are valid
		TicketsValidityCheck();
		RequestsValidityCheck();
		
		//step2. TicketGiveAway
		for ( i = 0; i < TicketPools.Size(); i+=1)
		{
			if ( ( TicketPools[i].lastGiveAwayTime + TicketPools[i].giveAwayFreq ) <= theGame.GetEngineTimeAsSeconds() )
			{
				if (sortNeeded)
				{
					SortRequests();
					sortNeeded = false;
				}
				TicketGiveAway(i);
			}
		}
		
	}
	
	function SendTicketOwners( type : CombatTicketType ) : array<CActor>
	{
		var i : int;
		var ticketOwners : array<CActor>;
		
		for ( i = 0 ; i < Tickets.Size(); i += 1)
		{
			if ( Tickets[i].type == type)
				ticketOwners.PushBack( (CActor)Tickets[i].npc );
		}
		return ticketOwners;
	}
	//************************** private functions *******************************
	
	private function PoolInit()
	{
		var i : int;
		var size : int;
		var pool : W3TicketPool;
		var type : CombatTicketType;
		size = EnumGetMax( 'CombatTicketType' );
		
		for ( i = 0; i <= size; i+=1 )
		{
			type = i;
			if (type == CTT_Attack)
			{
				pool.type = type;
				pool.defaultVal = 50;
				pool.currVal = 50;
				pool.giveAwayFreq = 2.0;//PFTODO: 2.0
				pool.ticketValidityTime = 10.0;
				pool.requestValidityTime = 10.0;
				TicketPools.PushBack(pool);
			}
			else if (type == CTT_StepIn )
			{
				pool.type = type;
				pool.defaultVal = 50;
				pool.currVal = 50;
				pool.giveAwayFreq = 0.0;
				pool.ticketValidityTime = 5.0;
				pool.requestValidityTime = 10.0;
				TicketPools.PushBack(pool);
			}
			else if (type == CTT_Strafe )
			{
				pool.type = type;
				pool.defaultVal = 150;
				pool.currVal = 150;
				pool.giveAwayFreq = 0.0;
				pool.ticketValidityTime = -1.0;
				pool.requestValidityTime = 10.0;
				TicketPools.PushBack(pool);
			}
			else if (type == CTT_Charge )
			{
				pool.type = type;
				pool.defaultVal = 25;
				pool.currVal = 25;
				pool.giveAwayFreq = 0.0;
				pool.ticketValidityTime = 5.0;
				pool.requestValidityTime = 100.0;
				TicketPools.PushBack(pool);
			}
			else if (type == CTT_TestDoNotUse )
			{
				pool.type = type;
				pool.defaultVal = 0;
				pool.currVal = 0;
				pool.giveAwayFreq = 0.0;
				pool.ticketValidityTime = 5.0;
				pool.requestValidityTime = 100.0;
				TicketPools.PushBack(pool);
			}
			else if (type == CTT_BattleCry )
			{
				pool.type = type;
				pool.defaultVal = 50;
				pool.currVal = 50;
				pool.giveAwayFreq = -1.0;
				pool.ticketValidityTime = 10.0;
				pool.requestValidityTime = 0.5;
				pool.allowInstantGiveAway = true;
				TicketPools.PushBack(pool);
			}
			else if (type == CTT_Leader )
			{
				pool.type = type;
				pool.defaultVal = 50;
				pool.currVal = 50;
				pool.giveAwayFreq = -1.f;
				pool.ticketValidityTime = -1.f;
				pool.requestValidityTime = 1.f;
				pool.allowInstantGiveAway = true;
				TicketPools.PushBack(pool);
			}
			else if (type == CTT_WaveAttack)
			{
				pool.type = type;
				pool.defaultVal = 50;
				pool.currVal = 50;
				pool.giveAwayFreq = 5.0;
				pool.ticketValidityTime = 2.0;
				pool.requestValidityTime = 10.0;
				TicketPools.PushBack(pool);
			}
			else if (type == CTT_Flying)
			{
				pool.type = type;
				pool.defaultVal = 50;
				pool.currVal = 50;
				pool.giveAwayFreq = 40.0;
				pool.ticketValidityTime = 40.0;
				pool.requestValidityTime = 10.0;
				TicketPools.PushBack(pool);
			}
			else if (type == CTT_Shoot)
			{
				pool.type = type;
				pool.defaultVal = 40;
				pool.currVal = 40;
				pool.giveAwayFreq = 0.0;
				pool.ticketValidityTime = 5.0;
				pool.requestValidityTime = 10.0;
				TicketPools.PushBack(pool);
			}
			else
			{
				pool.type = type;
				pool.defaultVal = 100;
				pool.currVal = 100;
				pool.giveAwayFreq = 100.0;
				pool.ticketValidityTime = 10.0;
				pool.requestValidityTime = 10.0;
				TicketPools.PushBack(pool);
			}
		}
		
	}
	
	private function CanRequestTicket( npc : CNewNPC, type : CombatTicketType ) : bool
	{
		var i : int;
		for ( i = 0; i < Tickets.Size(); i+=1 )
		{
			if ( Tickets[i].npc == npc && Tickets[i].type == type )
			{
				return false;
			}
		}
		for ( i = 0; i < Requests.Size(); i+=1 )
		{
			if ( Requests[i].npc == npc && Requests[i].type == type )
			{
				//checks if npc priority changed
				if ( Requests[i].priority != Requests[i].npc.GetPriority() )
				{
					//update the Request
					//PFTODO: should I update the time?
					Requests[i].priority = Requests[i].npc.GetPriority();
				}
				return false;
			}
		}
		return true;
	}

	private function TicketsValidityCheck()
	{
		var i : int;
		var currTime : float;
		var npc : CNewNPC;
		currTime = theGame.GetEngineTimeAsSeconds();
		if ( Tickets.Size() == 0 )
		{
			return;
		}
		for ( i = Tickets.Size()-1; i >= 0; i-=1 )
		{
			if ( TicketPools[Tickets[i].type].ticketValidityTime >= 0 && (currTime - Tickets[i].assignTime) > TicketPools[Tickets[i].type].ticketValidityTime )
			{
				GiveBackTicket(i);
			}
		}
	}
	
	private function RequestsValidityCheck()
	{
		var i : int;
		var currTime : float = theGame.GetEngineTimeAsSeconds();
		
		if ( Requests.Size() == 0 )
		{
			return;
		}
		for ( i = Requests.Size()-1; i >= 0; i-=1 )
		{
			if ( TicketPools[Requests[i].type].requestValidityTime >= 0 && (currTime - Requests[i].requestTime) > TicketPools[Requests[i].type].requestValidityTime )
			{
				RemoveRequest(i);
			}
		}
	}
	
	private function SortRequests()
	{
		var i : int;
		var priorities : array<int>;
		
		if ( Requests.Size() == 0 )
		{
			return;
		}
		
		for ( i = 0; i < Requests.Size() ; i+=1 )
		{
			priorities.PushBack( Requests[i].priority );
		}
		
		SortByKey(Requests,priorities);
	}
	
	private function TicketGiveAway( type : CombatTicketType)
	{
		var i : int;
		var j : int;
		var size : int;
		
		var request : W3CombatRequest;
		
		if ( Requests.Size() == 0 )
		{
			return;
		}
		
		size = Requests.Size();
		
		for ( i=size-1 ; i >=0 ; i-=1 )
		{
			request = Requests[i];
			if ( request.type != type )
			{
				continue;
			}
			Requests.Erase(i);
			if( request.weight <= TicketPools[request.type].currVal)
			{
				TicketPools[request.type].currVal -= request.weight;
				CreateNewTicket( request );
			}
			j = TicketsPriorityCheck( request );
			if ( j > -1 )
			{
				GiveBackTicket(j);
				TicketPools[request.type].currVal -= request.weight;
				CreateNewTicket( request );
			}
		}
		TicketPools[type].lastGiveAwayTime = theGame.GetEngineTimeAsSeconds();
	}
	
	private function CreateNewRequest( npc : CNewNPC , type : CombatTicketType )
	{
		var newRequest : W3CombatRequest;
		newRequest.npc = npc;
		newRequest.type = type;
		newRequest.weight = npc.GetWeight();
		newRequest.priority = npc.GetPriority();
		newRequest.requestTime = theGame.GetEngineTimeAsSeconds();
		Requests.PushBack( newRequest );
	}
	
	private function InstantTicketRequest( npc : CNewNPC , type : CombatTicketType )
	{
		var newRequest : W3CombatRequest;
		newRequest.npc = npc;
		newRequest.type = type;
		newRequest.weight = npc.GetWeight();
		newRequest.priority = npc.GetPriority();
		
		if( newRequest.weight <= TicketPools[newRequest.type].currVal)
		{
			TicketPools[newRequest.type].currVal -= newRequest.weight;
			CreateNewTicket( newRequest );
		}
	}
	
	private function CreateNewTicket( request : W3CombatRequest )
	{
		var newTicket : W3CombatTicket;
		newTicket.npc = request.npc;
		newTicket.type = request.type;
		newTicket.weight = request.weight;
		newTicket.priority = request.priority;
		newTicket.assignTime = theGame.GetEngineTimeAsSeconds();
		this.Tickets.PushBack(newTicket);
	}
	
	private function GiveBackTicket( i : int )
	{
		TicketPools[Tickets[i].type].currVal += Tickets[i].weight;	
		Tickets.Erase(i);
	}
	
	private function RemoveRequest( i : int )
	{
		Requests.Erase(i);
	}
	
	private function TicketsPriorityCheck( request : W3CombatRequest ) : int
	{
		var i : int;
		var priority : int;
		var ticketType : CombatTicketType;
		
		priority = request.priority;
		ticketType = request.type;
		
		for ( i = 0 ; i < this.Tickets.Size() ; i += 1 )
		{
			if ( Tickets[i].type == ticketType )
			{
				if ( (Tickets[i].npc.GetPriority() + 10) < priority && Tickets[i].weight >= request.weight )
				{
					return i;
				}
			}
		}
		return -1;
	}
	
	//***********************SORTING**************************************
	
	private function SortByKey(out requests : array<W3CombatRequest>, out keys : array<int>)
	{
		if(requests.Size() == 0 || keys.Size() == 0 || keys.Size() != requests.Size())
			return;
		SortByKeyQSort(requests,keys,0,requests.Size());
	}

	private function SortByKeyQSort(out requests : array<W3CombatRequest>, out keys : array<int>, start : int, stop : int)
	{
		var i,tmp_i : int;
		var tmp_n : W3CombatRequest;
		
		for(i=start+1; i<stop; i+=1){
			if(keys[start] > keys[i]){
				tmp_i = keys[start];
				keys[start] = keys[i];
				keys[i] = keys[start+1];
				keys[start+1] = tmp_i;
				
				tmp_n = requests[start];
				requests[start] = requests[i];
				requests[i] = requests[start+1];
				requests[start+1] = tmp_n;
				
				start+=1;
			}
		}
		
		if(start > 1)
			SortByKeyQSort(requests,keys,0,start);
		if( (stop-(start+1)) > 1)
			SortByKeyQSort(requests,keys,start+1,stop);
	}
	
	/*
	private function GetPool( type : CombatTicketType ) : W3TicketPool
	{
		var i : int;
		for ( i = 0; i < TicketPools.Size(); i+=1 )
		{
			if ( TicketPools[i].type == type )
			{
				return TicketPools[i];
			}
		}
	}
	*/
	/*
}*/