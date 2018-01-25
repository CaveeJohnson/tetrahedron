util.AddNetworkString("tetra_rpc")

function tetra.rpc(ply, method, metamethod, ...)
	net.Start("tetra_rpc")
		net.WriteString(method)
		net.WriteBool(metamethod)

		net.WriteTable{...}
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end
