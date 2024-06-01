do
	local trash = {
		user = true,
		admin = true,
		superadmin = true,
	}

	local GROUPS_FILE = "tetra/groups.txt"

	-- TODO: make this sytem more robust and easy to use
	-- management, networking, etc

	-- for now there is no group saving or timestamp check
	-- which means you MUST edit them into the file correctly
	-- then run tetra_reloadgroups on the server
	function tetra.users.loadGroups()
		local raw = file.Read(GROUPS_FILE, "DATA")
		if not raw then return end

		for _, v in ipairs(raw:Split("\n")) do
			local group, inherits, privs = v:match("^%s-(%w+);(%w+);(.*)$")

			if group and inherits and not trash[group] then
				tetra.users.registerGroup(group, inherits)

				if #privs > 4 then -- [""] this or anything less isn't worth parsing
					local privTbl = util.JSONToTable(privs)

					if privTbl and #privTbl > 0 then
						tetra.privs.setForGroup(group, privTbl)
					end
				end
			elseif trash[group] then
				tetra.warnf("invalid data in group file; '%s' is an attempt to register a default group", v:Trim())
			elseif v:Trim() ~= "" then
				tetra.warnf("corrupt line in group file; '%s' did not match", v:Trim())
			end
		end

		return
	end

	concommand.Add("tetra_reloadgroups", function(ply)
		if IsValid(ply) and not ply:IsSuperAdmin() then return end

		tetra.users.loadGroups()
	end, nil, "Reload all tetrahedron's usergroup file.")
	hook.Add("Initialize", "tetra.users.loadGroups", tetra.users.loadGroups)
end

local user_reference = tetra.users.reference or {}
tetra.users.reference = user_reference

do
	local USERS_FILE = "tetra/users.txt"
	tetra.users.file_loaded = tetra.users.file_loaded or false
	tetra.users.file_timestamp = tetra.users.file_timestamp or 0

	file.CreateDir("tetra")

	function tetra.users.loadUsers()
		local file_ts = file.Time(USERS_FILE, "DATA")
		if file_ts == tetra.users.file_timestamp and tetra.users.file_loaded then return false end

		tetra.users.file_timestamp = file_ts
		tetra.users.file_loaded = true

		local raw = file.Read(USERS_FILE, "DATA")
		if not raw then return false end

		for _, v in ipairs(raw:Split("\n")) do
			local sid64, group = v:match("^%s-(%d+);(%w+)%s-$")

			if sid64 and group then
				user_reference[sid64] = group
			elseif v:Trim() ~= "" then
				tetra.warnf("corrupt line in user file; '%s' did not match", v:Trim())
			end
		end

		return true
	end

	function tetra.users.saveUsers()
		local write = ""
		for sid64, group in pairs(user_reference) do
			write = write .. sid64 .. ";" .. group .. "\n"
		end

		file.Write(USERS_FILE, write:Trim())
	end
end

function tetra.users.getGroup(sid64)
	tetra.users.loadUsers()

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

	if sid64:match("^STEAM_0:[01]:%d+$") then
		sid64 = util.SteamIDTo64(sid64) or sid64
	end

	if group == "user" then
		group = nil
	elseif group then
		group = group:lower()
	end

	local new = group or "user"
	local old = user_reference[sid64] or "user"

	user_reference[sid64] = group

	if IsValid(ply) then
		ply:SetUserGroup(new)

		if tetra.cami then
			CAMI.SignalUserGroupChanged(ply, old, new, tetra.cami.token)
		end
	elseif tetra.cami then
		CAMI.SignalSteamIDUserGroupChanged(util.SteamIDFrom64(sid64), old, new, tetra.cami.token)
	end

	if not dontSave then
		tetra.logf("saving usergroup for '%s' (%s); new group is '%s'", IsValid(ply) and ply:Nick() or "unknown", sid64, new)
		tetra.users.saveUsers()
	end
end

function tetra.users.initialSpawn(ply)
	local sid64 = ply:SteamID64()
	local group = tetra.users.getGroup(sid64)

	if ply.IsFullyAuthenticated and not ply:IsFullyAuthenticated() then
		ply:SetUserGroup("user", true)
		ply._tetra_retry_on_auth = true
		tetra.logf("loaded user '%s' (%s); usergroup '%s' << NOT AUTHENTICATED >>", ply:Nick(), sid64, group)
	else
		ply:SetUserGroup(group, true)
		tetra.logf("loaded user '%s' (%s); usergroup '%s'", ply:Nick(), sid64, group)
	end

	for group_name, inherit in pairs(tetra.users.groups) do
		tetra.rpc(ply, "tetra.users.registerGroup", group_name, inherit, false) -- send them all the groups
	end
end
hook.Add("PlayerInitialSpawn", "tetra", tetra.users.initialSpawn)
hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn") -- YOU FUCKING SUBHUMAN APES WHO CANT CODE
-- ROBOT BOY YOU FUCKING DIPSHIT, YOU THINK ITS OKAY TO CHANGE HOOK ORDER SO YOUR FUCKING SHITTY
-- BUILTIN ADMIN SYSTEM THAT NOBODY HAS EVER USED RUNS AFTER EVERYTHING ELSE? FUCKING OVERRIDING
-- EVERY RANK TO USER? FUCKING STOP BREATHING

function tetra.users.onAuthed(ply, steamid)
	if not ply._tetra_retry_on_auth or ply:GetUserGroup() ~= "user" then return end -- don't care or already fixed

	local sid64 = ply:SteamID64()
	local group = tetra.users.getGroup(sid64)

	if group and group ~= "user" then
		ply:SetUserGroup(group, true)
		ply._tetra_retry_on_auth = nil
		tetra.logf("loaded user '%s' (%s); usergroup '%s' [delayed by steam auth]", ply:Nick(), sid64, group)

		tetra.chat(ply, tetra.warn_color, "Authenticated by steam [late], your usergroup is now loaded.")
	end
end
hook.Add("PlayerAuthed", "tetra", tetra.users.onAuthed)
