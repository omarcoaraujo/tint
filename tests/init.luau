local tint = require "@lib"

local color_convert = require "@lib/color_convert"
local color_support = require "@lib/color_support"

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

-- RGB to 256
function spec.should_convert_red_to_ansi256()
	assert(color_convert.to_ansi256(255, 0, 0) == 196)
end

function spec.should_convert_green_to_ansi256()
	assert(color_convert.to_ansi256(0, 255, 0) == 46)
end

function spec.should_convert_blue_to_ansi256()
	assert(color_convert.to_ansi256(0, 0, 255) == 21)
end

function spec.should_convert_white_to_ansi256()
	assert(color_convert.to_ansi256(255, 255, 255) == 231)
end

function spec.should_convert_black_to_ansi256()
	assert(color_convert.to_ansi256(0, 0, 0) == 16)
end

function spec.should_convert_gray_to_ansi256()
	assert(color_convert.to_ansi256(128, 128, 128) == 244)
end

-- RGB to 16
function spec.should_convert_red_to_ansi16()
	assert(color_convert.to_ansi16(255, 0, 0) == 91)
end

function spec.should_convert_green_to_ansi16()
	assert(color_convert.to_ansi16(0, 255, 0) == 92)
end

function spec.should_convert_blue_to_ansi16()
	assert(color_convert.to_ansi16(0, 0, 255) == 94)
end

function spec.should_convert_white_to_ansi16()
	assert(color_convert.to_ansi16(255, 255, 255) == 97)
end

function spec.should_convert_black_to_ansi16()
	assert(color_convert.to_ansi16(0, 0, 0) == 30)
end

-- Basic styling
function spec.should_style_with_underline()
	assert(tint.underline "foo" == "\27[4mfoo\27[24m")
end

function spec.should_style_with_red()
	assert(tint.red "foo" == "\27[31mfoo\27[39m")
end

function spec.should_style_with_bg_red()
	assert(tint.bg_red "foo" == "\27[41mfoo\27[49m")
end

-- Multiple styles at once
function spec.should_apply_red_bg_green_underline()
	assert(tint.red.bg_green.underline "foo" == "\27[31m\27[42m\27[4mfoo\27[24m\27[49m\27[39m")
end

function spec.should_apply_underline_red_bg_green()
	assert(tint.underline.red.bg_green "foo" == "\27[4m\27[31m\27[42mfoo\27[49m\27[39m\27[24m")
end

-- Nesting styles
function spec.should_nest_styles()
	assert(tint.red("foo" .. tint.underline.bg_blue "bar" .. "!") == "\27[31mfoo\27[4m\27[44mbar\27[49m\27[24m!\27[39m")
end

-- Nesting same type
function spec.should_nest_same_type_colors()
	assert(
		tint.red("a" .. tint.yellow("b" .. tint.green "c" .. "b") .. "c")
			== "\27[31ma\27[33mb\27[32mc\27[39m\27[31m\27[33mb\27[39m\27[31mc\27[39m"
	)
end

-- Reset
function spec.should_reset_all_styles()
	assert(
		tint.reset(tint.red.bg_green.underline "foo" .. "foo")
			== "\27[0m\27[31m\27[42m\27[4mfoo\27[24m\27[49m\27[39mfoo\27[0m"
	)
end

-- Caching / reusable styles
function spec.should_cache_styles()
	local red = tint.red
	local red_bold = tint.red.bold

	assert(red "foo" ~= red_bold "foo")
end

-- Gray alias
function spec.should_alias_gray_to_bright_black()
	assert(tint.gray "foo" == "\27[90mfoo\27[39m")
end

function spec.should_support_bright_black()
	assert(tint.bright_black "foo" == "\27[90mfoo\27[39m")
end

-- Multiple arguments
function spec.should_join_args_with_space()
	assert(tint.red("foo", "bar") == "\27[31mfoo bar\27[39m")
end

-- No arguments returns empty
function spec.should_return_empty_for_no_args()
	assert(tint.red() == "")
	assert(tint.red.blue.black() == "")
end

-- RGB
function spec.should_apply_rgb()
	assert(tint.rgb(255, 0, 0) "foo" == "\27[38;2;255;0;0mfoo\27[39m")
end

function spec.should_apply_bg_rgb()
	assert(tint.bg_rgb(255, 0, 0) "foo" == "\27[48;2;255;0;0mfoo\27[49m")
end

-- Hex
function spec.should_apply_hex()
	assert(tint.hex "#FF0000" "foo" == "\27[38;2;255;0;0mfoo\27[39m")
end

function spec.should_apply_bg_hex()
	assert(tint.bg_hex "#FF0000" "foo" == "\27[48;2;255;0;0mfoo\27[49m")
end

-- Hex chained with bold
function spec.should_chain_hex_with_bold()
	assert(tint.hex("#FF0000").bold "foo" == "\27[38;2;255;0;0m\27[1mfoo\27[22m\27[39m")
end

-- RGB chained
function spec.should_chain_rgb_with_underline()
	assert(tint.rgb(123, 45, 67).underline "foo" == "\27[38;2;123;45;67m\27[4mfoo\27[24m\27[39m")
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
		print(`  {tint.red.bold "✗"} {tint.dim(name)} {tint.red(errorMessage)}`)
	end
end

if failed > 0 then error(`\n{tint.red.bold(`✗ {failed}/{total} tests failed!`)}`) end
print(`{tint.green.bold(`✓ {total}/{total}`)} all tests passed! \n`)
