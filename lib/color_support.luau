local process_env = zune.process.env
local process_args = zune.process.args
local process_os = zune.platform.os
local is_tty = zune.io.terminal.isTTY

local function has_flag(args: { string }, flag: string)
	local prefix = if #flag == 1 then "-" else "--"
	return table.find(args, prefix .. flag) ~= nil
end

local function env_force_color(env: { [string]: string? }): number?
	local value = env.FORCE_COLOR

	if value == nil then return nil end
	if value == "true" or value == "" then return 1 end
	if value == "false" then return 0 end

	local level = tonumber(value)
	if level == nil then return nil end

	level = math.min(math.floor(level), 3)
	if level < 0 or level > 3 then return nil end

	return level
end

local function matches_any(str: string, patterns: { string })
	for _, pattern in patterns do
		if string.find(str, pattern) then return true end
	end

	return false
end

local function detect_level(config: { env: { [string]: string? }?, args: { string }?, os: string?, is_tty: boolean? }?)
	local env = if config then config.env or process_env else process_env
	local args = if config then config.args or {} else process_args
	local os = if config then config.os or "linux" else process_os
	local tty = if config then if config.is_tty ~= nil then config.is_tty else true else is_tty

	local function check_flag(flag: string)
		return has_flag(args, flag)
	end

	local flag_no_color = check_flag "no-color" or check_flag "color=false" or check_flag "color=never"
	local flag_color = check_flag "color" or check_flag "color=true" or check_flag "color=always"
	local env_force = env_force_color(env)

	local flag_force = if flag_no_color then 0 elseif flag_color then 1 else nil
	if env_force ~= nil then flag_force = env_force end

	local force_color = flag_force
	if force_color == 0 then return 0 end

	if check_flag "color=16m" or check_flag "color=full" or check_flag "color=truecolor" then return 3 end
	if check_flag "color=256" then return 2 end

	-- https://no-color.org (FORCE_COLOR overrides)
	if env.NO_COLOR ~= nil and force_color == nil then return 0 end

	-- No color when not a TTY (piping to file/process)
	if not tty and force_color == nil then return 0 end
	local min = force_color or 0

	if env.TERM == "dumb" then return min end
	if os == "windows" then return math.max(3, min) end

	if env.CI ~= nil then
		if env.GITHUB_ACTIONS ~= nil or env.GITLAB_CI ~= nil then return 3 end
		return 1
	end

	if env.COLORTERM == "truecolor" then return 3 end
	if env.TERM == "xterm-kitty" then return 3 end
	if env.TERM == "xterm-ghostty" then return 3 end
	if env.TERM == "wezterm" then return 3 end

	local term_program = env.TERM_PROGRAM
	local term_program_version = env.TERM_PROGRAM_VERSION or ""

	if term_program ~= nil then
		local version = tonumber(term_program_version:match "^(%d+)")

		if term_program == "iTerm.app" then return if version and version >= 3 then 3 else 2 end
		if term_program == "Apple_Terminal" then return 2 end
	end

	local term = env.TERM or ""
	local basic_terms = { "^screen", "^xterm", "^vt100", "^rxvt", "color", "ansi", "linux" }

	if term:match "%-256color$" then return 2 end
	if matches_any(term, basic_terms) then return 1 end
	if env.COLORTERM ~= nil then return 1 end

	return min
end

local level = detect_level()
return table.freeze {
	level = level,

	has_basic = level >= 1,
	has_256 = level >= 2,
	has_16m = level >= 3,

	detect_level = detect_level,
}
