-- commands which relate to players and performing an action

do
	local me_color = Color(160, 170, 220)
	tetra.commands.register("me", function(caller, line)
		local sentence_end = ""
		if not line:match("%p$") then
			sentence_end = "."
		end

		tetra.chat(nil, me_color, "* ", caller, me_color, " ", line, sentence_end)
	end, "user")

	:setFullName("Me")
	:setDescription("Chat as if you were performing an action.")
	:setSilent(true)
	:setIgnoreArguments(true)
end


do
	tetra.commands.register("setfov,fov", function(caller, _, target, fov)
		for _, ply in ipairs(target.players) do
			ply:SetFOV(fov, 0.5)
		end

		tetra.echo(nil, caller, " set the FOV of ", target, " to ", fov, ".")
	end, "admin")

	:setFullName("Set FOV")
	:setDescription("Change the FOV of players.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to set the FOV of.")
		:setDefaultToCaller(true)
	:addArgument(TETRA_ARG_NUMBER)
		:setName("FOV")
		:setDescription("The FOV (0 to reset).")
end

do
	tetra.commands.register("ignite,roast,burn", function(caller, _, target, time, range)
		for _, ply in ipairs(target.players) do
			ply:Ignite(time or 5, range or 0)
		end

		local t = {caller, " ignited ", target}

		if time then
			t[#t + 1] = " for "
			t[#t + 1] = time
			t[#t + 1] = time == 1 and " second" or " seconds"
		end

		if range then
			t[#t + 1] = " with range "
			t[#t + 1] = range
		end

		t[#t + 1] = "."

		tetra.echo(nil, unpack(t))
	end, "admin")

	:setFullName("Ignite")
	:setDescription("Ignite players.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to ignite.")
		:setDefaultToCaller(true)
	:addArgument(TETRA_ARG_NUMBER)
		:setName("Time")
		:setDescription("How long the ignition will last for.")
		:setOptional(true)
	:addArgument(TETRA_ARG_NUMBER)
		:setName("Range")
		:setDescription("How far the fire will spread.")
		:setOptional(true)
end

do
	tetra.commands.register("unignite,extinguish", function(caller, _, target)
		for _, ply in ipairs(target.players) do
			ply:Extinguish()
		end

		tetra.echo(nil, caller, " extinguished ", target, ".")
	end, "admin")

	:setFullName("Unignite")
	:setDescription("Extinguish players that have been ignited.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to extinguish.")
		:setDefaultToCaller(true)
end

do
	tetra.commands.register("slay,murder", function(caller, _, target)
		for _, ply in ipairs(target.players) do
			ply:Kill()
		end

		tetra.echo(nil, caller, " slayed ", target, ".")
	end, "admin")

	:setFullName("Slay")
	:setDescription("Slay players.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to slay.")
		:setDefaultToCaller(true)
end

do
	tetra.commands.register("sslay,expunge", function(caller, _, target)
		for _, ply in ipairs(target.players) do
			ply:KillSilent()
		end
	end, "admin")

	:setFullName("Silent Slay")
	:setDescription("Slay players with no notification of their death.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to slay silently.")
		:setDefaultToCaller(true)
end

do
	tetra.commands.register("explode,detonate,splode,asplode,boom", function(caller, _, target, magnitude)
		for _, ply in ipairs(target.players) do
			local ent = ents.Create("env_explosion")
			ent:SetPos(ply:GetPos())
			ent:SetKeyValue("iMagnitude", magnitude or 100)
			ent:Spawn()
			ent:Activate()
			ent:Fire("Explode")
		end

		tetra.echo(nil, caller, " exploded ", target, magnitude and " with a magnitude of " or "", magnitude or "", ".")
	end, "admin")

	:setFullName("Explode")
	:setDescription("Explode players.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to explode.")
		:setDefaultToCaller(true)
	:addArgument(TETRA_ARG_NUMBER)
		:setName("Magnitude")
		:setDescription("The magnitude of the explosion.")
		:setOptional(true)
end


do
	tetra.commands.register("revive,resuscitate,resurrect", function(caller, _, target)
		for _, ply in ipairs(target.players) do
			local oldpos = ply:GetPos()
			local oldang = ply:EyeAngles()

			ply:Spawn()
			ply:SetPos(oldpos)
			ply:SetEyeAngles(oldang)
		end

		tetra.echo(nil, caller, " revived ", target, ".")
	end, "admin")

	:setFullName("Revive")
	:setDescription("Respawn players at their last position.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to revive.")
		:setFilter(function(_, plyObj)
		    if not plyObj:filter(function(ply)
		        return not ply:Alive()
		    end) then return "did not match any suitable players" end
		end)
		:setDefaultToCaller(true)
end

do
	tetra.commands.register("respawn,spawn", function(caller, _, target)
		for _, ply in ipairs(target.players) do
			ply:Spawn()
		end

		tetra.echo(nil, caller, " has respawned ", target, ".")
	end, "admin")

	:setFullName("Respawn")
	:setDescription("Respawn players at a spawnpoint.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to respawn.")
		:setDefaultToCaller(true)
end

do
	tetra.commands.register("suicide,die,kill,kms,wrist", function(caller)
		caller:Kill()
	end, "user")

	:setFullName("Suicide")
	:setDescription("Commit suicide.")
end
