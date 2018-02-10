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
		:setFilter(function(data, group)
			if not tetra.users.groups[group:lower()] then
				return string.format("'%s' is not a valid usergroup", group)
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
		else
			if mode == "kick" then
				for _, ply in pairs(player.GetBots()) do
					ply:Kick("Kicking every bot")
				end
			elseif mode == "zombie" then
				local zombie = tobool(arg)
				game.ConsoleCommand("bot_zombie " .. (zombie and 1 or 0) .. "\n")

				tetra.echo(nil, caller, zombie and " enabled " or " disabled ", "bot zombie mode.")
			end
		end
	end, "admin")

	:setFullName("Bot")
	:setDescription("Bot operations")
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
