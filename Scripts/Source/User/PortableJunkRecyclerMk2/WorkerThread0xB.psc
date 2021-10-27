ScriptName PortableJunkRecyclerMk2:WorkerThread0xB Extends PortableJunkRecyclerMk2:WorkerThreadBase

Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    Debug.TraceUser(ModName, "WorkerThread 0xB: " + asMessage, aiSeverity)
EndFunction