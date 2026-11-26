// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Do not edit by hand. The code is generated from data in the Material
// Design token database by the script:
//   packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart.
part of '../navigation_bar.dart';

class _NavigationBarDefaultsM3E extends NavigationBarThemeData {
  _NavigationBarDefaultsM3E(this.context, NavigationDestinationLayout? destinationLayout)
    : _destinationLayout = destinationLayout,
      super(
        height: 64.0,
        elevation: 3.0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      );

  final BuildContext context;
  final NavigationDestinationLayout? _destinationLayout;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  /// The space between the destinations.
  static const double itemBetweenSpace = 0.0;

  /// The size of the indicator behind the icon when the destinations are laid
  /// out vertically.
  static const Size verticalIndicatorSize = Size(56.0, 32.0);

  /// The height of the indicator behind the icon and the label when the
  /// destinations are laid out horizontally.
  static const double horizontalIndicatorHeight = 40.0;

  /// The space between the edges of the indicator and its icon and label when
  /// the destinations are laid out horizontally.
  static const EdgeInsetsGeometry horizontalIndicatorPadding = EdgeInsetsDirectional.only(
    start: 16.0,
    end: 16.0,
  );

  @override
  NavigationDestinationLayout get destinationLayout =>
      _destinationLayout ?? NavigationDestinationLayout.vertical;

  @override
  Color? get backgroundColor => _colors.surfaceContainer;

  @override
  Color? get shadowColor => _colors.shadow;

  // No token defines a surface tint, so there is none, as with Material 3.
  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  WidgetStateProperty<IconThemeData?>? get iconTheme {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      return IconThemeData(
        size: 24.0,
        color: states.contains(WidgetState.disabled)
            ? _colors.onSurfaceVariant.withValues(alpha: 0.38)
            : states.contains(WidgetState.selected)
            ? _colors.onSecondaryContainer
            : _colors.onSurfaceVariant,
      );
    });
  }

  @override
  Color? get indicatorColor => _colors.secondaryContainer;

  @override
  ShapeBorder? get indicatorShape => const StadiumBorder();

  @override
  WidgetStateProperty<TextStyle?>? get labelTextStyle {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final TextStyle style = switch (destinationLayout) {
        NavigationDestinationLayout.vertical => _textTheme.labelMedium!,
        NavigationDestinationLayout.horizontal => _textTheme.labelMedium!,
      };
      return style.apply(
        color: states.contains(WidgetState.disabled)
            ? _colors.onSurfaceVariant.withValues(alpha: 0.38)
            : states.contains(WidgetState.selected)
            ? _colors.secondary
            : _colors.onSurfaceVariant,
      );
    });
  }

  @override
  WidgetStateProperty<Color?>? get overlayColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return _colors.onSecondaryContainer.withValues(alpha: 0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return _colors.onSecondaryContainer.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return _colors.onSecondaryContainer.withValues(alpha: 0.1);
        }
        return null;
      }
      if (states.contains(WidgetState.pressed)) {
        return _colors.onSecondaryContainer.withValues(alpha: 0.1);
      }
      if (states.contains(WidgetState.hovered)) {
        return _colors.onSecondaryContainer.withValues(alpha: 0.08);
      }
      if (states.contains(WidgetState.focused)) {
        return _colors.onSecondaryContainer.withValues(alpha: 0.1);
      }
      return null;
    });
  }

  @override
  EdgeInsetsGeometry? get labelPadding => switch (destinationLayout) {
    NavigationDestinationLayout.vertical => const EdgeInsets.only(top: 4.0),
    NavigationDestinationLayout.horizontal => const EdgeInsetsDirectional.only(start: 4.0),
  };
}
