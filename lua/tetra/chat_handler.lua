tetra.chatHandler = tetra.chatHandler or {}

local delim = GetConVar("tetra_delim")

do
	local function scoreLikelyhook(ply, word)
		local localPly = LocalPlayer()
		local s = -math.huge

		local nameGood = false
		local name = ply:Nick():lower()
		word = word:lower()

		if name == word then
			s = 1e4 -- not quite, prefer name(1) sitting infront of us to name in orbit

			nameGood = true
		elseif name:match("^" .. string.PatternSafe(word)) then
			local not_included = utf8.len(name) - utf8.len(word)

			s = 1e3 -- good match
			s = s - (not_included ^ 4) -- longer name = less 'close'

			nameGood = true
		elseif name:match(string.PatternSafe(word)) then
			s = 1

			nameGood = true -- better than nought
		end

		if nameGood then -- for low partiality matches, closes, looked at
			local localPos = localPly:EyePos()
			local plyPos   = ply:EyePos()

			s = math.max(0, s - plyPos:Distance(localPos) * 2) -- distance
			s = s + math.max(0, localPly:GetAimVector():Dot((plyPos - localPos):GetNormalized()) * 1e4) -- look angle
		end

		return s
	end

	function tetra.chatHandler.getClosest(word)
		local allPlys = player.GetAll()
		local plys = {}

		for _, v in ipairs(allPlys) do
			local score = scoreLikelyhook(v, word)

			if score >= 0 then
				local data = {v:Nick(), score}

				local i = 1
				local to_beat = plys[i] and plys[i][2]

				local done = false
				while to_beat do
					if to_beat and score > to_beat then
						table.insert(plys, i, data)

						done = true
						break
					end

					i = i + 1
					to_beat = plys[i] and plys[i][2]
				end

				if not done then
					table.insert(plys, data)
				end
			end
		end

		return plys
	end

	local nameCache = tetra.cache("chatHandler - Name Suggestions")
		:setDataProvider(tetra.chatHandler.getClosest)

	local last_index = 0
	local last_word

	function tetra.chatHandler.getReasonableGuessPly(word)
		last_word = last_word or word

		local selection = nameCache:get(last_word, 30)
		if not selection then
			last_index = 0
			last_word = nil

			return
		end

		last_index = last_index + 1
		if selection[last_index] then
			return selection[last_index][1]
		end

		last_index = 1
		return selection[last_index] and selection[last_index][1]
	end

	local ignore_abandon

	function tetra.chatHandler.doTab(cmd, args, guess)
		ignore_abandon = true

		table.insert(args, guess)
		return cmd .. tetra.commands.implode(args, delim:GetString())
	end

	function tetra.chatHandler.abandon()
		if ignore_abandon then
			ignore_abandon = nil

			return
		end

		last_index = 0
		last_word = nil
	end

	hook.Add("FinishChat", "tetra.chatHandler.abandon", tetra.chatHandler.abandon)
	hook.Add("ChatTextChanged", "tetra.chatHandler.abandon", tetra.chatHandler.abandon)
end

function tetra.chatHandler.autoComplete(current)
	local prefix = tetra.commands.prefix

	if not utf8.sub(current, 1, 1):find(prefix) then
		return
	end

	local cmd  = current:match(prefix .. "(.-) ") or current:match(prefix .. "(.+)")
	local line = current:match(prefix .. ".- (.+)")

	if not cmd then return end

	cmd = cmd:lower()

	local cmd_obj
	cmd_obj, cmd = tetra.commands.get(cmd)
	if not cmd_obj then
		-- TODO:
		-- if not line or line ""
		-- perform autocomplete for command name

		return
	end

	if not line then return end

	local args = tetra.commands.parse(line, delim:GetString())
	local last_arg = table.remove(args)

	if not last_arg then return end

	local guess = tetra.chatHandler.getReasonableGuessPly(last_arg)
	local cmd2  = current:match("(" .. prefix .. ".- )") or current:match("(" .. prefix .. ".+)")

	return guess and tetra.chatHandler.doTab(cmd2, args, guess)
end

hook.Add("OnChatTab", "tetra.chatHandler.autoComplete", tetra.chatHandler.autoComplete)

-- TODO: display
