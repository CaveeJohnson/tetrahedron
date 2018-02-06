tetra.users = tetra.users or {}

local authed = tetra.users.authed or {}
tetra.users.authed = authed

local groups = {
	admin = "user",
	superadmin = "admin",
}
tetra.users.groups = groups

-- TODO: load 'groups' file, management etc

function tetra.users.auth(ply, group)
	authed[ply] = true

	hook.Run("Tetra_Authed", ply, group)
end

function tetra.users.groupInherits(group, target, level)
	if group == target then return true end

	local base = groups[group]

	while base do
		if base == target then return true end

		local now = base
		base = groups[base]

		if not base and now ~= "user" then
			local info = debug.getinfo(level or 2)
			tetra.warnf("break in inheritance chain; chain for group '%s' ends at non-existing group '%s' (not user) (%s:%d-%d)", group, now, info.short_source, info.linedefined, info.lastlinedefined)
		end
	end

	return false
end

local meta = debug.getregistry().Player

function meta:hasUserGroup(target)
	target = target:lower()
	if target == "user" then return true end

	if not groups[target] then
		local info = debug.getinfo(2)
		local possibly_bad = target:match("admin") or target:match("developer") or target:match("operator")

		local res = false
		if not possibly_bad or self:IsAdmin() then
			res = true
		end

		tetra.warnf("attempting to check group inheritance; group '%s' does not exist, defaulting to %s (%s:%d-%d)", target, tostring(res), info.short_source, info.linedefined, info.lastlinedefined)
		return res
	end

	local group = self:GetUserGroup()
	if not groups[group] then
		tetra.warnf("player '%s' (%s) with an invalid group '%s'", self:Nick(), self:SteamID64(), group)

		return true
	end

	return tetra.users.groupInherits(group, target, 3)
end

function meta:IsAdmin()
	return meta:hasUserGroup("admin")
end

function meta:IsSuperAdmin()
	return meta:hasUserGroup("superadmin")
end


if CLIENT then return end


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

function tetra.users.setGroup(sid64, group, dontSave)
	local ply
	if isentity(sid64) then
		ply = sid64
		sid64 = sid64:SteamID64()
	else
		ply = player.GetBySteamID64(sid64)
	end

	if group == "user" then
		group = nil
	elseif group then
		group = group:lower()
	end

	local old = user_reference[sid64] or "user"
	user_reference[sid64] = group

	if IsValid(ply) then
		ply:SetUserGroup(group)

		if tetra.cami then
			CAMI.SignalUserGroupChanged(ply, old, group, tetra.cami.token)
		end
	elseif tetra.cami then
		CAMI.SignalSteamIDUserGroupChanged(util.SteamIDFrom64(sid64), old, group, tetra.cami.token)
	end

	if not dontSave then
		tetra.users.saveFile()
	end
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
