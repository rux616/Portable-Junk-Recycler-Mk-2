ScriptName PortableJunkRecyclerMk2:WorkerThread0x8 Extends PortableJunkRecyclerMk2:WorkerThreadBase

Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    Debug.TraceUser(ModName, "WorkerThread 0x8: " + asMessage, aiSeverity)
EndFunction