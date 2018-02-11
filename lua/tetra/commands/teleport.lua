tetra.teleport = tetra.teleport or {}

local stacks = tetra.teleport.stacks or {}
tetra.teleport.stacks = stacks

function tetra.teleport.pushBackPos(ply, pos)
	local sid64 = ply:SteamID64()

	stacks[sid64] = stacks[sid64] or {}
	table.insert(stacks[sid64], pos)
end

hook.Add("PlayerDisconnected", "tetra.teleport.back", function(ply)
	tetra.teleport.pushBackPos(ply, ply:GetPos())
end)

function tetra.teleport.popBackPos(ply)
	local sid64 = ply:SteamID64()

	stacks[sid64] = stacks[sid64] or {}
	return table.remove(stacks[sid64]), #stacks[sid64]
end

function tetra.teleport.clearBackStack(ply)
	local sid64 = ply:SteamID64()

	stacks[sid64] = {}
end

local isStuck
do
	local output = {}
	local t = {
		mask = MASK_PLAYERSOLID,
		output = output,
	}

	function isStuck(ply, pos)
		t.start  = pos or ply:GetPos()
		t.endpos = t.start
		t.filter = ply
		util.TraceEntity(t, ply)

		return output.StartSolid
	end
end

function tetra.teleport.lookAt(from, to) -- would be nice to lerp
	local look_at = to:EyePos() - from:EyePos()
	from:SetEyeAngles(look_at:Angle())
end

do
	sound.Add({
		name    = "tetra.teleport.1",
		channel = CHAN_AUTO,
		volume  = 0.5,
		level   = 100,
		pitch   = {100, 125},
		sound   = {"player/resistance_medium1.wav", "player/resistance_medium2.wav", "player/resistance_medium3.wav"}
	})

	sound.Add({
		name    = "tetra.teleport.2",
		channel = CHAN_AUTO,
		volume  = 0.7,
		level   = 100,
		pitch   = {90, 100},
		sound   = {"player/taunt_bumper_car_quit.wav"}
	})

	sound.Add({
		name    = "tetra.teleport.close.1",
		channel = CHAN_AUTO,
		volume  = 0.7,
		level   = 100,
		pitch   = {100, 110},
		sound   = {"replay/cameracontrolerror.wav"}
	})

	sound.Add({
		name    = "tetra.teleport.close.2",
		channel = CHAN_AUTO,
		volume  = 0.4,
		level   = 100,
		pitch   = {90, 95},
		sound   = {"misc/talk.wav"}
	})

	function tetra.teleport.doTeleport(from, to, last_pos, next_pos)
		if from:IsPlayer() then
			if not from:Alive() then from:Spawn()       end
			if from:InVehicle() then from:ExitVehicle() end

			if last_pos then tetra.teleport.pushBackPos(from, last_pos) end
		end

		if next_pos then
			from:SetPos(next_pos)

			from:EmitSound("tetra.teleport.1")
			from:EmitSound("tetra.teleport.2")
		else
			from:EmitSound("tetra.teleport.close.1")
			from:EmitSound("tetra.teleport.close.2")
		end

		if from:IsPlayer() then
			tetra.teleport.lookAt(from, to)
		end
	end
end

function tetra.teleport.sendPlayer(from, to)
	if from == to then
		return true -- self goto
	elseif not (IsValid(from) and IsValid(to)) then
		return false, "invalid entity"
	elseif not to:IsInWorld() then
		return false, "entity not in world"
	end

	local target_pos = to:GetPos()
	local last_pos   = from:GetPos()

	if target_pos:DistToSqr(last_pos) <= 0x00010000 then -- 256 squared
		tetra.teleport.doTeleport(from, to) -- doesn't actually do a tp, just makes them thing they did

		return true
	end

	-- If still, in front of them, if moving, behind them (avoids annoying people who are running / w/e)
	local ang = to:GetVelocity():Length2DSqr() < 1 and (to:IsPlayer() and to:GetAimVector() or to:GetForward()) or -to:GetVelocity()
		ang.z = 0 -- no pitch
		ang:Normalize()
	ang = ang:Angle()
	ang.r = 0 -- no roll

	local orig_y, times = ang.y, 8
	for i = 0, times do
		ang.y = orig_y + (-1) ^ i * (i / times) * 180
		local test_pos = target_pos + ang:Forward() * 64

		for z = 0, 50, 10 do
			local next_pos = test_pos + Vector(0, 0, z)

			if not isStuck(from, next_pos) then
				tetra.teleport.doTeleport(from, to, last_pos, next_pos)

				return true
			end
		end
	end

	if from:IsPlayer() and from:GetMoveType() == MOVETYPE_NOCLIP then
		ang.y = orig_y

		local next_pos = target_pos + ang:Forward() * 64
		tetra.teleport.doTeleport(from, to, last_pos, next_pos)

		return true
	end

	return false, "no free space (noclip to force)"
end


tetra.commands.register("go,goto", function(caller, _, target)
	-- TODO: inheritence / group based 'dont disturb'

	tetra.echo(nil, caller, " teleported to ", target.players[1], ".")
	return tetra.teleport.sendPlayer(caller, target.players[1]) -- don't match once but we do just go to the first one
end, "admin")

:setFullName("Goto")
:setDescription("Teleport yourself to a player.")

:addArgument(TETRA_ARG_PLAYER)
	:setName("Target")
	:setDescription("The player to teleport to.")


tetra.commands.register("bring,acquire", function(caller, _, target)
	-- TODO: inheritence / group based 'dont disturb'

	tetra.echo(nil, caller, " teleported ", target, " to them.")

	for _, v in ipairs(target.players) do
		tetra.teleport.sendPlayer(v, caller)
	end
end, "admin")

:setFullName("Bring")
:setDescription("Teleport players to you.")

:addArgument(TETRA_ARG_PLAYER)
	:setName("Target")
	:setDescription("The player(s) to bring to you.")


tetra.commands.register("back,return", function(caller, _, target)
	local target_ply = target.players[1]
	local forSelf = target_ply == caller
	local back_pos, back_left = tetra.teleport.popBackPos(target_ply)

	if back_pos then
		target_ply:SetPos(back_pos)

		if back_left > 0 then
			tetra.chat(target_ply, tetra.string_color, "Sending you back, ", tetra.number_color, back_left, tetra.string_color, " jumps to go.")
			if not forSelf then tetra.chat(caller, tetra.string_color, "Sending them back, ", tetra.number_color, back_left, tetra.string_color, " jumps to go.") end
		else
			tetra.chat(target_ply, tetra.string_color, "Sending you back, end of the line.")
			if not forSelf then tetra.chat(caller, tetra.string_color, "Sending them back, end of the line.") end
		end
	else
		return false, forSelf and "Nowhere to go back to!" or "Nowhere to send them back to!"
	end
end, "admin")

:setFullName("Back")
:setDescription("Teleport back to your previous location.")
:setSilent(true)

:addArgument(TETRA_ARG_PLAYER)
	:setName("Target")
	:setDescription("The player to send back.")
	:setMatchOnce(true)
	:setDefaultToCaller(true)

do
	sound.Add({
		name    = "tetra.blink.1",
		channel = CHAN_AUTO,
		volume  = 0.4,
		level   = 90,
		pitch   = {150, 155},
		sound   = {"player/suit_sprint.wav"}
	})

	sound.Add({
		name    = "tetra.blink.2",
		channel = CHAN_AUTO,
		volume  = 1,
		level   = 100,
		pitch   = {105, 120},
		sound   = {"passtime/projectile_swoosh2.wav", "passtime/projectile_swoosh3.wav", "passtime/projectile_swoosh4.wav"}
	})

	sound.Add({
		name    = "tetra.blink.impact",
		channel = CHAN_AUTO,
		volume  = 1,
		level   = 100,
		pitch   = 100,
		sound   = {"npc/dog/dog_footstep_run8.wav", "npc/dog/dog_footstep_run6.wav"}
	})

	local res = {}
	local tr  = {output = res}

	tetra.commands.register("blink,emerge", function(caller)
		tr.start  = caller:EyePos()
		tr.endpos = tr.start + caller:GetAimVector() * 16384
		tr.filter = caller
		tr.mins   = caller:OBBMins()
		tr.maxs   = caller:OBBMaxs()
		util.TraceHull(tr)

		local pos = res.HitPos

		if util.IsInWorld(pos) then
			caller:SetPos(pos)
			caller:EmitSound("tetra.blink.1")
			caller:EmitSound("tetra.blink.2")

			local vel = caller:GetVelocity()

			if vel:LengthSqr() >= 100000 then
				caller:EmitSound("tetra.blink.impact")
			end

			caller:SetVelocity(-vel)
		else
			return false, "You cannot blink yourself out of the world."
		end
	end, "admin")

	:setFullName("Blink")
	:setDescription("Teleport to the position you are looking at.")
end
