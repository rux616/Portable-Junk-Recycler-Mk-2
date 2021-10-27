ScriptName PortableJunkRecyclerMk2:WorkerThread0xF Extends PortableJunkRecyclerMk2:WorkerThreadBase

Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    Debug.TraceUser(ModName, "WorkerThread 0xF: " + asMessage, aiSeverity)
EndFunction