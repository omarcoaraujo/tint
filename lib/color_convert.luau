local function rgb_to_ansi256(r: number, g: number, b: number)
	if r == g and g == b then
		if r < 8 then return 16 end
		if r > 248 then return 231 end

		return math.round((r - 8) / 247 * 24) + 232
	end

	return 16 + 36 * math.round(r / 255 * 5) + 6 * math.round(g / 255 * 5) + math.round(b / 255 * 5)
end

local function ansi256_to_ansi16(code: number)
	if code < 8 then return 30 + code end
	if code < 16 then return 90 + (code - 8) end

	local r, g, b

	if code >= 232 then
		local gray = ((code - 232) * 10 + 8) / 255
		r, g, b = gray, gray, gray
	else
		code -= 16
		local remainder = code % 36

		r = math.floor(code / 36) / 5
		g = math.floor(remainder / 6) / 5
		b = (remainder % 6) / 5
	end

	local value = math.max(r, g, b) * 2
	if value == 0 then return 30 end
	local result = 30 + bit32.lshift(math.round(b), 2) + bit32.lshift(math.round(g), 1) + math.round(r)

	if value == 2 then
		result += 60
	end

	return result
end

local function rgb_to_ansi16(r: number, g: number, b: number)
	return ansi256_to_ansi16(rgb_to_ansi256(r, g, b))
end

return table.freeze {
	to_ansi256 = rgb_to_ansi256,
	to_ansi16 = rgb_to_ansi16,
}
