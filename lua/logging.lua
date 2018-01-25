tetra.main_color = Color(5, 224, 252)
tetra.warn_color = Color(231, 236, 163)

tetra.LOG  = {nil      , Color(157, 225, 154)}
tetra.WARN = {"warning", tetra.warn_color}

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

util.AddNetworkString("tetra_chat")
function tetra.chat(ply, ...)
	net.Start("tetra_chat")
		net.WriteTable{...}
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
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
	MsgN("")
end
