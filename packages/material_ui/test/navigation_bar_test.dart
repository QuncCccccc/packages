// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is run as part of a reduced test set in CI on Mac and Windows
// machines.
@Tags(<String>['reduced-test-set'])
library;

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'finders.dart';

void main() {
  testWidgets('Navigation bar updates destinations when tapped', (WidgetTester tester) async {
    var mutatedIndex = -1;
    final Widget widget = _buildWidget(
      NavigationBar(
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
          NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
        ],
        onDestinationSelected: (int i) {
          mutatedIndex = i;
        },
      ),
    );

    await tester.pumpWidget(widget);

    expect(find.text('AC'), findsOneWidget);
    expect(find.text('Alarm'), findsOneWidget);

    await tester.tap(find.text('Alarm'));
    expect(mutatedIndex, 1);

    await tester.tap(find.text('AC'));
    expect(mutatedIndex, 0);
  });

  testWidgets('NavigationBar can update background color', (WidgetTester tester) async {
    const Color color = Colors.yellow;

    await tester.pumpWidget(
      _buildWidget(
        NavigationBar(
          backgroundColor: color,
          destinations: const <Widget>[
            NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
            NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
          ],
          onDestinationSelected: (int i) {},
        ),
      ),
    );

    expect(_getMaterial(tester).color, equals(color));
  });

  testWidgets('NavigationBar can update elevation', (WidgetTester tester) async {
    const elevation = 42.0;

    await tester.pumpWidget(
      _buildWidget(
        NavigationBar(
          elevation: elevation,
          destinations: const <Widget>[
            NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
            NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
          ],
          onDestinationSelected: (int i) {},
        ),
      ),
    );

    expect(_getMaterial(tester).elevation, equals(elevation));
  });

  testWidgets('NavigationBar adds bottom padding to height', (WidgetTester tester) async {
    const bottomPadding = 40.0;

    await tester.pumpWidget(
      _buildWidget(
        NavigationBar(
          destinations: const <Widget>[
            NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
            NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
          ],
          onDestinationSelected: (int i) {},
        ),
      ),
    );

    final double defaultSize = tester.getSize(find.byType(NavigationBar)).height;
    expect(defaultSize, 80);

    await tester.pumpWidget(
      _buildWidget(
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(bottom: bottomPadding)),
          child: NavigationBar(
            destinations: const <Widget>[
              NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
              NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
            ],
            onDestinationSelected: (int i) {},
          ),
        ),
      ),
    );

    final double expectedHeight = defaultSize + bottomPadding;
    expect(tester.getSize(find.byType(NavigationBar)).height, expectedHeight);
  });

  testWidgets('NavigationBar respects the notch/system navigation bar in landscape mode', (
    WidgetTester tester,
  ) async {
    const safeAreaPadding = 40.0;
    Widget navigationBar() {
      return NavigationBar(
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
          NavigationDestination(
            key: Key('Center'),
            icon: Icon(Icons.center_focus_strong),
            label: 'Center',
          ),
          NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
        ],
        onDestinationSelected: (int i) {},
      );
    }

    await tester.pumpWidget(_buildWidget(navigationBar()));
    final double defaultWidth = tester.getSize(find.byType(NavigationBar)).width;
    final Finder defaultCenterItem = find.byKey(const Key('Center'));
    final Offset center = tester.getCenter(defaultCenterItem);
    expect(center.dx, defaultWidth / 2);

    await tester.pumpWidget(
      _buildWidget(
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(left: safeAreaPadding)),
          child: navigationBar(),
        ),
      ),
    );

    // The position of center item of navigation bar should indicate whether
    // the safe area is sufficiently respected, when safe area is on the left side.
    // e.g. Android device with system navigation bar in landscape mode.
    final Finder leftPaddedCenterItem = find.byKey(const Key('Center'));
    final Offset leftPaddedCenter = tester.getCenter(leftPaddedCenterItem);
    expect(
      leftPaddedCenter.dx,
      closeTo((defaultWidth + safeAreaPadding) / 2.0, precisionErrorTolerance),
    );

    await tester.pumpWidget(
      _buildWidget(
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(right: safeAreaPadding)),
          child: navigationBar(),
        ),
      ),
    );

    // The position of center item of navigation bar should indicate whether
    // the safe area is sufficiently respected, when safe area is on the right side.
    // e.g. Android device with system navigation bar in landscape mode.
    final Finder rightPaddedCenterItem = find.byKey(const Key('Center'));
    final Offset rightPaddedCenter = tester.getCenter(rightPaddedCenterItem);
    expect(
      rightPaddedCenter.dx,
      closeTo((defaultWidth - safeAreaPadding) / 2, precisionErrorTolerance),
    );

    await tester.pumpWidget(
      _buildWidget(
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.fromLTRB(safeAreaPadding, 0, safeAreaPadding, safeAreaPadding),
          ),
          child: navigationBar(),
        ),
      ),
    );

    // The position of center item of navigation bar should indicate whether
    // the safe area is sufficiently respected, when safe areas are on both sides.
    // e.g. iOS device with both sides of round corner.
    final Finder paddedCenterItem = find.byKey(const Key('Center'));
    final Offset paddedCenter = tester.getCenter(paddedCenterItem);
    expect(paddedCenter.dx, closeTo(defaultWidth / 2, precisionErrorTolerance));
  });

  testWidgets('Material2 - NavigationBar uses proper defaults when no parameters are given', (
    WidgetTester tester,
  ) async {
    // M2 settings that were hand coded.
    await tester.pumpWidget(
      _buildWidget(
        NavigationBar(
          destinations: const <Widget>[
            NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
            NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
          ],
          onDestinationSelected: (int i) {},
        ),
        useMaterial3: false,
      ),
    );

    expect(_getMaterial(tester).color, const Color(0xffeaeaea));
    expect(_getMaterial(tester).surfaceTintColor, null);
    expect(_getMaterial(tester).elevation, 0);
    expect(tester.getSize(find.byType(NavigationBar)).height, 80);
    expect(_getIndicatorDecoration(tester)?.color, const Color(0x3d2196f3));
    expect(
      _getIndicatorDecoration(tester)?.shape,
      const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    );
  });

  testWidgets('Material3 - NavigationBar uses proper defaults when no parameters are given', (
    WidgetTester tester,
  ) async {
    // M3 settings from the token database.
    final theme = ThemeData();
    await tester.pumpWidget(
      _buildWidget(
        NavigationBar(
          destinations: const <Widget>[
            NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
            NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
          ],
          onDestinationSelected: (int i) {},
        ),
        useMaterial3: theme.useMaterial3,
      ),
    );

    expect(_getMaterial(tester).color, theme.colorScheme.surfaceContainer);
    expect(_getMaterial(tester).surfaceTintColor, Colors.transparent);
    expect(_getMaterial(tester).elevation, 3);
    expect(tester.getSize(find.byType(NavigationBar)).height, 80);
    expect(_getIndicatorDecoration(tester)?.color, theme.colorScheme.secondaryContainer);
    expect(_getIndicatorDecoration(tester)?.shape, const StadiumBorder());
  });

  testWidgets('Material2 - NavigationBar shows tooltips with text scaling', (
    WidgetTester tester,
  ) async {
    const label = 'A';

    Widget buildApp({required TextScaler textScaler}) {
      return MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Localizations(
          locale: const Locale('en', 'US'),
          delegates: const <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          child: MaterialApp(
            theme: ThemeData(useMaterial3: false),
            home: Navigator(
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return Scaffold(
                      bottomNavigationBar: NavigationBar(
                        destinations: const <NavigationDestination>[
                          NavigationDestination(
                            label: label,
                            icon: Icon(Icons.ac_unit),
                            tooltip: label,
                          ),
                          NavigationDestination(label: 'B', icon: Icon(Icons.battery_alert)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(textScaler: TextScaler.noScaling));
    expect(find.text(label), findsOneWidget);
    await tester.longPress(find.text(label));
    expect(find.text(label), findsNWidgets(2));

    // The default size of a tooltip with the text A.
    const defaultTooltipSize = Size(14.0, 14.0);
    expect(tester.getSize(find.text(label).last), defaultTooltipSize);
    // The duration is needed to ensure the tooltip disappears.
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.pumpWidget(buildApp(textScaler: const TextScaler.linear(4.0)));
    expect(find.text(label), findsOneWidget);
    await tester.longPress(find.text(label));
    expect(
      tester.getSize(find.text(label).last),
      Size(defaultTooltipSize.width * 4, defaultTooltipSize.height * 4),
    );
  });

  testWidgets('Material3 - NavigationBar shows tooltips with text scaling', (
    WidgetTester tester,
  ) async {
    const label = 'A';

    Widget buildApp({required TextScaler textScaler}) {
      return MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Localizations(
          locale: const Locale('en', 'US'),
          delegates: const <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          child: MaterialApp(
            home: Navigator(
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return Scaffold(
                      bottomNavigationBar: NavigationBar(
                        destinations: const <NavigationDestination>[
                          NavigationDestination(
                            label: label,
                            icon: Icon(Icons.ac_unit),
                            tooltip: label,
                          ),
                          NavigationDestination(label: 'B', icon: Icon(Icons.battery_alert)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(textScaler: TextScaler.noScaling));
    expect(find.text(label), findsOneWidget);
    await tester.longPress(find.text(label));
    expect(find.text(label), findsNWidgets(2));

    expect(tester.getSize(find.text(label).last), const Size(14.25, 20.0));
    // The duration is needed to ensure the tooltip disappears.
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.pumpWidget(buildApp(textScaler: const TextScaler.linear(4.0)));
    expect(find.text(label), findsOneWidget);
    await tester.longPress(find.text(label));

    expect(tester.getSize(find.text(label).last), const Size(56.25, 80.0));
  });

  testWidgets('Material3 - NavigationBar label can scale and has maxScaleFactor', (
    WidgetTester tester,
  ) async {
    const label = 'A';

    Widget buildApp({required TextScaler textScaler}) {
      return MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Localizations(
          locale: const Locale('en', 'US'),
          delegates: const <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          child: MaterialApp(
            home: Navigator(
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return Scaffold(
                      bottomNavigationBar: NavigationBar(
                        destinations: const <NavigationDestination>[
                          NavigationDestination(label: label, icon: Icon(Icons.ac_unit)),
                          NavigationDestination(label: 'B', icon: Icon(Icons.battery_alert)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(textScaler: TextScaler.noScaling));
    expect(find.text(label), findsOneWidget);
    expect(_sizeAlmostEqual(tester.getSize(find.text(label)), const Size(12.5, 16.0)), true);

    await tester.pumpWidget(buildApp(textScaler: const TextScaler.linear(1.1)));
    await tester.pumpAndSettle();

    expect(_sizeAlmostEqual(tester.getSize(find.text(label)), const Size(13.7, 18.0)), true);

    await tester.pumpWidget(buildApp(textScaler: const TextScaler.linear(1.3)));

    expect(_sizeAlmostEqual(tester.getSize(find.text(label)), const Size(16.1, 21.0)), true);

    await tester.pumpWidget(buildApp(textScaler: const TextScaler.linear(4)));
    expect(_sizeAlmostEqual(tester.getSize(find.text(label)), const Size(16.1, 21.0)), true);
  });

  testWidgets('Custom tooltips in NavigationBarDestination', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NavigationBar(
            destinations: const <NavigationDestination>[
              NavigationDestination(label: 'A', tooltip: 'A tooltip', icon: Icon(Icons.ac_unit)),
              NavigationDestination(label: 'B', icon: Icon(Icons.battery_alert)),
              NavigationDestination(label: 'C', icon: Icon(Icons.cake), tooltip: ''),
            ],
          ),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    await tester.longPress(find.text('A'));
    expect(findByTooltip('A tooltip'), findsOneWidget);

    expect(find.text('B'), findsOneWidget);
    await tester.longPress(find.text('B'));
    expect(findByTooltip('B'), findsOneWidget);

    expect(find.text('C'), findsOneWidget);
    await tester.longPress(find.text('C'));
    expect(findByTooltip('C'), findsNothing);
  });

  testWidgets('Navigation bar semantics', (WidgetTester tester) async {
    Widget widget({int selectedIndex = 0}) {
      return _buildWidget(
        NavigationBar(
          selectedIndex: selectedIndex,
          destinations: const <Widget>[
            NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
            NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
            NavigationDestination(icon: Icon(Icons.abc), label: 'ABC'),
          ],
        ),
      );
    }

    await tester.pumpWidget(widget());

    expect(
      tester.getSemantics(find.text('AC')),
      matchesSemantics(
        label: 'AC${kIsWeb ? '' : '\nTab 1 of 3'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isSelected: true,
        isButton: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('Alarm')),
      matchesSemantics(
        label: 'Alarm${kIsWeb ? '' : '\nTab 2 of 3'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isButton: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('ABC')),
      matchesSemantics(
        label: 'ABC${kIsWeb ? '' : '\nTab 3 of 3'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isButton: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );

    await tester.pumpWidget(widget(selectedIndex: 1));

    expect(
      tester.getSemantics(find.text('AC')),
      matchesSemantics(
        label: 'AC${kIsWeb ? '' : '\nTab 1 of 3'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isButton: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('Alarm')),
      matchesSemantics(
        label: 'Alarm${kIsWeb ? '' : '\nTab 2 of 3'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isSelected: true,
        isButton: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('ABC')),
      matchesSemantics(
        label: 'ABC${kIsWeb ? '' : '\nTab 3 of 3'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isButton: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
  }, tags: 'reduced-web-test-set');
  testWidgets('Navigation bar disabled semantics', (WidgetTester tester) async {
    Widget widget({int selectedIndex = 0}) {
      return _buildWidget(
        NavigationBar(
          selectedIndex: selectedIndex,
          destinations: const <Widget>[
            NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC', enabled: false),
            NavigationDestination(icon: Icon(Icons.ac_unit), label: 'Another'),
          ],
        ),
      );
    }

    await tester.pumpWidget(widget());

    expect(
      tester.getSemantics(find.text('AC')),
      matchesSemantics(
        label: 'AC${kIsWeb ? '' : '\nTab 1 of 2'}',
        textDirection: TextDirection.ltr,
        isSelected: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isButton: true,
      ),
    );
  }, tags: 'reduced-web-test-set');

  testWidgets('Navigation bar semantics with some labels hidden', (WidgetTester tester) async {
    Widget widget({int selectedIndex = 0}) {
      return _buildWidget(
        NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: selectedIndex,
          destinations: const <Widget>[
            NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
            NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
          ],
        ),
      );
    }

    await tester.pumpWidget(widget());

    expect(
      tester.getSemantics(find.text('AC')),
      matchesSemantics(
        label: 'AC${kIsWeb ? '' : '\nTab 1 of 2'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isSelected: true,
        isButton: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('Alarm')),
      matchesSemantics(
        label: 'Alarm${kIsWeb ? '' : '\nTab 2 of 2'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isButton: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );

    await tester.pumpWidget(widget(selectedIndex: 1));

    expect(
      tester.getSemantics(find.text('AC')),
      matchesSemantics(
        label: 'AC${kIsWeb ? '' : '\nTab 1 of 2'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isButton: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('Alarm')),
      matchesSemantics(
        label: 'Alarm${kIsWeb ? '' : '\nTab 2 of 2'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isEnabled: true,
        isSelected: true,
        isButton: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
  }, tags: 'reduced-web-test-set');

  testWidgets('Navigation bar does not grow with text scale factor', (WidgetTester tester) async {
    const animationMilliseconds = 800;

    Widget widget({TextScaler textScaler = TextScaler.noScaling}) {
      return _buildWidget(
        MediaQuery(
          data: MediaQueryData(textScaler: textScaler),
          child: NavigationBar(
            animationDuration: const Duration(milliseconds: animationMilliseconds),
            destinations: const <NavigationDestination>[
              NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
              NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(widget());
    final double initialHeight = tester.getSize(find.byType(NavigationBar)).height;

    await tester.pumpWidget(widget(textScaler: const TextScaler.linear(2)));
    final double newHeight = tester.getSize(find.byType(NavigationBar)).height;

    expect(newHeight, equals(initialHeight));
  });

  testWidgets('Material3 - Navigation indicator renders ripple', (WidgetTester tester) async {
    // This is a regression test for https://github.com/flutter/flutter/issues/116751.
    var selectedIndex = 0;

    Widget buildWidget({NavigationDestinationLabelBehavior? labelBehavior}) {
      return MaterialApp(
        home: Scaffold(
          bottomNavigationBar: Center(
            child: NavigationBar(
              selectedIndex: selectedIndex,
              labelBehavior: labelBehavior,
              destinations: const <Widget>[
                NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
                NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
              ],
              onDestinationSelected: (int i) {},
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildWidget());

    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    await gesture.moveTo(tester.getCenter(find.byIcon(Icons.access_alarm)));
    await tester.pumpAndSettle();

    final RenderObject inkFeatures = tester.allRenderObjects.firstWhere(
      (RenderObject object) => object.runtimeType.toString() == '_RenderInkFeatures',
    );
    var indicatorCenter = const Offset(600, 30);
    const includedIndicatorSize = Size(64, 32);
    const excludedIndicatorSize = Size(74, 40);

    // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.alwaysShow` (default).
    expect(
      inkFeatures,
      paints
        ..clipPath(
          pathMatcher: isPathThat(
            includes: <Offset>[
              // Left center.
              Offset(indicatorCenter.dx - (includedIndicatorSize.width / 2), indicatorCenter.dy),
              // Top center.
              Offset(indicatorCenter.dx, indicatorCenter.dy - (includedIndicatorSize.height / 2)),
              // Right center.
              Offset(indicatorCenter.dx + (includedIndicatorSize.width / 2), indicatorCenter.dy),
              // Bottom center.
              Offset(indicatorCenter.dx, indicatorCenter.dy + (includedIndicatorSize.height / 2)),
            ],
            excludes: <Offset>[
              // Left center.
              Offset(indicatorCenter.dx - (excludedIndicatorSize.width / 2), indicatorCenter.dy),
              // Top center.
              Offset(indicatorCenter.dx, indicatorCenter.dy - (excludedIndicatorSize.height / 2)),
              // Right center.
              Offset(indicatorCenter.dx + (excludedIndicatorSize.width / 2), indicatorCenter.dy),
              // Bottom center.
              Offset(indicatorCenter.dx, indicatorCenter.dy + (excludedIndicatorSize.height / 2)),
            ],
          ),
        )
        ..circle(
          x: indicatorCenter.dx,
          y: indicatorCenter.dy,
          radius: 35.0,
          color: const Color(0x0a000000),
        ),
    );

    // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.alwaysHide`.
    await tester.pumpWidget(
      buildWidget(labelBehavior: NavigationDestinationLabelBehavior.alwaysHide),
    );
    await gesture.moveTo(tester.getCenter(find.byIcon(Icons.access_alarm)));
    await tester.pumpAndSettle();

    indicatorCenter = const Offset(600, 40);

    expect(
      inkFeatures,
      paints
        ..clipPath(
          pathMatcher: isPathThat(
            includes: <Offset>[
              // Left center.
              Offset(indicatorCenter.dx - (includedIndicatorSize.width / 2), indicatorCenter.dy),
              // Top center.
              Offset(indicatorCenter.dx, indicatorCenter.dy - (includedIndicatorSize.height / 2)),
              // Right center.
              Offset(indicatorCenter.dx + (includedIndicatorSize.width / 2), indicatorCenter.dy),
              // Bottom center.
              Offset(indicatorCenter.dx, indicatorCenter.dy + (includedIndicatorSize.height / 2)),
            ],
            excludes: <Offset>[
              // Left center.
              Offset(indicatorCenter.dx - (excludedIndicatorSize.width / 2), indicatorCenter.dy),
              // Top center.
              Offset(indicatorCenter.dx, indicatorCenter.dy - (excludedIndicatorSize.height / 2)),
              // Right center.
              Offset(indicatorCenter.dx + (excludedIndicatorSize.width / 2), indicatorCenter.dy),
              // Bottom center.
              Offset(indicatorCenter.dx, indicatorCenter.dy + (excludedIndicatorSize.height / 2)),
            ],
          ),
        )
        ..circle(
          x: indicatorCenter.dx,
          y: indicatorCenter.dy,
          radius: 35.0,
          color: const Color(0x0a000000),
        ),
    );

    // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.onlyShowSelected`.
    await tester.pumpWidget(
      buildWidget(labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected),
    );
    await gesture.moveTo(tester.getCenter(find.byIcon(Icons.access_alarm)));
    await tester.pumpAndSettle();

    expect(
      inkFeatures,
      paints
        ..clipPath(
          pathMatcher: isPathThat(
            includes: <Offset>[
              // Left center.
              Offset(indicatorCenter.dx - (includedIndicatorSize.width / 2), indicatorCenter.dy),
              // Top center.
              Offset(indicatorCenter.dx, indicatorCenter.dy - (includedIndicatorSize.height / 2)),
              // Right center.
              Offset(indicatorCenter.dx + (includedIndicatorSize.width / 2), indicatorCenter.dy),
              // Bottom center.
              Offset(indicatorCenter.dx, indicatorCenter.dy + (includedIndicatorSize.height / 2)),
            ],
            excludes: <Offset>[
              // Left center.
              Offset(indicatorCenter.dx - (excludedIndicatorSize.width / 2), indicatorCenter.dy),
              // Top center.
              Offset(indicatorCenter.dx, indicatorCenter.dy - (excludedIndicatorSize.height / 2)),
              // Right center.
              Offset(indicatorCenter.dx + (excludedIndicatorSize.width / 2), indicatorCenter.dy),
              // Bottom center.
              Offset(indicatorCenter.dx, indicatorCenter.dy + (excludedIndicatorSize.height / 2)),
            ],
          ),
        )
        ..circle(
          x: indicatorCenter.dx,
          y: indicatorCenter.dy,
          radius: 35.0,
          color: const Color(0x0a000000),
        ),
    );

    // Make sure ripple is shifted when selectedIndex changes.
    selectedIndex = 1;
    await tester.pumpWidget(
      buildWidget(labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected),
    );
    await tester.pumpAndSettle();
    indicatorCenter = const Offset(600, 30);

    expect(
      inkFeatures,
      paints
        ..clipPath(
          pathMatcher: isPathThat(
            includes: <Offset>[
              // Left center.
              Offset(indicatorCenter.dx - (includedIndicatorSize.width / 2), indicatorCenter.dy),
              // Top center.
              Offset(indicatorCenter.dx, indicatorCenter.dy - (includedIndicatorSize.height / 2)),
              // Right center.
              Offset(indicatorCenter.dx + (includedIndicatorSize.width / 2), indicatorCenter.dy),
              // Bottom center.
              Offset(indicatorCenter.dx, indicatorCenter.dy + (includedIndicatorSize.height / 2)),
            ],
            excludes: <Offset>[
              // Left center.
              Offset(indicatorCenter.dx - (excludedIndicatorSize.width / 2), indicatorCenter.dy),
              // Top center.
              Offset(indicatorCenter.dx, indicatorCenter.dy - (excludedIndicatorSize.height / 2)),
              // Right center.
              Offset(indicatorCenter.dx + (excludedIndicatorSize.width / 2), indicatorCenter.dy),
              // Bottom center.
              Offset(indicatorCenter.dx, indicatorCenter.dy + (excludedIndicatorSize.height / 2)),
            ],
          ),
        )
        ..circle(
          x: indicatorCenter.dx,
          y: indicatorCenter.dy,
          radius: 35.0,
          color: const Color(0x0a000000),
        ),
    );
  });

  testWidgets('Material3 - Navigation indicator ripple golden test', (WidgetTester tester) async {
    // This is a regression test for https://github.com/flutter/flutter/issues/117420.

    Widget buildWidget({NavigationDestinationLabelBehavior? labelBehavior}) {
      return MaterialApp(
        home: Scaffold(
          bottomNavigationBar: Center(
            child: NavigationBar(
              labelBehavior: labelBehavior,
              destinations: const <Widget>[
                NavigationDestination(icon: SizedBox(), label: 'AC'),
                NavigationDestination(icon: SizedBox(), label: 'Alarm'),
              ],
              onDestinationSelected: (int i) {},
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildWidget());

    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    await gesture.moveTo(tester.getCenter(find.byType(NavigationDestination).last));
    await tester.pumpAndSettle();

    // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.alwaysShow` (default).
    await expectLater(find.byType(NavigationBar), matchesGoldenFile('indicator_alwaysShow_m3.png'));

    // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.alwaysHide`.
    await tester.pumpWidget(
      buildWidget(labelBehavior: NavigationDestinationLabelBehavior.alwaysHide),
    );
    await gesture.moveTo(tester.getCenter(find.byType(NavigationDestination).last));
    await tester.pumpAndSettle();

    await expectLater(find.byType(NavigationBar), matchesGoldenFile('indicator_alwaysHide_m3.png'));

    // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.onlyShowSelected`.
    await tester.pumpWidget(
      buildWidget(labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected),
    );
    await gesture.moveTo(tester.getCenter(find.byType(NavigationDestination).first));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(NavigationBar),
      matchesGoldenFile('indicator_onlyShowSelected_selected_m3.png'),
    );

    await gesture.moveTo(tester.getCenter(find.byType(NavigationDestination).last));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(NavigationBar),
      matchesGoldenFile('indicator_onlyShowSelected_unselected_m3.png'),
    );
  });

  // Regression test for https://github.com/flutter/flutter/issues/169249.
  testWidgets('Material3 - Navigation indicator moves to selected item', (
    WidgetTester tester,
  ) async {
    final theme = ThemeData();
    var index = 0;

    Widget buildNavigationBar({Color? indicatorColor, ShapeBorder? indicatorShape}) {
      return MaterialApp(
        theme: theme,
        home: Scaffold(
          bottomNavigationBar: RepaintBoundary(
            child: NavigationBar(
              indicatorColor: indicatorColor,
              indicatorShape: indicatorShape,
              selectedIndex: index,
              destinations: const <Widget>[
                NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
                NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
              ],
              onDestinationSelected: (int i) {},
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildNavigationBar());

    // Move the selection to the second destination.
    index = 1;
    await tester.pumpWidget(buildNavigationBar());
    await tester.pumpAndSettle();

    // The navigation indicator should be on the second item.
    await expectLater(
      find.byType(NavigationBar),
      matchesGoldenFile('m3.navigation_bar.indicator.ink.position.png'),
    );
  });

  testWidgets('Navigation indicator scale transform', (WidgetTester tester) async {
    var selectedIndex = 0;

    Widget buildNavigationBar() {
      return MaterialApp(
        home: Scaffold(
          bottomNavigationBar: Center(
            child: NavigationBar(
              selectedIndex: selectedIndex,
              destinations: const <Widget>[
                NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
                NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
              ],
              onDestinationSelected: (int i) {},
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildNavigationBar());
    await tester.pumpAndSettle();
    final Finder transformFinder = find
        .descendant(of: find.byType(NavigationIndicator), matching: find.byType(Transform))
        .last;
    Matrix4 transform = tester.widget<Transform>(transformFinder).transform;
    expect(transform.getColumn(0)[0], 0.0);

    selectedIndex = 1;
    await tester.pumpWidget(buildNavigationBar());
    await tester.pump(const Duration(milliseconds: 100));
    transform = tester.widget<Transform>(transformFinder).transform;
    expect(transform.getColumn(0)[0], closeTo(0.7805849514007568, precisionErrorTolerance));

    await tester.pump(const Duration(milliseconds: 100));
    transform = tester.widget<Transform>(transformFinder).transform;
    expect(transform.getColumn(0)[0], closeTo(0.9473570239543915, precisionErrorTolerance));

    await tester.pumpAndSettle();
    transform = tester.widget<Transform>(transformFinder).transform;
    expect(transform.getColumn(0)[0], 1.0);
  });

  testWidgets('Material3 - Navigation destination updates indicator color and shape', (
    WidgetTester tester,
  ) async {
    final theme = ThemeData();
    const color = Color(0xff0000ff);
    const ShapeBorder shape = RoundedRectangleBorder();

    Widget buildNavigationBar({Color? indicatorColor, ShapeBorder? indicatorShape}) {
      return MaterialApp(
        theme: theme,
        home: Scaffold(
          bottomNavigationBar: RepaintBoundary(
            child: NavigationBar(
              indicatorColor: indicatorColor,
              indicatorShape: indicatorShape,
              destinations: const <Widget>[
                NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
                NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
              ],
              onDestinationSelected: (int i) {},
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildNavigationBar());

    // Test default indicator color and shape.
    expect(_getIndicatorDecoration(tester)?.color, theme.colorScheme.secondaryContainer);
    expect(_getIndicatorDecoration(tester)?.shape, const StadiumBorder());

    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    await gesture.moveTo(tester.getCenter(find.byType(NavigationIndicator).last));
    await tester.pumpAndSettle();

    // Test default indicator color and shape with ripple.
    await expectLater(
      find.byType(NavigationBar),
      matchesGoldenFile('m3.navigation_bar.default.indicator.inkwell.shape.png'),
    );

    await tester.pumpWidget(buildNavigationBar(indicatorColor: color, indicatorShape: shape));

    // Test custom indicator color and shape.
    expect(_getIndicatorDecoration(tester)?.color, color);
    expect(_getIndicatorDecoration(tester)?.shape, shape);

    // Test custom indicator color and shape with ripple.
    await expectLater(
      find.byType(NavigationBar),
      matchesGoldenFile('m3.navigation_bar.custom.indicator.inkwell.shape.png'),
    );
  });

  testWidgets('Destinations respect their disabled state', (WidgetTester tester) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      _buildWidget(
        NavigationBar(
          destinations: const <Widget>[
            NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
            NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
            NavigationDestination(icon: Icon(Icons.bookmark), label: 'Bookmark', enabled: false),
          ],
          onDestinationSelected: (int i) => selectedIndex = i,
          selectedIndex: selectedIndex,
        ),
      ),
    );

    await tester.tap(find.text('AC'));
    expect(selectedIndex, 0);

    await tester.tap(find.text('Alarm'));
    expect(selectedIndex, 1);

    await tester.tap(find.text('Bookmark'));
    expect(selectedIndex, 1);
  });

  testWidgets('NavigationBar respects overlayColor in active/pressed/hovered states', (
    WidgetTester tester,
  ) async {
    tester.binding.focusManager.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    const hoverColor = Color(0xff0000ff);
    const focusColor = Color(0xff00ffff);
    const pressedColor = Color(0xffff00ff);
    final WidgetStateProperty<Color?> overlayColor = WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.hovered)) {
        return hoverColor;
      }
      if (states.contains(WidgetState.focused)) {
        return focusColor;
      }
      if (states.contains(WidgetState.pressed)) {
        return pressedColor;
      }
      return Colors.transparent;
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: RepaintBoundary(
            child: NavigationBar(
              overlayColor: overlayColor,
              destinations: const <Widget>[
                NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
                NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
              ],
              onDestinationSelected: (int i) {},
            ),
          ),
        ),
      ),
    );

    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    await gesture.moveTo(tester.getCenter(find.byType(NavigationIndicator).last));
    await tester.pumpAndSettle();

    final RenderObject inkFeatures = tester.allRenderObjects.firstWhere(
      (RenderObject object) => object.runtimeType.toString() == '_RenderInkFeatures',
    );

    // Test hovered state.
    expect(
      inkFeatures,
      kIsWeb
          ? (paints
              ..rrect()
              ..rrect()
              ..circle(color: hoverColor))
          : (paints..circle(color: hoverColor)),
    );

    await gesture.down(tester.getCenter(find.byType(NavigationIndicator).last));
    await tester.pumpAndSettle();

    // Test pressed state.
    expect(
      inkFeatures,
      kIsWeb
          ? (paints
              ..circle()
              ..circle()
              ..circle(color: pressedColor))
          : (paints
              ..circle()
              ..circle(color: pressedColor)),
    );

    await gesture.up();
    await tester.pumpAndSettle();

    // Press tab to focus the navigation bar.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    // Test focused state.
    expect(
      inkFeatures,
      kIsWeb
          ? (paints
              ..circle()
              ..circle(color: focusColor))
          : (paints
              ..circle()
              ..circle(color: focusColor)),
    );
  }, tags: 'reduced-web-test-set');

  testWidgets('NavigationBar.labelPadding overrides NavigationDestination.label padding', (
    WidgetTester tester,
  ) async {
    const EdgeInsetsGeometry labelPadding = EdgeInsets.all(8);
    Widget buildNavigationBar({EdgeInsetsGeometry? labelPadding}) {
      return MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NavigationBar(
            labelPadding: labelPadding,
            destinations: const <Widget>[
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
            ],
            onDestinationSelected: (int i) {},
          ),
        ),
      );
    }

    await tester.pumpWidget(buildNavigationBar());
    expect(_getLabelPadding(tester, 'Home'), const EdgeInsets.only(top: 4));
    expect(_getLabelPadding(tester, 'Settings'), const EdgeInsets.only(top: 4));

    await tester.pumpWidget(buildNavigationBar(labelPadding: labelPadding));
    expect(_getLabelPadding(tester, 'Home'), labelPadding);
    expect(_getLabelPadding(tester, 'Settings'), labelPadding);
  });

  group('Material 2', () {
    // These tests are only relevant for Material 2. Once Material 2
    // support is deprecated and the APIs are removed, these tests
    // can be deleted.

    testWidgets('Material2 - Navigation destination updates indicator color and shape', (
      WidgetTester tester,
    ) async {
      final theme = ThemeData(useMaterial3: false);
      const color = Color(0xff0000ff);
      const ShapeBorder shape = RoundedRectangleBorder();

      Widget buildNavigationBar({Color? indicatorColor, ShapeBorder? indicatorShape}) {
        return MaterialApp(
          theme: theme,
          home: Scaffold(
            bottomNavigationBar: NavigationBar(
              indicatorColor: indicatorColor,
              indicatorShape: indicatorShape,
              destinations: const <Widget>[
                NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
                NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
              ],
              onDestinationSelected: (int i) {},
            ),
          ),
        );
      }

      await tester.pumpWidget(buildNavigationBar());

      // Test default indicator color and shape.
      expect(_getIndicatorDecoration(tester)?.color, theme.colorScheme.secondary.withOpacity(0.24));
      expect(
        _getIndicatorDecoration(tester)?.shape,
        const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      );

      await tester.pumpWidget(buildNavigationBar(indicatorColor: color, indicatorShape: shape));

      // Test custom indicator color and shape.
      expect(_getIndicatorDecoration(tester)?.color, color);
      expect(_getIndicatorDecoration(tester)?.shape, shape);
    });

    testWidgets('Material2 - Navigation indicator renders ripple', (WidgetTester tester) async {
      // This is a regression test for https://github.com/flutter/flutter/issues/116751.
      var selectedIndex = 0;

      Widget buildWidget({NavigationDestinationLabelBehavior? labelBehavior}) {
        return MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Scaffold(
            bottomNavigationBar: Center(
              child: NavigationBar(
                selectedIndex: selectedIndex,
                labelBehavior: labelBehavior,
                destinations: const <Widget>[
                  NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
                  NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
                ],
                onDestinationSelected: (int i) {},
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildWidget());

      final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer();
      await gesture.moveTo(tester.getCenter(find.byIcon(Icons.access_alarm)));
      await tester.pumpAndSettle();

      final RenderObject inkFeatures = tester.allRenderObjects.firstWhere(
        (RenderObject object) => object.runtimeType.toString() == '_RenderInkFeatures',
      );
      var indicatorCenter = const Offset(600, 33);
      const includedIndicatorSize = Size(64, 32);
      const excludedIndicatorSize = Size(74, 40);

      // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.alwaysShow` (default).
      expect(
        inkFeatures,
        paints
          ..clipPath(
            pathMatcher: isPathThat(
              includes: <Offset>[
                // Left center.
                Offset(indicatorCenter.dx - (includedIndicatorSize.width / 2), indicatorCenter.dy),
                // Top center.
                Offset(indicatorCenter.dx, indicatorCenter.dy - (includedIndicatorSize.height / 2)),
                // Right center.
                Offset(indicatorCenter.dx + (includedIndicatorSize.width / 2), indicatorCenter.dy),
                // Bottom center.
                Offset(indicatorCenter.dx, indicatorCenter.dy + (includedIndicatorSize.height / 2)),
              ],
              excludes: <Offset>[
                // Left center.
                Offset(indicatorCenter.dx - (excludedIndicatorSize.width / 2), indicatorCenter.dy),
                // Top center.
                Offset(indicatorCenter.dx, indicatorCenter.dy - (excludedIndicatorSize.height / 2)),
                // Right center.
                Offset(indicatorCenter.dx + (excludedIndicatorSize.width / 2), indicatorCenter.dy),
                // Bottom center.
                Offset(indicatorCenter.dx, indicatorCenter.dy + (excludedIndicatorSize.height / 2)),
              ],
            ),
          )
          ..circle(
            x: indicatorCenter.dx,
            y: indicatorCenter.dy,
            radius: 35.0,
            color: const Color(0x0a000000),
          ),
      );

      // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.alwaysHide`.
      await tester.pumpWidget(
        buildWidget(labelBehavior: NavigationDestinationLabelBehavior.alwaysHide),
      );
      await gesture.moveTo(tester.getCenter(find.byIcon(Icons.access_alarm)));
      await tester.pumpAndSettle();

      indicatorCenter = const Offset(600, 40);

      expect(
        inkFeatures,
        paints
          ..clipPath(
            pathMatcher: isPathThat(
              includes: <Offset>[
                // Left center.
                Offset(indicatorCenter.dx - (includedIndicatorSize.width / 2), indicatorCenter.dy),
                // Top center.
                Offset(indicatorCenter.dx, indicatorCenter.dy - (includedIndicatorSize.height / 2)),
                // Right center.
                Offset(indicatorCenter.dx + (includedIndicatorSize.width / 2), indicatorCenter.dy),
                // Bottom center.
                Offset(indicatorCenter.dx, indicatorCenter.dy + (includedIndicatorSize.height / 2)),
              ],
              excludes: <Offset>[
                // Left center.
                Offset(indicatorCenter.dx - (excludedIndicatorSize.width / 2), indicatorCenter.dy),
                // Top center.
                Offset(indicatorCenter.dx, indicatorCenter.dy - (excludedIndicatorSize.height / 2)),
                // Right center.
                Offset(indicatorCenter.dx + (excludedIndicatorSize.width / 2), indicatorCenter.dy),
                // Bottom center.
                Offset(indicatorCenter.dx, indicatorCenter.dy + (excludedIndicatorSize.height / 2)),
              ],
            ),
          )
          ..circle(
            x: indicatorCenter.dx,
            y: indicatorCenter.dy,
            radius: 35.0,
            color: const Color(0x0a000000),
          ),
      );

      // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.onlyShowSelected`.
      await tester.pumpWidget(
        buildWidget(labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected),
      );
      await gesture.moveTo(tester.getCenter(find.byIcon(Icons.access_alarm)));
      await tester.pumpAndSettle();

      expect(
        inkFeatures,
        paints
          ..clipPath(
            pathMatcher: isPathThat(
              includes: <Offset>[
                // Left center.
                Offset(indicatorCenter.dx - (includedIndicatorSize.width / 2), indicatorCenter.dy),
                // Top center.
                Offset(indicatorCenter.dx, indicatorCenter.dy - (includedIndicatorSize.height / 2)),
                // Right center.
                Offset(indicatorCenter.dx + (includedIndicatorSize.width / 2), indicatorCenter.dy),
                // Bottom center.
                Offset(indicatorCenter.dx, indicatorCenter.dy + (includedIndicatorSize.height / 2)),
              ],
              excludes: <Offset>[
                // Left center.
                Offset(indicatorCenter.dx - (excludedIndicatorSize.width / 2), indicatorCenter.dy),
                // Top center.
                Offset(indicatorCenter.dx, indicatorCenter.dy - (excludedIndicatorSize.height / 2)),
                // Right center.
                Offset(indicatorCenter.dx + (excludedIndicatorSize.width / 2), indicatorCenter.dy),
                // Bottom center.
                Offset(indicatorCenter.dx, indicatorCenter.dy + (excludedIndicatorSize.height / 2)),
              ],
            ),
          )
          ..circle(
            x: indicatorCenter.dx,
            y: indicatorCenter.dy,
            radius: 35.0,
            color: const Color(0x0a000000),
          ),
      );

      // Make sure ripple is shifted when selectedIndex changes.
      selectedIndex = 1;
      await tester.pumpWidget(
        buildWidget(labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected),
      );
      await tester.pumpAndSettle();
      indicatorCenter = const Offset(600, 33);

      expect(
        inkFeatures,
        paints
          ..clipPath(
            pathMatcher: isPathThat(
              includes: <Offset>[
                // Left center.
                Offset(indicatorCenter.dx - (includedIndicatorSize.width / 2), indicatorCenter.dy),
                // Top center.
                Offset(indicatorCenter.dx, indicatorCenter.dy - (includedIndicatorSize.height / 2)),
                // Right center.
                Offset(indicatorCenter.dx + (includedIndicatorSize.width / 2), indicatorCenter.dy),
                // Bottom center.
                Offset(indicatorCenter.dx, indicatorCenter.dy + (includedIndicatorSize.height / 2)),
              ],
              excludes: <Offset>[
                // Left center.
                Offset(indicatorCenter.dx - (excludedIndicatorSize.width / 2), indicatorCenter.dy),
                // Top center.
                Offset(indicatorCenter.dx, indicatorCenter.dy - (excludedIndicatorSize.height / 2)),
                // Right center.
                Offset(indicatorCenter.dx + (excludedIndicatorSize.width / 2), indicatorCenter.dy),
                // Bottom center.
                Offset(indicatorCenter.dx, indicatorCenter.dy + (excludedIndicatorSize.height / 2)),
              ],
            ),
          )
          ..circle(
            x: indicatorCenter.dx,
            y: indicatorCenter.dy,
            radius: 35.0,
            color: const Color(0x0a000000),
          ),
      );
    });

    testWidgets('Material2 - Navigation indicator ripple golden test', (WidgetTester tester) async {
      // This is a regression test for https://github.com/flutter/flutter/issues/117420.

      Widget buildWidget({NavigationDestinationLabelBehavior? labelBehavior}) {
        return MaterialApp(
          theme: ThemeData(useMaterial3: false),
          home: Scaffold(
            bottomNavigationBar: Center(
              child: NavigationBar(
                labelBehavior: labelBehavior,
                destinations: const <Widget>[
                  NavigationDestination(icon: SizedBox(), label: 'AC'),
                  NavigationDestination(icon: SizedBox(), label: 'Alarm'),
                ],
                onDestinationSelected: (int i) {},
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildWidget());

      final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer();
      await gesture.moveTo(tester.getCenter(find.byType(NavigationDestination).last));
      await tester.pumpAndSettle();

      // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.alwaysShow` (default).
      await expectLater(
        find.byType(NavigationBar),
        matchesGoldenFile('indicator_alwaysShow_m2.png'),
      );

      // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.alwaysHide`.
      await tester.pumpWidget(
        buildWidget(labelBehavior: NavigationDestinationLabelBehavior.alwaysHide),
      );
      await gesture.moveTo(tester.getCenter(find.byType(NavigationDestination).last));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(NavigationBar),
        matchesGoldenFile('indicator_alwaysHide_m2.png'),
      );

      // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.onlyShowSelected`.
      await tester.pumpWidget(
        buildWidget(labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected),
      );
      await gesture.moveTo(tester.getCenter(find.byType(NavigationDestination).first));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(NavigationBar),
        matchesGoldenFile('indicator_onlyShowSelected_selected_m2.png'),
      );

      await gesture.moveTo(tester.getCenter(find.byType(NavigationDestination).last));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(NavigationBar),
        matchesGoldenFile('indicator_onlyShowSelected_unselected_m2.png'),
      );
    });

    testWidgets('Destination icon does not rebuild when tapped', (WidgetTester tester) async {
      // This is a regression test for https://github.com/flutter/flutter/issues/122811.

      Widget buildNavigationBar() {
        return MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                var selectedIndex = 0;
                return NavigationBar(
                  selectedIndex: selectedIndex,
                  destinations: const <Widget>[
                    NavigationDestination(
                      icon: IconWithRandomColor(icon: Icons.ac_unit),
                      label: 'AC',
                    ),
                    NavigationDestination(
                      icon: IconWithRandomColor(icon: Icons.access_alarm),
                      label: 'Alarm',
                    ),
                  ],
                  onDestinationSelected: (int i) {
                    setState(() {
                      selectedIndex = i;
                    });
                  },
                );
              },
            ),
          ),
        );
      }

      await tester.pumpWidget(buildNavigationBar());
      Icon icon = tester.widget<Icon>(find.byType(Icon).last);
      final Color initialColor = icon.color!;

      // Trigger a rebuild.
      await tester.tap(find.text('Alarm'));
      await tester.pumpAndSettle();

      // Icon color should be the same as before the rebuild.
      icon = tester.widget<Icon>(find.byType(Icon).last);
      expect(icon.color, initialColor);
    });
  });

  testWidgets('NavigationBar.labelPadding overrides NavigationDestination.label padding', (
    WidgetTester tester,
  ) async {
    const selectedText = 'Home';
    const unselectedText = 'Settings';
    const EdgeInsetsGeometry labelPadding = EdgeInsets.all(8);
    Widget buildNavigationBar({EdgeInsetsGeometry? labelPadding}) {
      return MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NavigationBar(
            labelPadding: labelPadding,
            destinations: const <Widget>[
              NavigationDestination(icon: Icon(Icons.home), label: selectedText),
              NavigationDestination(icon: Icon(Icons.settings), label: unselectedText),
            ],
            onDestinationSelected: (int i) {},
          ),
        ),
      );
    }

    await tester.pumpWidget(buildNavigationBar());
    expect(_getLabelPadding(tester, selectedText), const EdgeInsets.only(top: 4));
    expect(_getLabelPadding(tester, unselectedText), const EdgeInsets.only(top: 4));

    await tester.pumpWidget(buildNavigationBar(labelPadding: labelPadding));
    expect(_getLabelPadding(tester, selectedText), labelPadding);
    expect(_getLabelPadding(tester, unselectedText), labelPadding);
  });

  testWidgets('NavigationBar.labelTextStyle overrides NavigationDestination.label text style', (
    WidgetTester tester,
  ) async {
    const selectedText = 'Home';
    const unselectedText = 'Settings';
    const disabledText = 'Bookmark';
    final theme = ThemeData();
    Widget buildNavigationBar({WidgetStateProperty<TextStyle?>? labelTextStyle}) {
      return MaterialApp(
        theme: theme,
        home: Scaffold(
          bottomNavigationBar: NavigationBar(
            labelTextStyle: labelTextStyle,
            destinations: const <Widget>[
              NavigationDestination(icon: Icon(Icons.home), label: selectedText),
              NavigationDestination(icon: Icon(Icons.settings), label: unselectedText),
              NavigationDestination(
                enabled: false,
                icon: Icon(Icons.bookmark),
                label: disabledText,
              ),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(buildNavigationBar());

    // Test selected label text style.
    expect(_getLabelStyle(tester, selectedText).fontSize, equals(12.0));
    expect(_getLabelStyle(tester, selectedText).color, equals(theme.colorScheme.onSurface));

    // Test unselected label text style.
    expect(_getLabelStyle(tester, unselectedText).fontSize, equals(12.0));
    expect(
      _getLabelStyle(tester, unselectedText).color,
      equals(theme.colorScheme.onSurfaceVariant),
    );

    // Test disabled label text style.
    expect(_getLabelStyle(tester, disabledText).fontSize, equals(12.0));
    expect(
      _getLabelStyle(tester, disabledText).color,
      equals(theme.colorScheme.onSurfaceVariant.withOpacity(0.38)),
    );

    const selectedTextStyle = TextStyle(fontSize: 15, color: Color(0xFF00FF00));
    const unselectedTextStyle = TextStyle(fontSize: 15, color: Color(0xFF0000FF));
    const disabledTextStyle = TextStyle(fontSize: 16, color: Color(0xFFFF0000));
    await tester.pumpWidget(
      buildNavigationBar(
        labelTextStyle: const WidgetStateProperty<TextStyle?>.fromMap(
          <WidgetStatesConstraint, TextStyle?>{
            WidgetState.disabled: disabledTextStyle,
            WidgetState.selected: selectedTextStyle,
            WidgetState.any: unselectedTextStyle,
          },
        ),
      ),
    );

    // Test selected label text style.
    expect(_getLabelStyle(tester, selectedText).fontSize, equals(selectedTextStyle.fontSize));
    expect(_getLabelStyle(tester, selectedText).color, equals(selectedTextStyle.color));

    // Test unselected label text style.
    expect(_getLabelStyle(tester, unselectedText).fontSize, equals(unselectedTextStyle.fontSize));
    expect(_getLabelStyle(tester, unselectedText).color, equals(unselectedTextStyle.color));

    // Test disabled label text style.
    expect(_getLabelStyle(tester, disabledText).fontSize, equals(disabledTextStyle.fontSize));
    expect(_getLabelStyle(tester, disabledText).color, equals(disabledTextStyle.color));
  });

  testWidgets('NavigationBar.maintainBottomViewPadding can consume bottom MediaQuery.padding', (
    WidgetTester tester,
  ) async {
    const double bottomPadding = 40;
    const TextDirection textDirection = TextDirection.ltr;

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: textDirection,
          child: MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.only(bottom: bottomPadding)),
            child: Scaffold(
              bottomNavigationBar: NavigationBar(
                maintainBottomViewPadding: true,
                destinations: const <Widget>[
                  NavigationDestination(icon: Icon(Icons.ac_unit), label: 'AC'),
                  NavigationDestination(icon: Icon(Icons.access_alarm), label: 'Alarm'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final double safeAreaBottomPadding = tester
        .widget<Padding>(find.byType(Padding).first)
        .padding
        .resolve(textDirection)
        .bottom;
    expect(safeAreaBottomPadding, equals(0));
  });

  testWidgets('NavigationBar does not crash at zero area', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox.shrink(
            child: NavigationBar(
              destinations: const <Widget>[
                NavigationDestination(icon: Icon(Icons.add), label: 'X'),
                NavigationDestination(icon: Icon(Icons.abc), label: 'Y'),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(NavigationBar)), Size.zero);
  });

  group('Material 3 Expressive', () {
    ThemeData m3eTheme({NavigationDestinationLayout? destinationLayout}) {
      return ThemeData(
        navigationBarTheme: NavigationBarThemeData(
          variant: StyleVariant.material3Expressive,
          destinationLayout: destinationLayout,
        ),
      );
    }

    const homeKey = Key('home');
    const searchKey = Key('search');
    const settingsKey = Key('settings');
    const keys = <Key>[homeKey, searchKey, settingsKey];
    const destinations = <Widget>[
      NavigationDestination(
        key: homeKey,
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(key: searchKey, icon: Icon(Icons.search), label: 'Search'),
      NavigationDestination(
        key: settingsKey,
        enabled: false,
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];
    const icons = <IconData>[Icons.home, Icons.search, Icons.settings];
    const labels = <String>['Home', 'Search', 'Settings'];

    Widget buildNavigationBar({
      required ThemeData theme,
      int selectedIndex = 0,
      NavigationDestinationLayout? destinationLayout,
      NavigationDestinationLabelBehavior? labelBehavior,
      WidgetStateProperty<Color?>? overlayColor,
      ValueChanged<int>? onDestinationSelected,
      TextDirection textDirection = TextDirection.ltr,
    }) {
      return MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: textDirection,
          child: Scaffold(
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              destinationLayout: destinationLayout,
              labelBehavior: labelBehavior,
              overlayColor: overlayColor,
              onDestinationSelected: onDestinationSelected ?? (int index) {},
              destinations: destinations,
            ),
          ),
        ),
      );
    }

    // The bounds of the indicator of the destination at the given index.
    //
    // The bounds don't include the scale transform that hides the indicator of
    // unselected destinations.
    Rect indicatorRect(WidgetTester tester, int index) {
      return tester.getRect(find.byType(NavigationIndicator).at(index));
    }

    // Whether the label is fully visible, that is, it isn't faded out by the
    // label behavior.
    bool isLabelVisible(WidgetTester tester, String label) {
      return tester
          .widgetList<FadeTransition>(
            find.ancestor(of: find.text(label), matching: find.byType(FadeTransition)),
          )
          .every((FadeTransition transition) => transition.opacity.value == 1.0);
    }

    RenderObject inkFeatures(WidgetTester tester) {
      return tester.allRenderObjects.firstWhere(
        (RenderObject object) => object.runtimeType.toString() == '_RenderInkFeatures',
      );
    }

    // Expects the label to use the font of TextTheme.labelMedium.
    //
    // The text geometry, such as the font size, is only added to the theme by
    // Theme.of, so the expected style comes from the theme in the tree.
    void expectLabelMediumFont(WidgetTester tester, String label) {
      final TextStyle labelMedium = Theme.of(tester.element(find.byType(NavigationBar)))
          .textTheme
          .labelMedium!;
      final TextStyle style = _getLabelStyle(tester, label);
      expect(style.fontSize, labelMedium.fontSize);
      expect(style.height, labelMedium.height);
      expect(style.fontWeight, labelMedium.fontWeight);
      expect(style.letterSpacing, labelMedium.letterSpacing);
    }

    testWidgets('NavigationBar uses the Material 3 Expressive defaults', (
      WidgetTester tester,
    ) async {
      final ThemeData theme = m3eTheme();
      final ColorScheme colors = theme.colorScheme;
      await tester.pumpWidget(buildNavigationBar(theme: theme));

      final Material material = _getMaterial(tester);
      expect(material.color, colors.surfaceContainer);
      expect(material.elevation, 3);
      expect(material.shadowColor, colors.shadow);
      expect(material.surfaceTintColor, Colors.transparent);
      expect(tester.getSize(find.byType(NavigationBar)).height, 64);

      expect(_getIndicatorDecoration(tester)?.color, colors.secondaryContainer);
      expect(_getIndicatorDecoration(tester)?.shape, const StadiumBorder());
      for (var i = 0; i < destinations.length; i++) {
        expect(indicatorRect(tester, i).size, const Size(56, 32));
      }

      // The first destination is selected, and the last one is disabled.
      expect(_getIconStyle(tester, Icons.home).color, colors.onSecondaryContainer);
      expect(_getIconStyle(tester, Icons.search).color, colors.onSurfaceVariant);
      expect(
        _getIconStyle(tester, Icons.settings).color,
        colors.onSurfaceVariant.withValues(alpha: 0.38),
      );
      for (final icon in icons) {
        expect(_getIconStyle(tester, icon).fontSize, 24);
      }

      expect(_getLabelStyle(tester, 'Home').color, colors.secondary);
      expect(_getLabelStyle(tester, 'Search').color, colors.onSurfaceVariant);
      expect(
        _getLabelStyle(tester, 'Settings').color,
        colors.onSurfaceVariant.withValues(alpha: 0.38),
      );
      for (final label in labels) {
        expectLabelMediumFont(tester, label);
        expect(_getLabelPadding(tester, label), const EdgeInsets.only(top: 4));
        expect(isLabelVisible(tester, label), isTrue);
      }
    });

    testWidgets('NavigationBar uses the Material 3 Expressive overlay colors', (
      WidgetTester tester,
    ) async {
      tester.binding.focusManager.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      final ThemeData theme = m3eTheme();
      final Color stateLayerColor = theme.colorScheme.onSecondaryContainer;
      await tester.pumpWidget(buildNavigationBar(theme: theme));

      // The first destination is selected, and the second one isn't.
      for (final index in <int>[0, 1]) {
        final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: tester.getCenter(find.byIcon(icons[index])));
        await tester.pumpAndSettle();
        expect(
          inkFeatures(tester),
          paints..circle(color: stateLayerColor.withValues(alpha: 0.08)),
          reason: 'Hovered destination $index',
        );

        await gesture.down(tester.getCenter(find.byIcon(icons[index])));
        await tester.pumpAndSettle();
        expect(
          inkFeatures(tester),
          paints
            ..circle()
            ..circle(color: stateLayerColor.withValues(alpha: 0.1)),
          reason: 'Pressed destination $index',
        );

        await gesture.up();
        await gesture.removePointer();
        await tester.pumpAndSettle();
      }

      // Press tab to focus the first destination.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        inkFeatures(tester),
        paints..circle(color: stateLayerColor.withValues(alpha: 0.1)),
        reason: 'Focused destination',
      );
    });

    testWidgets('The overlay color of the selected destination is resolved with selected', (
      WidgetTester tester,
    ) async {
      const selectedColor = Color(0xffff0000);
      const unselectedColor = Color(0xff0000ff);
      final overlayColor = WidgetStateProperty<Color?>.fromMap(<WidgetStatesConstraint, Color?>{
        WidgetState.selected & WidgetState.hovered: selectedColor,
        WidgetState.hovered: unselectedColor,
      });

      Future<void> expectHoverColor(int index, Color color) async {
        final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: tester.getCenter(find.byIcon(icons[index])));
        await tester.pumpAndSettle();
        expect(inkFeatures(tester), paints..circle(color: color));
        await gesture.removePointer();
        await tester.pumpAndSettle();
      }

      final ThemeData theme = m3eTheme();
      await tester.pumpWidget(buildNavigationBar(theme: theme, overlayColor: overlayColor));
      await expectHoverColor(0, selectedColor);
      await expectHoverColor(1, unselectedColor);

      // With the Material 3 style, the states don't include selected.
      final m3Theme = ThemeData();
      await tester.pumpWidget(buildNavigationBar(theme: m3Theme, overlayColor: overlayColor));
      await tester.pumpAndSettle();
      await expectHoverColor(0, unselectedColor);
      await expectHoverColor(1, unselectedColor);
    });

    testWidgets('Vertical destinations share the width of the navigation bar', (
      WidgetTester tester,
    ) async {
      final ThemeData theme = m3eTheme();
      await tester.pumpWidget(buildNavigationBar(theme: theme));

      final Rect bar = tester.getRect(find.byType(NavigationBar));
      for (var i = 0; i < destinations.length; i++) {
        final Rect destination = tester.getRect(find.byKey(keys[i]));
        final Rect indicator = indicatorRect(tester, i);
        final Rect icon = tester.getRect(find.byIcon(icons[i]));
        final Rect label = tester.getRect(find.text(labels[i]));

        expect(destination.width, moreOrLessEquals(bar.width / destinations.length));
        expect(destination.left, moreOrLessEquals(bar.left + i * bar.width / destinations.length));
        expect(destination.height, 64);

        // The icon is centered in the indicator, and the label is 4 pixels
        // below the indicator.
        expect(indicator.size, const Size(56, 32));
        expect(indicator.center.dx, moreOrLessEquals(destination.center.dx));
        expect(icon.center, offsetMoreOrLessEquals(indicator.center));
        expect(label.top, moreOrLessEquals(indicator.bottom + 4));
        expect(label.center.dx, moreOrLessEquals(destination.center.dx));

        // The indicator and the label are centered vertically.
        expect(indicator.top - bar.top, moreOrLessEquals(bar.bottom - label.bottom));
      }
    });

    testWidgets('Horizontal destinations are as wide as their content and centered', (
      WidgetTester tester,
    ) async {
      final ThemeData theme = m3eTheme();
      await tester.pumpWidget(
        buildNavigationBar(theme: theme, destinationLayout: NavigationDestinationLayout.horizontal),
      );

      final Rect bar = tester.getRect(find.byType(NavigationBar));
      expect(bar.height, 64);

      for (var i = 0; i < destinations.length; i++) {
        final Rect destination = tester.getRect(find.byKey(keys[i]));
        final Rect indicator = indicatorRect(tester, i);
        final Rect icon = tester.getRect(find.byIcon(icons[i]));
        final Rect label = tester.getRect(find.text(labels[i]));

        // The destination is as wide as its indicator, which is 40 pixels
        // tall and centered vertically in the navigation bar.
        expect(destination.width, moreOrLessEquals(indicator.width));
        expect(destination.left, moreOrLessEquals(indicator.left));
        expect(destination.height, 64);
        expect(indicator.height, 40);
        expect(indicator.center.dy, moreOrLessEquals(bar.center.dy));

        // The icon is at the start of the indicator, and the label is next to
        // it. Both are centered vertically.
        expect(icon.left, moreOrLessEquals(indicator.left + 16));
        expect(label.left, moreOrLessEquals(icon.right + 4));
        expect(label.right, moreOrLessEquals(indicator.right - 16));
        expect(icon.center.dy, moreOrLessEquals(indicator.center.dy));
        expect(label.center.dy, moreOrLessEquals(indicator.center.dy));

        if (i > 0) {
          expect(destination.left, moreOrLessEquals(tester.getRect(find.byKey(keys[i - 1])).right));
        }
      }

      // The destinations are centered as a group, with the extra space at both
      // ends of the navigation bar.
      final Rect first = tester.getRect(find.byKey(keys.first));
      final Rect last = tester.getRect(find.byKey(keys.last));
      expect(first.left - bar.left, greaterThan(0));
      expect(first.left - bar.left, moreOrLessEquals(bar.right - last.right));
    });

    testWidgets('Horizontal destinations use the Material 3 Expressive defaults', (
      WidgetTester tester,
    ) async {
      final ThemeData theme = m3eTheme(destinationLayout: NavigationDestinationLayout.horizontal);
      final ColorScheme colors = theme.colorScheme;
      await tester.pumpWidget(buildNavigationBar(theme: theme));

      final Material material = _getMaterial(tester);
      expect(material.color, colors.surfaceContainer);
      expect(material.elevation, 3);
      expect(material.shadowColor, colors.shadow);
      expect(tester.getSize(find.byType(NavigationBar)).height, 64);
      expect(_getIndicatorDecoration(tester)?.color, colors.secondaryContainer);
      expect(_getIndicatorDecoration(tester)?.shape, const StadiumBorder());

      expect(_getIconStyle(tester, Icons.home).color, colors.onSecondaryContainer);
      expect(_getIconStyle(tester, Icons.search).color, colors.onSurfaceVariant);
      expect(
        _getIconStyle(tester, Icons.settings).color,
        colors.onSurfaceVariant.withValues(alpha: 0.38),
      );

      expect(_getLabelStyle(tester, 'Home').color, colors.secondary);
      expect(_getLabelStyle(tester, 'Search').color, colors.onSurfaceVariant);
      expect(
        _getLabelStyle(tester, 'Settings').color,
        colors.onSurfaceVariant.withValues(alpha: 0.38),
      );
      for (final label in labels) {
        expectLabelMediumFont(tester, label);
        expect(_getLabelPadding(tester, label), const EdgeInsetsDirectional.only(start: 4));
      }
    });

    testWidgets('The ink of horizontal destinations fills the indicator', (
      WidgetTester tester,
    ) async {
      final ThemeData theme = m3eTheme();
      await tester.pumpWidget(
        buildNavigationBar(theme: theme, destinationLayout: NavigationDestinationLayout.horizontal),
      );

      final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: tester.getCenter(find.text('Search')));
      await tester.pumpAndSettle();

      // The ink is painted in the coordinates of the navigation bar's Material.
      final Offset barOrigin = tester.getTopLeft(find.byType(NavigationBar));
      final Rect indicator = indicatorRect(tester, 1).shift(-barOrigin);
      expect(
        inkFeatures(tester),
        paints
          ..clipPath(
            pathMatcher: isPathThat(
              includes: <Offset>[
                indicator.center,
                indicator.centerLeft + const Offset(1, 0),
                indicator.centerRight - const Offset(1, 0),
                indicator.topCenter + const Offset(0, 1),
                indicator.bottomCenter - const Offset(0, 1),
              ],
              excludes: <Offset>[
                indicator.centerLeft - const Offset(1, 0),
                indicator.centerRight + const Offset(1, 0),
                indicator.topCenter - const Offset(0, 1),
                indicator.bottomCenter + const Offset(0, 1),
                // The corners are rounded.
                indicator.topLeft + const Offset(1, 1),
                indicator.bottomRight - const Offset(1, 1),
              ],
            ),
          )
          ..rect(
            rect: indicator,
            color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.08),
          ),
      );
    });

    testWidgets('Horizontal destinations always show their labels', (WidgetTester tester) async {
      final ThemeData theme = m3eTheme();
      for (final NavigationDestinationLabelBehavior labelBehavior
          in NavigationDestinationLabelBehavior.values) {
        await tester.pumpWidget(
          buildNavigationBar(
            theme: theme,
            destinationLayout: NavigationDestinationLayout.horizontal,
            labelBehavior: labelBehavior,
          ),
        );
        await tester.pumpAndSettle();

        for (var i = 0; i < destinations.length; i++) {
          expect(isLabelVisible(tester, labels[i]), isTrue, reason: '$labelBehavior');
          expect(
            tester.getRect(find.text(labels[i])).left,
            greaterThan(tester.getRect(find.byIcon(icons[i])).right),
            reason: '$labelBehavior',
          );
        }
      }

      // The label behavior is used when the destinations are laid out
      // vertically.
      await tester.pumpWidget(
        buildNavigationBar(
          theme: theme,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        ),
      );
      await tester.pumpAndSettle();
      for (final label in labels) {
        expect(isLabelVisible(tester, label), isFalse);
      }
    });

    testWidgets('Horizontal destinations can be selected', (WidgetTester tester) async {
      var selectedIndex = 0;
      final ThemeData theme = m3eTheme();
      await tester.pumpWidget(
        buildNavigationBar(
          theme: theme,
          destinationLayout: NavigationDestinationLayout.horizontal,
          onDestinationSelected: (int index) => selectedIndex = index,
        ),
      );

      await tester.tap(find.text('Search'));
      expect(selectedIndex, 1);
      await tester.tap(find.byIcon(Icons.home));
      expect(selectedIndex, 0);
      // The last destination is disabled.
      await tester.tap(find.text('Settings'));
      expect(selectedIndex, 0);
    });

    testWidgets('Horizontal destinations support right-to-left', (WidgetTester tester) async {
      final ThemeData theme = m3eTheme();
      await tester.pumpWidget(
        buildNavigationBar(
          theme: theme,
          destinationLayout: NavigationDestinationLayout.horizontal,
          textDirection: TextDirection.rtl,
        ),
      );

      final Rect bar = tester.getRect(find.byType(NavigationBar));
      for (var i = 0; i < destinations.length; i++) {
        final Rect destination = tester.getRect(find.byKey(keys[i]));
        final Rect indicator = indicatorRect(tester, i);
        final Rect icon = tester.getRect(find.byIcon(icons[i]));
        final Rect label = tester.getRect(find.text(labels[i]));

        // The icon is at the start, which is the right side, of the indicator.
        expect(destination.width, moreOrLessEquals(indicator.width));
        expect(icon.right, moreOrLessEquals(indicator.right - 16));
        expect(label.right, moreOrLessEquals(icon.left - 4));
        expect(label.left, moreOrLessEquals(indicator.left + 16));

        // The first destination is on the right.
        if (i > 0) {
          expect(destination.right, moreOrLessEquals(tester.getRect(find.byKey(keys[i - 1])).left));
        }
      }

      final Rect first = tester.getRect(find.byKey(keys.first));
      final Rect last = tester.getRect(find.byKey(keys.last));
      expect(bar.right - first.right, moreOrLessEquals(last.left - bar.left));
    });

    testWidgets('Horizontal destinations shrink to fit a narrow navigation bar', (
      WidgetTester tester,
    ) async {
      final ThemeData theme = m3eTheme();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            bottomNavigationBar: Center(
              child: SizedBox(
                width: 360,
                child: NavigationBar(
                  destinationLayout: NavigationDestinationLayout.horizontal,
                  destinations: const <Widget>[
                    NavigationDestination(icon: Icon(Icons.home), label: 'Home sweet home'),
                    NavigationDestination(icon: Icon(Icons.search), label: 'Search everything'),
                    NavigationDestination(icon: Icon(Icons.settings), label: 'All the settings'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final Rect bar = tester.getRect(find.byType(NavigationBar));
      for (var i = 0; i < 3; i++) {
        final Rect destination = tester.getRect(find.byType(NavigationDestination).at(i));
        expect(destination.left, greaterThanOrEqualTo(bar.left));
        expect(destination.right, lessThanOrEqualTo(bar.right));
        expect(destination.width, lessThanOrEqualTo(bar.width / 3));
      }
    });

    testWidgets('Horizontal destinations do not crash at zero area', (WidgetTester tester) async {
      final ThemeData theme = m3eTheme();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Center(
            child: SizedBox.shrink(
              child: NavigationBar(
                destinationLayout: NavigationDestinationLayout.horizontal,
                destinations: destinations,
              ),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(NavigationBar)), Size.zero);
    });

    testWidgets('Badges stay on the icon of horizontal destinations', (WidgetTester tester) async {
      final ThemeData theme = m3eTheme(destinationLayout: NavigationDestinationLayout.horizontal);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            bottomNavigationBar: NavigationBar(
              destinations: const <Widget>[
                NavigationDestination(
                  icon: Badge(label: Text('3'), child: Icon(Icons.mail)),
                  label: 'Mail',
                ),
                NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
              ],
            ),
          ),
        ),
      );

      final Rect icon = tester.getRect(find.byIcon(Icons.mail));
      final Rect badgeLabel = tester.getRect(find.text('3'));
      final Rect label = tester.getRect(find.text('Mail'));
      // The badge is at the top end of the icon, and the label is next to the
      // icon.
      expect(badgeLabel.center.dx, greaterThan(icon.center.dx));
      expect(badgeLabel.center.dy, lessThan(icon.center.dy));
      expect(tester.getRect(find.byType(Badge)), icon);
      expect(label.left, moreOrLessEquals(icon.right + 4));
    });

    testWidgets('NavigationBar.destinationLayout overrides the theme', (WidgetTester tester) async {
      // The theme lays out the destinations horizontally.
      ThemeData theme = m3eTheme(destinationLayout: NavigationDestinationLayout.horizontal);
      await tester.pumpWidget(buildNavigationBar(theme: theme));
      expect(indicatorRect(tester, 0).height, 40);
      expect(
        tester.getRect(find.text('Home')).left,
        greaterThan(tester.getRect(find.byIcon(Icons.home)).right),
      );

      await tester.pumpWidget(
        buildNavigationBar(theme: theme, destinationLayout: NavigationDestinationLayout.vertical),
      );
      expect(indicatorRect(tester, 0).size, const Size(56, 32));
      expect(
        tester.getRect(find.text('Home')).top,
        greaterThan(tester.getRect(find.byIcon(Icons.home)).bottom),
      );

      // The theme lays out the destinations vertically.
      theme = m3eTheme(destinationLayout: NavigationDestinationLayout.vertical);
      await tester.pumpWidget(
        buildNavigationBar(theme: theme, destinationLayout: NavigationDestinationLayout.horizontal),
      );
      await tester.pumpAndSettle();
      expect(indicatorRect(tester, 0).height, 40);
      expect(
        tester.getRect(find.text('Home')).left,
        greaterThan(tester.getRect(find.byIcon(Icons.home)).right),
      );
    });

    testWidgets('The horizontal layout is ignored without the Material 3 Expressive style', (
      WidgetTester tester,
    ) async {
      final materialThemes = <ThemeData>[
        ThemeData(),
        ThemeData(
          navigationBarTheme: const NavigationBarThemeData(variant: StyleVariant.material3),
        ),
        // Material 2 ignores the variant.
        ThemeData(
          useMaterial3: false,
          navigationBarTheme: const NavigationBarThemeData(
            variant: StyleVariant.material3Expressive,
          ),
        ),
      ];
      for (final theme in materialThemes) {
        await tester.pumpWidget(
          buildNavigationBar(
            theme: theme,
            destinationLayout: NavigationDestinationLayout.horizontal,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          ),
        );
        await tester.pumpAndSettle();

        final reason = 'useMaterial3: ${theme.useMaterial3}';
        expect(tester.getSize(find.byType(NavigationBar)).height, 80, reason: reason);
        expect(indicatorRect(tester, 0).size, const Size(64, 32), reason: reason);
        expect(
          tester.getRect(find.text('Home')).top,
          greaterThan(tester.getRect(find.byIcon(Icons.home)).bottom),
          reason: reason,
        );
        // The label behavior isn't ignored.
        expect(isLabelVisible(tester, 'Home'), isTrue, reason: reason);
        expect(isLabelVisible(tester, 'Search'), isFalse, reason: reason);
      }
    });

    testWidgets('A nested NavigationBarTheme without a variant keeps Material 3 Expressive', (
      WidgetTester tester,
    ) async {
      final ThemeData theme = m3eTheme();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            bottomNavigationBar: NavigationBarTheme(
              data: const NavigationBarThemeData(
                destinationLayout: NavigationDestinationLayout.horizontal,
              ),
              child: NavigationBar(destinations: destinations),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(NavigationBar)).height, 64);
      expect(indicatorRect(tester, 0).height, 40);
      expect(_getLabelStyle(tester, 'Home').color, theme.colorScheme.secondary);
    });

    testWidgets('Material 3 NavigationBar keeps the Material 3 defaults', (
      WidgetTester tester,
    ) async {
      final theme = ThemeData(
        navigationBarTheme: const NavigationBarThemeData(variant: StyleVariant.material3),
      );
      final ColorScheme colors = theme.colorScheme;
      await tester.pumpWidget(buildNavigationBar(theme: theme));

      final Material material = _getMaterial(tester);
      expect(material.color, colors.surfaceContainer);
      expect(material.elevation, 3);
      expect(material.shadowColor, Colors.transparent);
      expect(tester.getSize(find.byType(NavigationBar)).height, 80);
      expect(indicatorRect(tester, 0).size, const Size(64, 32));
      expect(_getLabelStyle(tester, 'Home').color, colors.onSurface);
      expect(_getLabelStyle(tester, 'Search').color, colors.onSurfaceVariant);
      expect(_getLabelPadding(tester, 'Home'), const EdgeInsets.only(top: 4));
    });
  });
}

Widget _buildWidget(Widget child, {bool? useMaterial3}) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: useMaterial3),
    home: Scaffold(bottomNavigationBar: Center(child: child)),
  );
}

Material _getMaterial(WidgetTester tester) {
  return tester.firstWidget<Material>(
    find.descendant(of: find.byType(NavigationBar), matching: find.byType(Material)),
  );
}

ShapeDecoration? _getIndicatorDecoration(WidgetTester tester) {
  return tester
          .firstWidget<Ink>(
            find.descendant(of: find.byType(FadeTransition), matching: find.byType(Ink)),
          )
          .decoration
      as ShapeDecoration?;
}

class IconWithRandomColor extends StatelessWidget {
  const IconWithRandomColor({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final Color randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt())
        .withValues(alpha: 1.0);
    return Icon(icon, color: randomColor);
  }
}

bool _sizeAlmostEqual(Size a, Size b, {double maxDiff = 0.05}) {
  return (a.width - b.width).abs() <= maxDiff && (a.height - b.height).abs() <= maxDiff;
}

EdgeInsetsGeometry _getLabelPadding(WidgetTester tester, String text) {
  return tester
      .widget<Padding>(find.ancestor(of: find.text(text), matching: find.byType(Padding)).first)
      .padding;
}

TextStyle _getLabelStyle(WidgetTester tester, String text) {
  return tester
      .widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)))
      .text
      .style!;
}

TextStyle _getIconStyle(WidgetTester tester, IconData icon) {
  return tester
      .widget<RichText>(find.descendant(of: find.byIcon(icon), matching: find.byType(RichText)))
      .text
      .style!;
}
