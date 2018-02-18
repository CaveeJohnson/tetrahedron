if aowl and not aowl.fake then return end

aowl = {fake = "tetra"}
aowl.GotoLocations = {}

local function aowl_initialised()
	hook.Run("AowlInitialized")
end
timer.Simple(1, aowl_initialised)

aowl.Prefix = tetra.commands.prefix

function aowlMsg(cmd, line)
	local ok = hook.Run("AowlMessage", cmd, line)

	if ok then
		tetra.logf("(aowl wrapped)%s %s", cmd and " " .. tostring(cmd) or " ", line)
	end
end

aowl.ParseArgs = tetra.commands.parse

local stub = function()
	error(string.format("call to stub function '%s'", debug.getinfo(1).name or "unknown"), 2)
end

aowl.CommunityIDToSteamID = stub
aowl.SteamIDToCommunityID = stub
aowl.AvatarForSteamID     = stub

aowl.CallCommand = tetra.commands.run
concommand.Add("aowl", tetra.commands.cmd)

function aowl.AddCommand(...)
	tetra.commands.register(...)
		:setConsoleAllowed(true)
		:setVariadic(true)
		:setEasyluaEnvironment(true)
end

function aowl.TargetNotFound(target)
	return string.format("could not find: %q", target or "<no target>")
end

aowl.AbortCountDown = stub
aowl.CountDown      = stub
