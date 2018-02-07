tetra.main_color = Color(5, 224, 252)
tetra.warn_color = Color(231, 236, 163)

tetra.LOG  = {nil      , Color(157, 225, 154)}
tetra.WARN = {"warning", tetra.warn_color}

do
	tetra.consoleName = CreateConVar("tetra_console_name", "", FCVAR_REPLICATED, "The name of the person using the console")

	if SERVER then
		concommand.Add("iam", function(ply, _, args, name)
			if IsValid(ply) then return end

			name = name or table.concat(args, " ")
			game.ConsoleCommand("tetra_console_name " .. name .. "\n")
		end)
	end

	tetra.console_color = Color(178,  34,  34)
	tetra.player_console_color = Color(112, 128, 144)

	function tetra.insertConsoleName(tbl)
		local name = tetra.consoleName:GetString()
		if name:Trim() == "" then
			table.insert(tbl, tetra.console_color)
			table.insert(tbl, "Console")

			return
		end

		table.insert(tbl, tetra.player_console_color)
		table.insert(tbl, name)
		table.insert(tbl, tetra.console_color)
		table.insert(tbl, "@gamepanel")
	end

	function tetra.getConsoleName()
		local name = tetra.consoleName:GetString()
		if name:Trim() == "" then return "Console" end

		return name .. "@gamepanel"
	end
end

function tetra.out(l, f, ...)
	local text = string.format(f, ...)

	local mod = l[1]
	if mod then
		text = mod .. ": " .. text
	end

	MsgC(tetra.main_color, "[tetra] ", l[2], text, "\n")
end

function tetra.logf(...)
	tetra.out(tetra.LOG , ...)
end

function tetra.warnf(...)
	tetra.out(tetra.WARN, ...)
end

tetra.number_color = Color(100, 255, 100)
tetra.string_color = Color(200, 200, 200)
tetra.misc_color   = Color(100, 100, 200)

function tetra.chat(ply, ...)
	if isentity(ply) and not ply:IsValid() then -- console
		MsgC(...)
		MsgN("")

		return
	end

	if CLIENT then
		chat.AddText(...)
	else
		tetra.rpc(ply, "chat.AddText", ...)
	end
end

function tetra.sound(ply, ...)
	if isentity(ply) and not ply:IsValid() then -- console
		return
	end

	if CLIENT then
		surface.PlaySound(...)
	else
		tetra.rpc(ply, "surface.PlaySound", ...)
	end
end

function tetra.echo(ply, ...)
	local out = {}
	for _, v in ipairs{...} do
		if isnumber(v) then
			table.insert(out, tetra.number_color)
			table.insert(out, tostring(v))
		elseif istable(v) and v.isPlayerObject then
			v:insertPlayersForDisplay(out)
		elseif isentity(v) and v:IsPlayer() then
			table.insert(out, team.GetColor(v:Team()))
			table.insert(out, v:Nick())
		elseif isentity(v) and not IsValid(v) then -- i trust you to use this correctly
			tetra.insertConsoleName(out)
		elseif isstring(v) then
			table.insert(out, tetra.string_color)
			table.insert(out, tostring(v))
		else
			table.insert(out, tetra.misc_color)
			table.insert(out, tostring(v))
		end
	end

	tetra.chat(ply, unpack(out))

	MsgC(tetra.main_color, "[tetra] ", unpack(out))
	MsgN("") -- cant pass after unpack and isnt needed in chat
end
