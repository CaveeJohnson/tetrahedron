tetra.spectate = tetra.spectate or {}

local ongoing = tetra.spectate.ongoing or false
tetra.spectate.ongoing = ongoing

local target = tetra.spectate.target
tetra.spectate.target = target

local roamPos, thirdPerson, nextDoIt
local movementTrack = {}

local function recieveSpectateToggle()
	local started = net.ReadBool()

	if started then
		local new_target = net.ReadEntity()
		roamPos = nil
		target = nil

		if IsValid(new_target) then
			target = new_target
		end

		movementTrack = {}
		ongoing = true
		tetra.spectate.ongoing = true
	else
		ongoing = false
		tetra.spectate.ongoing = false
	end
end
net.Receive("tetra_spectate_notify", recieveSpectateToggle)

-- tetra_spectate_ent

--[[
	local function findNearestObject()
    local aimvec = LocalPlayer():GetAimVector()
    local fromPos = not isRoaming and IsValid(specEnt) and specEnt:EyePos() or roamPos
    local lookingAt = util.QuickTrace(fromPos, aimvec * 5000, LocalPlayer())
    if IsValid(lookingAt.Entity) then return lookingAt.Entity end
    local foundPly, foundDot = nil, 0
    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) or ply == LocalPlayer() then continue end
        local pos = ply:GetShootPos()
        local dot = (pos - fromPos):GetNormalized():Dot(aimvec)
        -- Discard players you're not looking at
        if dot < 0.97 then continue end
        -- not a better alternative
        if dot < foundDot then continue end

        local trace = util.QuickTrace(fromPos, pos - fromPos, ply)

        if trace.Hit then continue end

        foundPly, foundDot = ply, dot
    end

    return foundPly
end
]]

function tetra.spectate.update(ply, origin, angles, fov, znear, zfar)
	if not ongoing then return end

	local view = {}
	view.fov = fov
	view.znear = znear
	view.zfar = zfar
	view.drawviewer = true

	if not IsValid(target) then
		roamPos = roamPos or origin

		local ft = RealFrameTime()
		local vel = 350
		if ply:KeyDown(IN_SPEED) then
			vel = 700
		end
		vel = vel * ft

		local forward = ply:GetAimVector()
		local right   = forward:Angle():Right():GetNormalized()
		local do_it   = false

		if movementTrack["forward"] then
			roamPos = roamPos + forward * vel
			do_it = true
		end

		if movementTrack["back"] then
			roamPos = roamPos - forward * vel
			do_it = true
		end

		if movementTrack["moveright"] then
			roamPos = roamPos + right * vel
			do_it = true
		end

		if movementTrack["moveleft"] then
			roamPos = roamPos - right * vel
			do_it = true
		end

		local ct = CurTime()
		if do_it and (not nextDoIt or CurTime() <= nextDoIt) then
			net.Start("tetra_spectate_pos")
				net.WriteVector(roamPos)
			net.SendToServer()

			nextDoIt = ct + 1
		end

		view.angles = angles
		view.origin = roamPos
	else -- target
		local targOrigin = target:IsPlayer() and target:EyePos() or target:LocalToWorld(target:OBBCenter())

		if thirdPerson then
			local aimVec     = ply:GetAimVector()

			view.angles = target:EyeAngles()
			view.origin = targOrigin
		else
			view.angles = target:IsPlayer() target:EyeAngles()
			view.origin = targOrigin
		end
	end

	return view
end
hook.Add("CalcView", "tetra.spectate", tetra.spectate.update)

function tetra.spectate.start(ent) -- doesn't do setup as we recieve
	net.Start("tetra_spectate_notify")
		net.WriteBit(1)
		net.WriteEntity(ent)
	net.SendToServer()
end

function tetra.spectate.finish() -- does shutdown since the server doesn't get to say no
	ongoing = false
	tetra.spectate.ongoing = false

	net.Start("tetra_spectate_notify")
		net.WriteBit(0)
	net.SendToServer()
end

function tetra.spectate.hotmenu()
	print("tetra open hotmenu for selected ent")
end

function tetra.spectate.toggleEntity()
	if IsValid(target) then
		target = nil
		thirdPerson = nil
	else
		print("attempt to get new target")
	end
end

function tetra.spectate.toggleView()
	thirdPerson = not thirdPerson
end

local movement = {
	["+moveleft"] = true,
	["+moveright"] = true,
	["+forward"] = true,
	["+back"] = true,

	["-moveleft"] = true,
	["-moveright"] = true,
	["-forward"] = true,
	["-back"] = true,
}

function tetra.spectate.handleBinds(ply, bind, pressed)
	if not ongoing then return end
	bind = bind:lower():Trim()

	if bind == "+jump" then
		return tetra.spectate.finish()
	elseif bind == "+attack" then
		tetra.spectate.toggleEntity()
	elseif bind == "+attack2" then
		tetra.spectate.toggleView()
	elseif bind == "+attack3" then
		tetra.spectate.hotmenu()
	elseif movement[bind] then
		movementTrack[bind:sub(2, -1)] = pressed
		return true -- maybe bad, can tell if admins are spectating?
	end
end
hook.Add("PlayerBindPress", "tetra.spectate", tetra.spectate.handleBinds)
