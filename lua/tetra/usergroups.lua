tetra.users = tetra.users or {}

local groups = tetra.users.groups or {
	user = "user", -- make sure to use groupInherits
	admin = "user",
	superadmin = "admin",
}
tetra.users.groups = groups

do
	local trash = {
		user = true,
		admin = true,
		superadmin = true,
	}

	function tetra.users.registerGroup(group, inherits, notOurs)
		if SERVER then
			tetra.rpc(nil, "tetra.users.registerGroup", group, inherits, notOurs)
		end

		local exists = groups[group]
		groups[group] = inherits

		if not tetra.cami or notOurs or trash[group] then return end

		if exists then
			CAMI.UnregisterUsergroup(group, tetra.cami.token)
		end
		CAMI.RegisterUsergroup({Name = group, Inherits = inherits}, tetra.cami.token)
	end
end

function tetra.users.groupInherits(group, target, level)
	if group == target then return true end

	local base = groups[group]

	while base do
		if base == target then return true end
		if base == "user" then return false end -- user = "user"

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

function meta:hasUserGroup(target, ignoreSafeguards)
	target = target:lower()
	if target == "user" then return true end

	if SERVER and not self:IsFullyAuthenticated() then
		return false
	end

	if not groups[target] and not ignoreSafeguards then
		local info = debug.getinfo(2)
		local possibly_bad = target:match("admin") or target:match("developer") or target:match("operator")

		local res = false
		if not possibly_bad or self:IsAdmin(true) then
			res = true
		end

		tetra.warnf("attempting to check group inheritance; group '%s' does not exist, defaulting to %s (%s:%d-%d)", target, tostring(res), info.short_source, info.linedefined, info.lastlinedefined)
		return res
	end

	local group = self:GetUserGroup()
	if not groups[group] then
		local possibly_bad = target:match("admin") or target:match("developer") or target:match("operator")

		local res = false
		if not possibly_bad or self:IsAdmin(true) then
			res = true
		end

		tetra.warnf("player '%s' (%s) with an invalid group '%s', defaulting to %s", self:Nick(), self:SteamID64(), group, tostring(res))
		return res
	end

	return tetra.users.groupInherits(group, target, 3)
end

function meta:IsAdmin(ignoreSafeguards)
	return self:hasUserGroup("admin", ignoreSafeguards)
end

function meta:IsSuperAdmin(ignoreSafeguards)
	return self:hasUserGroup("superadmin", ignoreSafeguards)
end
