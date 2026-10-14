local ansi = require "@self/ansi"
local color_convert = require "@self/color_convert"
local color_support = require "@self/color_support"

export type style = ((...any) -> string) & {
	reset: style,
	bold: style,
	dim: style,
	italic: style,
	underline: style,
	overline: style,
	inverse: style,
	hidden: style,
	strikethrough: style,
	visible: style,

	underline_double: style,
	underline_curly: style,
	underline_dotted: style,
	underline_dashed: style,

	underline_black: style,
	underline_red: style,
	underline_green: style,
	underline_yellow: style,
	underline_blue: style,
	underline_magenta: style,
	underline_cyan: style,
	underline_white: style,
	underline_gray: style,
	underline_bright_black: style,
	underline_bright_red: style,
	underline_bright_green: style,
	underline_bright_yellow: style,
	underline_bright_blue: style,
	underline_bright_magenta: style,
	underline_bright_cyan: style,
	underline_bright_white: style,

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

type tint = style & ((...any) -> string) & {
	rgb: (r: number, g: number, b: number) -> style,
	hex: (hex: string) -> style,

	bg_rgb: (r: number, g: number, b: number) -> style,
	bg_hex: (hex: string) -> style,

	ansi256: (code: number) -> style,
	bg_ansi256: (code: number) -> style,

	underline_rgb: (r: number, g: number, b: number) -> style,
	underline_hex: (hex: string) -> style,
	underline_ansi256: (code: number) -> style,

	strip: (text: string) -> string,
	new: (config: { level: number? }?) -> tint,
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

local function encase_line_breaks(text: string, open: string, close: string)
	local result = text
	local position = 1

	while true do
		local start = string.find(result, "\n", position, true)
		if not start then break end

		local before = start
		if string.sub(result, start - 1, start - 1) == "\r" then before = start - 1 end

		result = string.sub(result, 1, before - 1)
			.. close
			.. string.sub(result, before, start)
			.. open
			.. string.sub(result, start + 1)

		position = start + #close + #open + 1
	end

	return result
end

local function join_arguments(...)
	local count = select("#", ...)
	local parts = table.create(count)

	for index = 1, count do
		local value = select(index, ...)
		parts[index] = if value == nil then "" else tostring(value)
	end

	return table.concat(parts, " ")
end

local function create_style(level: number, codes: { { number | string } }, visible_only: boolean?)
	local style = {}

	setmetatable(style, {
		__call = function(_, ...)
			if select("#", ...) == 0 then return "" end

			local text = join_arguments(...)
			if level == 0 then return if visible_only then "" else text end

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

			text = encase_line_breaks(text, open, close)
			return open .. text .. close
		end,

		__index = function(_, key)
			if key == "visible" then return create_style(level, codes, true) end

			local code = ansi[key]
			if not code then return end

			local new_codes = table.clone(codes)
			table.insert(new_codes, code)

			return create_style(level, new_codes, visible_only)
		end,
	})

	return style
end

local function parse_hex(hex: string)
	hex = hex:gsub("#", "")

	local r = tonumber(hex:sub(1, 2), 16) or 0
	local g = tonumber(hex:sub(3, 4), 16) or 0
	local b = tonumber(hex:sub(5, 6), 16) or 0

	return r, g, b
end

local function create_tint(level: number): tint
	local has_256 = level >= 2
	local has_16m = level >= 3

	local tint = setmetatable({}, {
		__call = function(_, ...)
			if select("#", ...) == 0 then return "" end
			return join_arguments(...)
		end,

		__index = function(self, key)
			if key == "visible" then return create_style(level, {}, true) end
			local code = ansi[key]

			if not code then return end
			return create_style(level, { code })
		end,
	})

	function tint.new(config: { level: number? }?)
		local requested = if config then config.level else nil
		if requested == nil then return create_tint(color_support.level) end
		return create_tint(math.clamp(math.floor(requested), 0, 3))
	end

	function tint.rgb(r: number, g: number, b: number)
		if has_16m then return create_style(level, { { `38;2;{r};{g};{b}`, 39 } }) end
		if has_256 then return create_style(level, { { `38;5;{color_convert.to_ansi256(r, g, b)}`, 39 } }) end
		return create_style(level, { { color_convert.to_ansi16(r, g, b), 39 } })
	end

	function tint.bg_rgb(r: number, g: number, b: number)
		if has_16m then return create_style(level, { { `48;2;{r};{g};{b}`, 49 } }) end
		if has_256 then return create_style(level, { { `48;5;{color_convert.to_ansi256(r, g, b)}`, 49 } }) end
		return create_style(level, { { color_convert.to_ansi16(r, g, b) + 10, 49 } })
	end

	function tint.hex(hex: string)
		return tint.rgb(parse_hex(hex))
	end

	function tint.bg_hex(hex: string)
		return tint.bg_rgb(parse_hex(hex))
	end

	function tint.ansi256(code: number)
		if has_256 then return create_style(level, { { `38;5;{code}`, 39 } }) end
		return create_style(level, { { color_convert.ansi256_to_ansi16(code), 39 } })
	end

	function tint.bg_ansi256(code: number)
		if has_256 then return create_style(level, { { `48;5;{code}`, 49 } }) end
		return create_style(level, { { color_convert.ansi256_to_ansi16(code) + 10, 49 } })
	end

	function tint.underline_ansi256(code: number)
		if has_256 then return create_style(level, { { `58;5;{code}`, 59 } }) end
		return create_style(level, { { `58;5;{color_convert.ansi256_to_palette16(code)}`, 59 } })
	end

	function tint.underline_rgb(r: number, g: number, b: number)
		if has_16m then return create_style(level, { { `58;2;{r};{g};{b}`, 59 } }) end
		return tint.underline_ansi256(color_convert.to_ansi256(r, g, b))
	end

	function tint.underline_hex(hex: string)
		return tint.underline_rgb(parse_hex(hex))
	end

	function tint.strip(text: string)
		local stripped = string.gsub(text, "\27%[[%d;:?]*[ -/]*[@-~]", "")
		return stripped
	end

	return tint :: tint
end

return create_tint(color_support.level)
