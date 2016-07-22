/***********************************************************************/
/** Witcher Script file
/***********************************************************************/
/** Array functions list
/** Copyright © 2010
/***********************************************************************/

/*array< T >
{
	// Element access
	operator[int index] : T;

	// Clear array
	function Clear();

	// Get array size
	function Size() : int;
	
	// Add element at the end of array
	function PushBack( element : T );
	
	// Remove element at the end of array
	function PopBack() : T;

	// Resize array
	function Resize( newSize : int );
	
	// Remove given element, returns false if not found
	function Remove( element : T ) : bool;
	
	// Does array contain element?
	function Contains( element : T ) : bool;

	// Find first element, returns -1 if not found
	function FindFirst( element : T ) : int;

	// Find last element, returns -1 if not found
	function FindLast( element : T ) : int;
	
	// Add space to array, returns new size
	function Grow( numElements : int ) : int;
	
	// Erase place in array
	function Erase( index : int );
	
	// Insert item at given position
	function Insert( index : int, element : T );
	
	// Get last element
	function Last() : T;
};*/

// Returns index of highest element
function ArrayFindMaxF( a : array< float > ) : int
{
	var i, s, index : int;
	var val : float;	
	
	s = a.Size();
	if( s > 0 )
	{			
		index = 0;
		val = a[0];
		for( i=1; i<s; i+=1 )
		{
			if( a[i] > val )
			{
				index = i;
				val = a[i];
			}
		};
		
		return index;
	}	
	
	return -1;			
}

// Returns index of highest element using a mask to mask out some of the values
function ArrayMaskedFindMaxF( a : array< float >, thresholdVal : float ) : int
{
	var i, s, index : int;
	var val : float;	
	
	s = a.Size();
	if( s > 0 )
	{			
		val = a[0];
		if ( val < thresholdVal )
		{
			index = 0;
		}
		else
		{
			index = -1;
			val = -100000000;
		}
		for( i=1; i<s; i+=1 )
		{
			if( a[i] > val && a[i] < thresholdVal )
			{
				index = i;
				val = a[i];
			}
		};
		
		return index;
	}	
	
	return -1;			
}


// Returns index of lowest element
function ArrayFindMinF( a : array< float > ) : int
{
	var i, s, index : int;
	var val : float;	
	
	s = a.Size();
	if( s > 0 )
	{			
		index = 0;
		val = a[0];
		for( i=1; i<s; i+=1 )
		{
			if( a[i] < val )
			{
				index = i;
				val = a[i];
			}
		};
		
		return index;
	}	
	
	return -1;			
}

// Returns index of lowest element
function ArrayFindMinIndexInt( a : array< int > ) : int
{
	var i, s, val, index : int;
	
	s = a.Size();
	if( s > 0 )
	{			
		index = 0;
		val = a[0];
		for( i=1; i<s; i+=1 )
		{
			if( a[i] < val )
			{
				index = i;
				val = a[i];
			}
		}
		
		return index;
	}	
	
	return -1;			
}

// Returns index of lowest element
function ArrayFindMinInt( a : array< int > ) : int
{
	var i, s, val : int;
	
	s = a.Size();
	if( s > 0 )
	{			
		val = a[0];
		for( i=1; i<s; i+=1 )
		{
			if( a[i] < val )
			{
				val = a[i];
			}
		}
		
		return val;
	}	
	
	return -1;			
}

// Returns index of highest element
function ArrayFindMaxInt( a : array< int > ) : int
{
	var i, s, val, index : int;
	
	s = a.Size();
	if( s > 0 )
	{			
		index = 0;
		val = a[0];
		for( i=1; i<s; i+=1 )
		{
			if( a[i] > val )
			{
				index = i;
				val = a[i];
			}
		};
		
		return index;
	}	
	
	return -1;			
}

function ArraySortNames(out names : array<name>)
{
	var i, j, size : int;
	var ret : array<name>;
	var found : bool;
	
	if(names.Size() <= 0)
		return;
		
	size = names.Size();	
	ret.PushBack(names[0]);
	
	for(i=1; i<size; i+=1)
	{
		found = false;
		
		for(j=0; j<ret.Size(); j+=1)
		{
			if( StrCmp( StrLower(NameToString(names[i])), StrLower(NameToString(ret[j]))) < 0 )
			{
				ret.Insert(j, names[i]);
				found = true;
				break;
			}
		}
		
		if ( !found )
		{
			ret.PushBack(names[i]);
		}
	}
	
	names.Clear();
	names = ret;
}

/**
	Sorts the array using given array of keys. The keys array is sorted as well.
*/
function ArraySortNamesByKey(out names : array<name>, out keys : array<int>){
	if(names.Size() == 0 || keys.Size() == 0 || keys.Size() != names.Size())
		return;
	ArraySortNamesByKeyQSort(names,keys,0,names.Size());
}

function ArraySortNamesByKeyQSort(out names : array<name>, out keys : array<int>, start : int, stop : int){
	var i,tmp_i : int;
	var tmp_n : name;
	
	for(i=start+1; i<stop; i+=1){
		if(keys[start] > keys[i]){
			tmp_i = keys[start];
			keys[start] = keys[i];
			keys[i] = keys[start+1];
			keys[start+1] = tmp_i;
			
			tmp_n = names[start];
			names[start] = names[i];
			names[i] = names[start+1];
			names[start+1] = tmp_n;
			
			start+=1;
		}
	}
  
	if(start > 1)
		ArraySortNamesByKeyQSort(names,keys,0,start);
	if( (stop-(start+1)) > 1)
		ArraySortNamesByKeyQSort(names,keys,start+1,stop);
}

function ArraySortNPCsByKey(out actors : array<CNewNPC>, out keys : array<int>){
	if(actors.Size() == 0 || keys.Size() == 0 || keys.Size() != actors.Size())
		return;
	ArraySortNPCsByKeyQSort(actors,keys,0,actors.Size());
}

function ArraySortNPCsByKeyQSort(out actors : array<CNewNPC>, out keys : array<int>, start : int, stop : int){
	var i,tmp_i : int;
	var tmp_n : CNewNPC;
	
	for(i=start+1; i<stop; i+=1){
		if(keys[start] > keys[i]){
			tmp_i = keys[start];
			keys[start] = keys[i];
			keys[i] = keys[start+1];
			keys[start+1] = tmp_i;
			
			tmp_n = actors[start];
			actors[start] = actors[i];
			actors[i] = actors[start+1];
			actors[start+1] = tmp_n;
			
			start+=1;
		}
	}
  
	if(start > 1)
		ArraySortNPCsByKeyQSort(actors,keys,0,start);
	if( (stop-(start+1)) > 1)
		ArraySortNPCsByKeyQSort(actors,keys,start+1,stop);
}

import function ArraySortInts   ( out arrayToSort : array< int > );
import function ArraySortFloats ( out arrayToSort : array< float > );
import function ArraySortStrings( out arrayToSort : array< string > );

// Appends second array to the first array (at the end)
function ArrayOfNamesAppend(out first : array<name>, second : array<name>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
		first.PushBack(second[i]);
}

// Appends second array to the first array (at the end) skipping duplicate elements
function ArrayOfNamesAppendUnique(out first : array<name>, second : array<name>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
	{
		if(!first.Contains(second[i]))
		{
			first.PushBack(second[i]);
		}
	}
}

// Pushes back name to the array (at the end) skipping duplicate elements
function ArrayOfNamesPushBackUnique(out arr : array<name>, val : name)
{
	if ( !arr.Contains( val ) )
	{
		arr.PushBack( val );
	}
}

// Appends second array to the first array (at the end)
function ArrayOfActorsAppend(out first : array<CActor>, second : array<CActor>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
		first.PushBack(second[i]);
}

// Appends second array to the first array (at the end)
function ArrayOfActorsAppendUnique(out first : array<CActor>, second : array<CActor>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
	{
		if( !first.Contains( second[i] ) )
		{
			first.PushBack(second[i]);
		}
	}
}

// Appends array of gameplay entities to the array of actors
function ArrayOfActorsAppendArrayOfGameplayEntities(out first : array< CActor >, second : array< CGameplayEntity >)
{
	var i, s : int;
	var actor : CActor;
	
	s = second.Size();
	for ( i = 0; i < s; i+=1 )
	{
		actor = (CActor)second[i];
		if ( actor )
		{
			first.PushBack( actor );
		}
	}
}

// Appends second array to the first array (at the end)
function ArrayOfIdsAppend(out first : array<SItemUniqueId>, second : array<SItemUniqueId>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
		first.PushBack(second[i]);
}

// Appends second array to the first array (at the end) skipping duplicate elements
function ArrayOfIdsAppendUnique(out first : array<SItemUniqueId>, second : array<SItemUniqueId>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
	{
		if (!first.Contains(second[i]))
		{
			first.PushBack(second[i]);
		}
	}
}


// Appends second array to the first array (at the end)
function ArrayOfGameplayEntitiesAppendArrayOfActorsUnique(out first : array<CGameplayEntity>, second : array<CActor>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
	{
		if (!first.Contains(second[i]))
		{
			first.PushBack(second[i]);
		}
	}
}

// Appends second array to the first array (at the end)
function ArrayOfGameplayEntitiesAppendUnique(out first : array<CGameplayEntity>, second : array<CGameplayEntity>)
{
	var i, s : int;
	
	s = second.Size();
	for(i=0; i<s; i+=1)
	{
		if (!first.Contains(second[i]))
		{
			first.PushBack(second[i]);
		}
	}
}

function ArrayOfNamesCount(arr : array<name>, item : name) : int
{
	var i, cnt : int;
	
	cnt = 0;
	for(i=0; i<arr.Size(); i+=1)
		if(arr[i] == item)
			cnt += 1;
			
	return cnt;
}

function ArrayOfNamesRemoveAll(out arr : array<name>, item : name)
{
	var i : int;
	
	while(true)
	{
		i = arr.FindFirst(item);
		if(i == -1)
			return;
			
		arr.Erase(i);
	}
}

//Returns array containing strings existing in 'toRemoveFrom' array but not existing in 'toRemove' array
function ArrayOfStringsRemove( toRemoveFrom : array< string >, toRemove : array< string > ) : array < string >
{
	var i : int;
	var ret : array< string >;
	
	for( i=0; i<toRemoveFrom.Size(); i+=1 )
	{
		if( !toRemove.Contains( toRemoveFrom[i] ) )
		{
			ret.PushBack( toRemoveFrom[i] );
		}
	}
	
	return ret;
}

//Random Order - order of elements may change as a result of using this function
function ArrayOfStringsRemoveDuplicatesRO( out arr : array< string > )
{
	var i,j : int;
	
	if( arr.Size() < 2 )
	{
		return;
	}
	
	for( i=arr.Size()-2; i>=0; i-= 1 )
	{
		for( j=arr.Size()-1; j>i; j-=1 )
		{
			if( arr[j] == arr[i] )
			{
				arr.EraseFast( i );
				break;
			}
		}
	}
}