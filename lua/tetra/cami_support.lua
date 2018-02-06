tetra.cami = tetra.cami or {}

local token = "tetrahedron"
tetra.cami.token = token

local trash = {
	user = true,
	admin = true,
	superadmin = true,
}

tetra.cami.registeredToOthers = tetra.cami.registeredToOthers or {}

function tetra.cami.OnUsergroupRegistered(camiGroup, source)
	if source == token then return end

	local name = camiGroup.Name:lower()
	if trash[name] then return end

	-- TODO: register group function?
	if tetra.users.groups[name] and not tetra.cami.registeredToOthers[name] then
		tetra.warnf("cami attempting to overwrite group '%s'; group belongs to us but access token is not ours", name)

		return -- CAMI compliancy is worth less than security and integrity
	else
		tetra.cami.registeredToOthers[name] = true
	end

	-- we don't complain about missing inheritence groups here because we handle
	-- it at runtime, and I feel like groups might not be registered
	-- in the correct order
	tetra.users.groups[name] = camiGroup.inherits
end
hook.add("OnUsergroupRegistered", "tetrahedron.cami", tetra.cami.OnUsergroupRegistered)

function tetra.cami.OnUsergroupUnregistered(camiGroup, source)
	if source == token then return end

	local name = camiGroup.Name:lower()
	if trash[name] then return end

	if tetra.users.groups[name] and not tetra.cami.registeredToOthers[name] then
		tetra.warnf("cami attempting to remove group '%s'; group belongs to us but access token is not ours", name)

		return -- CAMI compliancy is worth less than security and integrity
	else
		tetra.cami.registeredToOthers[name] = nil -- dead
	end

	tetra.users.groups[name] = nil
end
hook.add("OnUsergroupUnregistered", "tetrahedron.cami", tetra.cami.OnUsergroupUnregistered)

-- TODO: SteamIDUsergroupChanged, PlayerUsergroupChanged
-- TODO: access
