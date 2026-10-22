import 'package:flutter_test/flutter_test.dart';
import 'package:lujian_workorder/main.dart';

void main() {
  testWidgets('work-order app renders task list', (tester) async {
    await tester.pumpWidget(const LujianWorkorderApp());
    await tester.pumpAndSettle();
    expect(find.text('路鉴智巡'), findsOneWidget);
    expect(find.text('我的工单'), findsOneWidget);
    expect(find.text('坑槽'), findsWidgets);
  });
}
