import 'models.dart';

class LujianStore {
  LujianStore()
      : workers = demoWorkers(),
        defects = demoDefects(),
        orders = demoOrders();

  final List<Worker> workers;
  final List<Defect> defects;
  final List<WorkOrder> orders;

  WorkspaceSummary get summary => WorkspaceSummary(
        monitoredKm: 126.4,
        activeTerminals: 4,
        totalTerminals: 6,
        pendingCount: defects
            .where((defect) => [
                  DefectStatus.pendingReview,
                  DefectStatus.awaitingDispatch,
                ].contains(defect.status))
            .length,
        highRiskCount: defects
            .where((defect) =>
                defect.severity == DefectSeverity.high &&
                defect.status != DefectStatus.completed)
            .length,
        openOrderCount: orders
            .where((order) => order.status != WorkOrderStatus.completed)
            .length,
      );

  List<Defect> get priorityQueue {
    final queue = defects
        .where((defect) => [
              DefectStatus.pendingReview,
              DefectStatus.awaitingDispatch,
            ].contains(defect.status))
        .toList();
    queue.sort(
      (a, b) => b.recommendationScore.compareTo(a.recommendationScore),
    );
    return queue;
  }

  WorkOrder? orderForDefect(String defectId) {
    for (final order in orders) {
      if (order.defectId == defectId) return order;
    }
    return null;
  }

  Worker workerFor(String workerId) =>
      workers.firstWhere((worker) => worker.id == workerId);

  void dispatch({
    required String defectId,
    required String workerId,
    required String priority,
    required String note,
  }) {
    final defect = defects.firstWhere((item) => item.id == defectId);
    final now = DateTime(2026, 10, 21, 11, 20);
    orders.insert(
      0,
      WorkOrder(
        id: 'WO-20261021-${(orders.length + 19).toString().padLeft(3, '0')}',
        defectId: defectId,
        workerId: workerId,
        priority: priority,
        note: note,
        createdAt: now,
        dueAt: now.add(const Duration(hours: 6)),
      ),
    );
    defect.status = DefectStatus.dispatched;
  }

  void updateOrder(String orderId, WorkOrderStatus status) {
    final order = orders.firstWhere((item) => item.id == orderId);
    final defect = defects.firstWhere((item) => item.id == order.defectId);
    order.status = status;
    if (status == WorkOrderStatus.completed) {
      order.completedAt = DateTime(2026, 10, 21, 11, 28);
      defect.status = DefectStatus.completed;
    } else {
      defect.status = DefectStatus.inProgress;
    }
  }

  void observe(String defectId) {
    defects
        .firstWhere((defect) => defect.id == defectId)
        .status = DefectStatus.observing;
  }
}

List<Worker> demoWorkers() => const [
      Worker(id: 'w-01', name: '王磊', team: '城东养护一班', phone: '138****2026'),
      Worker(id: 'w-02', name: '赵晨', team: '城北养护二班', phone: '139****1180'),
      Worker(id: 'w-03', name: '李建军', team: '灞桥作业组', phone: '136****6912'),
    ];

List<Defect> demoDefects() => [
      Defect(
        id: 'DEF-20261021-014',
        type: '横向裂缝',
        typeCode: 'D10',
        severity: DefectSeverity.high,
        roadCode: 'G312-K1082+350',
        roadName: 'G312 沪霍线 · 灞桥段',
        latitude: 34.27386,
        longitude: 109.06421,
        mileage: 'K1082+350',
        lane: '上行 · 第2车道',
        terminalCount: 6,
        confidence: 0.93,
        status: DefectStatus.awaitingDispatch,
        recommendationScore: 92,
        recommendationAction: '建议派发',
        recommendationReason: '高风险、6个终端重复捕获，位于重载货车通行路段，建议当日派发。',
        lastSeen: DateTime(2026, 10, 21, 10, 46),
        lengthCm: 142,
        widthCm: 8.5,
      ),
      Defect(
        id: 'DEF-20261021-010',
        type: '坑槽',
        typeCode: 'D40',
        severity: DefectSeverity.high,
        roadCode: 'XA-BY-002-K7+120',
        roadName: '未央区县道 002 · 汉城段',
        latitude: 34.28991,
        longitude: 109.03914,
        mileage: 'K7+120',
        lane: '双向 · 右侧车道',
        terminalCount: 7,
        confidence: 0.95,
        status: DefectStatus.dispatched,
        recommendationScore: 96,
        recommendationAction: '立即派发',
        recommendationReason: '7次重复捕获且面积持续扩大，建议立即设置警示并派发。',
        lastSeen: DateTime(2026, 10, 21, 10, 6),
        lengthCm: 114,
        widthCm: 83,
      ),
      Defect(
        id: 'DEF-20261021-013',
        type: '坑槽',
        typeCode: 'D40',
        severity: DefectSeverity.high,
        roadCode: 'XA-CB-007-K3+260',
        roadName: '灞桥区乡道 007 · 席王段',
        latitude: 34.28142,
        longitude: 109.05277,
        mileage: 'K3+260',
        lane: '双向 · 右侧车道',
        terminalCount: 4,
        confidence: 0.90,
        status: DefectStatus.inProgress,
        recommendationScore: 87,
        recommendationAction: '建议派发',
        recommendationReason: '坑槽边缘存在扩展，建议设置临时警示并尽快修补。',
        lastSeen: DateTime(2026, 10, 21, 9, 52),
        lengthCm: 68,
        widthCm: 44,
      ),
      Defect(
        id: 'DEF-20261021-006',
        type: '龟裂',
        typeCode: 'D20',
        severity: DefectSeverity.high,
        roadCode: 'XA-BY-002-K8+050',
        roadName: '未央区县道 002 · 汉城段',
        latitude: 34.29276,
        longitude: 109.04584,
        mileage: 'K8+050',
        lane: '双向 · 右侧车道',
        terminalCount: 5,
        confidence: 0.91,
        status: DefectStatus.awaitingDispatch,
        recommendationScore: 89,
        recommendationAction: '建议派发',
        recommendationReason: '龟裂面积较大且5个终端重复捕获，建议评估基层含水量。',
        lastSeen: DateTime(2026, 10, 21, 9, 48),
        lengthCm: 188,
        widthCm: 126,
      ),
      Defect(
        id: 'DEF-20261021-008',
        type: '横向裂缝',
        typeCode: 'D10',
        severity: DefectSeverity.medium,
        roadCode: 'S107-K044+930',
        roadName: 'S107 关中环线 · 长安段',
        latitude: 34.25496,
        longitude: 109.07924,
        mileage: 'K44+930',
        lane: '下行 · 第2车道',
        terminalCount: 3,
        confidence: 0.88,
        status: DefectStatus.awaitingDispatch,
        recommendationScore: 73,
        recommendationAction: '建议派发',
        recommendationReason: '横缝贯穿右侧轮迹带，3个终端一致捕获，建议雨天前处理。',
        lastSeen: DateTime(2026, 10, 21, 10, 12),
        lengthCm: 286,
        widthCm: 6.4,
      ),
      Defect(
        id: 'DEF-20261021-011',
        type: '纵向裂缝',
        typeCode: 'D00',
        severity: DefectSeverity.medium,
        roadCode: 'G312-K1081+860',
        roadName: 'G312 沪霍线 · 灞桥段',
        latitude: 34.26925,
        longitude: 109.07458,
        mileage: 'K1081+860',
        lane: '上行 · 第1车道',
        terminalCount: 2,
        confidence: 0.82,
        status: DefectStatus.dispatched,
        recommendationScore: 61,
        recommendationAction: '纳入本周巡查',
        recommendationReason: '病害长度有限，暂未发现宽度扩展，建议纳入本周巡查。',
        lastSeen: DateTime(2026, 10, 21, 10, 34),
        lengthCm: 213,
        widthCm: 4.2,
      ),
      Defect(
        id: 'DEF-20261021-012',
        type: '龟裂',
        typeCode: 'D20',
        severity: DefectSeverity.medium,
        roadCode: 'S107-K045+780',
        roadName: 'S107 关中环线 · 长安段',
        latitude: 34.25867,
        longitude: 109.08311,
        mileage: 'K45+780',
        lane: '下行 · 第1车道',
        terminalCount: 3,
        confidence: 0.86,
        status: DefectStatus.pendingReview,
        recommendationScore: 68,
        recommendationAction: '建议复核',
        recommendationReason: '置信度较高但处于车道边缘，建议结合近景图像复核。',
        lastSeen: DateTime(2026, 10, 21, 10, 18),
        lengthCm: 95,
        widthCm: 72,
      ),
      Defect(
        id: 'DEF-20261021-009',
        type: '修补破损',
        typeCode: 'D44',
        severity: DefectSeverity.low,
        roadCode: 'XA-NH-011-K2+640',
        roadName: '长安区乡道 011 · 王曲段',
        latitude: 34.26561,
        longitude: 109.09512,
        mileage: 'K2+640',
        lane: '双向 · 中间',
        terminalCount: 1,
        confidence: 0.74,
        status: DefectStatus.observing,
        recommendationScore: 34,
        recommendationAction: '建议观察',
        recommendationReason: '单终端捕获且病害轻微，建议纳入日常巡查观察。',
        lastSeen: DateTime(2026, 10, 21, 10, 2),
        lengthCm: 46,
        widthCm: 35,
      ),
    ];

List<WorkOrder> demoOrders() => [
      WorkOrder(
        id: 'WO-20261021-018',
        defectId: 'DEF-20261021-013',
        workerId: 'w-01',
        priority: '高',
        note: '现场确认坑槽深度，先设置临时警示。',
        createdAt: DateTime(2026, 10, 21, 9, 26),
        dueAt: DateTime(2026, 10, 21, 16),
        status: WorkOrderStatus.inProgress,
      ),
      WorkOrder(
        id: 'WO-20261021-017',
        defectId: 'DEF-20261021-011',
        workerId: 'w-01',
        priority: '中',
        note: '现场确认裂缝是否贯穿轮迹带。',
        createdAt: DateTime(2026, 10, 21, 9, 32),
        dueAt: DateTime(2026, 10, 21, 14, 30),
      ),
      WorkOrder(
        id: 'WO-20261021-016',
        defectId: 'DEF-20261021-010',
        workerId: 'w-02',
        priority: '紧急',
        note: '坑槽持续扩展，优先处置。',
        createdAt: DateTime(2026, 10, 21, 8, 44),
        dueAt: DateTime(2026, 10, 21, 14),
      ),
    ];
