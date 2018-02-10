-- commands required for tetrahedron to be usable
-- this is just 'rank' for now

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
