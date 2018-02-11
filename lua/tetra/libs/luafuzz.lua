-- luafuzz.lua
-- public domain by szensk
-- buggy reimplementation of https://github.com/garybernhardt/selecta

-- returns indexes of character within string (str)
local function find_chars(str, first_char)
	local i = 0
	local res = {}
	while i do
		i = str:find(first_char, i + 1, true)
		res[#res + 1] = i
	end
	return res
end

-- returns last index of pattern within string (str) starting after first index (index)
local function find_end(str, index, query)
	local last = index
	for i = 2, #query do
		last = str:find(utf8.sub(query,i,i), index + 1, true) --or last
		if not last then return nil end
	end
	return last
end

-- returns length of match within str
local function compute_match_len(str, query)
	local first_char = utf8.sub(query,1,1)
	local first_indexes = find_chars(str, first_char)
	local res = {}
	-- find last indexes
	for i, index in ipairs(first_indexes) do
		local last_index = find_end(str, index, query)
		if last_index then
			res[#res + 1] = last_index - index
		end
	end

	if #res == 0 then return nil end
	return math.min(unpack(res)) --crash if #matches is over MAXSTACK (defined at compile time)
end

function string.fuzzy_match(str, query)
	if utf8.len(query) == 0 then return 1 end
	if utf8.len(str) == 0 then return 0 end

	str = str:lower()
	local match_len = compute_match_len(str, query)
	if not match_len or match_len == 0 then return 0 end

	local score = utf8.len(query) / match_len
	return score / utf8.len(str)
end
