-- commands which echo information or provide an insight of some kind

tetra.commands.register("uptime,curtime", function(caller)
	tetra.echo(nil, caller, " requested server uptime.")
	tetra.echo(nil, "Server has been up for ", math.Truncate(CurTime() / 3600, 1), " hours.")
end, "user")

:setFullName("Server Uptime")
:setDescription("Echo the time since the server started.")
:setIgnoreArguments(true)
:setConsoleAllowed(true)
