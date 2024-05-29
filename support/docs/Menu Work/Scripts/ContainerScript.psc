ScriptName PortableJunkRecyclerMk2:ContainerScript Extends ObjectReference

Event OnActivate(ObjectReference akActionRef)
    UI.OpenMenu("ContainerMenu")
    ;UI.Load("ContainerMenu", "root1", "", None, "")
    var[] args = new var[2]
    args[0] = "Portable Junk Recycler Mk 2"
    args[1] = 6
    UI.Invoke("ContainerMenu", "root1.FilterHolder_mc.Menu_mc.SetContainerInfo", args)
    UI.Invoke("ContainerMenu", "root1.FilterHolder_mc.Menu_mc.UpdateButtonHints")

EndEvent