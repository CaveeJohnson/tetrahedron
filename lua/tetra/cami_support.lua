if not tetra.users then return end

tetra.cami = tetra.cami or {}

local token = "tetrahedron"
tetra.cami.token = token

local trash = {
	user = true,
	admin = true,
	superadmin = true,
}

function tetra.cami.OnUsergroupRegistered(camiGroup, source)
	if source == token then return end

	local name = camiGroup.Name:lower()
	if trash[name] then return end
	if tetra.users.groups[name] then return end

	-- we don't complain about missing inheritance groups here because we handle
	-- it at runtime, and I feel like groups might not be registered
	-- in the correct order
	tetra.users.registerGroup(name, camiGroup.inherits, true) -- register but dont call cami
end
hook.Add("CAMI.OnUsergroupRegistered", "tetrahedron.cami", tetra.cami.OnUsergroupRegistered)

for _, camiGroup in pairs(CAMI.GetUsergroups()) do
	tetra.cami.OnUsergroupRegistered(camiGroup)
end

function tetra.cami.OnUsergroupUnregistered(camiGroup, source)
	if source == token then return end

	local name = camiGroup.Name:lower()
	if trash[name] then return end

	tetra.users.groups[name] = nil
end
hook.Add("CAMI.OnUsergroupUnregistered", "tetrahedron.cami", tetra.cami.OnUsergroupUnregistered)

function tetra.cami.UsergroupChanged(sid, old, new, source) -- setGroup works for ply, sid64 and sid, so no need for other funcs
	if source == token then return end

	if not tetra.users.groups[name] then  -- in case it was not notified
		local camiGroup = CAMI.GetUsergroup(usergroupName)

		if camiGroup then
			tetra.cami.OnUsergroupRegistered(camiGroup, source)
		end
	end

	tetra.users.setGroup(sid, new)
end
hook.Add("CAMI.SteamIDUsergroupChanged", "tetra.cami", tetra.cami.UsergroupChanged)
hook.Add("CAMI.PlayerUsergroupChanged", "tetra.cami", tetra.cami.UsergroupChanged)



function tetra.cami.OnPrivilegeRegistered(camiPriv)
	tetra.privs.registerCAMI(camiPriv)
end
hook.Add("CAMI.OnPrivilegeRegistered", "tetra.cami", tetra.cami.OnPrivilegeRegistered)

for _, camiPriv in pairs(CAMI.GetPrivileges()) do
	tetra.cami.OnPrivilegeRegistered(camiPriv)
end
