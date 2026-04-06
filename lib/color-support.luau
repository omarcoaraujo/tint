-- Detects the level of ANSI color support in the current terminal.
-- Returns false if colors are not supported, or a ColorInfo table:
--   level        0 = none | 1 = basic 16 | 2 = 256 colors | 3 = true color
--   hasBasic     true for level >= 1
--   has256       true for level >= 2
--   hasMillions  true for level >= 3
--
-- Override detection with environment variables:
--   FORCE_COLOR=0|1|2|3|true|false  — force a specific level
--   NO_COLOR (any value)            — disable colors (https://no-color.org)

export type ColorInfo = {
	level: number,
	hasBasic: boolean,
	has256: boolean,
	hasMillions: boolean,
}

-- When os.getenv is unavailable (sandboxed environments), we cannot inspect
-- environment variables, so we assume full true-color support rather than
-- silently disabling all output.
local canDetect = os ~= nil and os.getenv ~= nil

local getenv: (string) -> string?
if canDetect then
	getenv = os.getenv
else
	getenv = function(_: string): string?
		return nil
	end
end

local function makeLevel(level: number): ColorInfo | false
	if level == 0 then
		return false
	end
	return {
		level = level,
		hasBasic = true,
		has256 = level >= 2,
		hasMillions = level >= 3,
	}
end

local function envForceColor(): number?
	local value = getenv("FORCE_COLOR")
	if value == nil then return nil end
	if value == "true" then return 1 end
	if value == "false" then return 0 end
	if value == "" then return 1 end
	local n = tonumber(value)
	if n then return math.min(math.max(math.floor(n), 0), 3) end
	return 1
end

local function detect(): ColorInfo | false
	-- Cannot read environment — assume full color support
	if not canDetect then
		return makeLevel(3)
	end

	-- FORCE_COLOR overrides everything
	local forced = envForceColor()
	if forced ~= nil then
		return makeLevel(forced)
	end

	-- https://no-color.org
	if getenv("NO_COLOR") ~= nil then
		return makeLevel(0)
	end

	if getenv("TERM") == "dumb" then
		return makeLevel(0)
	end

	-- Windows: check via OS env var
	local osEnv = getenv("OS") or ""
	if osEnv:find("Windows", 1, true) then
		-- Windows Terminal supports true color
		if getenv("WT_SESSION") ~= nil then
			return makeLevel(3)
		end
		local colorterm = getenv("COLORTERM") or ""
		if colorterm == "truecolor" or colorterm == "24bit" then
			return makeLevel(3)
		end
		return makeLevel(1)
	end

	-- COLORTERM=truecolor or 24bit → true color
	local colorterm = getenv("COLORTERM") or ""
	if colorterm == "truecolor" or colorterm == "24bit" then
		return makeLevel(3)
	end

	-- CI environments support basic colors
	if getenv("CI") ~= nil then
		local knownCIs =
			{ "TRAVIS", "CIRCLECI", "APPVEYOR", "GITLAB_CI", "GITHUB_ACTIONS", "BUILDKITE", "DRONE" }
		for _, var in knownCIs do
			if getenv(var) ~= nil then
				return makeLevel(1)
			end
		end
		return makeLevel(1)
	end

	-- TERM_PROGRAM (macOS terminals)
	local termProgram = getenv("TERM_PROGRAM") or ""
	if termProgram ~= "" then
		local versionStr = getenv("TERM_PROGRAM_VERSION") or ""
		local version = tonumber(versionStr:match("^(%d+)")) or 0
		if termProgram == "iTerm.app" then
			return makeLevel(version >= 3 and 3 or 2)
		elseif termProgram == "Apple_Terminal" then
			return makeLevel(2)
		end
	end

	-- TERM variable patterns
	local term = getenv("TERM") or ""
	if term:match("%-256color$") or term:match("%-256$") then
		return makeLevel(2)
	end
	if
		term:match("^screen")
		or term:match("^xterm")
		or term:match("^vt100")
		or term:match("^vt220")
		or term:match("^rxvt")
		or term:find("color", 1, true)
		or term:find("ansi", 1, true)
		or term:find("cygwin", 1, true)
		or term:find("linux", 1, true)
	then
		return makeLevel(1)
	end

	-- Any COLORTERM value → at least basic colors
	if getenv("COLORTERM") ~= nil then
		return makeLevel(1)
	end

	return makeLevel(0)
end

return detect()
