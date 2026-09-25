// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/cubic_struct.dart';
import '../data/motion_expressive.dart';
import '../data/motion_standard.dart';
import 'template.dart';

class MotionTemplateM3 extends TokenTemplateM3 {
  const MotionTemplateM3();

  @override
  String get name => 'Motion';

  @override
  String get parentFilePath => 'motion.dart';

  @override
  String get className => '';

  String _durationTokenString(String tokenName, Duration tokenValue) {
    final int milliseconds = tokenValue.inMilliseconds;
    return '''
  /// The $tokenName duration (${milliseconds}ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  static const Duration $tokenName = Duration(milliseconds: $milliseconds);
''';
  }

  String _easingCurveTokenString(String tokenName, Cubic tokenValue) =>
      '''
  /// The $tokenName easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  static const Curve $tokenName = Cubic(${number(tokenValue.a)}, ${number(tokenValue.b)}, ${number(tokenValue.c)}, ${number(tokenValue.d)});
''';

  @override
  String generateContents(String className) =>
      '''
/// The set of durations in the Material specification.
///
/// See also:
///
/// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
/// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
abstract final class Durations {
${_durationTokenString('short1', TokenMotionStandard.durationShort1)}
${_durationTokenString('short2', TokenMotionStandard.durationShort2)}
${_durationTokenString('short3', TokenMotionStandard.durationShort3)}
${_durationTokenString('short4', TokenMotionStandard.durationShort4)}
${_durationTokenString('medium1', TokenMotionStandard.durationMedium1)}
${_durationTokenString('medium2', TokenMotionStandard.durationMedium2)}
${_durationTokenString('medium3', TokenMotionStandard.durationMedium3)}
${_durationTokenString('medium4', TokenMotionStandard.durationMedium4)}
${_durationTokenString('long1', TokenMotionStandard.durationLong1)}
${_durationTokenString('long2', TokenMotionStandard.durationLong2)}
${_durationTokenString('long3', TokenMotionStandard.durationLong3)}
${_durationTokenString('long4', TokenMotionStandard.durationLong4)}
${_durationTokenString('extralong1', TokenMotionStandard.durationExtraLong1)}
${_durationTokenString('extralong2', TokenMotionStandard.durationExtraLong2)}
${_durationTokenString('extralong3', TokenMotionStandard.durationExtraLong3)}
${_durationTokenString('extralong4', TokenMotionStandard.durationExtraLong4)}}

// TODO(guidezpl): Improve with description and assets, b/289870605

/// The set of easing curves in the Material specification.
///
/// See also:
///
/// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
/// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
/// * [Curves], for a collection of non-Material animation easing curves.
abstract final class Easing {
${_easingCurveTokenString('emphasizedAccelerate', TokenMotionExpressive.easingEmphasizedAccelerate)}
${_easingCurveTokenString('emphasizedDecelerate', TokenMotionExpressive.easingEmphasizedDecelerate)}
${_easingCurveTokenString('linear', TokenMotionStandard.easingLinear)}
${_easingCurveTokenString('standard', TokenMotionStandard.easingStandard)}
${_easingCurveTokenString('standardAccelerate', TokenMotionStandard.easingStandardAccelerate)}
${_easingCurveTokenString('standardDecelerate', TokenMotionStandard.easingStandardDecelerate)}
${_easingCurveTokenString('legacyDecelerate', TokenMotionStandard.easingLegacyDecelerate)}
${_easingCurveTokenString('legacyAccelerate', TokenMotionStandard.easingLegacyAccelerate)}
${_easingCurveTokenString('legacy', TokenMotionStandard.easingLegacy)}}
''';
}
