local ansi = require "@self/ansi"
local color_convert = require "@self/color_convert"
local color_support = require "@self/color_support"

export type style = ((...string) -> string) & {
	reset: style,
	bold: style,
	dim: style,
	italic: style,
	underline: style,
	overline: style,
	inverse: style,
	hidden: style,
	strikethrough: style,

	black: style,
	red: style,
	green: style,
	yellow: style,
	blue: style,
	magenta: style,
	cyan: style,
	white: style,
	gray: style,

	bright_black: style,
	bright_red: style,
	bright_green: style,
	bright_yellow: style,
	bright_blue: style,
	bright_magenta: style,
	bright_cyan: style,
	bright_white: style,

	bg_black: style,
	bg_red: style,
	bg_green: style,
	bg_yellow: style,
	bg_blue: style,
	bg_magenta: style,
	bg_cyan: style,
	bg_white: style,

	bg_bright_black: style,
	bg_bright_red: style,
	bg_bright_green: style,
	bg_bright_yellow: style,
	bg_bright_blue: style,
	bg_bright_magenta: style,
	bg_bright_cyan: style,
	bg_bright_white: style,
}

type tint = style & {
	rgb: (r: number, g: number, b: number) -> style,
	hex: (hex: string) -> style,

	bg_rgb: (r: number, g: number, b: number) -> style,
	bg_hex: (hex: string) -> style,
}

local function replace_all(str: string, find: string, replacement: string)
	local result = str
	local position = 1

	while true do
		local start = string.find(result, find, position, true)
		if not start then break end

		result = string.sub(result, 1, start - 1) .. replacement .. string.sub(result, start + #find)
		position = start + #replacement
	end

	return result
end

local function create_style(codes: { { number | string } })
	local style = {}

	setmetatable(style, {
		__call = function(_, ...)
			if select("#", ...) == 0 then return "" end
			if color_support.level == 0 then return table.concat({ ... }, " ") end

			local text = table.concat({ ... }, " ")
			local close_map = {}

			local open = ""
			local close = ""

			for _, code in codes do
				open ..= `\27[{code[1]}m`
				close = `\27[{code[2]}m` .. close
			end

			for _, code in codes do
				local close_sequence = `\27[{code[2]}m`
				if close_map[close_sequence] then continue end

				close_map[close_sequence] = true
				text = replace_all(text, close_sequence, close_sequence .. open)
			end

			return open .. text .. close
		end,

		__index = function(_, key)
			local code = ansi[key]
			if not code then return end

			local new_codes = table.clone(codes)
			table.insert(new_codes, code)

			return create_style(new_codes)
		end,
	})

	return style
end

local tint = setmetatable({}, {
	__index = function(self, key)
		local code = ansi[key]

		if not code then return end
		return create_style { code }
	end,
})

function tint.rgb(r: number, g: number, b: number)
	if color_support.has_16m then
		return create_style { { `38;2;{r};{g};{b}`, 39 } }
	elseif color_support.has_256 then
		return create_style { { `38;5;{color_convert.to_ansi256(r, g, b)}`, 39 } }
	else
		return create_style { { color_convert.to_ansi16(r, g, b), 39 } }
	end
end

function tint.bg_rgb(r: number, g: number, b: number)
	if color_support.has_16m then
		return create_style { { `48;2;{r};{g};{b}`, 49 } }
	elseif color_support.has_256 then
		return create_style { { `48;5;{color_convert.to_ansi256(r, g, b)}`, 49 } }
	else
		return create_style { { color_convert.to_ansi16(r, g, b) + 10, 49 } }
	end
end

function tint.hex(hex: string)
	hex = hex:gsub("#", "")

	local r = tonumber(hex:sub(1, 2), 16) or 0
	local g = tonumber(hex:sub(3, 4), 16) or 0
	local b = tonumber(hex:sub(5, 6), 16) or 0

	return tint.rgb(r, g, b)
end

function tint.bg_hex(hex: string)
	hex = hex:gsub("#", "")

	local r = tonumber(hex:sub(1, 2), 16) or 0
	local g = tonumber(hex:sub(3, 4), 16) or 0
	local b = tonumber(hex:sub(5, 6), 16) or 0

	return tint.bg_rgb(r, g, b)
end

return tint :: tint
