tetra.fail_sound = "buttons/button18.wav"

local function fail(caller, ...)
	tetra.chat (caller, tetra.warn_color, string.format(...))
	tetra.sound(caller, tetra.fail_sound)
end

function tetra.commands.run(caller, cmd, args, line)
	cmd = cmd:lower()

	local cmd_obj = tetra.commands.get(cmd)
	if not cmd_obj then return end

	local valid = IsValid(caller)
	if not valid and not cmd_obj:isConsoleAllowed() then
		tetra.logf("console attempted to use command '%s'; this command is not supported for the console!", cmd)
		return
	end

	local call = function(res, err)
		if valid and not IsValid(caller) then
			return -- disconnected during privilege check
		end

		if res == false then
			return fail(caller, "Access Denied: %s.", err and err:gsub("^(%l)", string.upper) or "You do not have the privilige for this command")
		end

		local pass = {}
		local bottom = 0
		if not cmd_obj.ignoreArguments and #cmd_obj.arguments ~= 0 then
			for i, v in ipairs(cmd_obj.arguments) do
				local optional = v:isOptional()
				local arg = args[i]

				if not arg and v.argtype == TETRA_ARG_PLAYER and v:shouldDefaultToCaller() then
					res = tetra.playerObjectFromTable{caller} -- default to caller
				elseif not arg and not optional then
					return fail(caller, "Argument '%s' (#%d) is missing and is not optional.", v.name or i, i)
				else
					res, err = v:doParse(arg, caller)
				end

				if res and v.filter then
					local fres, ferr = pcall(v.filter, arg, res)

					if not fres or ferr then -- filter can fail it, not magically make new data, would be too weird
						res, err = nil, ferr
					end
				end

				if not res and not optional then
					return fail(caller, "Argument '%s' (#%d) %s.", v.name or i, i, err or "was of incorrect type and is not optional")
				end

				table.insert(pass, res or false)
				bottom = bottom + 1
			end
		end

		if not cmd_obj.ignoreArguments and cmd_obj:isVariadic() then
			for i = bottom, #args do
				table.insert(pass, args[i])
			end
		end

		res, err = pcall(function()
			res, err, why = cmd_obj.callback(caller, line, unpack(pass))

			if res == false then
				tetra.chat(caller, tetra.warn_color, err)
				tetra.sound(caller, tetra.fail_sound)
				hook.Run("Tetra_CommandFailed", caller, line, pass, err)
			elseif err == false then
				tetra.chat(caller, tetra.warn_color, why)
				tetra.sound(caller, tetra.fail_sound)
				hook.Run("Tetra_CommandFailed", caller, line, pass, why)
			else
				tetra.logf("%s called command '%s' with line '%s'", IsValid(caller) and caller or tetra.getConsoleName(), cmd, line)
				hook.Run("Tetra_CommandSuccess", caller, line, pass)
			end
		end)

		if not res then
			tetra.warnf("command '%s' failed with a lua error '%s'", cmd, err)
		end
	end

	if valid then
		tetra.privs.has(caller, cmd, call)
	else
		call()
	end

	return cmd_obj
end

function tetra.commands.cmd(ply, _, args, line)
	line = line or table.concat(args, " ") -- idiots breaking concommand.Add :V

	local cmd = table.remove(args, 1)
	if not cmd then return end

	line = line:gsub("^" .. cmd .. "%s?", "")
	tetra.commands.run(ply, cmd, args, line)
end
concommand.Add("tetra", tetra.commands.cmd) -- TODO: autocomplete (aids)

tetra.commands.prefix = "[%.!/]"
local string_pattern  = "[\"|']"
local escape_pattern  = "[\\]"
local delim_pattern   = "[ ]"

function tetra.commands.parse(data, delim)
	local ret     = {}
	local current = ""

	local strchar = ""
	local inside  = false
	local escaped = false

	-- Iterate for each character
	for _, char in ipairs(utf8.totable(data)) do
		if escaped then
			current = current .. char
			escaped = false
		elseif char:find(string_pattern) and not inside and not escaped then
			inside  = true
			strchar = char
		elseif char:find(escape_pattern) then
			escaped = true
		elseif inside and char == strchar then
			inside 	= false
			table.insert(ret, current:Trim())
			current = ""
		elseif char:find(delim or delim_pattern) and not inside and current ~= "" then
			table.insert(ret, current)
			current = ""
		else
			current = current .. char
		end
	end

	if current:Trim():len() ~= 0 then
		table.insert(ret, current:Trim())
	end

	return ret
end

function tetra.commands.said(caller, line)
	if not utf8.sub(line, 1, 1):find(tetra.commands.prefix) then
		return
	end

	local cmd  = line:match(tetra.commands.prefix .. "(.-) ") or line:match(tetra.commands.prefix .. "(.+)") or ""
	line       = line:match(tetra.commands.prefix .. ".- (.+)")

	if not cmd then return end

	local args
	if line then
		local delim = caller:GetInfo("tetra_delim") or " "
		if #delim == 0 then delim = " " end
		delim = "[" .. delim .. "]"

		args = tetra.commands.parse(line, delim)
	else
		args = {}
		line = ""
	end

	local cmd_obj = tetra.commands.run(caller, cmd, args, line)

	if cmd_obj and cmd_obj:isSilent() then
		return ""
	end
end
hook.Add("PlayerSay", "tetra.commands", tetra.commands.said)
