# Tint API Reference

## Overview

Tint is a chainable terminal styling library for Luau. The default export is the root `Tint` object. Accessing a color or modifier on it returns a new **chain** — a callable that applies all accumulated styles to its string arguments.

```luau
local Tint = require("@pkg/tint")
```

---

## Foreground colors

| Name           | Code |
|----------------|------|
| `Tint.black`   | 30   |
| `Tint.red`     | 31   |
| `Tint.green`   | 32   |
| `Tint.yellow`  | 33   |
| `Tint.blue`    | 34   |
| `Tint.magenta` | 35   |
| `Tint.cyan`    | 36   |
| `Tint.white`   | 37   |
| `Tint.gray`    | 90   |

```luau
print(Tint.red("error"))
print(Tint.green("ok"))
```

---

## Bright foreground colors

| Name                | Code |
|---------------------|------|
| `Tint.brightBlack`  | 90   |
| `Tint.brightRed`    | 91   |
| `Tint.brightGreen`  | 92   |
| `Tint.brightYellow` | 93   |
| `Tint.brightBlue`   | 94   |
| `Tint.brightMagenta`| 95   |
| `Tint.brightCyan`   | 96   |
| `Tint.brightWhite`  | 97   |

```luau
print(Tint.brightRed("bright error"))
```

---

## Background colors

| Name               | Code |
|--------------------|------|
| `Tint.bgBlack`     | 40   |
| `Tint.bgRed`       | 41   |
| `Tint.bgGreen`     | 42   |
| `Tint.bgYellow`    | 43   |
| `Tint.bgBlue`      | 44   |
| `Tint.bgMagenta`   | 45   |
| `Tint.bgCyan`      | 46   |
| `Tint.bgWhite`     | 47   |
| `Tint.bgGray`      | 100  |
| `Tint.bgBrightRed` | 101  |
| `Tint.bgBrightGreen` | 102 |
| `Tint.bgBrightYellow` | 103 |
| `Tint.bgBrightBlue` | 104 |
| `Tint.bgBrightMagenta` | 105 |
| `Tint.bgBrightCyan` | 106 |
| `Tint.bgBrightWhite` | 107 |

```luau
print(Tint.bgRed("red background"))
print(Tint.white(Tint.bgBlue(" info ")))
```

---

## Modifiers

| Name                  | Open | Close |
|-----------------------|------|-------|
| `Tint.bold`           | 1    | 22    |
| `Tint.dim`            | 2    | 22    |
| `Tint.italic`         | 3    | 23    |
| `Tint.underline`      | 4    | 24    |
| `Tint.inverse`        | 7    | 27    |
| `Tint.hidden`         | 8    | 28    |
| `Tint.strikethrough`  | 9    | 29    |

```luau
print(Tint.bold("bold"))
print(Tint.italic("italic"))
print(Tint.underline("underline"))
print(Tint.strikethrough("done"))
```

---

## True color

### `Tint.rgb(r, g, b)`

Returns a chain with a foreground true color (24-bit) style. Accepts values `0–255`.

```luau
print(Tint.rgb(255, 136, 0)("orange"))
print(Tint.rgb(100, 200, 50).bold("bold green"))
```

Automatically downgraded based on the detected color level:
- **Level 3** → `\e[38;2;r;g;bm` (true color)
- **Level 2** → nearest ANSI 256 color
- **Level 1** → nearest ANSI 16 color

### `Tint.hex(color)`

Same as `Tint.rgb` but accepts a hex string with or without a leading `#`.

```luau
print(Tint.hex("#ff8800")("orange"))
print(Tint.hex("ff8800")("also orange"))
print(Tint.hex("#0000ff").bold("bold blue"))
```

### `Tint.bgRgb(r, g, b)`

Background true color. Same downgrade rules as `Tint.rgb`.

```luau
print(Tint.bgRgb(30, 30, 46)("text on dark background"))
```

### `Tint.bgHex(color)`

Background hex color.

```luau
print(Tint.bgHex("#1e1e2e")("text on hex background"))
```

---

## Chaining

Any color, background, or modifier can be chained. Each access creates a new chain without mutating the previous one.

```luau
print(Tint.red.bold("red bold"))
print(Tint.red.bold.underline("red bold underline"))
print(Tint.rgb(255, 0, 128).bold.italic("custom color, bold, italic"))
```

---

## Nesting

Chains accept multiple arguments. Styled strings can be passed as arguments to outer chains — the outer style is automatically restored after each inner segment.

```luau
-- "outer" and "continues" are red; "inner" is blue
print(Tint.red("outer ", Tint.blue("inner"), " continues"))

-- BOLD, then BOLD+UNDERLINE, back to BOLD
print(Tint.bold("BOLD ", Tint.underline("BOLD+UNDERLINE"), " BOLD"))

-- Complex nesting
print(
    Tint.red.bold(
        "Error: ",
        Tint.yellow("detail"),
        " in ",
        Tint.cyan("module")
    )
)
```

---

## Color level detection

`lib/color-support.luau` runs at startup and returns either `false` (no color support) or a `ColorInfo` table:

```luau
export type ColorInfo = {
    level: number,       -- 0 | 1 | 2 | 3
    hasBasic: boolean,   -- level >= 1
    has256: boolean,     -- level >= 2
    hasMillions: boolean,-- level >= 3
}
```

You can require it directly if you need to branch on color support in your own code:

```luau
local colorSupport = require("@pkg/tint/color-support")

if colorSupport then
    print("Color level:", colorSupport.level)
    print("True color:", colorSupport.hasMillions)
else
    print("No color support")
end
```

### Detection order

1. `FORCE_COLOR` env var — overrides everything (`0`/`false` = level 0, `1`/`2`/`3`/`true` = that level)
2. `NO_COLOR` env var — disables colors ([no-color.org](https://no-color.org))
3. `TERM=dumb` — disables colors
4. Windows Terminal (`WT_SESSION`) → level 3
5. `COLORTERM=truecolor` or `COLORTERM=24bit` → level 3
6. CI environments → level 1
7. `TERM_PROGRAM` (iTerm 3+ → level 3, iTerm 2 → level 2, Apple Terminal → level 2)
8. `TERM` pattern matching (`*-256color` → level 2, `xterm*` / `screen*` / etc. → level 1)
9. `COLORTERM` (any value) → level 1
10. Default → level 0
