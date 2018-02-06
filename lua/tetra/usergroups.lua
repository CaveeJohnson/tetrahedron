tetra.users = tetra.users or {}

local authed = tetra.users.authed or {}
tetra.users.authed = authed

local groups = {
	user = 0,
	admin = 100,
	superadmin = 200,
	owner = math.huge,
}
tetra.users.groups = groups

-- TODO: load 'groups' file

function tetra.users.auth(ply, group)
	authed[ply] = true

	hook.Run("Tetra_Authed", ply, group)
end

local meta = debug.getregistry().Player

function meta:hasUserGroup(group)
	local group = self:GetUserGroup()

	-- TODO:
end

if CLIENT then return end

function meta:SetUserGroup(group, internal)
	-- TODO:
end

local user_reference = {}
local loaded = false

local USERS_FILE = "tetra/users.txt"
local timestamp = 0

file.CreateDir("tetra")

function tetra.users.loadFile()
	local file_ts = file.Time(USERS_FILE, "DATA")
	if file_ts == timestamp and loaded then return false end

	timestamp = file_ts
	loaded = true

	local raw = file.Read(USERS_FILE, "DATA")
	if not raw then return false end

	user_reference = {}
	for _, v in ipairs(raw:Split("\n")) do
		local sid64, group = v:match("^%s-(%d+);(%w-)%-?$")

		if sid64 and group then
			user_reference[sid64] = group
		end
	end

	return true
end

function tetra.users.saveFile()
	local write = ""
	for sid64, group in pairs(user_reference) do
		write = write .. sid64 .. ";" .. group .. "\n"
	end

	file.Write(USERS_FILE, write:Trim())
end

function tetra.users.getGroup(sid64)
	tetra.users.loadFile()

	return user_reference[sid64] or "user"
end

function tetra.users.onAuthed(ply)
	local sid64 = ply:SteamID64()
	local group = tetra.users.getGroup(sid64)

	ply:SetUserGroup(group, true)

	tetra.users.auth(ply)
	tetra.rpc(nil, "tetra.users.auth", ply, group) -- idk if cl will want this but fuck it

	tetra.logf("authed user '%s' (%s); usergroup '%s'", ply:Nick(), sid64, group or "user")
end
hook.Add("PlayerInitialSpawn", "tetra", tetra.users.onAuthed)
