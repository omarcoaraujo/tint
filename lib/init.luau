local ansi = require("@self/ansi")
local colorSupport = require("@self/color-support")

local level: number = if colorSupport then colorSupport.level else 0

type Style = {
	open: string,
	close: string,
}

-- Escapes Lua pattern magic characters so close codes can be used in gsub
local function escapePattern(s: string): string
	return (s:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1"))
end

local ChainMeta: any = {}

local function makeChain(styles: { Style }): any
	return setmetatable({ _styles = styles }, ChainMeta)
end

-- Parses a hex color string (with or without leading #) into r, g, b components.
local function hexToRgb(hex: string): (number, number, number)
	hex = hex:gsub("^#", "")
	return tonumber(hex:sub(1, 2), 16) or 0,
		tonumber(hex:sub(3, 4), 16) or 0,
		tonumber(hex:sub(5, 6), 16) or 0
end

-- Builds a foreground Style for the given RGB values, downgraded to the
-- current color level when the terminal does not support true color.
local function rgbStyle(r: number, g: number, b: number): Style
	if level >= 3 then
		return ansi.rgb(r, g, b)
	elseif level == 2 then
		local code = ansi.rgbToAnsi256(r, g, b)
		return { open = string.format("\27[38;5;%dm", code), close = "\27[39m" }
	else
		local code = ansi.rgbToAnsi16(r, g, b)
		return { open = string.format("\27[%dm", code), close = "\27[39m" }
	end
end

-- Builds a background Style for the given RGB values, downgraded to the
-- current color level when the terminal does not support true color.
local function bgRgbStyle(r: number, g: number, b: number): Style
	if level >= 3 then
		return ansi.bgRgb(r, g, b)
	elseif level == 2 then
		local code = ansi.rgbToAnsi256(r, g, b)
		return { open = string.format("\27[48;5;%dm", code), close = "\27[49m" }
	else
		-- bg codes are fg codes + 10 (30→40, 90→100)
		local code = ansi.rgbToAnsi16(r, g, b)
		return { open = string.format("\27[%dm", code + 10), close = "\27[49m" }
	end
end

-- Accessing a property on a chain returns a new chain with that style appended.
-- rgb/hex/bgRgb/bgHex are functions that return a new chain when called.
ChainMeta.__index = function(t: any, key: string): any
	local styles: { Style } = rawget(t, "_styles")

	if key == "rgb" then
		return function(r: number, g: number, b: number)
			local new = table.clone(styles)
			table.insert(new, rgbStyle(r, g, b))
			return makeChain(new)
		end
	elseif key == "hex" then
		return function(h: string)
			local new = table.clone(styles)
			table.insert(new, rgbStyle(hexToRgb(h)))
			return makeChain(new)
		end
	elseif key == "bgRgb" then
		return function(r: number, g: number, b: number)
			local new = table.clone(styles)
			table.insert(new, bgRgbStyle(r, g, b))
			return makeChain(new)
		end
	elseif key == "bgHex" then
		return function(h: string)
			local new = table.clone(styles)
			table.insert(new, bgRgbStyle(hexToRgb(h)))
			return makeChain(new)
		end
	elseif ansi.codes[key] then
		local new = table.clone(styles)
		table.insert(new, ansi.codes[key])
		return makeChain(new)
	end

	return nil
end

-- Calling a chain applies all its styles to the concatenated arguments.
-- When color level is 0, plain text is returned with no ANSI codes.
-- Styles are applied from innermost (last added) to outermost (first added).
-- Nested Tint calls are handled by replacing inner close codes with close+open,
-- which restores the outer style after an inner one ends.
ChainMeta.__call = function(t: any, ...: string): string
	local styles: { Style } = rawget(t, "_styles")

	local parts = { ... }
	local str = table.concat(parts)

	if level == 0 then
		return str
	end

	for i = #styles, 1, -1 do
		local style = styles[i]
		str = style.open .. str:gsub(escapePattern(style.close), style.close .. style.open) .. style.close
	end

	return str
end

return makeChain({})
