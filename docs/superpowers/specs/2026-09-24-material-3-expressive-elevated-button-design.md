# Material 3 Expressive ElevatedButton Design

## Goal

Add opt-in Material 3 Expressive defaults and selectable behavior to
`ElevatedButton` in `packages/material_ui` while preserving existing Material 2
and Material 3 behavior. This work is stacked on the IconButton migration and
reuses its `StyleVariant`, `ButtonSizeVariant`, and `ButtonShapeVariant` APIs.

This design follows the Material 3
[button specification](https://m3.material.io/components/buttons/overview), the
[component migration checklist](https://github.com/flutter/flutter/blob/master/docs/ecosystem/material_ui/Material-3-Expressive-component-migration-checklist.md),
and the checked-in `button_elevated` and `button_<size>` token data.

## Scope

This PR includes:

- Token-generated expressive ElevatedButton defaults.
- An `ElevatedButtonThemeData.variant` component-level opt-in.
- Xsmall, small, medium, large, and xlarge sizes.
- Round and square shape variants, including selected and pressed shapes.
- A nullable, caller-controlled `isSelected` API.
- Expressive icon size, icon-label spacing, typography, padding, colors,
  elevation, and interaction states.
- Focused generator, theme-data, widget, and semantics tests.
- Pending release information.

FilledButton, FilledButton.tonal, OutlinedButton, and TextButton are follow-up
component migrations. A centralized ThemeData support list and a gallery
example are also deferred to follow-up PRs.

The size token files include spring damping and stiffness for the pressed shape.
The current `ButtonStyle` and Material shape animation APIs cannot represent
those spring parameters. This PR applies the tokenized pressed shape through the
existing state-based shape animation; adopting expressive spring motion requires
a separate API design.

## Compatibility And Opt-In

Material 3 Expressive activates only when Material 3 is enabled and the
ElevatedButton component theme opts in:

```dart
ThemeData(
  elevatedButtonTheme: const ElevatedButtonThemeData(
    variant: StyleVariant.material3Expressive,
  ),
)
```

When `variant` is null or `StyleVariant.material3`, ElevatedButton retains its
existing Material 3 defaults. Material 2 always retains its existing defaults,
even if the component theme requests the expressive variant. The variant
selects only the default style family; widget and component-theme `ButtonStyle`
properties continue to override generated defaults.

`isSelected` is available independently of the selected style family so its
state and semantics remain coherent. Existing M2 and M3 defaults do not add a
selected visual treatment, although an explicit `ButtonStyle` may resolve
`WidgetState.selected`. Built-in selected visuals are supplied only by the M3E
defaults.

## Public APIs

`ElevatedButtonThemeData` gains `final StyleVariant? variant` and a matching
constructor parameter. Its `lerp`, equality, `hashCode`, and diagnostics follow
`IconButtonThemeData`; interpolation switches the discrete value at `t = 0.5`.

Both `ElevatedButton` constructors gain `bool? isSelected`:

- Null creates an ordinary momentary button.
- False creates a selectable button in its unselected state.
- True creates a selectable button in its selected state.

Selection is controlled by the caller. `onPressed` reports activation but does
not mutate `isSelected`. This matches the existing IconButton contract.

The public `ButtonStyleButton` base stores the nullable value and synchronizes
`WidgetState.selected` when a subclass exposes it. This shared plumbing remains
inert for other button classes until their constructors pass `isSelected` in
their own migration PRs.

## Generated Defaults

`button_template.dart` gains `ButtonTemplateM3E`, extending
`TokenTemplateM3E`. The first registration is
`ButtonTemplateM3E('Elevated Button')`, which combines
`TokenButtonElevated` with the five `TokenButton<size>` files and writes:

`packages/material_ui/lib/src/generated/elevated_button_defaults_m3e.g.dart`

The generated `_ElevatedButtonDefaultsM3E` accepts `BuildContext`, a
`toggleable` flag, and nullable effective size and shape variants. Size and
shape default to `ButtonSizeVariant.small` and `ButtonShapeVariant.round`.
Generated output uses `WidgetStateProperty` APIs. Existing Material 3 generated
output remains unchanged.

The size mapping is:

| Variant | Height | Text style | Icon | Horizontal space | Icon-label gap |
| --- | ---: | --- | ---: | ---: | ---: |
| xsmall | 32 | labelLarge | 20 | 12 | 4 |
| small | 40 | labelLarge | 20 | 16 | 8 |
| medium | 56 | titleMedium | 24 | 24 | 8 |
| large | 96 | headlineSmall | 32 | 48 | 12 |
| xlarge | 136 | headlineLarge | 40 | 64 | 16 |

For colors and state layers, resolution uses disabled, pressed, hovered,
focused, then base precedence. Non-toggleable buttons use the ordinary elevated
tokens. Toggleable buttons use the selected or unselected token family according
to `WidgetState.selected`. ElevatedButton has shared disabled tokens, so its
disabled appearance is the same for selected and unselected buttons. Elevation
uses the ordinary disabled, pressed, focused, and base elevated tokens because
the token set does not define selection-specific elevations.

For shape, an ordinary or unselected button uses the size-specific round or
square container shape. A selected button uses the corresponding size-specific
selected shape. The pressed shape takes precedence whenever pressed. Disabled,
hovered, and focused states do not otherwise change shape.

## Runtime Wiring

`elevated_button.dart` includes the expressive generated part. In
`defaultStyleOf`, the existing `useMaterial3` path reads
`ElevatedButtonTheme.of(context).variant`, defaulting null to
`StyleVariant.material3`. Only `material3Expressive` selects the new defaults.

Before constructing expressive defaults, `defaultStyleOf` resolves
`sizeVariant` and `shapeVariant` from the widget style, then the component-theme
style. It passes those nullable values and `isSelected != null` to the generated
class. The generated class supplies small and round fallbacks. The existing
`ButtonStyleButton` merge order remains widget style, component-theme style,
then generated defaults.

When `isSelected` is non-null, `ButtonStyleButton` keeps
`WidgetState.selected` synchronized during initialization, widget updates, and
states-controller changes. It adds selected/unselected semantics to the existing
button and enabled semantics. When `isSelected` is null, existing state and
semantics behavior remains unchanged. When non-null, `isSelected` is the
authoritative selected state; an external states controller cannot override it.

`ElevatedButton.icon` resolves expressive icon-label spacing from widget style,
then component-theme style, then the small default. Expressive spacing is the
fixed token value shown above and does not shrink with text scaling. Legacy M2
and M3 retain their existing text-scale-dependent 8-to-4-pixel spacing.

## Testing

Generator tests cover the supported ElevatedButton name, parent path, output
filename and class, all five size mappings, round/square/selected/pressed shape
generation, and representative ordinary, selected, and unselected state tokens.

Theme-data tests cover construction, interpolation, equality, hashing, and
diagnostics for `ElevatedButtonThemeData.variant`.

Widget tests cover:

- No-opt-in M2 and M3 regression behavior.
- Expressive opt-in and explicit widget/theme style precedence.
- All five sizes, both shapes, typography, padding, icon size, and icon spacing.
- Null, false, and true `isSelected` values and controlled updates.
- Selected/unselected semantics and `WidgetState.selected` synchronization.
- Ordinary, selected, and unselected colors in enabled, disabled, pressed,
  hovered, and focused states.
- Ordinary, selected, and pressed shape precedence.
- Expressive spacing under text scaling and unchanged legacy spacing.

## Verification

Use Flutter 3.47.5 or a compatible newer toolchain. Run the generator tests,
`elevated_button_test.dart`, `elevated_button_theme_test.dart`, package
formatting and analysis through `flutter_plugin_tools`, and `git diff --check`.
Regenerate defaults and confirm a clean diff to prove reproducibility. The PR
must include pending release information and leave M2/M3 behavior unchanged.

## Follow-Ups

Migrate OutlinedButton, FilledButton with FilledButton.tonal, and TextButton in
separate component PRs using the reviewed ElevatedButton pattern. Add the
centralized ThemeData documentation and examples separately if including them
would make a component migration harder to review. Design expressive spring
shape motion when the framework has an API capable of representing the motion
tokens.
