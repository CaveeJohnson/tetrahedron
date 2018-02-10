function tetra.typeCheck(expected, n, var)
	if type(var) ~= expected then
		tetra.typeError(debug.getinfo(2).name, n, expected, var, 4)
	end
end

function tetra.typeError(f, n, expected, var, level)
	error(string.format("bad argument #%d to '%s' (%s expected, got %s)", n, f, expected, type(var)), level or 3)
end

function tetra.urlEscape(str)
	return string.gsub(str, "([^%w_])", function(c)
		return string.format("%%%02x", string.byte(c))
	end)
end
