import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lujian_control_console/console_app.dart';

void main() {
  testWidgets('control console renders native dashboard', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const LujianControlApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('道路数字孪生控制台'), findsOneWidget);
    expect(find.text('道路空间孪生'), findsOneWidget);
    expect(find.text('优先研判'), findsOneWidget);
  });

  testWidgets('service page renders four-party cooperation model', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1180, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const LujianControlApp());
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('合作服务'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('一套平台，连接养护、车企、科研与采集伙伴'), findsOneWidget);
    expect(find.text('数据授权与合规'), findsOneWidget);
    expect(find.text('合作准备状态'), findsOneWidget);
    expect(find.text('POST /api/v1/detections'), findsOneWidget);
  });
}
