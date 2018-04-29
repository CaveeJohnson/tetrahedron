local c_time, lines, n_lines
local last_number = -1

local siren, sound = Sound("ambient/alarms/combine_bank_alarm_loop4.wav"), nil

function tetra.countdown(message, time)
	c_time  = CurTime() + time
	lines   = message:Split("\n")
	n_lines = #lines
	sound   = sound or CreateSound(LocalPlayer(), siren)
	          sound:SetSoundLevel(45)
	          sound:Play()

	last_number = -1

	hook.Add("HUDPaint", "tetra.countdown", tetra.drawCountdown)
end

function tetra.abortCountdown()
	c_time  = nil
	lines   = nil
	n_lines = nil

	if sound then
		sound:FadeOut(2)
	end

	hook.Remove("HUDPaint", "tetra.countdown", tetra.drawCountdown)
end

local numbers = {
	Sound("npc/overwatch/radiovoice/one.wav"),
	Sound("npc/overwatch/radiovoice/two.wav"),
	Sound("npc/overwatch/radiovoice/three.wav"),
	Sound("npc/overwatch/radiovoice/four.wav"),
	Sound("npc/overwatch/radiovoice/five.wav"),
	Sound("npc/overwatch/radiovoice/six.wav"),
	Sound("npc/overwatch/radiovoice/seven.wav"),
	Sound("npc/overwatch/radiovoice/eight.wav"),
	Sound("npc/overwatch/radiovoice/nine.wav"),
}

surface.CreateFont("tetra_restart_time", {
	font   = "Roboto Bk",
	size   = 60,
	weight = 1000,
})

surface.CreateFont("tetra_restart", {
	font   = "Roboto",
	size   = 48,
	weight = 0,
})

local bg_color = Color(0, 120, 255)
local start_y = 100

function tetra.drawCountdown()
	if not (lines and c_time) then return end

	local scrW, scrH = ScrW(), ScrH()
	local curtime = CurTime()

	bg_color.a = 0 + math.max(0, math.sin(curtime * 3) * 25)

	surface.SetDrawColor(bg_color)
	surface.DrawRect(0, 0, scrW, scrH)

	local half_scr_w = scrW / 2

	surface.SetFont("tetra_restart")
	surface.SetTextColor(255, 255, 255, 255)
	local y = start_y

	for i = 1, n_lines do
		local line = lines[i]

		local w, h = surface.GetTextSize(line)
		surface.SetTextPos(half_scr_w - w / 2, y)
		surface.DrawText(line)

		y = y + h + 1
	end

	y = y + 10

	surface.SetFont("tetra_restart_time")

	local time_remaining_num = math.max(0, c_time - curtime)
	local time_remaining = string.format("%.3f", time_remaining_num)
	local w, h = surface.GetTextSize(time_remaining)

	surface.SetTextPos(half_scr_w - w / 2, y)
	surface.DrawText(time_remaining)

	local num = math.ceil(time_remaining_num)
	if numbers[num] and num ~= last_number then
		last_number = num
		LocalPlayer():EmitSound(numbers[num], 511, 100)
	end

	y = y + h

	hook.Run("Tetra_PostDrawCountdown", start_y, y, time_remaining_num) -- for basewars to draw 'refunds are automatic'
end
