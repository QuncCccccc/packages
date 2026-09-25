# Material 3 Expressive Buttons Design

## Goal

Add opt-in Material 3 Expressive defaults to `ElevatedButton`, `FilledButton`,
`FilledButton.tonal`, `OutlinedButton`, and `TextButton` in
`packages/material_ui` while preserving current Material 2 and Material 3
behavior. This work is stacked on the IconButton migration because it reuses
the `ButtonSizeVariant` and `ButtonShapeVariant` APIs introduced there.

## Scope

The migration includes token-generated expressive defaults for all five button
appearances, a nullable `StyleVariant variant` opt-in on each component theme,
five expressive sizes, round and square shape variants, focused tests, and
pending release information. Examples and centralized `ThemeData`
documentation are deferred unless the implementation diff remains comfortably
reviewable.

## Compatibility And Opt-In

Material 3 remains the default when a component theme's `variant` is null or
`StyleVariant.material3`. Material 2 continues to use its existing defaults.
Material 3 Expressive activates only through the matching component theme:

```dart
ThemeData(
  elevatedButtonTheme: const ElevatedButtonThemeData(
    variant: StyleVariant.material3Expressive,
  ),
)
```

The same pattern applies to `FilledButtonThemeData`,
`OutlinedButtonThemeData`, and `TextButtonThemeData`. `FilledButton` and
`FilledButton.tonal` share `FilledButtonThemeData`, matching existing ownership.
Widget styles continue to override component-theme styles and generated
defaults. The `variant` selects only the default style family.

## Generated Defaults

`button_template.dart` gains `ButtonTemplateM3E`, extending
`TokenTemplateM3E`. Existing Material 3 output remains behaviorally unchanged.
The generator registers all appearances and writes:

- `elevated_button_defaults_m3e.g.dart`
- `filled_button_defaults_m3e.g.dart`
- `filled_tonal_button_defaults_m3e.g.dart`
- `outlined_button_defaults_m3e.g.dart`
- `text_button_defaults_m3e.g.dart`

The template combines each appearance token file with `button_xsmall`,
`button_small`, `button_medium`, `button_large`, and `button_xlarge`. New output
uses `WidgetStateProperty` APIs. The expressive default is
`ButtonSizeVariant.small`, retaining the standard 40 logical-pixel height.
Generated styles switch on `ButtonStyle.sizeVariant` for height, typography,
icon size, padding, icon-label spacing, and outline width, and on
`ButtonStyle.shapeVariant` for round/square and state-dependent shapes.
`IconButtonWidthVariant` remains IconButton-only.

## Runtime Wiring

Each button source includes its expressive defaults part and selects the
default class from the component theme's `variant` inside the existing
`useMaterial3` path. Material 2 therefore cannot select expressive defaults.

Icon constructors need a small runtime addition because their icon-label gap is
owned by the child row rather than `ButtonStyle`. The gap resolves from the
effective `ButtonSizeVariant`, using `small` as the expressive default and
retaining the legacy gap for non-expressive buttons. No new button classes or
constructors are introduced.

## Theme Data API

`ElevatedButtonThemeData`, `FilledButtonThemeData`,
`OutlinedButtonThemeData`, and `TextButtonThemeData` gain
`final StyleVariant? variant` and a matching constructor parameter. Each class
updates `lerp`, equality, `hashCode`, and diagnostics following
`IconButtonThemeData`; interpolation switches the discrete variant at `t = 0.5`.

## Testing

Generator tests cover supported names, parent-file mappings, class/file names,
and representative appearance, size, and shape tokens. Theme-data tests cover
construction, interpolation, equality, hashing, and diagnostics.

Widget tests verify that legacy Material 3 defaults remain unchanged without
opt-in; expressive opt-in selects the new defaults; all sizes and both shapes
resolve expected dimensions, typography, icon layout, and outline width;
relevant widget states use token colors, elevations, and shapes; explicit theme
and widget styles keep precedence; and filled versus filled-tonal defaults stay
distinct under their shared theme opt-in.

## PR Structure

Start with one stacked implementation branch because the appearances share one
generator template, selector APIs, and runtime pattern. After generation and
focused tests, measure the diff excluding generated files.

Keep one PR when the handwritten diff is at most 1,500 changed lines and each
appearance remains independently reviewable. Otherwise split into stacked PRs:

1. ElevatedButton, including shared generator infrastructure.
2. OutlinedButton.
3. FilledButton and FilledButton.tonal together.
4. TextButton.

Every split must remain testable and must not expose an opt-in before its
generated defaults are wired.

## Verification

Use Flutter 3.47.5 or a compatible newer toolchain. Run generator tests; all
eight focused component/theme test files; package formatting and Dart analysis
through `flutter_plugin_tools`; and `git diff --check`. Generated output must be
reproducible, legacy defaults unchanged, and pending release information present.
