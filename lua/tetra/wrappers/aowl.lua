if aowl and not aowl.fake then return end

aowl = {fake = "tetra"}
aowl.GotoLocations = {}

local function aowl_initialised()
	hook.Run("AowlInitialized")
end
hook.Add("Tetra_Startup", "aowl", aowl_initialised)

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

do
	local NOTIFY = {
		GENERIC	= 0,
		ERROR	= 1,
		UNDO	= 2,
		HINT	= 3,
		CLEANUP	= 4,
	}

	function aowl.Message(ply, msg, type, duration)
		duration = duration or 5

		tetra.rpc(
			ply or nil,
			"notification.AddLegacy",
			"tetra: " .. msg,
			NOTIFY[(type and type:upper())] or NOTIFY.GENERIC,
			duration)

		tetra.rpc(
			ply or nil,
			"MsgN",
			"tetra: " .. msg)
	end
end

aowl.CallCommand = tetra.commands.run or stub
if SERVER then concommand.Add("aowl", tetra.commands.cmd) end

function aowl.AddCommand(cmd, callback, group)
	tetra.commands.register(cmd, callback, group or "user") -- aowl defaults to user, tetra to admin
		:setConsoleAllowed(true)
		:setVariadic(true)
		:setEasyluaEnvironment(true)
end

function aowl.TargetNotFound(target)
	return string.format("could not find: %q", target or "<no target>")
end

aowl.AbortCountDown = tetra.abortCountdown or stub
aowl.CountDown      = tetra.countdown      or stub
