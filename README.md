<div align="center">
  <img width="320" src="https://raw.githubusercontent.com/omarcoaraujo/tint/main/assets/logo.svg" alt="Tint"/>
  <br/><br/>
  <p>Chalk-inspired terminal string styling for <a href="https://lua.org">Luau</a>.</p>
</div>

---

## Features

- Fluent chainable API — `tint.red.bold.underline("text")`
- Nested styles with automatic color restoration
- True color RGB and hex support with automatic downgrading per terminal capability
- Automatic terminal color level detection (respects `NO_COLOR`, `FORCE_COLOR`, `COLORTERM`, etc.)
- Runtime agnostic — works with Zune, Lune, and Lute
- Zero dependencies

## Installation

Add Tint to your `pesde.toml`:

```toml
[dependencies]
tint = { name = "omarcoaraujo/tint", version = "^0.1.0" }
```

Then require it:

```lua
local tint = require("@pkg/tint")
```

## Usage

### Basic colors

```lua
print(tint.red("ERROR"))
print(tint.green("SUCCESS"))
print(tint.yellow("WARNING"))
print(tint.blue("INFO"))
print(tint.cyan("note"))
```

### Modifiers

```lua
print(tint.bold("bold"))
print(tint.italic("italic"))
print(tint.underline("underline"))
print(tint.dim("dim"))
print(tint.strikethrough("strikethrough"))
```

### Chaining

Styles can be chained in any order:

```lua
print(tint.red.bold("red and bold"))
print(tint.blue.bold.underline("important"))
print(tint.green.italic("success"))
```

### Nesting

Outer colors are automatically restored after inner styled segments:

```lua
print(tint.red("error: ", tint.yellow("detail"), " continues in red"))
print(tint.bold("BOLD ", tint.underline("BOLD+UNDERLINE"), " BOLD again"))
```

### True color (RGB & Hex)

```lua
print(tint.rgb(255, 136, 0)("orange"))
print(tint.hex("#ff8800")("also orange"))
print(tint.rgb(255, 136, 0).bold("bold orange"))

-- Background
print(tint.bg_rgb(30, 30, 46)("text on dark bg"))
print(tint.bg_hex("#1e1e2e")("text on hex bg"))
```

On terminals that do not support true color, RGB and hex values are automatically downgraded to the nearest 256-color or 16-color equivalent.

### Background colors

```lua
print(tint.bg_red("red background"))
print(tint.bg_green("green background"))
print(tint.red(tint.bg_white("red text on white background")))
```

## Color level detection

Tint detects color support automatically at startup and adapts all output accordingly.

| Level | Description        | Triggered by                          |
|-------|--------------------|---------------------------------------|
| `0`   | No colors          | `NO_COLOR`, `TERM=dumb`, pipe / non-TTY |
| `1`   | Basic 16 colors    | Most terminals, CI environments       |
| `2`   | 256 colors         | `TERM=xterm-256color`                 |
| `3`   | True color (16M)   | `COLORTERM=truecolor`, Windows Terminal, iTerm 3+ |

### Overriding

```sh
FORCE_COLOR=0 zune run script.luau  # disable all colors
FORCE_COLOR=3 zune run script.luau  # force true color
NO_COLOR=1    zune run script.luau  # disable per no-color.org spec
```

Or via CLI flags:

```sh
zune run script.luau --no-color     # disable colors
zune run script.luau --color=256    # force 256 color mode
```

## Runtime compatibility

Tint works across Luau runtimes with automatic detection:

| Runtime | Color support | TTY detection |
|---------|--------------|---------------|
| [Zune](https://zune.sh) | Full | Yes |
| [Lune](https://lune-org.github.io/docs) | Full | No (assumes TTY) |
| [Lute](https://lute.lua.org) | Full | No (assumes TTY) |

## License

MIT
