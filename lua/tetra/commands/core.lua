tetra.commands.register("uptime,curtime", function(caller)
	tetra.echo(nil, caller, " requested server uptime.")
	tetra.echo(nil, "Server has been up for ", math.Truncate(CurTime() / 3600, 1), " hours.")
end, "user")

:setFullName("Server Uptime")
:setDescription("Echo the time since the server started.")
:setIgnoreArguments(true)
:setConsoleAllowed(true)


tetra.commands.register("rank,adduser,setrank,promote,usergroup", function(caller, line, target, group)
	group = group:lower()

	tetra.echo(nil, caller, " has set ", target, "'s usergroup to '", group, "'.")
	tetra.users.setGroup(target.players[1], group)
end, "superadmin")

:setFullName("Set UserGroup")
:setDescription("Change a player's usergroup.")
:setConsoleAllowed(true)

:addArgument(TETRA_ARG_PLAYER)
	:setName("Target")
	:setDescription("The player to change the usergroup of.")
	:setMatchOnce(true)

:addArgument(TETRA_ARG_STRING)
	:setName("User Group")
	:setDescription("The target's new usergroup.")
	:setFilter(function(data, group)
		if not tetra.users.groups[group:lower()] then
			return string.format("'%s' is not a valid usergroup", group)
		end
	end)
