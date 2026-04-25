local version = _VERSION:lower()
local env, args, os, is_tty

local is_zune = version:find "zune" ~= nil
local is_lune = version:find "lune" ~= nil

if is_zune then
	env = zune.process.env
	args = zune.process.args
	os = zune.platform.os
	is_tty = zune.io.terminal.isTTY
else
	local alias = if is_lune then "@lune" else "@lute"
	local ok, process = pcall(require, `{alias}/process`)

	if ok then
		env = process.env
		args = process.args
		os = process.os
		is_tty = true
	else
		env = {}
		args = {}
		os = "unknown"
		is_tty = true
	end
end

return table.freeze {
	env = env,
	args = args,
	os = os,
	is_tty = is_tty,
}
