// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/color_role.dart';
import '../data/nav_bar.dart';
import '../data/nav_bar_item_horizontal.dart';
import '../data/nav_bar_item_vertical.dart';
import '../data/navigation_bar.dart';
import '../data/state.dart';
import 'template.dart';

class NavigationBarTemplateM3 extends TokenTemplateM3 {
  const NavigationBarTemplateM3();

  @override
  String get name => 'Navigation Bar';

  @override
  String get parentFilePath => 'navigation_bar.dart';

  // TODO(QuncCccccc): Replace these with token values once disabled-state
  // tokens are available.
  static const TokenColorRole _legacyDisabledColor = TokenColorRole.onSurfaceVariant;
  static const double _legacyDisabledOpacity = 0.38;

  @override
  String generateContents(String className) =>
      '''
class $className extends NavigationBarThemeData {
  $className(this.context)
    : super(
        height: ${number(TokenNavigationBar.containerHeight)},
        elevation: ${number(TokenNavigationBar.containerElevation)},
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => ${color(TokenNavigationBar.containerColor)};

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  WidgetStateProperty<IconThemeData?>? get iconTheme {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      return IconThemeData(
        size: ${number(TokenNavigationBar.iconSize)},
        color: states.contains(WidgetState.disabled)
          ? ${colorWithOpacity(_legacyDisabledColor, _legacyDisabledOpacity)}
          : states.contains(WidgetState.selected)
            ? ${color(TokenNavigationBar.activeIconColor)}
            : ${color(TokenNavigationBar.inactiveIconColor)},
      );
    });
  }

  @override
  Color? get indicatorColor => ${color(TokenNavigationBar.activeIndicatorColor)};

  @override
  ShapeBorder? get indicatorShape => ${shape(TokenNavigationBar.activeIndicatorShape)};

  @override
  WidgetStateProperty<TextStyle?>? get labelTextStyle {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final TextStyle style = ${textStyle(TokenNavigationBar.labelTextType, '_textTheme')}!;
      return style.apply(
        color: states.contains(WidgetState.disabled)
          ? ${colorWithOpacity(_legacyDisabledColor, _legacyDisabledOpacity)}
          : states.contains(WidgetState.selected)
            ? ${color(TokenNavigationBar.activeLabelTextColor)}
            : ${color(TokenNavigationBar.inactiveLabelTextColor)},
      );
    });
  }

  @override
  EdgeInsetsGeometry? get labelPadding => const EdgeInsets.only(top: 4);
}
''';
}

class NavigationBarTemplateM3E extends TokenTemplateM3E {
  const NavigationBarTemplateM3E();

  @override
  String get name => 'Navigation Bar';

  @override
  String get parentFilePath => 'navigation_bar.dart';

  // TODO(QuncCccccc): Replace these with token values once disabled-state
  // tokens are available.
  static const TokenColorRole _legacyDisabledColor = TokenColorRole.onSurfaceVariant;
  static const double _legacyDisabledOpacity = 0.38;

  // The inactive items have state layer color tokens, but no state layer
  // opacity tokens. The active state layer opacity tokens refer to the system
  // state layer opacities, so the inactive items use them too.
  // TODO(QuncCccccc): Replace these with token values once inactive state layer
  // opacity tokens are available.
  static const double _inactivePressedStateLayerOpacity = TokenState.pressedStateLayerOpacity;
  static const double _inactiveHoveredStateLayerOpacity = TokenState.hoverStateLayerOpacity;
  static const double _inactiveFocusedStateLayerOpacity = TokenState.focusStateLayerOpacity;

  @override
  String generateContents(String className) =>
      '''
class $className extends NavigationBarThemeData {
  $className(this.context, NavigationDestinationLayout? destinationLayout)
    : _destinationLayout = destinationLayout,
      super(
        height: ${number(TokenNavBar.containerHeight)},
        elevation: ${number(TokenNavBar.containerElevation)},
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      );

  final BuildContext context;
  final NavigationDestinationLayout? _destinationLayout;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  /// The space between the destinations.
  static const double itemBetweenSpace = ${number(TokenNavBar.itemBetweenSpace)};

  /// The size of the indicator behind the icon when the destinations are laid
  /// out vertically.
  static const Size verticalIndicatorSize = Size(${number(TokenNavBarItemVertical.activeIndicatorWidth)}, ${number(TokenNavBarItemVertical.activeIndicatorHeight)});

  /// The height of the indicator behind the icon and the label when the
  /// destinations are laid out horizontally.
  static const double horizontalIndicatorHeight = ${number(TokenNavBarItemHorizontal.activeIndicatorHeight)};

  /// The space between the edges of the indicator and its icon and label when
  /// the destinations are laid out horizontally.
  static const EdgeInsetsGeometry horizontalIndicatorPadding = EdgeInsetsDirectional.only(
    start: ${number(TokenNavBarItemHorizontal.activeIndicatorLeadingSpace)},
    end: ${number(TokenNavBarItemHorizontal.activeIndicatorTrailingSpace)},
  );

  @override
  NavigationDestinationLayout get destinationLayout =>
      _destinationLayout ?? NavigationDestinationLayout.vertical;

  @override
  Color? get backgroundColor => ${color(TokenNavBar.containerColor)};

  @override
  Color? get shadowColor => ${color(TokenNavBar.containerShadowColor)};

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  WidgetStateProperty<IconThemeData?>? get iconTheme {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      return IconThemeData(
        size: ${number(TokenNavBar.itemIconSize)},
        color: states.contains(WidgetState.disabled)
          ? ${colorWithOpacity(_legacyDisabledColor, _legacyDisabledOpacity)}
          : states.contains(WidgetState.selected)
            ? ${color(TokenNavBar.itemActiveIconColor)}
            : ${color(TokenNavBar.itemInactiveIconColor)},
      );
    });
  }

  @override
  Color? get indicatorColor => ${color(TokenNavBar.itemActiveIndicatorColor)};

  @override
  ShapeBorder? get indicatorShape => ${shape(TokenNavBar.itemActiveIndicatorShape)};

  @override
  WidgetStateProperty<TextStyle?>? get labelTextStyle {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final TextStyle style = switch (destinationLayout) {
        NavigationDestinationLayout.vertical => ${textStyle(TokenNavBarItemVertical.labelTextFont, '_textTheme')}!,
        NavigationDestinationLayout.horizontal => ${textStyle(TokenNavBarItemHorizontal.labelTextFont, '_textTheme')}!,
      };
      return style.apply(
        color: states.contains(WidgetState.disabled)
          ? ${colorWithOpacity(_legacyDisabledColor, _legacyDisabledOpacity)}
          : states.contains(WidgetState.selected)
            ? ${color(TokenNavBar.itemActiveLabelTextColor)}
            : ${color(TokenNavBar.itemInactiveLabelTextColor)},
      );
    });
  }

  @override
  WidgetStateProperty<Color?>? get overlayColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        if (states.contains(WidgetState.pressed)) {
          return ${colorWithOpacity(TokenNavBar.itemActivePressedStateLayerColor, TokenNavBar.itemActivePressedStateLayerOpacity)};
        }
        if (states.contains(WidgetState.hovered)) {
          return ${colorWithOpacity(TokenNavBar.itemActiveHoveredStateLayerColor, TokenNavBar.itemActiveHoveredStateLayerOpacity)};
        }
        if (states.contains(WidgetState.focused)) {
          return ${colorWithOpacity(TokenNavBar.itemActiveFocusedStateLayerColor, TokenNavBar.itemActiveFocusedStateLayerOpacity)};
        }
        return null;
      }
      if (states.contains(WidgetState.pressed)) {
        return ${colorWithOpacity(TokenNavBar.itemInactivePressedStateLayerColor, _inactivePressedStateLayerOpacity)};
      }
      if (states.contains(WidgetState.hovered)) {
        return ${colorWithOpacity(TokenNavBar.itemInactiveHoveredStateLayerColor, _inactiveHoveredStateLayerOpacity)};
      }
      if (states.contains(WidgetState.focused)) {
        return ${colorWithOpacity(TokenNavBar.itemInactiveFocusedStateLayerColor, _inactiveFocusedStateLayerOpacity)};
      }
      return null;
    });
  }

  @override
  EdgeInsetsGeometry? get labelPadding => switch (destinationLayout) {
    NavigationDestinationLayout.vertical => const EdgeInsets.only(top: ${number(TokenNavBarItemVertical.activeIndicatorIconLabelSpace)}),
    NavigationDestinationLayout.horizontal => const EdgeInsetsDirectional.only(start: ${number(TokenNavBarItemHorizontal.activeIndicatorIconLabelSpace)}),
  };
}
''';
}
