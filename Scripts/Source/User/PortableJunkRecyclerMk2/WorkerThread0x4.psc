ScriptName PortableJunkRecyclerMk2:WorkerThread0x4 Extends PortableJunkRecyclerMk2:WorkerThreadBase

Function _DebugTrace(string asMessage, int aiSeverity = 0) DebugOnly
    Debug.TraceUser(ModName, "WorkerThread 0x4: " + asMessage, aiSeverity)
EndFunction