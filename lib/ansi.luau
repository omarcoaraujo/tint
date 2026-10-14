local codes: { [string]: { number | string } } = {
	-- Modifiers
	reset = { 0, 0 },
	bold = { 1, 22 },
	dim = { 2, 22 },
	italic = { 3, 23 },
	underline = { 4, 24 },
	overline = { 53, 55 },
	inverse = { 7, 27 },
	hidden = { 8, 28 },
	strikethrough = { 9, 29 },

	-- Underline styles
	underline_double = { "4:2", 24 },
	underline_curly = { "4:3", 24 },
	underline_dotted = { "4:4", 24 },
	underline_dashed = { "4:5", 24 },

	-- Underline colors
	underline_black = { "58;5;0", 59 },
	underline_red = { "58;5;1", 59 },
	underline_green = { "58;5;2", 59 },
	underline_yellow = { "58;5;3", 59 },
	underline_blue = { "58;5;4", 59 },
	underline_magenta = { "58;5;5", 59 },
	underline_cyan = { "58;5;6", 59 },
	underline_white = { "58;5;7", 59 },
	underline_gray = { "58;5;8", 59 },
	underline_bright_black = { "58;5;8", 59 },
	underline_bright_red = { "58;5;9", 59 },
	underline_bright_green = { "58;5;10", 59 },
	underline_bright_yellow = { "58;5;11", 59 },
	underline_bright_blue = { "58;5;12", 59 },
	underline_bright_magenta = { "58;5;13", 59 },
	underline_bright_cyan = { "58;5;14", 59 },
	underline_bright_white = { "58;5;15", 59 },

	-- Foreground colors
	black = { 30, 39 },
	red = { 31, 39 },
	green = { 32, 39 },
	yellow = { 33, 39 },
	blue = { 34, 39 },
	magenta = { 35, 39 },
	cyan = { 36, 39 },
	white = { 37, 39 },
	gray = { 90, 39 },

	-- Bright foreground
	bright_black = { 90, 39 },
	bright_red = { 91, 39 },
	bright_green = { 92, 39 },
	bright_yellow = { 93, 39 },
	bright_blue = { 94, 39 },
	bright_magenta = { 95, 39 },
	bright_cyan = { 96, 39 },
	bright_white = { 97, 39 },

	-- Background colors
	bg_black = { 40, 49 },
	bg_red = { 41, 49 },
	bg_green = { 42, 49 },
	bg_yellow = { 43, 49 },
	bg_blue = { 44, 49 },
	bg_magenta = { 45, 49 },
	bg_cyan = { 46, 49 },
	bg_white = { 47, 49 },

	-- Bright background
	bg_bright_black = { 100, 49 },
	bg_bright_red = { 101, 49 },
	bg_bright_green = { 102, 49 },
	bg_bright_yellow = { 103, 49 },
	bg_bright_blue = { 104, 49 },
	bg_bright_magenta = { 105, 49 },
	bg_bright_cyan = { 106, 49 },
	bg_bright_white = { 107, 49 },
}

return table.freeze(codes)
