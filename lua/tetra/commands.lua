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

	for name, val in pairs(types) do
		_G["TETRA_" .. name] = val
	end

	tetra.isSet (argMeta, "optional", "boolean")
	tetra.hasSet(argMeta, "fuzzyMatching", "boolean")
	tetra.getSet(argMeta, "matchOnce", "boolean", "must")
	tetra.getSet(argMeta, "defaultToCaller", "boolean", "should")
	tetra.getSet(argMeta, "filter", "function")
	tetra.getSet(argMeta, "name", "string")
	tetra.getSet(argMeta, "description", "string")

	function argMeta:addArgument(...)
		return self.command:addArgument(...)
	end

	function argMeta:doParse(data, caller)
		local t = self.argtype or -1

		if t == TETRA_ARG_PLAYER then
			local ply = tetra.findPlayersFrom(data, caller, self:hasFuzzyMatching())

			if ply then
				if ply:containsMultiple() and self:mustMatchOnce() then
					return nil, string.format("'%s' matched %d players (only one allowed)", data, #ply.players)
				end

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
	tetra.hasSet(cmdMeta, "easyluaEnvironment", "boolean")
	tetra.getSet(cmdMeta, "ignoreArguments", "boolean", "should")
	tetra.getSet(cmdMeta, "fullName", "string")
	tetra.getSet(cmdMeta, "callback", "function")
	tetra.getSet(cmdMeta, "description", "string")

	function cmdMeta:getArgumentCount()
		return self.argument_count
	end

	local m = {__index = argMeta}
	function cmdMeta:addArgument(argtype)
		if self:shouldIgnoreArguments() then
			error("call to 'addArgument' when 'ignoreArguments' is set", 2)
		end
		self.argument_count = self.argument_count + 1

		local obj = {
			argtype = argtype,
			command = self,
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

	return list[real], real
end

local m = {__index = cmdMeta}
function tetra.commands.register(cmd, callback, default_group)
	if SERVER then tetra.typeCheck("function", 2, callback) end

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
		root = default_group or "admin",
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
