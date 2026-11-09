// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'icon_button.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'button_style.dart';
import 'theme.dart';
import 'theme_data.dart';

// Examples can assume:
// late BuildContext context;

/// A [ButtonStyle] that overrides the default appearance of
/// [IconButton]s when it's used with the [IconButton], the [IconButtonTheme] or the
/// overall [Theme]'s [ThemeData.iconButtonTheme].
///
/// The [IconButton] will be affected by [IconButtonTheme] and [IconButtonThemeData]
/// only if [ThemeData.useMaterial3] is set to true; otherwise, [IconTheme] will be used.
///
/// The [style]'s properties override [IconButton]'s default style. Only
/// the style's non-null property values or resolved non-null
/// [WidgetStateProperty] values are used.
///
/// See also:
///
///  * [IconButtonTheme], the theme which is configured with this class.
///  * [IconButton.styleFrom], which converts simple values into a
///    [ButtonStyle] that's consistent with [IconButton]'s defaults.
///  * [WidgetStateProperty.resolve], "resolve" a material state property
///    to a simple value based on a set of [WidgetState]s.
///  * [ThemeData.iconButtonTheme], which can be used to override the default
///    [ButtonStyle] for [IconButton]s below the overall [Theme].
@immutable
class IconButtonThemeData with Diagnosticable {
  /// Creates a [IconButtonThemeData].
  ///
  /// The [style] may be null.
  const IconButtonThemeData({this.style, this.variant});

  /// Overrides for [IconButton]'s default style if [ThemeData.useMaterial3]
  /// is set to true.
  ///
  /// Non-null properties or non-null resolved [WidgetStateProperty]
  /// values override the default [ButtonStyle] in [IconButton].
  ///
  /// If [style] is null, then this theme doesn't override anything.
  final ButtonStyle? style;

  /// The style variant of Material Design used by [IconButton].
  ///
  /// Set this to [StyleVariant.material3Expressive] to opt icon buttons into
  /// the Material 3 Expressive style.
  ///
  /// If null, the variant is inherited from the closest enclosing
  /// [IconButtonTheme] that specifies one, and then from
  /// [ThemeData.iconButtonTheme]. If none of them specify a variant,
  /// [IconButton] uses [StyleVariant.material3]. To keep a subtree on
  /// Material 3 when an ancestor opts into Material 3 Expressive, set this to
  /// [StyleVariant.material3].
  ///
  /// An enclosing [IconButtonTheme] that specifies a variant takes precedence
  /// over [ThemeData.iconButtonTheme], even when a closer [Theme] specifies a
  /// different variant. To change the variant of a subtree, wrap it in an
  /// [IconButtonTheme].
  ///
  /// See also:
  ///
  ///  * [IconButtonTheme.of], which returns the theme that applies at a given
  ///    location, with the inherited variant.
  final StyleVariant? variant;

  /// Linearly interpolate between two icon button themes.
  static IconButtonThemeData? lerp(IconButtonThemeData? a, IconButtonThemeData? b, double t) {
    if (identical(a, b)) {
      return a;
    }
    return IconButtonThemeData(
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
    return other is IconButtonThemeData && other.style == style && other.variant == variant;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ButtonStyle>('style', style, defaultValue: null));
    properties.add(EnumProperty<StyleVariant>('variant', variant, defaultValue: null));
  }
}

/// Overrides the default [ButtonStyle] of its [IconButton] descendants.
///
/// See also:
///
///  * [IconButtonThemeData], which is used to configure this theme.
///  * [IconButton.styleFrom], which converts simple values into a
///    [ButtonStyle] that's consistent with [IconButton]'s defaults.
///  * [ThemeData.iconButtonTheme], which can be used to override the default
///    [ButtonStyle] for [IconButton]s below the overall [Theme].
class IconButtonTheme extends InheritedTheme {
  /// Create a [IconButtonTheme].
  const IconButtonTheme({super.key, required this.data, required super.child});

  /// The configuration of this theme.
  final IconButtonThemeData data;

  /// Retrieves the [IconButtonThemeData] from the closest ancestor [IconButtonTheme].
  ///
  /// If there is no enclosing [IconButtonTheme] widget, then
  /// [ThemeData.iconButtonTheme] is used.
  ///
  /// If the closest [IconButtonTheme] doesn't specify a variant, the returned
  /// [IconButtonThemeData.variant] is inherited from the closest enclosing
  /// [IconButtonTheme] that specifies one, and then from
  /// [ThemeData.iconButtonTheme]. The other properties are not inherited.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// IconButtonThemeData theme = IconButtonTheme.of(context);
  /// ```
  static IconButtonThemeData of(BuildContext context) {
    final IconButtonThemeData? data = context
        .dependOnInheritedWidgetOfExactType<_ResolvedIconButtonTheme>()
        ?.data;
    if (data == null) {
      return Theme.of(context).iconButtonTheme;
    }
    if (data.variant != null) {
      return data;
    }
    final StyleVariant? themeVariant = Theme.of(context).iconButtonTheme.variant;
    if (themeVariant == null) {
      return data;
    }
    return IconButtonThemeData(style: data.style, variant: themeVariant);
  }

  /// Returns the [StyleVariant] that [IconButton]s use at the given [context].
  ///
  /// This is the [IconButtonThemeData.variant] returned by [of], or
  /// [StyleVariant.material3] if that is null.
  @Deprecated(
    'Use IconButtonTheme.of(context).variant instead. '
    'This feature was deprecated after material_ui v1.11.0.',
  )
  static StyleVariant variantOf(BuildContext context) {
    return of(context).variant ?? StyleVariant.material3;
  }

  @override
  InheritedElement createElement() => _IconButtonThemeElement(this);

  @override
  Widget wrap(BuildContext context, Widget child) {
    return IconButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(IconButtonTheme oldWidget) => data != oldWidget.data;
}

// Inserts a _ResolvedIconButtonTheme below its IconButtonTheme, so that the
// variant is inherited when the theme is built rather than looked up by every
// IconButtonTheme.of call, and so that InheritedTheme.capture keeps it.
class _IconButtonThemeElement extends InheritedElement {
  _IconButtonThemeElement(IconButtonTheme super.widget);

  @override
  Widget build() {
    IconButtonThemeData data = (widget as IconButtonTheme).data;
    if (data.variant == null) {
      final StyleVariant? inheritedVariant =
          dependOnInheritedWidgetOfExactType<_ResolvedIconButtonTheme>()?.data.variant;
      if (inheritedVariant != null) {
        data = IconButtonThemeData(style: data.style, variant: inheritedVariant);
      }
    }
    return _ResolvedIconButtonTheme(data: data, child: super.build());
  }
}

// The data of the closest IconButtonTheme, with the variant inherited from the
// enclosing IconButtonThemes.
class _ResolvedIconButtonTheme extends InheritedTheme {
  const _ResolvedIconButtonTheme({required this.data, required super.child});

  final IconButtonThemeData data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return _ResolvedIconButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(_ResolvedIconButtonTheme oldWidget) => data != oldWidget.data;
}
