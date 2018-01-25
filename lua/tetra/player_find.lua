local playerMeta = {isPlayerObject = true}

tetra.getSet(playerMeta, "multiple", "boolean", "contains")

function playerMeta:insertPlayersForDisplay(tbl)
	local c = #self.players

	for i, v in ipairs(self.players) do
		table.insert(tbl, team.GetColor(v:Team()))
		table.insert(tbl, v:Nick())

		if i ~= c then
			table.insert(tbl, ", ")
		end
	end
end

local close = 256 * 256
local special = {
	["#all"]      = player.GetAll,
	["#everyone"] = player.GetAll,

	["#humans"]   = player.GetHumans,
	["#bots"]     = player.GetBots,

	["#us"]       = function(caller)
		if not IsValid(caller) then return end

		local us = {}
		for _, v in ipairs(player.GetAll()) do
			if caller:GetPos():DistToSqr(v:GetPos()) <= close then
				table.insert(us, v)
			end
		end
		return us
	end,

	["#me"]      = function(caller)
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

	if not players or #players == 0 then return end

	local obj = {
		players = players,
	}
	setmetatable(obj, m)

	obj:setMultiple(#players > 1)

	return obj
end
