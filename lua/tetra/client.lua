local function find(name)
	local lookup = string.Explode("[%.:]", name, true)
	local f_name = table.remove(lookup, #lookup)

	local f, namespace = nil, _G
	while namespace and not f do
		if #lookup == 0 then
			f = namespace[f_name]
			break
		else
			namespace = namespace[table.remove(lookup, 1)]
		end
	end

	return f, namespace, name:match("^.+:.-$")
end

net.Receive("tetra_rpc", function()
	local name = net.ReadString()
	local f, namespace, meta = find(name)

	local res, err = false, "failed to find method"
	if f then
		if meta then
			res, err = pcall(f, namespace, unpack(net.ReadTable()))
		else
			res, err = pcall(f, unpack(net.ReadTable()))
		end
	end

	if res == false then
		ErrorNoHalt(string.format("tetra.rpc (client): failed for '%s'; %s\n", name, err or "unknown"))
	end
end)

CreateClientConVar("tetra_delim", " ", true, true, "Delimiter used for chat commands, default is space, another common one is ','.")
