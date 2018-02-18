tetra.spectate = tetra.spectate or {}

local ongoing = tetra.spectate.ongoing or false
tetra.spectate.ongoing = ongoing

local target = tetra.spectate.target
tetra.spectate.target = target

local roamPos--, thirdperson
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

		if do_it then
			net.Start("tetra_spectate_pos")
				net.WriteVector(roamPos)
			net.SendToServer()
		end

		view.angles = angles
		view.origin = roamPos
	else
		print"FUCK"
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
	elseif movement[bind] then
		movementTrack[bind:sub(2, -1)] = pressed
		return true -- maybe bad, can tell if admins are spectating?
	end
end
hook.Add("PlayerBindPress", "tetra.spectate", tetra.spectate.handleBinds)
