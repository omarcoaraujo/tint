# Changelog

## 0.2.0 - 2026-10-13

- Underline styles: double, curly, dotted and dashed
- Underline colors, from named colors, RGB, hex and 256-color codes
- 256-color codes can now be used directly for text and background
- Styled text now keeps its style on every line of a multi-line text
- New `visible` style that only prints when colors are on
- New `strip` function that removes colors and styles from a text
- Numeric `FORCE_COLOR` now sets exactly the color level it says, also on Windows
- RGB, hex and 256-color styles can now be chained after any other style
- New `tint.new` that creates a copy of tint locked to a chosen color level
- Calling `tint` directly with text now returns the text unstyled
- Invalid `FORCE_COLOR` values such as `2abc` or `0x2` are now ignored
- `--color=256` and `--color=16m` now win over a numeric `FORCE_COLOR`
- Mixing empty values and numbers in the same text no longer breaks it

## 0.1.1 - 2026-04-25

- Documentation fixes and status badges
