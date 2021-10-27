ScriptName PortableJunkRecyclerMk2:WorkerThread0x2 Extends PortableJunkRecyclerMk2:WorkerThreadBase

Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    Debug.TraceUser(ModName, "WorkerThread 0x2: " + asMessage, aiSeverity)
EndFunction