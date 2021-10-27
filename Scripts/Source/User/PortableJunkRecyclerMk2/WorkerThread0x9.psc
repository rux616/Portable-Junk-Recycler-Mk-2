ScriptName PortableJunkRecyclerMk2:WorkerThread0x9 Extends PortableJunkRecyclerMk2:WorkerThreadBase

Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    Debug.TraceUser(ModName, "WorkerThread 0x9: " + asMessage, aiSeverity)
EndFunction