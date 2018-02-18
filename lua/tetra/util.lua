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

if not (utf8.sub and utf8.totable) then
	local s_byte = string.byte
	local function charbytes(str, pos)
		local c = s_byte(str, pos)

		if c > 0 and c <= 127 then
			return 1
		elseif c >= 194 and c <= 223 then
			return 2
		elseif c >= 224 and c <= 239 then
			return 3
		elseif c >= 240 and c <= 244 then
			return 4
		end

		return -1
	end

	local s_len = string.len
	local u_len = utf8.len
	local s_sub = string.sub
	function utf8.sub(str, start, send)
		send = send or -1

		local pos = 1
		local bytes = s_len(str)
		local len = 0

		local a = (start >= 0 and send >= 0) or u_len(str)
		local startChar = (start >= 0) and start or a + start + 1
		local endChar = (send >= 0) and send or a + send + 1

		if startChar > endChar then
			return ""
		end

		local startByte, endByte = 1, bytes

		while pos <= bytes do
			len = len + 1

			if len == startChar then
				startByte = pos
			end

			pos = pos + charbytes(str, pos)

			if len == endChar then
				endByte = pos - 1
				break
			end
		end

		return s_sub(str, startByte, endByte)
	end

	local s_gmatch = string.gmatch
	function utf8.totable(str)
		local tbl = {}

		local i = 0
		for uchar in s_gmatch(str, "([%z\1-\127\194-\244][\128-\191]*)") do
			i = i + 1
			tbl[i] = uchar
		end

		return tbl
	end
end
