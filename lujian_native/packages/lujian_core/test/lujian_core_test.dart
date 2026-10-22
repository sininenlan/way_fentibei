import 'package:lujian_core/lujian_core.dart';
import 'package:test/test.dart';

void main() {
  test('dispatch creates an assigned work order', () {
    final store = LujianStore();
    final defect = store.priorityQueue.first;
    store.dispatch(
      defectId: defect.id,
      workerId: 'w-01',
      priority: '高',
      note: 'test',
    );
    final order = store.orderForDefect(defect.id);
    expect(order, isNotNull);
    expect(order!.workerId, 'w-01');
    expect(defect.status, DefectStatus.dispatched);
  });
}
