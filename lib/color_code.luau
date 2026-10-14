local color_convert = require "./color_convert"
export type code = { number | string }

local function parse_hex(hex: string)
	hex = hex:gsub("#", "")

	local r = tonumber(hex:sub(1, 2), 16) or 0
	local g = tonumber(hex:sub(3, 4), 16) or 0
	local b = tonumber(hex:sub(5, 6), 16) or 0

	return r, g, b
end

local function rgb(level: number, r: number, g: number, b: number): code
	if level >= 3 then return { `38;2;{r};{g};{b}`, 39 } end
	if level >= 2 then return { `38;5;{color_convert.to_ansi256(r, g, b)}`, 39 } end
	return { color_convert.to_ansi16(r, g, b), 39 }
end

local function bg_rgb(level: number, r: number, g: number, b: number): code
	if level >= 3 then return { `48;2;{r};{g};{b}`, 49 } end
	if level >= 2 then return { `48;5;{color_convert.to_ansi256(r, g, b)}`, 49 } end
	return { color_convert.to_ansi16(r, g, b) + 10, 49 }
end

local function ansi256(level: number, value: number): code
	if level >= 2 then return { `38;5;{value}`, 39 } end
	return { color_convert.ansi256_to_ansi16(value), 39 }
end

local function bg_ansi256(level: number, value: number): code
	if level >= 2 then return { `48;5;{value}`, 49 } end
	return { color_convert.ansi256_to_ansi16(value) + 10, 49 }
end

local function underline_ansi256(level: number, value: number): code
	if level >= 2 then return { `58;5;{value}`, 59 } end
	return { `58;5;{color_convert.ansi256_to_palette16(value)}`, 59 }
end

local function underline_rgb(level: number, r: number, g: number, b: number): code
	if level >= 3 then return { `58;2;{r};{g};{b}`, 59 } end
	return underline_ansi256(level, color_convert.to_ansi256(r, g, b))
end

local function hex(level: number, value: string): code
	return rgb(level, parse_hex(value))
end

local function bg_hex(level: number, value: string): code
	return bg_rgb(level, parse_hex(value))
end

local function underline_hex(level: number, value: string): code
	return underline_rgb(level, parse_hex(value))
end

return table.freeze {
	rgb = rgb,
	bg_rgb = bg_rgb,

	hex = hex,
	bg_hex = bg_hex,

	ansi256 = ansi256,
	bg_ansi256 = bg_ansi256,

	underline_rgb = underline_rgb,
	underline_hex = underline_hex,
	underline_ansi256 = underline_ansi256,
} :: { [string]: (level: number, a: any, b: any, c: any) -> code }
