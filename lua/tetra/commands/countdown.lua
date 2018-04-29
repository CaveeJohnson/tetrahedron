tetra.commands.register("countdown", function(caller, _, message, time)
	tetra.countdown(message:gsub("\\n", "\n"), time or 60)
end, "superadmin")

:setFullName("Countdown")
:setDescription("Perform a server-wide countdown.")
:setConsoleAllowed(true)

:addArgument(TETRA_ARG_STRING)
	:setName("Message")
	:setDescription("The message to perform the countdown with.")

:addArgument(TETRA_ARG_NUMBER)
	:setName("Time")
	:setDescription("The time for the countdown to take.")
	:setOptional(true)

tetra.commands.register("abort,stopcountdown,cancelcountdown", function()
	tetra.abortCountdown(false)
end, "superadmin")

:setFullName("Abort Countdown")
:setDescription("Stop the current countdown, if there is one.")
:setConsoleAllowed(true)


tetra.commands.register("restart,restartmap", function(caller, _, time)
	tetra.countdown("Server Restarting", time or 60, game.ConsoleCommand, "changelevel " .. game.GetMap() .. "\n")
end, "superadmin")

:setFullName("Restart")
:setDescription("Restart the server on the same map, reconnecting all players.")
:setConsoleAllowed(true)

:addArgument(TETRA_ARG_NUMBER)
	:setName("Time")
	:setDescription("The time for the countdown to take.")
	:setOptional(true)


tetra.commands.register("reboot", function(caller, _, time)
	tetra.countdown("Server Rebooting\nYou may need to reconnect!", time or 60, function()
		BroadcastLua("LocalPlayer():ConCommand(\"disconnect;snd_restart;retry\")")
		timer.Simple(0.1, function() game.ConsoleCommand("_restart\n") end) -- in case of delays
	end)
end, "superadmin")

:setFullName("Restart")
:setDescription("Reboots the server, this is only needed for new addons or after major fuckups.")
:setConsoleAllowed(true)

:addArgument(TETRA_ARG_NUMBER)
	:setName("Time")
	:setDescription("The time for the countdown to take.")
	:setOptional(true)
