
// Functions used to turn  ON/OFF new profiler
import function PROFILER_Init( bufforSize : int );
import function PROFILER_InitEx( bufforSize : int, bufforSignalsSize : int );
import function PROFILER_ScriptEnable();
import function PROFILER_ScriptDisable();
import function PROFILER_Start();
import function PROFILER_Stop();
import function PROFILER_Store( profileName : string );
import function PROFILER_StoreDef();
import function PROFILER_StoreInstrFuncList();
import function PROFILER_StartCatchBreakpoint();
import function PROFILER_StopCatchBreakpoint();
import function PROFILER_SetTimeBreakpoint( instrFuncName : string, time : float, stopOnce : bool );
import function PROFILER_SetHitCountBreakpoint( instrFuncName : string, counter : int );
import function PROFILER_DisableTimeBreakpoint( instrFuncName : string );
import function PROFILER_DisableHitCountBreakpoint( instrFuncName : string );
	