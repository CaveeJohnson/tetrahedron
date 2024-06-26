local playerMeta = {isPlayerObject = true}

tetra.getSet(playerMeta, "multiple", "boolean", "contains")
tetra.isSet (playerMeta, "callerOnly", "boolean")

tetra.multiplepeople_color = Color(72, 125, 175)

function playerMeta:insertPlayersForDisplay(tbl)
	local c = #self.players

	if self:isCallerOnly() then
		table.insert(tbl, tetra.multiplepeople_color)
		table.insert(tbl, "themself")

		return
	elseif c == player.GetCount() then
		table.insert(tbl, tetra.multiplepeople_color)
		table.insert(tbl, "everyone")

		return
	elseif c > 10 then
		table.insert(tbl, tetra.multiplepeople_color)
		table.insert(tbl, "multiple people")

		return
	end

	for i, v in ipairs(self.players) do
		table.insert(tbl, team.GetColor(v:Team()))
		table.insert(tbl, v:Nick())

		if i ~= c then
			table.insert(tbl, ", ")
		end
	end
end

function playerMeta:setPlayers(tbl)
	self.players = tbl
	self:setMultiple(#tbl > 0)
end

function playerMeta:filter(callback)
	local new, good = {}, false
	for _, v in ipairs(self.players) do
		if callback(v) then
			table.insert(new, v)
			good = true
		end
	end

	self.players = new
	self:setMultiple(#new > 0)
	self:setCallerOnly(#new == 1 and new[1] == self.caller)

	return good
end

function playerMeta:forEach(callback, ...)
	for _, v in ipairs(self.players) do
		callback(v, ...)
	end
end

local close = 256 * 256
local special = {
	["#all"]      = player.GetAll,
	["#everyone"] = player.GetAll,

	["#humans"]   = player.GetHumans,
	["#bots"]     = player.GetBots,

	["#us"]       = function(caller)
		if not IsValid(caller) then return {} end

		local us = {}
		for _, v in ipairs(player.GetAll()) do
			if caller:GetPos():DistToSqr(v:GetPos()) <= close then
				table.insert(us, v)
			end
		end
		return us
	end,

	["#admins"]   = function(caller)
		if not IsValid(caller) or not caller:IsAdmin() then return {} end

		local plys = {}
		for _, v in ipairs(player.GetAll()) do
			if v:IsAdmin() then
				table.insert(plys, v)
			end
		end
		return plys
	end,

	["#sadmins"]  = function(caller)
		if not IsValid(caller) or not caller:IsSuperAdmin() then return {} end

		local plys = {}
		for _, v in ipairs(player.GetAll()) do
			if v:IsSuperAdmin() then
				table.insert(plys, v)
			end
		end
		return plys
	end,

	["#me"]      = function(caller)
		if not IsValid(caller) then return {} end

		return {caller}
	end,
}

special["^"] = special["#me"]
special["*"] = special["#all"]

local matchTrans = GLib and GLib.UTF8 and GLib.UTF8.MatchTransliteration
local m = {__index = playerMeta}
function tetra.findPlayersFrom(data, caller, fuzzy) -- warning: returns nil on failure to find
	tetra.typeCheck("string", 1, data)
	fuzzy = fuzzy or false

	data = data:lower()

	local players
	if special[data] then
		players = special[data](caller)
	elseif data:match("^_%d+$") then
		local target = player.GetById(data:match("^_(%d+)$"))
		if IsValid(target) then players = {target} end
	else
		players = {}

		for _, v in ipairs(player.GetAll()) do
			local nick_lower = v:Nick():lower()

			if v:SteamID() == data or v:SteamID64() == data or nick_lower == data then -- exact
				players = {v}
				break
			end

			if nick_lower:find(data, 1, true) then -- partial
				table.insert(players, v)
			elseif matchTrans and matchTrans(nick_lower, data) then
				table.insert(players, v)
			end
		end

		if #players == 0 and fuzzy then
			for _, v in ipairs(player.GetAll()) do
				if string.fuzzy_match(v:Nick():lower(), data) > 0 then -- fuzzy, TODO: replace this fucking shite algorithm
					table.insert(players, v)
				end
			end
		end
	end

	local amt = #players
	if not players or amt == 0 then return end

	local obj = {
		players = players,
		caller = caller,
	}
	setmetatable(obj, m)

	obj:setMultiple  (amt > 1)
	obj:setCallerOnly(amt == 1 and players[1] == caller)

	return obj
end

function tetra.playerObjectFromTable(players, caller)
	local obj = {
		players = players,
		caller = caller,
	}
	setmetatable(obj, m)

	local amt = #players
	obj:setMultiple(amt > 1)
	obj:setCallerOnly(amt == 1 and players[1] == caller)

	return obj
end
