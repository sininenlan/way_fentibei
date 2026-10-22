enum DefectSeverity { high, medium, low }

enum DefectStatus {
  pendingReview,
  awaitingDispatch,
  dispatched,
  inProgress,
  completed,
  observing,
}

enum WorkOrderStatus { assigned, inProgress, completed }

class Defect {
  Defect({
    required this.id,
    required this.type,
    required this.typeCode,
    required this.severity,
    required this.roadCode,
    required this.roadName,
    required this.latitude,
    required this.longitude,
    required this.mileage,
    required this.lane,
    required this.terminalCount,
    required this.confidence,
    required this.status,
    required this.recommendationScore,
    required this.recommendationAction,
    required this.recommendationReason,
    required this.lastSeen,
    required this.lengthCm,
    required this.widthCm,
  });

  final String id;
  final String type;
  final String typeCode;
  final DefectSeverity severity;
  final String roadCode;
  final String roadName;
  final double latitude;
  final double longitude;
  final String mileage;
  final String lane;
  final int terminalCount;
  final double confidence;
  DefectStatus status;
  final int recommendationScore;
  final String recommendationAction;
  final String recommendationReason;
  final DateTime lastSeen;
  final double lengthCm;
  final double widthCm;

  String get severityLabel => switch (severity) {
        DefectSeverity.high => '高风险',
        DefectSeverity.medium => '中风险',
        DefectSeverity.low => '低风险',
      };

  String get statusLabel => switch (status) {
        DefectStatus.pendingReview => '待复核',
        DefectStatus.awaitingDispatch => '待研判',
        DefectStatus.dispatched => '已派发',
        DefectStatus.inProgress => '处置中',
        DefectStatus.completed => '已完成',
        DefectStatus.observing => '观察中',
      };

  String get coordinateLabel =>
      '${latitude.toStringAsFixed(6)}° N\n${longitude.toStringAsFixed(6)}° E';
}

class Worker {
  const Worker({
    required this.id,
    required this.name,
    required this.team,
    required this.phone,
  });

  final String id;
  final String name;
  final String team;
  final String phone;
}

class WorkOrder {
  WorkOrder({
    required this.id,
    required this.defectId,
    required this.workerId,
    required this.priority,
    required this.note,
    required this.createdAt,
    required this.dueAt,
    this.status = WorkOrderStatus.assigned,
    this.completedAt,
  });

  final String id;
  final String defectId;
  final String workerId;
  final String priority;
  final String note;
  final DateTime createdAt;
  final DateTime dueAt;
  WorkOrderStatus status;
  DateTime? completedAt;

  String get statusLabel => switch (status) {
        WorkOrderStatus.assigned => '待接单',
        WorkOrderStatus.inProgress => '处置中',
        WorkOrderStatus.completed => '已完成',
      };
}

class WorkspaceSummary {
  const WorkspaceSummary({
    required this.monitoredKm,
    required this.activeTerminals,
    required this.totalTerminals,
    required this.pendingCount,
    required this.highRiskCount,
    required this.openOrderCount,
  });

  final double monitoredKm;
  final int activeTerminals;
  final int totalTerminals;
  final int pendingCount;
  final int highRiskCount;
  final int openOrderCount;
}
