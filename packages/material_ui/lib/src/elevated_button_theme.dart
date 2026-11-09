// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'elevated_button.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'button_style.dart';
import 'theme.dart';
import 'theme_data.dart';

// Examples can assume:
// late BuildContext context;

/// A [ButtonStyle] that overrides the default appearance of
/// [ElevatedButton]s when it's used with [ElevatedButtonTheme] or with the
/// overall [Theme]'s [ThemeData.elevatedButtonTheme].
///
/// The [style]'s properties override [ElevatedButton]'s default style,
/// i.e. the [ButtonStyle] returned by [ElevatedButton.defaultStyleOf]. Only
/// the style's non-null property values or resolved non-null
/// [WidgetStateProperty] values are used.
///
/// See also:
///
///  * [ElevatedButtonTheme], the theme which is configured with this class.
///  * [ElevatedButton.defaultStyleOf], which returns the default [ButtonStyle]
///    for text buttons.
///  * [ElevatedButton.styleFrom], which converts simple values into a
///    [ButtonStyle] that's consistent with [ElevatedButton]'s defaults.
///  * [WidgetStateProperty.resolve], "resolve" a material state property
///    to a simple value based on a set of [WidgetState]s.
///  * [ThemeData.elevatedButtonTheme], which can be used to override the default
///    [ButtonStyle] for [ElevatedButton]s below the overall [Theme].
@immutable
class ElevatedButtonThemeData with Diagnosticable {
  /// Creates an [ElevatedButtonThemeData].
  ///
  /// The [style] may be null.
  const ElevatedButtonThemeData({this.style, this.variant});

  /// Overrides for [ElevatedButton]'s default style.
  ///
  /// Non-null properties or non-null resolved [WidgetStateProperty]
  /// values override the [ButtonStyle] returned by
  /// [ElevatedButton.defaultStyleOf].
  ///
  /// If [style] is null, then this theme doesn't override anything.
  final ButtonStyle? style;

  /// The style variant of Material Design used by [ElevatedButton].
  ///
  /// Set this to [StyleVariant.material3Expressive] to opt elevated buttons
  /// into the Material 3 Expressive style.
  ///
  /// If null, the variant is inherited from the closest enclosing
  /// [ElevatedButtonTheme] that specifies one, and then from
  /// [ThemeData.elevatedButtonTheme]. If none of them specify a variant,
  /// [ElevatedButton] uses [StyleVariant.material3]. To keep a subtree on
  /// Material 3 when an ancestor opts into Material 3 Expressive, set this to
  /// [StyleVariant.material3].
  ///
  /// An enclosing [ElevatedButtonTheme] that specifies a variant takes
  /// precedence over [ThemeData.elevatedButtonTheme], even when a closer
  /// [Theme] specifies a different variant. To change the variant of a
  /// subtree, wrap it in an [ElevatedButtonTheme].
  ///
  /// See also:
  ///
  ///  * [ElevatedButtonTheme.of], which returns the theme that applies at a
  ///    given location, with the inherited variant.
  final StyleVariant? variant;

  /// Linearly interpolate between two elevated button themes.
  static ElevatedButtonThemeData? lerp(
    ElevatedButtonThemeData? a,
    ElevatedButtonThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    return ElevatedButtonThemeData(
      style: ButtonStyle.lerp(a?.style, b?.style, t),
      variant: t < 0.5 ? a?.variant : b?.variant,
    );
  }

  @override
  int get hashCode => Object.hash(style, variant);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ElevatedButtonThemeData && other.style == style && other.variant == variant;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ButtonStyle>('style', style, defaultValue: null));
    properties.add(EnumProperty<StyleVariant>('variant', variant, defaultValue: null));
  }
}

/// Overrides the default [ButtonStyle] of its [ElevatedButton] descendants.
///
/// See also:
///
///  * [ElevatedButtonThemeData], which is used to configure this theme.
///  * [ElevatedButton.defaultStyleOf], which returns the default [ButtonStyle]
///    for elevated buttons.
///  * [ElevatedButton.styleFrom], which converts simple values into a
///    [ButtonStyle] that's consistent with [ElevatedButton]'s defaults.
///  * [ThemeData.elevatedButtonTheme], which can be used to override the default
///    [ButtonStyle] for [ElevatedButton]s below the overall [Theme].
class ElevatedButtonTheme extends InheritedTheme {
  /// Create a [ElevatedButtonTheme].
  const ElevatedButtonTheme({super.key, required this.data, required super.child});

  /// The configuration of this theme.
  final ElevatedButtonThemeData data;

  /// Retrieves the [ElevatedButtonThemeData] from the closest ancestor [ElevatedButtonTheme].
  ///
  /// If there is no enclosing [ElevatedButtonTheme] widget, then
  /// [ThemeData.elevatedButtonTheme] is used.
  ///
  /// If the closest [ElevatedButtonTheme] doesn't specify a variant, the
  /// returned [ElevatedButtonThemeData.variant] is inherited from the closest
  /// enclosing [ElevatedButtonTheme] that specifies one, and then from
  /// [ThemeData.elevatedButtonTheme]. The other properties are not inherited.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ElevatedButtonThemeData theme = ElevatedButtonTheme.of(context);
  /// ```
  static ElevatedButtonThemeData of(BuildContext context) {
    final ElevatedButtonThemeData? data = context
        .dependOnInheritedWidgetOfExactType<_ResolvedElevatedButtonTheme>()
        ?.data;
    if (data == null) {
      return Theme.of(context).elevatedButtonTheme;
    }
    if (data.variant != null) {
      return data;
    }
    final StyleVariant? themeVariant = Theme.of(context).elevatedButtonTheme.variant;
    if (themeVariant == null) {
      return data;
    }
    return ElevatedButtonThemeData(style: data.style, variant: themeVariant);
  }

  /// Returns the [StyleVariant] that [ElevatedButton]s use at the given
  /// [context].
  ///
  /// This is the [ElevatedButtonThemeData.variant] returned by [of], or
  /// [StyleVariant.material3] if that is null.
  @Deprecated(
    'Use ElevatedButtonTheme.of(context).variant instead. '
    'This feature was deprecated after material_ui v1.11.0.',
  )
  static StyleVariant variantOf(BuildContext context) {
    return of(context).variant ?? StyleVariant.material3;
  }

  @override
  InheritedElement createElement() => _ElevatedButtonThemeElement(this);

  @override
  Widget wrap(BuildContext context, Widget child) {
    return ElevatedButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(ElevatedButtonTheme oldWidget) => data != oldWidget.data;
}

// Inserts a _ResolvedElevatedButtonTheme below its ElevatedButtonTheme, so that
// the variant is inherited when the theme is built rather than looked up by
// every ElevatedButtonTheme.of call, and so that InheritedTheme.capture keeps
// it.
class _ElevatedButtonThemeElement extends InheritedElement {
  _ElevatedButtonThemeElement(ElevatedButtonTheme super.widget);

  @override
  Widget build() {
    ElevatedButtonThemeData data = (widget as ElevatedButtonTheme).data;
    if (data.variant == null) {
      final StyleVariant? inheritedVariant =
          dependOnInheritedWidgetOfExactType<_ResolvedElevatedButtonTheme>()?.data.variant;
      if (inheritedVariant != null) {
        data = ElevatedButtonThemeData(style: data.style, variant: inheritedVariant);
      }
    }
    return _ResolvedElevatedButtonTheme(data: data, child: super.build());
  }
}

// The data of the closest ElevatedButtonTheme, with the variant inherited from
// the enclosing ElevatedButtonThemes.
class _ResolvedElevatedButtonTheme extends InheritedTheme {
  const _ResolvedElevatedButtonTheme({required this.data, required super.child});

  final ElevatedButtonThemeData data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return _ResolvedElevatedButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(_ResolvedElevatedButtonTheme oldWidget) => data != oldWidget.data;
}
