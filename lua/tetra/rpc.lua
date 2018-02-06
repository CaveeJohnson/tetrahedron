util.AddNetworkString("tetra_rpc")

function tetra.rpc(ply, method, ...)
	net.Start("tetra_rpc")
		net.WriteString(method)

		net.WriteTable{...}
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end
