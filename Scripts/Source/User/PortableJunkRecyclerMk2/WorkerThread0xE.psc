ScriptName PortableJunkRecyclerMk2:WorkerThread0xE Extends PortableJunkRecyclerMk2:WorkerThreadBase

Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    Debug.TraceUser(ModName, "WorkerThread 0xE: " + asMessage, aiSeverity)
EndFunction