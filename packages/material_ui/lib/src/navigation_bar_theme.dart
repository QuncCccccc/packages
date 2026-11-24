// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'navigation_bar.dart';
import 'theme.dart';
import 'theme_data.dart';

// Examples can assume:
// late BuildContext context;

/// Defines default property values for descendant [NavigationBar]
/// widgets.
///
/// Descendant widgets obtain the current [NavigationBarThemeData] object
/// using [NavigationBarTheme.of]. Instances of [NavigationBarThemeData] can be
/// customized with [NavigationBarThemeData.copyWith].
///
/// Typically a [NavigationBarThemeData] is specified as part of the
/// overall [Theme] with [ThemeData.navigationBarTheme]. Alternatively, a
/// [NavigationBarTheme] inherited widget can be used to theme [NavigationBar]s
/// in a subtree of widgets.
///
/// All [NavigationBarThemeData] properties are `null` by default.
/// When null, the [NavigationBar] will provide its own defaults based on the
/// overall [Theme]'s textTheme and colorScheme. See the individual
/// [NavigationBar] properties for details.
///
/// See also:
///
///  * [ThemeData], which describes the overall theme information for the
///    application.
@immutable
class NavigationBarThemeData with Diagnosticable {
  /// Creates a theme that can be used for [ThemeData.navigationBarTheme] and
  /// [NavigationBarTheme].
  const NavigationBarThemeData({
    this.height,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.indicatorColor,
    this.indicatorShape,
    this.labelTextStyle,
    this.iconTheme,
    this.labelBehavior,
    this.overlayColor,
    this.labelPadding,
    this.destinationLayout,
    this.variant,
  });

  /// Overrides the default value of [NavigationBar.height].
  final double? height;

  /// Overrides the default value of [NavigationBar.backgroundColor].
  final Color? backgroundColor;

  /// Overrides the default value of [NavigationBar.elevation].
  final double? elevation;

  /// Overrides the default value of [NavigationBar.shadowColor].
  final Color? shadowColor;

  /// Overrides the default value of [NavigationBar.surfaceTintColor].
  final Color? surfaceTintColor;

  /// Overrides the default value of [NavigationBar]'s selection indicator.
  final Color? indicatorColor;

  /// Overrides the default shape of the [NavigationBar]'s selection indicator.
  final ShapeBorder? indicatorShape;

  /// The style to merge with the default text style for
  /// [NavigationDestination] labels.
  ///
  /// You can use this to specify a different style when the label is selected.
  final WidgetStateProperty<TextStyle?>? labelTextStyle;

  /// The theme to merge with the default icon theme for
  /// [NavigationDestination] icons.
  ///
  /// You can use this to specify a different icon theme when the icon is
  /// selected.
  final WidgetStateProperty<IconThemeData?>? iconTheme;

  /// Overrides the default value of [NavigationBar.labelBehavior].
  final NavigationDestinationLabelBehavior? labelBehavior;

  /// Overrides the default value of [NavigationBar.overlayColor].
  final WidgetStateProperty<Color?>? overlayColor;

  /// Overrides the default value of [NavigationBar.labelPadding].
  final EdgeInsetsGeometry? labelPadding;

  /// Overrides the default value of [NavigationBar.destinationLayout].
  ///
  /// [NavigationDestinationLayout.horizontal] is only used with the Material 3
  /// Expressive style. See [variant].
  final NavigationDestinationLayout? destinationLayout;

  /// The style variant of Material Design used by [NavigationBar].
  ///
  /// Set this to [StyleVariant.material3Expressive] to opt navigation bars
  /// into the Material 3 Expressive style.
  ///
  /// If null, the variant is inherited from the closest enclosing
  /// [NavigationBarTheme] that specifies one, and then from
  /// [ThemeData.navigationBarTheme]. If none of them specify a variant,
  /// [NavigationBar] uses [StyleVariant.material3]. To keep a subtree on
  /// Material 3 when an ancestor opts into Material 3 Expressive, set this to
  /// [StyleVariant.material3].
  ///
  /// An enclosing [NavigationBarTheme] takes precedence over
  /// [ThemeData.navigationBarTheme], even when a closer [Theme] specifies a
  /// different variant. This matches [NavigationBarTheme.of], which only uses
  /// [ThemeData.navigationBarTheme] when there is no enclosing
  /// [NavigationBarTheme]. To change the variant of a subtree, wrap it in a
  /// [NavigationBarTheme].
  ///
  /// See also:
  ///
  ///  * [NavigationBarTheme.variantOf], which returns the variant that
  ///    applies at a given location.
  final StyleVariant? variant;

  /// Creates a copy of this object with the given fields replaced with the
  /// new values.
  NavigationBarThemeData copyWith({
    double? height,
    Color? backgroundColor,
    double? elevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    Color? indicatorColor,
    ShapeBorder? indicatorShape,
    WidgetStateProperty<TextStyle?>? labelTextStyle,
    WidgetStateProperty<IconThemeData?>? iconTheme,
    NavigationDestinationLabelBehavior? labelBehavior,
    WidgetStateProperty<Color?>? overlayColor,
    EdgeInsetsGeometry? labelPadding,
    NavigationDestinationLayout? destinationLayout,
    StyleVariant? variant,
  }) {
    return NavigationBarThemeData(
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      indicatorShape: indicatorShape ?? this.indicatorShape,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      iconTheme: iconTheme ?? this.iconTheme,
      labelBehavior: labelBehavior ?? this.labelBehavior,
      overlayColor: overlayColor ?? this.overlayColor,
      labelPadding: labelPadding ?? this.labelPadding,
      destinationLayout: destinationLayout ?? this.destinationLayout,
      variant: variant ?? this.variant,
    );
  }

  /// Linearly interpolate between two navigation rail themes.
  ///
  /// If both arguments are null then null is returned.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static NavigationBarThemeData? lerp(
    NavigationBarThemeData? a,
    NavigationBarThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    return NavigationBarThemeData(
      height: lerpDouble(a?.height, b?.height, t),
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t),
      shadowColor: Color.lerp(a?.shadowColor, b?.shadowColor, t),
      surfaceTintColor: Color.lerp(a?.surfaceTintColor, b?.surfaceTintColor, t),
      indicatorColor: Color.lerp(a?.indicatorColor, b?.indicatorColor, t),
      indicatorShape: ShapeBorder.lerp(a?.indicatorShape, b?.indicatorShape, t),
      labelTextStyle: WidgetStateProperty.lerp<TextStyle?>(
        a?.labelTextStyle,
        b?.labelTextStyle,
        t,
        TextStyle.lerp,
      ),
      iconTheme: WidgetStateProperty.lerp<IconThemeData?>(
        a?.iconTheme,
        b?.iconTheme,
        t,
        IconThemeData.lerp,
      ),
      labelBehavior: t < 0.5 ? a?.labelBehavior : b?.labelBehavior,
      overlayColor: WidgetStateProperty.lerp<Color?>(
        a?.overlayColor,
        b?.overlayColor,
        t,
        Color.lerp,
      ),
      labelPadding: EdgeInsetsGeometry.lerp(a?.labelPadding, b?.labelPadding, t),
      destinationLayout: t < 0.5 ? a?.destinationLayout : b?.destinationLayout,
      variant: t < 0.5 ? a?.variant : b?.variant,
    );
  }

  @override
  int get hashCode => Object.hash(
    height,
    backgroundColor,
    elevation,
    shadowColor,
    surfaceTintColor,
    indicatorColor,
    indicatorShape,
    labelTextStyle,
    iconTheme,
    labelBehavior,
    overlayColor,
    labelPadding,
    destinationLayout,
    variant,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is NavigationBarThemeData &&
        other.height == height &&
        other.backgroundColor == backgroundColor &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.surfaceTintColor == surfaceTintColor &&
        other.indicatorColor == indicatorColor &&
        other.indicatorShape == indicatorShape &&
        other.labelTextStyle == labelTextStyle &&
        other.iconTheme == iconTheme &&
        other.labelBehavior == labelBehavior &&
        other.overlayColor == overlayColor &&
        other.labelPadding == labelPadding &&
        other.destinationLayout == destinationLayout &&
        other.variant == variant;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('height', height, defaultValue: null));
    properties.add(ColorProperty('backgroundColor', backgroundColor, defaultValue: null));
    properties.add(DoubleProperty('elevation', elevation, defaultValue: null));
    properties.add(ColorProperty('shadowColor', shadowColor, defaultValue: null));
    properties.add(ColorProperty('surfaceTintColor', surfaceTintColor, defaultValue: null));
    properties.add(ColorProperty('indicatorColor', indicatorColor, defaultValue: null));
    properties.add(
      DiagnosticsProperty<ShapeBorder>('indicatorShape', indicatorShape, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<TextStyle?>>(
        'labelTextStyle',
        labelTextStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<IconThemeData?>>(
        'iconTheme',
        iconTheme,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<NavigationDestinationLabelBehavior>(
        'labelBehavior',
        labelBehavior,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<Color?>>(
        'overlayColor',
        overlayColor,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry>('labelPadding', labelPadding, defaultValue: null),
    );
    properties.add(
      EnumProperty<NavigationDestinationLayout>(
        'destinationLayout',
        destinationLayout,
        defaultValue: null,
      ),
    );
    properties.add(EnumProperty<StyleVariant>('variant', variant, defaultValue: null));
  }
}

/// An inherited widget that defines visual properties for [NavigationBar]s and
/// [NavigationDestination]s in this widget's subtree.
///
/// Values specified here are used for [NavigationBar] properties that are not
/// given an explicit non-null value.
///
/// See also:
///
///  * [ThemeData.navigationBarTheme], which describes the
///    [NavigationBarThemeData] in the overall theme for the application.
class NavigationBarTheme extends InheritedTheme {
  /// Creates a navigation rail theme that controls the
  /// [NavigationBarThemeData] properties for a [NavigationBar].
  const NavigationBarTheme({super.key, required this.data, required super.child});

  /// Specifies the background color, label text style, icon theme, and label
  /// type values for descendant [NavigationBar] widgets.
  final NavigationBarThemeData data;

  /// Retrieves the [NavigationBarThemeData] from the closest ancestor [NavigationBarTheme].
  ///
  /// If there is no enclosing [NavigationBarTheme] widget, then
  /// [ThemeData.navigationBarTheme] is used.
  ///
  /// The returned [NavigationBarThemeData.variant] is the value specified by
  /// that theme, which can be null even when an ancestor specifies a variant.
  /// Use [variantOf] to get the variant that applies at the given [context].
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// NavigationBarThemeData theme = NavigationBarTheme.of(context);
  /// ```
  static NavigationBarThemeData of(BuildContext context) {
    final NavigationBarTheme? navigationBarTheme = context
        .dependOnInheritedWidgetOfExactType<NavigationBarTheme>();
    return navigationBarTheme?.data ?? Theme.of(context).navigationBarTheme;
  }

  /// Returns the [StyleVariant] that [NavigationBar]s use at the given
  /// [context].
  ///
  /// The closest enclosing [NavigationBarTheme] whose
  /// [NavigationBarThemeData.variant] is non-null determines the variant, so a
  /// [NavigationBarTheme] that doesn't specify a variant inherits it from its
  /// ancestors. If none of the enclosing [NavigationBarTheme]s specify a
  /// variant, the variant of [ThemeData.navigationBarTheme] is used. If that is
  /// also null, [StyleVariant.material3] is returned.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// final StyleVariant variant = NavigationBarTheme.variantOf(context);
  /// ```
  static StyleVariant variantOf(BuildContext context) {
    InheritedElement? element = context
        .getElementForInheritedWidgetOfExactType<NavigationBarTheme>();
    while (element != null) {
      // Depend on every theme that is visited, so that a change to any of them
      // rebuilds the dependent.
      context.dependOnInheritedElement(element);
      final StyleVariant? variant = (element.widget as NavigationBarTheme).data.variant;
      if (variant != null) {
        return variant;
      }
      // Calling getElementForInheritedWidgetOfExactType on the element itself
      // would return the same element, so continue the search from its parent.
      Element? parent;
      element.visitAncestorElements((Element ancestor) {
        parent = ancestor;
        return false;
      });
      element = parent?.getElementForInheritedWidgetOfExactType<NavigationBarTheme>();
    }
    return Theme.of(context).navigationBarTheme.variant ?? StyleVariant.material3;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return NavigationBarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(NavigationBarTheme oldWidget) => data != oldWidget.data;
}
