local Tint = require("../lib")

print(Tint.red("ERROR"))
print(Tint.green("SUCCESS"))
print(Tint.yellow("WARNING"))
print(Tint.blue("INFO"))
print(Tint.magenta("MAGENTA"))
print(Tint.cyan("CYAN"))
print(Tint.white("WHITE"))
print(Tint.gray("GRAY"))

print(Tint.brightRed("BRIGHT RED"))
print(Tint.brightGreen("BRIGHT GREEN"))
print(Tint.brightBlue("BRIGHT BLUE"))

print(Tint.bgRed("RED BACKGROUND"))
print(Tint.bgGreen("GREEN BACKGROUND"))
print(Tint.bgBlue("BLUE BACKGROUND"))

print(Tint.bold("Bold text"))
print(Tint.dim("Dim text"))
print(Tint.italic("Italic text"))
print(Tint.underline("Underlined text"))
print(Tint.inverse("Inverse text"))
print(Tint.hidden("Hidden text (not visible)"))
print(Tint.strikethrough("Strikethrough text"))

print(Tint.red("normal red"))
print(Tint.red.bold("red bold"))
print(Tint.red.bold.underline("red bold underline"))
print(Tint.red.bold.dim("red bold dim"))
print(Tint.green.bold("Success!"))
print(Tint.blue.bold.underline("Important note"))

print(Tint.red("outer red ", Tint.blue("inner blue"), " outer red again"))
print(Tint.bold("BOLD ", Tint.underline("BOLD UNDERLINE"), " BOLD again"))
print(Tint.green("Success: ", Tint.red("Error inside?"), " no problem."))

print(Tint.rgb(200, 10, 50)("Reddish RGB"))
print(Tint.rgb(100, 200, 50)("Greenish RGB"))
print(Tint.rgb(50, 100, 200)("Blueish RGB"))
print(Tint.rgb(255, 200, 0)("Orange RGB"))

print(Tint.rgb(200, 10, 50).bold("Bold reddish"))
print(Tint.rgb(100, 200, 50).italic("Italic greenish"))
print(Tint.rgb(50, 100, 200).bold.underline("Bold underline blueish"))

print(Tint.hex("#aabbcc")("Hex color aa bb cc"))
print(Tint.hex("aabbcc")("Hex without #"))
print(Tint.hex("#ff0000")("Red HEX"))
print(Tint.hex("#00ff00")("Green HEX"))
print(Tint.hex("#0000ff").bold("Bold blue HEX"))

print(Tint.bgRgb(100, 50, 50)("Text on custom RGB background"))
print(Tint.bgHex("#223344")("Text on HEX background"))
print(Tint.red(Tint.bgWhite("RED ON WHITE BG")))
print(Tint.brightBlack(Tint.bgYellow("WARNING: yellow background")))

print(
	Tint.red.bold(
		"ERROR: ",
		Tint.green.bold("All systems"),
		" ",
		Tint.yellow.bold("working "),
		"with ",
		Tint.rgb(150, 50, 200).bold("custom color")
	)
)

print(
	Tint.brightMagenta(
		Tint.bgBlue(
			" SECURITY ALERT: ",
			Tint.bold("High severity"),
			" on ",
			Tint.hex("#ffcc00").bold("critical module")
		)
	)
)

print(
	Tint.dim(
		"Info: ",
		Tint.bold("User "),
		Tint.cyan("Marco"),
		Tint.bold(" "),
		Tint.green("logged in"),
		" ",
		Tint.dim("successfully")
	)
)
