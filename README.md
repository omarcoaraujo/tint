<div align="center">
  <img width="360" src="assets/logo.svg" alt="Tint"/>
  <br/><br/>
  <p>Chalk-inspired terminal string styling for <a href="https://luau.org">Luau</a>.</p>
</div>

---

## Features

- Fluent chainable API — `Tint.red.bold.underline("text")`
- Nested styles with automatic color restoration
- True color RGB and hex support with automatic downgrading per terminal capability
- Automatic terminal color level detection (respects `NO_COLOR`, `FORCE_COLOR`, `COLORTERM`, etc.)
- Zero dependencies

## Installation

Add Tint to your `pesde.toml`:

```toml
[dependencies]
tint = { name = "omarcoaraujo/tint", version = "^0.1.0" }
```

Then require it:

```luau
local Tint = require("@pkg/tint")
```

## Usage

### Basic colors

```luau
print(Tint.red("ERROR"))
print(Tint.green("SUCCESS"))
print(Tint.yellow("WARNING"))
print(Tint.blue("INFO"))
print(Tint.cyan("note"))
```

### Modifiers

```luau
print(Tint.bold("bold"))
print(Tint.italic("italic"))
print(Tint.underline("underline"))
print(Tint.dim("dim"))
print(Tint.strikethrough("strikethrough"))
```

### Chaining

Styles can be chained in any order:

```luau
print(Tint.red.bold("red and bold"))
print(Tint.blue.bold.underline("important"))
print(Tint.green.italic("success"))
```

### Nesting

Outer colors are automatically restored after inner styled segments:

```luau
print(Tint.red("error: ", Tint.yellow("detail"), " continues in red"))
print(Tint.bold("BOLD ", Tint.underline("BOLD+UNDERLINE"), " BOLD again"))
```

### True color (RGB & Hex)

```luau
print(Tint.rgb(255, 136, 0)("orange"))
print(Tint.hex("#ff8800")("also orange"))
print(Tint.rgb(255, 136, 0).bold("bold orange"))

-- Background
print(Tint.bgRgb(30, 30, 46)("text on dark bg"))
print(Tint.bgHex("#1e1e2e")("text on hex bg"))
```

On terminals that do not support true color, RGB and hex values are automatically downgraded to the nearest 256-color or 16-color equivalent.

### Background colors

```luau
print(Tint.bgRed("red background"))
print(Tint.bgGreen("green background"))
print(Tint.red(Tint.bgWhite("red text on white background")))
```

## Color level detection

Tint detects color support automatically at startup and adapts all output accordingly.

| Level | Description        | Triggered by                          |
|-------|--------------------|---------------------------------------|
| `0`   | No colors          | `NO_COLOR`, `TERM=dumb`, pipe         |
| `1`   | Basic 16 colors    | Most terminals, CI environments       |
| `2`   | 256 colors         | `TERM=xterm-256color`                 |
| `3`   | True color (16M)   | `COLORTERM=truecolor`, Windows Terminal, iTerm 3+ |

### Overriding

```sh
FORCE_COLOR=0 luau script.luau   # disable all colors
FORCE_COLOR=3 luau script.luau   # force true color
NO_COLOR=1    luau script.luau   # disable per no-color.org spec
```

## API

See [`docs/api.md`](docs/api.md) for the full API reference.

## License

MIT
