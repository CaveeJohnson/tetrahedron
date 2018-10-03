local function outputVar(namespace, k, v)
	local out = {Color(255, 255, 255), string.format("%s%s", namespace or "", namespace and "." .. k or k), Color(100, 100, 100), "\t- "}
	if isfunction(v) then
		local info = debug.getinfo(v)

		table.insert(out, Color(200, 100, 100))
		if info.what == "C" then
			table.insert(out, "function [NATIVE]")
		else
			table.insert(out, string.format("function [%s:%d-%d]", info.short_src, info.linedefined, info.lastlinedefined))
		end
	elseif isstring(v) then
		table.insert(out, tetra.string_color)
		table.insert(out, string.format("string '%s'", v))
	elseif isnumber(v) then
		table.insert(out, tetra.number_color)
		table.insert(out, tostring(v))
	else
		table.insert(out, tetra.misc_color)
		table.insert(out, string.format("%s [%s]", type(v), tostring(v)))
	end

	MsgC(unpack(out))
	MsgN("")
end

local _R = debug.getregistry()

local function findInternal(lookup, tbl, namespace, depth)
	depth = depth or 1
	if depth > 5 then return end -- in case of major fuckup, Garry's is 3

	for k, v in pairs(tbl) do
		if isstring(k) and k:lower():find(lookup:lower(), 1, true) then
			outputVar(namespace, k, v)
		end

		if istable(v)       and
			v ~= _G         and -- stop going into globals
			v ~= package    and -- stop going into more globals
			v ~= _R         and -- don't go into

			not (tbl == _R and isnumber(k)) and -- _R[i] is annoying

			k ~= "_M"       and -- module meta, can contain globals
			k ~= "_LOADED"  and -- _R._LOADED contains lua modules
			k ~= "__index"      -- since we can touch _R
		then
			local new
			if not namespace then
				new = k
			elseif isstring(k) then
				new = namespace .. "." .. k
			else
				new = namespace .. "[" .. tostring(k) .. "]"
			end

			findInternal(lookup, v, new, depth + 1)
		end
	end
end

function tetra.findInG(lookup)
	tetra.logf("lua: locating '%s' %s in _G", lookup, CLIENT and "clientside" or "serverside")
	findInternal(lookup, _G)
end

function tetra.findInR(lookup)
	tetra.logf("lua: locating '%s' %s in _R", lookup, CLIENT and "clientside" or "serverside")
	findInternal(lookup, _R, "_R")
end

function tetra.findInGR(lookup)
	tetra.logf("lua: locating '%s' %s in _G + _R", lookup, CLIENT and "clientside" or "serverside")
	findInternal(lookup, _G)
	findInternal(lookup, _R, "_R")
end

function tetra.findInX(lookup, ref, namespace)
	tetra.logf("lua: locating '%s' %s in %s", lookup, CLIENT and "clientside" or "serverside", namespace or ref)
	findInternal(lookup, ref, namespace)
end
