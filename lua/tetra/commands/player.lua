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
	:setConsoleAllowed(true)
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
		if not caller:IsAdmin() and not hook.Run("CanPlayerSuicide", caller) then
			return false, "You cannot kill yourself right now"
		end

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

do
	local mapper = {
		["#p"]       = "primary ammo",
		["#s"]       = "secondary ammo",
		ar2          = "AR2 ammo",
		ar2altfire   = "combine ball(s)",
		pistol       = "pistol ammo",
		smg1         = "SMG ammo",
		["357"]      = ".357 ammo",
		xbowbolt     = "crossbow bolt(s)",
		buckshot     = "shotgun ammo",
		rpg_round    = "RPG round(s)",
		smg1_grenade = "SMG grenade(s)",
		grenade      = "grenade(s)",
		slam         = "SLAM ammo"
	}

	tetra.commands.register("giveammo,ammo", function(caller, _, amount, type, target)
		if type and not (type == "#p" or type == "#s") then
			local id = tonumber(type)

			if (id and not game.GetAmmoName(id)) or game.GetAmmoID(type) == -1 then
				return false, "That is an invalid ammo type."
			end
		end

		local ammo

		if type then
			if tonumber(type) then
				ammo = game.GetAmmoName(type)
			else
				ammo = type
			end
		else
			ammo = "#p"
		end

		for _, ply in pairs(target.players) do
			local wep  = ply:GetActiveWeapon()
			local ourAmmo = (ammo == "#p" and wep:GetPrimaryAmmoType()) or (ammo == "#s" and wep:GetSecondaryAmmoType()) or ammo

			local realAmount = math.Clamp(amount or 1e5, 0, 9999)

			ply:GiveAmmo(realAmount, ourAmmo)
		end

		local t = {nil, caller, " gave ", target}

		if amount then
			t[#t + 1] = " "
			t[#t + 1] = amount
		end

		if type then
			t[#t + 1] = " "
			t[#t + 1] = mapper[ammo:lower()] or ("%q ammo"):format(ammo)
			t[#t + 1] = "."
		else
			t[#t + 1] = " ammo."
		end

		tetra.echo(unpack(t))
	end, "admin")

	:setFullName("Give Ammo")
	:setDescription("Give some ammo to players.")
	:setConsoleAllowed(true)

	:addArgument(TETRA_ARG_NUMBER)
		:setName("Amount")
		:setDescription("Amount of ammo to give to the player(s).")
		:setOptional(true)

	:addArgument(TETRA_ARG_STRING)
		:setName("Ammo Type")
		:setDescription("Type of ammo to give. (#p for weapon primary, #s for weapon secondary)")
		:setOptional(true)

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to give ammunition to.")
		:setDefaultToCaller(true)
end

do
	tetra.commands.register("cexec,cmd", function(caller, _, command, target)
		command = command:gsub("%[%[", "\""):gsub("%]%]", "\"") -- no escaping fuckers.

		for _, v in ipairs(target.players) do
			v:SendLua(string.format([=[LocalPlayer():ConCommand([[%s]])]=], command)) -- can't use :ConCommand since it blocks lots of shit on server
		end
	end, "user")

	:setFullName("Client Execute")
	:setDescription("Execute a command on a specific player.")

	:addArgument(TETRA_ARG_STRING)
		:setName("Command")
		:setDescription("The command to call.")

	:addArgument(TETRA_ARG_PLAYER)
		:setName("Target")
		:setDescription("The player(s) to run the command on.")
		:setDefaultToCaller(true)
		:setFilter(function(_, target, caller)
			if not (target:isCallerOnly() or (not IsValid(caller) or caller:IsSuperAdmin())) then
				return "only superadmins can target other players"
			end
		end)
end
