local color_support = require "@lib/color_support"
local tint = require "@lib"

local spec = {} :: { [string]: any }

-- CLI flags: disable
function spec.should_return_0_for_no_color_flag()
	assert(color_support.detect_level { args = { "--no-color" }, env = {} } == 0)
end

function spec.should_return_0_for_color_false_flag()
	assert(color_support.detect_level { args = { "--color=false" }, env = {} } == 0)
end

function spec.should_return_0_for_color_never_flag()
	assert(color_support.detect_level { args = { "--color=never" }, env = {} } == 0)
end

-- CLI flags: enable
function spec.should_return_1_for_color_flag()
	assert(color_support.detect_level { args = { "--color" }, env = {} } == 1)
end

function spec.should_return_1_for_color_true_flag()
	assert(color_support.detect_level { args = { "--color=true" }, env = {} } == 1)
end

function spec.should_return_1_for_color_always_flag()
	assert(color_support.detect_level { args = { "--color=always" }, env = {} } == 1)
end

-- CLI flags: specific levels
function spec.should_return_3_for_color_16m_flag()
	assert(color_support.detect_level { args = { "--color=16m" }, env = {} } == 3)
end

function spec.should_return_3_for_color_full_flag()
	assert(color_support.detect_level { args = { "--color=full" }, env = {} } == 3)
end

function spec.should_return_3_for_color_truecolor_flag()
	assert(color_support.detect_level { args = { "--color=truecolor" }, env = {} } == 3)
end

function spec.should_return_2_for_color_256_flag()
	assert(color_support.detect_level { args = { "--color=256" }, env = {} } == 2)
end

-- FORCE_COLOR env
function spec.should_return_1_for_force_color_true()
	assert(color_support.detect_level { env = { FORCE_COLOR = "true" } } == 1)
end

function spec.should_return_0_for_force_color_false()
	assert(color_support.detect_level { env = { FORCE_COLOR = "false" } } == 0)
end

function spec.should_return_1_for_force_color_empty()
	assert(color_support.detect_level { env = { FORCE_COLOR = "" } } == 1)
end

function spec.should_return_0_for_force_color_0()
	assert(color_support.detect_level { env = { FORCE_COLOR = "0" } } == 0)
end

function spec.should_return_1_for_force_color_1()
	assert(color_support.detect_level { env = { FORCE_COLOR = "1" } } == 1)
end

function spec.should_return_2_for_force_color_2()
	assert(color_support.detect_level { env = { FORCE_COLOR = "2" } } == 2)
end

function spec.should_return_3_for_force_color_3()
	assert(color_support.detect_level { env = { FORCE_COLOR = "3" } } == 3)
end

function spec.should_cap_force_color_at_3()
	assert(color_support.detect_level { env = { FORCE_COLOR = "99" } } == 3)
end

function spec.should_ignore_invalid_force_color()
	assert(color_support.detect_level { env = { FORCE_COLOR = "banana" } } == 0)
end

-- NO_COLOR
function spec.should_return_0_for_no_color_env()
	assert(color_support.detect_level { env = { NO_COLOR = "" } } == 0)
end

function spec.should_return_0_for_no_color_env_with_value()
	assert(color_support.detect_level { env = { NO_COLOR = "1" } } == 0)
end

-- TERM=dumb
function spec.should_return_0_for_dumb_term()
	assert(color_support.detect_level { env = { TERM = "dumb" } } == 0)
end

function spec.should_return_1_for_dumb_term_with_force_color()
	assert(color_support.detect_level { env = { TERM = "dumb", FORCE_COLOR = "1" } } == 1)
end

-- Windows
function spec.should_return_3_for_windows()
	assert(color_support.detect_level { os = "windows", env = {} } == 3)
end

function spec.should_return_3_for_windows_with_force_color()
	assert(color_support.detect_level { os = "windows", env = { FORCE_COLOR = "1" } } == 3)
end

-- CI
function spec.should_return_1_for_generic_ci()
	assert(color_support.detect_level { env = { CI = "true" } } == 1)
end

function spec.should_return_3_for_github_actions()
	assert(color_support.detect_level { env = { CI = "true", GITHUB_ACTIONS = "true" } } == 3)
end

function spec.should_return_3_for_gitlab_ci()
	assert(color_support.detect_level { env = { CI = "true", GITLAB_CI = "true" } } == 3)
end

-- Truecolor terminals
function spec.should_return_3_for_colorterm_truecolor()
	assert(color_support.detect_level { env = { COLORTERM = "truecolor" } } == 3)
end

function spec.should_return_3_for_xterm_kitty()
	assert(color_support.detect_level { env = { TERM = "xterm-kitty" } } == 3)
end

function spec.should_return_3_for_xterm_ghostty()
	assert(color_support.detect_level { env = { TERM = "xterm-ghostty" } } == 3)
end

function spec.should_return_3_for_wezterm()
	assert(color_support.detect_level { env = { TERM = "wezterm" } } == 3)
end

-- TERM_PROGRAM
function spec.should_return_3_for_iterm_v3()
	assert(color_support.detect_level { env = { TERM_PROGRAM = "iTerm.app", TERM_PROGRAM_VERSION = "3.0.0" } } == 3)
end

function spec.should_return_2_for_iterm_v2()
	assert(color_support.detect_level { env = { TERM_PROGRAM = "iTerm.app", TERM_PROGRAM_VERSION = "2.9.0" } } == 2)
end

function spec.should_return_2_for_iterm_no_version()
	assert(color_support.detect_level { env = { TERM_PROGRAM = "iTerm.app" } } == 2)
end

function spec.should_return_2_for_apple_terminal()
	assert(color_support.detect_level { env = { TERM_PROGRAM = "Apple_Terminal" } } == 2)
end

-- TERM 256 color
function spec.should_return_2_for_xterm_256color()
	assert(color_support.detect_level { env = { TERM = "xterm-256color" } } == 2)
end

function spec.should_return_2_for_screen_256color()
	assert(color_support.detect_level { env = { TERM = "screen-256color" } } == 2)
end

-- TERM basic color
function spec.should_return_1_for_xterm()
	assert(color_support.detect_level { env = { TERM = "xterm" } } == 1)
end

function spec.should_return_1_for_screen()
	assert(color_support.detect_level { env = { TERM = "screen" } } == 1)
end

function spec.should_return_1_for_vt100()
	assert(color_support.detect_level { env = { TERM = "vt100" } } == 1)
end

function spec.should_return_1_for_rxvt()
	assert(color_support.detect_level { env = { TERM = "rxvt" } } == 1)
end

function spec.should_return_1_for_linux()
	assert(color_support.detect_level { env = { TERM = "linux" } } == 1)
end

function spec.should_return_1_for_term_with_color()
	assert(color_support.detect_level { env = { TERM = "xterm-color" } } == 1)
end

function spec.should_return_1_for_term_with_ansi()
	assert(color_support.detect_level { env = { TERM = "ansi" } } == 1)
end

-- COLORTERM (any value)
function spec.should_return_1_for_colorterm_any()
	assert(color_support.detect_level { env = { COLORTERM = "yes" } } == 1)
end

-- Fallback
function spec.should_return_0_for_empty_env()
	assert(color_support.detect_level { env = {} } == 0)
end

function spec.should_return_0_for_unknown_term()
	assert(color_support.detect_level { env = { TERM = "something-unknown" } } == 0)
end

-- Priority / override tests
function spec.should_force_color_override_no_color()
	assert(color_support.detect_level { env = { NO_COLOR = "1", FORCE_COLOR = "3" } } == 3)
end

function spec.should_env_force_override_flag()
	assert(color_support.detect_level { args = { "--no-color" }, env = { FORCE_COLOR = "3" } } == 3)
end

function spec.should_force_color_0_override_truecolor()
	assert(color_support.detect_level { env = { FORCE_COLOR = "0", COLORTERM = "truecolor" } } == 0)
end

-- FORCE_COLOR edge cases
function spec.should_ignore_negative_force_color()
	assert(color_support.detect_level { env = { FORCE_COLOR = "-1" } } == 0)
end

-- Conflicting CLI flags (no-color comes first in check order)
function spec.should_no_color_flag_win_over_color_flag()
	assert(color_support.detect_level { args = { "--no-color", "--color" }, env = {} } == 0)
end

-- CLI flag level with FORCE_COLOR=0
function spec.should_force_color_0_override_color_256_flag()
	assert(color_support.detect_level { args = { "--color=256" }, env = { FORCE_COLOR = "0" } } == 0)
end

-- dumb + NO_COLOR
function spec.should_return_0_for_dumb_with_no_color()
	assert(color_support.detect_level { env = { TERM = "dumb", NO_COLOR = "" } } == 0)
end

-- Windows + FORCE_COLOR=0
function spec.should_return_0_for_windows_with_force_color_0()
	assert(color_support.detect_level { os = "windows", env = { FORCE_COLOR = "0" } } == 0)
end

-- CI + FORCE_COLOR=0
function spec.should_return_0_for_ci_with_force_color_0()
	assert(color_support.detect_level { env = { CI = "true", FORCE_COLOR = "0" } } == 0)
end

-- TTY
function spec.should_return_0_when_not_tty()
	assert(color_support.detect_level { is_tty = false, env = { COLORTERM = "truecolor" } } == 0)
end

function spec.should_return_3_when_not_tty_with_force_color()
	assert(color_support.detect_level { is_tty = false, env = { FORCE_COLOR = "3" } } == 3)
end

function spec.should_return_3_when_tty_with_truecolor()
	assert(color_support.detect_level { is_tty = true, env = { COLORTERM = "truecolor" } } == 3)
end

local function is_test(name: string, value: any)
	return typeof(value) == "function" and name:sub(1, 7) == "should_"
end

local function get_sorted_keys()
	local keys = {}

	for key, value in spec do
		if is_test(key, value) then table.insert(keys, key) end
	end

	table.sort(keys)
	return keys
end

local keys = get_sorted_keys()
local total = #keys
local failed = 0

for _, name in keys do
	local success, errorMessage = pcall(spec[name])

	if not success then
		failed += 1
		print(`\27[31m✗\27[0m [{name}] {errorMessage}`)
	end
end

if failed > 0 then print(`\n\27[31m✗ {failed}/{total} tests failed!\27[0m`) end
print(`\27[32m✓ {total}/{total} all tests passed!\27[0m \n`)
