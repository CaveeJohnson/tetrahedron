tetra.commands = tetra.commands or {}

local argMeta = {}
do
	tetra.commands.argumentMeta = argMeta

	local types = {
		ARG_PLAYER = 1,
		ARG_STRING = 2,
		ARG_NUMBER = 3,
		ARG_VARARG = 4,
	}
	tetra.commands.arg_t = types

	for name, v in ipairs(types) do
		_G["TETRA_" .. name] = val
	end

	tetra.isSet (argMeta, "optional", "boolean")
	tetra.hasSet(argMeta, "fuzzyMatching", "boolean")
	tetra.getSet(argMeta, "forceMatchOnce", "boolean")
	tetra.getSet(argMeta, "filter", "function")
	tetra.getSet(argMeta, "name", "string")
	tetra.getSet(argMeta, "description", "string")

	function argMeta:doParse(data, caller)
		local t = self.argtype

		if t == TETRA_ARG_PLAYER then
			local ply = tetra.findPlayersFrom(data, caller, self:hasFuzzyMatching())
			if ply then
				return ply
			else
				return nil, string.format("did not find any players matching '%s'", data)
			end
		elseif t == TETRA_ARG_NUMBER then
			return tonumber(data)
		elseif t == TETRA_ARG_STRING then
			return data
		else
			tetra.warnf("unknown argument type '%d' attempted to parse", t)
		end
	end
end

local cmdMeta = {}
do
	tetra.commands.commandMeta = cmdMeta

	tetra.isSet (cmdMeta, "silent", "boolean")
	tetra.isSet (cmdMeta, "consoleAllowed", "boolean")
	tetra.isSet (cmdMeta, "variadic", "boolean")
	tetra.hasSet(cmdMeta, "ignoreArguments", "boolean")
	tetra.getSet(cmdMeta, "fullName", "string")
	tetra.getSet(cmdMeta, "callback", "function")
	tetra.getSet(cmdMeta, "description", "string")

	function cmdMeta:getArgumentCount()
		return self.argument_count
	end

	local m = {__index = argMeta}
	function cmdMeta:addArgument(argtype)
		if self.ignoreArguments then
			error("call to 'addArgument' when 'ignoreArguments' is set", 2)
		end
		self.argument_count = self.argument_count + 1

		local obj = {
			argtype = argtype,
		}
		self.arguments[self.argument_count] = setmetatable(obj, m)

		return obj
	end
end


local list = tetra.commands.list or {}
tetra.commands.list = list

local alias_list = tetra.commands.alias_list or {}
tetra.commands.alias_list = alias_list

function tetra.commands.get(cmd)
	local real = alias_list[cmd]
	if not real then return end

	return list[real]
end

local m = {__index = cmdMeta}
function tetra.commands.register(cmd, callback, default_group)
	tetra.typeCheck("function", 2, callback)

	local cmds, primary
	if istable(cmd) then
		cmds = cmd

		primary = cmd[1]
		if not primary then
			tetra.typeError("register", 1, "tbl[1]", nil)
		end
	elseif isstring(cmd) then
		if cmd:match("^.-,.-$") then
			cmds = cmd:Split(",")
			primary = cmds[1]
		else
			primary = cmd
		end
	else
		tetra.typeError("register", 1, "string or table", cmd)
	end
	primary = primary:lower()

	tetra.privs.register {
		name = primary,
		root = default_group,
		desc = string.format("Privilege for the '%s' command.", primary),
	}

	local obj = {
		argument_count = 0,
		arguments      = {},
		callback       = callback,
	}
	list[primary] = setmetatable(obj, m)
	alias_list[primary] = primary

	if cmds and cmds[2] then -- ignore if {cmd}
		for _, c in ipairs(cmds) do
			c = c:lower()

			if alias_list[c] and alias_list[c] ~= primary then
				tetra.warnf("command alias '%s' was overwritten from '%s' to '%s'", c, alias_list[c], primary)
			end

			alias_list[c] = primary
		end
	end

	return obj
end

function tetra.commands.run(caller, cmd, args, line)
	cmd = cmd:lower()
	cmd = alias_list[cmd] or cmd

	local cmd_obj = tetra.commands.get(cmd)
	if not cmd_obj then return end

	local valid = IsValid(caller)
	if not valid and not cmd_obj:isConsoleAllowed() then
		tetra.logf("console attempted to use command '%s'; this command is not supported for the console!", cmd)
		return
	end

	local call = function(res, err)
		if valid and not IsValid(caller) then
			return
		end

		if res == false then
			tetra.chat(caller, tetra.warn_color, string.format("Access Denied: %s.", err or "You do not have the correct prvilige"))
			return
		end

		local pass = {}
		local bottom = 0
		if not cmd_obj.ignoreArguments and #cmd_obj.arguments ~= 0 then
			for i, v in ipairs(cmd_obj.arguments) do
				local optional = v:isOptional()

				if not args[i] and not optional then
					tetra.chat(caller, tetra.warn_color, string.format("Argument '%s' (%d) is missing and is not optional.", v.name or i, i))
					return
				end

				res, err = v:doParse(args[i], caller)
				if not res and not optional then
					tetra.chat(caller, tetra.warn_color, string.format("Argument '%s' (%d) %s.", v.name or i, i, err or "was of incorrect type and is not optional"))
					return
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
			res, err = cmd_obj.callback(caller, line, unpack(pass))

			if res == false then
				tetra.chat(caller, tetra.warn_color, err)
				hook.Run("Tetra_CommandFailed", caller, line, pass, err)
			else
				tetra.logf("%s called command '%s' with line '%s'", caller, cmd, line)
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

tetra.commands.prefix = "[%.]"
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
