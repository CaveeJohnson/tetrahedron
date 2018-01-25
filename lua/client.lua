net.Receive("tetra_chat", function()
	chat.AddText(unpack(net.ReadTable()))
end)

CreateClientConVar("tetra_delim", " ", true, true, "Delimiter used for chat commands, default is space, another common one is ','.")
