function tetra.getSet(meta, var, expected, get, set)
	local name = var:gsub("^(%l)", string.upper)

	local get_name = (get or "get") .. name
	meta[get_name] = function(o)
		return o[var]
	end

	local set_name = (set or "set") .. name
	meta[set_name] = function(o, val)
		if expected then
			tetra.typeCheck(expected, 1, val)
		end

		o[var] = val
		return o -- chaining support
	end
end

function tetra.isSet(meta, var, expected)
	tetra.getSet(meta, var, expected, "is")
end

function tetra.hasSet(meta, var, expected)
	tetra.getSet(meta, var, expected, "has")
end
