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

do
	tetra.commands.register("sethealth,sethp,health,hp", function(caller, _, target, health)
		for _, ply in ipairs(target.players) do
			ply:SetHealth(health)
		end

		tetra.echo(nil, caller, " set ", target, "'s health to ", health, ".")
	end, "admin")

	:setFullName("Set Health")
	:setDescription("Set the health of players.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to slay silently.")
	:addArgument(TETRA_ARG_NUMBER)
		:setName("Health")
		:setDescription("The health to set.")
end


do
	tetra.commands.register("setarmor,armor", function(caller, _, target, armor)
		for _, ply in ipairs(target.players) do
			ply:SetArmor(armor)
		end

		tetra.echo(nil, caller, " set ", target, "'s armor to ", armor, ".")
	end, "admin")

	:setFullName("Set Armor")
	:setDescription("Set the armor of players.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to slay silently.")
	:addArgument(TETRA_ARG_NUMBER)
		:setName("Armor")
		:setDescription("The armor to set.")
end

do
	tetra.commands.register("stripweapons,strip", function(caller, _, target)
		for _, ply in pairs(target.players) do
			ply:StripWeapons()
		end

		tetra.echo(nil, caller, " stripped ", target, " of their weapons.")
	end, "admin")

	:setFullName("Strip Weapons")
	:setDescription("Strip a player of their weapons.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to strip weapons from.")
		:setDefaultToCaller(true)
end

do -- give weapon
	local prefixes = {
		"",
		"weapon_",
		"basewars_",
		"fas2_",
		"cw_",
	}

	local hl2_weps = {
		"weapon_357",
		"weapon_alyxgun",
		"weapon_annabelle",
		"weapon_ar2",
		"weapon_brickbat",
		"weapon_bugbait",
		"weapon_crossbow",
		"weapon_crowbar",
		"weapon_frag",
		"weapon_physcannon",
		"weapon_pistol",
		"weapon_rpg",
		"weapon_shotgun",
		"weapon_smg1",
		"weapon_striderbuster",
		"weapon_stunstick",
	}
	for _, v in ipairs(hl2_weps) do
		hl2_weps[v] = true
	end

	local real = {}

	tetra.commands.register("give,weapon,giveweapon", function(caller, _, class, target)
		local name
		for _, v in ipairs(prefixes) do
			name = v .. class
			if hl2_weps[name] or weapons.GetStored(name) then break end
		end

		if real[name] == nil then
			local ent = ents.Create(name)
			if not IsValid(ent) then
				return false, string.format("class '%s' exists but could not be spawned", name)
			end

			ent:Remove()
			real[name] = true
		end

		tetra.echo(nil, caller, " gave ", target, " a '", name, "'.")

		for _, v in ipairs(target.players) do
			if v:HasWeapon(name) then v:StripWeapon(name) end

			local wep = v:Give(name, true)
			if IsValid(wep) then
				v:SelectWeapon(name)

				if wep.GetPrimaryAmmoType and wep.GetMaxClip1 then
					local ammo_type = wep:GetPrimaryAmmoType()
					local max_clip  = wep:GetMaxClip1()
					local to_give   = math.max(max_clip * 10, 10)
					v:SetAmmo(math.max(v:GetAmmoCount(ammo_type), to_give), ammo_type)

					if max_clip == -1 then
						wep:SetClip1(-1) -- giving with no ammo bugs ammo counter
					end
				end
				if wep.GetSecondaryAmmoType and wep.GetMaxClip2 then
					local ammo_type = wep:GetSecondaryAmmoType()
					local max_clip  = wep:GetMaxClip2()
					local to_give   = math.max(max_clip * 10, 10)
					v:SetAmmo(math.max(v:GetAmmoCount(ammo_type), to_give), ammo_type)

					if max_clip == -1 then
						wep:SetClip2(-1) -- giving with no ammo bugs ammo counter
					end
				end
			end
		end
	end, "admin")

	:setFullName("Give Weapon")
	:setDescription("Give a player a specific weapon class.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_STRING)
		:setName("Class Name")
		:setDescription("The class of the weapon to give.")
		:setFilter(function(_, class)
			if hl2_weps[class] or hl2_weps["weapon_" .. class] then return end
			for _, v in ipairs(prefixes) do
				if weapons.GetStored(v .. class) then return end
			end

			return string.format("'%s' is not a valid weapon class", class)
		end)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to give the weapon to.")
		:setDefaultToCaller(true)
end
