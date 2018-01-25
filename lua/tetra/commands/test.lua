tetra.commands.register("uptime,curtime", function(caller)
	tetra.echo(nil, caller, " requested server uptime.")
	tetra.echo(nil, "Server has been up for ", math.Truncate(CurTime() / 3600, 1), " hours.")
end, "player")

:setFullName("Server Uptime")
:setDescription("Echo the time since the server started.")
:setIgnoreArguments(true)


tetra.commands.register("playermatch", function(caller, line, playerObj)
	tetra.echo(nil, "Matched ", line, " to ", playerObj, ".")
end, "player")

:setFullName("Player Match")
:setDescription("Echo the matched players for an argument.")

:addArgument(TETRA_ARG_PLAYER)
	:setName("Match")
	:setFuzzyMatching(true)


tetra.commands.register("alwaysfail", function()
	return false, "This command always fails."
end, "superadmin")

:setFullName("Always Fail")
:setDescription("Always fails, for testing.")
