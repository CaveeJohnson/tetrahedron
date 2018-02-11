do
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
		:setFilter(function(_, group)
			if not tetra.users.groups[group:lower()] then
				return string.format("'%s' is not a valid usergroup", group:lower())
			end
		end)
end

do
	tetra.commands.register("kick,boot,cya", function(caller, _, target, reason)
		target.players[1]:Kick(reason or "Kicked from server")

		tetra.echo(nil, caller, " kicked ", target, reason and (" for %q"):format(reason) or "", ".")
	end, "admin")

	:setFullName("Kick")
	:setDescription("Kick a player from the server.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player to kick.")
		:setMatchOnce(true)

	:addArgument(TETRA_ARG_STRING)
		:setName("Reason")
		:setDescription("The reason for the kick.")
		:setOptional(true)
end

do
	local bot_names = {
		"Adam", "April",
		"Aaron", "Amethyst",
		"Benjamin", "Beatrix",
		"Blake", "Bethany",
		"Brad", "Brittany",
		"Callum", "Candace",
		"Connor", "Caroline",
		"Damian", "Danielle",
		"David", "Denise",
		"Eric", "Erica",
		"Elliott", "Eleanor",
		"Felix", "Felicia",
		"Flynn", "Flora",
		"Gabriel", "Garnett",
		"Geoffrey", "Genevieve",
		"Harry", "Harriet",
		"Hugh", "Helen",
		"Ian", "Isabel",
		"Isaac", "Ivy",
		"Jack", "Jacqueline",
		"Jason", "Jasmin",
		"Kaleb", "Kerry",
		"Karl", "Karen",
		"Landon", "Laura",
		"Lenny", "Lavender",
		"Mark", "Magdalene",
		"Mortimer", "Maria",
		"Nick", "Natasha",
		"Noah", "Nicole",
		"Oliver", "Olivia",
		"Owen", "Opal",
		"Patrick", "Patricia",
		"Percival", "Pauline",
		"Quentin", "Queen",
		"Quinn", "Quintella",
		"Ralph", "Rachel",
		"Reagan", "Rebecca",
		"Samuel", "Samantha",
		"Seymour", "Sarah",
		"Taylor", "Theresa",
		"Terence", "Tiffany",
		"Ulysses", "Unity",
		"Upton", "Ursula",
		"Vance", "Valentine",
		"Virgil", "Vanessa",
		"Wade", "Wendy",
		"Wayne", "Wilda",
		"Xander", "Xanthe",
		"Xavier", "Xavia",
		"Yancy", "Yolanda",
		"Yorick", "Yvonne",
		"Zach", "Zelda",
		"Zeph", "Zoe"
	}

	--local modes = {add = true, kick = true, zombie = true}

	tetra.commands.register("bot", function(caller, _, mode, arg)
		if mode == "add" or not mode then
			player.CreateNextBot(arg or ("BOT " .. bot_names[math.random(1, #bot_names)]))
		elseif mode == "kick" then
			for _, ply in ipairs(player.GetBots()) do
				ply:Kick("Kicking every bot")
			end
		elseif mode == "zombie" then
			local zombie = tobool(arg)
			game.ConsoleCommand("bot_zombie " .. (zombie and 1 or 0) .. "\n")

			tetra.echo(nil, caller, zombie and " enabled " or " disabled ", "bot zombie mode.")
		end
	end, "admin")

	:setFullName("Bot")
	:setDescription("Bot operations.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_STRING)
		:setName("Mode")
		:setDescription("Mode of operation. (add, kick, zombie)")
		:setOptional(true)
		-- :setFilter(function(data)
		-- 	if not modes[data] then
		-- 		return "was supplied with an invalid mode"
		-- 	end
		-- end)
	:addArgument(TETRA_ARG_STRING)
		:setName("Argument")
		:setDescription("Depends on the selected mode.")
		:setOptional(true)
end

do
	tetra.commands.register("cleanup,clean", function(caller, _, target)
		tetra.echo(nil, caller, " cleaned up ", target, "'s entities.")
		cleanup.CC_Cleanup(target.players[1], nil, {}) -- doesn't check for nil args, completely fucking retarded
		-- the entire cleanup system is retarded tbh, just be glad bw18 makes UniqueID return SID64
		-- because in the default system collisions can happen and some random russian can delete your shit
	end, "admin")

	:setFullName("Cleanup")
	:setDescription("Clean the props and entities of a specific player.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player to cleanup.")
		:setMatchOnce(true)
		:setDefaultToCaller(true)
end
