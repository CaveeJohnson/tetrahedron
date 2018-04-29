function tetra.countdown(message, time, callback, ...)
	if not (message and time) then
		tetra.abortCountdown()
	end

	tetra.logf("countdown started for '%s'", message:Trim():gsub("\n", " "))
	tetra.rpc(nil, "tetra.countdown", message, time)

	local args = {...}
	local done = function()
		tetra.abortCountdown(true)
		if not callback then return end

		local res, err = pcall(callback, unpack(args))
		if not res then
			local info = debug.getinfo(callback)
			tetra.warnf("countdown callback errored; '%s' (%s:%d-%d)", err, info.short_src, info.linedefined, info.lastlinedefined)
		end
	end

	timer.Create("tetra_countdown", time, 1, done)
end

function tetra.abortCountdown(success)
	tetra.rpc(nil, "tetra.abortCountdown")

	if timer.Exists("tetra_countdown") then
		timer.Remove("tetra_countdown")
		tetra.logf("countdown %s", success and "finished" or "aborted")
	end
end
