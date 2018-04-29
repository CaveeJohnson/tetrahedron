tetra.privs = tetra.privs or {}

local privs = tetra.privs.list or {}
tetra.privs.list = privs

local translate = { -- aowl compat
	player     = "user",
	players    = "user",

	moderators = "admin",
	helpers    = "admin",
	admins     = "admin",

	developer  = "superadmin",
	developers = "superadmin",
	owners     = "superadmin",
}

-- name, root, desc
function tetra.privs.register(priv)
	priv.root = translate[priv.root] or priv.root
	priv.root = priv.root:lower()

	privs[priv.name] = priv
end

function tetra.privs.registerCAMI(camiPriv)
	local name = camiPriv.Name

	if privs[name] and not privs[name].cami then
		return tetra.warnf("attempt to overwrite privilege; CAMI registered conflicting privilege '%s'", name)
	end

	privs[name] = {
		name = camiPriv.name,
		root = camiPriv.MinAccess:lower(),
		desc = camiPriv.Description,

		cami_filter = camiPriv.HasAccess,
		cami = camiPriv,
	}
end

local groups = tetra.privs.groups or {}
tetra.privs.groups = groups

function tetra.privs.groupHas(group, name)
	local root = privs[name].root

	if group == root then return true end
	if groups[group] and groups[group][name] then return true end

	local base = tetra.users.groups[group]

	while base do
		if base == root then return true end
		if groups[base] and groups[base][name] then return true end
		if base == "user" then break end

		base = tetra.users.groups[base]
	end

	if CAMI.UsergroupInherits(group, name) then return true end

	return false
end

function tetra.privs.setForGroup(group, privTbl)
	local tbl = {}

	for _, v in ipairs(privTbl) do
		tbl[v] = true
	end

	groups[group] = tbl
end

function tetra.privs.hasImmediate(caller, priv) -- inside tetra only, outside may depend on CAMI privs (potentially defered)
	local priv_obj = privs[priv]
	if not priv_obj then return true end -- doesn't exist? fuck it
	if not IsValid(caller) then return true end -- console? fuck it

	if SERVER and not caller:IsFullyAuthenticated() then return false, "user is not fully authenticated; restart steam" end -- steamid spoofing has existed before, lets learn from the past

	local group = caller:GetUserGroup()
	if tetra.privs.groupHas(group, priv) then return true end -- has it, inherits it or inherits root

	if priv_obj.cami_callback then
		local res, err, msg = pcall(priv_obj.cami_callback, priv_obj.cami, caller, nil) -- fucking 'target', despite being 'common' CAMI assumes commands may only have one fucking target?
		-- even if we handle our own fucking player objects, WHAT IF WE HAVE MORE THAN ONE PLAYER FUCKING ARGUMENT? WHAT THE FUCK IS 'TARGET'

		if res then
			return err, msg
		end
	end

	return false -- string.format("group '%s' does not have nor inherit privilege '%s'", group, priv)
end

function tetra.privs.has(caller, priv, callback)
	local res, err = tetra.privs.hasImmediate(caller, priv)
	if res or err then return callback(res, err) end

	-- we have no answer, defer to CAMI?
	-- CAMI's handling of access is fucking autistic

	return false
end

local meta = debug.getregistry().Player

function meta:hasPriv(priv, callback)
	tetra.privs.has(self, priv, callback)
end
