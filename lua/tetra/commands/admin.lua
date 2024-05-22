do
	tetra.commands.register("rank,adduser,setrank,promote,usergroup", function(caller, line, target, group)
		if not tetra.users then return false, "Tetra is sideloaded: User management is denied." end

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
			if tetra.users and not tetra.users.groups[group:lower()] then
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

do
	local whitelist = {
		"sv_cheats",
	}

	tetra.commands.register("replicate", function(caller, _, cvar, value, target)
		if not GetNetChannel and not NetChannel and not CNetChan then
			pcall(require, "cvar3")
		end

		local func = caller.SetConVar or caller.ReplicateData
		if not func then return false, "Module CVar3 is missing or failed to load" end

		target:forEach(func, cvar, value)
	end, "admin")

	:setFullName("Replicate ConVar")
	:setDescription("Change the value of a replicated convar for a specific client.")
	:setSilent(true)
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_STRING)
		:setName("CVar Name")
		:setDescription("The convar to change the value of.")
		:setFilter(function(_, cvar, caller)
			if not (whitelist[cvar] or (not IsValid(caller) or caller:IsSuperAdmin())) then
				return "'%s' is not on the convar whitelist for admins"
			end
		end)

	:addArgument(TETRA_ARG_STRING)
		:setName("Value")
		:setDescription("The new value to replicate.")

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to replicate the convar on.")
		:setDefaultToCaller(true)
		:setFilter(function(_, target, caller)
			if not (target:isCallerOnly() or (not IsValid(caller) or caller:IsSuperAdmin())) then
				return "only superadmins can target other players"
			end
		end)
end

do
	tetra.commands.register("rcon", function(caller, line)
		game.ConsoleCommand(line .. "\n")
	end, "superadmin")

	:setFullName("Remote Console")
	:setDescription("Execute a command on the server.")
	:setIgnoreArguments(true)
	:setSilent(true)
end

do
	tetra.commands.register("noclip", function(caller, _, target)
		tetra.echo(nil, caller, " noclipped ", target, ".")

		for _, v in ipairs(target.players) do
			v:SetMoveType(MOVETYPE_NOCLIP)
		end
	end, "admin")

	:setFullName("Noclip")
	:setDescription("Force players to enter noclip.")

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to make noclip.")
		:setDefaultToCaller(true)
		:setFilter(function(_, target, caller)
			if not (target:isCallerOnly() or (not IsValid(caller) or caller:IsSuperAdmin())) then
				return "only superadmins can target other players"
			end
		end)
end

do
	tetra.commands.register("unrestrict,unrestricted,restrictions,restrict,restricted", function(caller)
		if caller.Unrestricted then
			tetra.echo(nil, caller, " became restricted, ", {text = "admin abuse over", color = Color(150, 255, 150)}, ".")

			caller.Unrestricted = nil
			caller:SetNWBool("Unrestricted", false)
			caller:SetNW2Bool("Unrestricted", false)
		else
			tetra.echo(nil, caller, " became unrestricted, ", {text = "admin abuse incoming", color = Color(255, 150, 150)}, ".")

			caller.Unrestricted = true
			caller:SetNWBool("Unrestricted", true)
			caller:SetNW2Bool("Unrestricted", true)
		end
	end, "superadmin")

	:setFullName("Unrestricted Mode")
	:setDescription("Toggle Unrestricted, only ever applies to caller.")
	:setIgnoreArguments(true)
	:setSilent(true)
end
