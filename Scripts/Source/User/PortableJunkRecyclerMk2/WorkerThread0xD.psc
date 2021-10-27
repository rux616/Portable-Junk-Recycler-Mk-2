ScriptName PortableJunkRecyclerMk2:WorkerThread0xD Extends PortableJunkRecyclerMk2:WorkerThreadBase

Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    Debug.TraceUser(ModName, "WorkerThread 0xD: " + asMessage, aiSeverity)
EndFunction