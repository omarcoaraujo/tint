local ansi = {}

ansi.codes = {
	-- Modifiers
	bold = { open = "\27[1m", close = "\27[22m" },
	dim = { open = "\27[2m", close = "\27[22m" },
	italic = { open = "\27[3m", close = "\27[23m" },
	underline = { open = "\27[4m", close = "\27[24m" },
	inverse = { open = "\27[7m", close = "\27[27m" },
	hidden = { open = "\27[8m", close = "\27[28m" },
	strikethrough = { open = "\27[9m", close = "\27[29m" },

	-- Foreground colors
	black = { open = "\27[30m", close = "\27[39m" },
	red = { open = "\27[31m", close = "\27[39m" },
	green = { open = "\27[32m", close = "\27[39m" },
	yellow = { open = "\27[33m", close = "\27[39m" },
	blue = { open = "\27[34m", close = "\27[39m" },
	magenta = { open = "\27[35m", close = "\27[39m" },
	cyan = { open = "\27[36m", close = "\27[39m" },
	white = { open = "\27[37m", close = "\27[39m" },
	gray = { open = "\27[90m", close = "\27[39m" },

	-- Bright foreground colors
	brightBlack = { open = "\27[90m", close = "\27[39m" },
	brightRed = { open = "\27[91m", close = "\27[39m" },
	brightGreen = { open = "\27[92m", close = "\27[39m" },
	brightYellow = { open = "\27[93m", close = "\27[39m" },
	brightBlue = { open = "\27[94m", close = "\27[39m" },
	brightMagenta = { open = "\27[95m", close = "\27[39m" },
	brightCyan = { open = "\27[96m", close = "\27[39m" },
	brightWhite = { open = "\27[97m", close = "\27[39m" },

	-- Background colors
	bgBlack = { open = "\27[40m", close = "\27[49m" },
	bgRed = { open = "\27[41m", close = "\27[49m" },
	bgGreen = { open = "\27[42m", close = "\27[49m" },
	bgYellow = { open = "\27[43m", close = "\27[49m" },
	bgBlue = { open = "\27[44m", close = "\27[49m" },
	bgMagenta = { open = "\27[45m", close = "\27[49m" },
	bgCyan = { open = "\27[46m", close = "\27[49m" },
	bgWhite = { open = "\27[47m", close = "\27[49m" },
	bgGray = { open = "\27[100m", close = "\27[49m" },
	bgBrightBlack = { open = "\27[100m", close = "\27[49m" },
	bgBrightRed = { open = "\27[101m", close = "\27[49m" },
	bgBrightGreen = { open = "\27[102m", close = "\27[49m" },
	bgBrightYellow = { open = "\27[103m", close = "\27[49m" },
	bgBrightBlue = { open = "\27[104m", close = "\27[49m" },
	bgBrightMagenta = { open = "\27[105m", close = "\27[49m" },
	bgBrightCyan = { open = "\27[106m", close = "\27[49m" },
	bgBrightWhite = { open = "\27[107m", close = "\27[49m" },
}

function ansi.rgb(r: number, g: number, b: number): { open: string, close: string }
	return {
		open = string.format("\27[38;2;%d;%d;%dm", r, g, b),
		close = "\27[39m",
	}
end

function ansi.bgRgb(r: number, g: number, b: number): { open: string, close: string }
	return {
		open = string.format("\27[48;2;%d;%d;%dm", r, g, b),
		close = "\27[49m",
	}
end

function ansi.hex(hex: string): { open: string, close: string }
	hex = hex:gsub("^#", "")
	local r = tonumber(hex:sub(1, 2), 16) or 0
	local g = tonumber(hex:sub(3, 4), 16) or 0
	local b = tonumber(hex:sub(5, 6), 16) or 0
	return ansi.rgb(r, g, b)
end

function ansi.bgHex(hex: string): { open: string, close: string }
	hex = hex:gsub("^#", "")
	local r = tonumber(hex:sub(1, 2), 16) or 0
	local g = tonumber(hex:sub(3, 4), 16) or 0
	local b = tonumber(hex:sub(5, 6), 16) or 0
	return ansi.bgRgb(r, g, b)
end

-- Nearest ANSI 16-color palette (r, g, b, ansi-code)
local ANSI16_PALETTE = {
	{ 0, 0, 0, 30 },
	{ 170, 0, 0, 31 },
	{ 0, 170, 0, 32 },
	{ 170, 170, 0, 33 },
	{ 0, 0, 170, 34 },
	{ 170, 0, 170, 35 },
	{ 0, 170, 170, 36 },
	{ 170, 170, 170, 37 },
	{ 85, 85, 85, 90 },
	{ 255, 85, 85, 91 },
	{ 85, 255, 85, 92 },
	{ 255, 255, 85, 93 },
	{ 85, 85, 255, 94 },
	{ 255, 85, 255, 95 },
	{ 85, 255, 255, 96 },
	{ 255, 255, 255, 97 },
}

-- Returns the nearest ANSI 16-color foreground code for the given RGB values.
function ansi.rgbToAnsi16(r: number, g: number, b: number): number
	local nearest = 30
	local minDist = math.huge
	for _, c in ANSI16_PALETTE do
		local dr, dg, db = r - c[1], g - c[2], b - c[3]
		local dist = dr * dr + dg * dg + db * db
		if dist < minDist then
			minDist = dist
			nearest = c[4]
		end
	end
	return nearest
end

-- Returns the nearest ANSI 256-color index for the given RGB values.
function ansi.rgbToAnsi256(r: number, g: number, b: number): number
	if r == g and g == b then
		if r < 8 then return 16 end
		if r > 248 then return 231 end
		return math.round(((r - 8) / 247) * 24) + 232
	end
	return 16
		+ 36 * math.round(r / 255 * 5)
		+ 6 * math.round(g / 255 * 5)
		+ math.round(b / 255 * 5)
end

return ansi
