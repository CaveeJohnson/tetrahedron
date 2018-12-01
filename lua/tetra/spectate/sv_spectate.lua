tetra.spectate = tetra.spectate or {}

local list = tetra.spectate.list or {}
tetra.spectate.list = list

local function cleanList()
	local new = {}
	for k, data in pairs(list) do
		if IsValid(k) then new[k] = data end
	end
	list                = new
	tetra.spectate.list = new
end

function tetra.spectate.updatePVS(ply)
	local data = list[ply]
	if not data then return end

	-- only one at once, otherwise redundant
	if data.pos then
		AddOriginToPVS(data.pos)
	elseif IsValid(data.ent) then
		AddOriginToPVS(data.ent:EyePos())
	end
end
hook.Add("SetupPlayerVisibility", "tetra.spectate", tetra.spectate.updatePVS)

function tetra.spectate.updateVoice(listener, talker)
	local data = list[listener]
	if not data then return end

	local pos = data.pos
	if IsValid(data.ent) and data.ent:IsPlayer() then
		return GAMEMODE:PlayerCanHearPlayersVoice(data.ent, talker)
	elseif IsValid(data.ent) then
		pos = data.ent:EyePos()
	end
	if not pos then return end

	local hear, surround = GAMEMODE:PlayerCanHearPlayersVoice(listener, talker)
	if not hear then
		return pos:DistToSqr(talker:EyePos()) <= 0x00040000, surround
	end
end
hook.Add("PlayerCanHearPlayersVoice", "tetra.spectate", tetra.spectate.updateVoice)


local tenno_scuum = {}

local function logIfNotAdmin(ply)
	local admin = ply:IsAdmin()
	if not tenno_scuum[ply] and not admin then
		tetra.echo(nil, "Hey ", ply, ", why are you sending internal net messages to the admin mod when you aren't an admin?\nThis has been logged and everyone saw this, this will not repeat.")
		tenno_scuum[ply] = true
	end

	return admin
end

local function validate(ply)
	local data = list[ply]

	if not data then
		logIfNotAdmin(ply)

		return false
	end

	return data
end

util.AddNetworkString("tetra_spectate_notify")
util.AddNetworkString("tetra_spectate_pos")
util.AddNetworkString("tetra_spectate_ent")

local function recievePlayerPosUpdate(_, ply)
	if not validate(ply) then return end

	local pos = net.ReadVector()
	list[ply].pos = pos
	list[ply].ent = nil
end
net.Receive("tetra_spectate_pos", recievePlayerPosUpdate)

local function recievePlayerEntUpdate(_, ply)
	if not validate(ply) then return end

	local ent = net.ReadEntity()
	list[ply].pos = nil
	list[ply].ent = ent
end
net.Receive("tetra_spectate_ent", recievePlayerEntUpdate)


function tetra.spectate.start(ply, ent)
	-- now is an OK time to do spring cleaning
	cleanList()
	list[ply] = {}

	if IsValid(ent) then
		list[ply].ent = ent
	else
		list[ply].pos = ply:EyePos()
	end

	net.Start("tetra_spectate_notify")
		net.WriteBit(1)
		net.WriteEntity(ent) -- it handles NULL/nil internally
	net.Send(ply)
end

function tetra.spectate.finish(ply, noSend)
	list[ply] = nil
	if noSend then return end

	net.Start("tetra_spectate_notify")
		net.WriteBit(0)
	net.Send(ply)
end

local function recievePlayerNotify(_, ply)
	local start = net.ReadBool()

	if start then
		if not logIfNotAdmin(ply) then return end
		tetra.spectate.start(ply, net.ReadEntity())
	else
		tetra.spectate.finish(ply, true)
	end
end
net.Receive("tetra_spectate_notify", recievePlayerNotify)
