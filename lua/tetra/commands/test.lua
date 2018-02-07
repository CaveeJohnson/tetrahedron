tetra.commands.register("playermatch", function(caller, line, playerObj)
	tetra.echo(nil, "Matched ", line, " to ", playerObj, ".")
end, "user")

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
