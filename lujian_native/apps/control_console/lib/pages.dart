import 'package:flutter/material.dart';
import 'package:lujian_core/lujian_core.dart';

import 'common.dart';
import 'digital_twin.dart';
import 'theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.store,
    required this.selected,
    required this.onSelect,
    required this.onOpenDispatch,
  });

  final LujianStore store;
  final Defect? selected;
  final ValueChanged<Defect> onSelect;
  final VoidCallback onOpenDispatch;

  @override
  Widget build(BuildContext context) {
    final current =
        selected ??
        (store.priorityQueue.isEmpty ? null : store.priorityQueue.first);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
      child: Column(
        children: [
          _KpiStrip(summary: store.summary),
          const SizedBox(height: 14),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 7,
                  child: ConsolePanel(
                    child: Column(
                      children: [
                        const PanelHeading(
                          eyebrow: 'ROAD NETWORK / 3D',
                          title: '道路空间孪生',
                          trailing: [
                            Icon(Icons.sensors_rounded, size: 14, color: teal),
                            SizedBox(width: 5),
                            Text(
                              '6 台终端 · 4 在线',
                              style: TextStyle(color: muted, fontSize: 9),
                            ),
                          ],
                        ),
                        Expanded(
                          child: DigitalTwinView(
                            defects: store.defects,
                            selectedDefect: current,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 346,
                  child: Column(
                    children: [
                      Expanded(
                        child: ConsolePanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PanelHeading(
                                eyebrow: 'TRIAGE QUEUE',
                                title: '优先研判',
                                trailing: [
                                  CountBadge(value: store.priorityQueue.length),
                                ],
                              ),
                              Expanded(
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemCount: store.priorityQueue.length,
                                  separatorBuilder: (_, _) =>
                                      const Divider(height: 1, color: line),
                                  itemBuilder: (context, index) {
                                    final defect = store.priorityQueue[index];
                                    return QueueTile(
                                      defect: defect,
                                      selected: current?.id == defect.id,
                                      onTap: () => onSelect(defect),
                                    );
                                  },
                                ),
                              ),
                              InkWell(
                                onTap: onOpenDispatch,
                                child: Container(
                                  height: 38,
                                  decoration: const BoxDecoration(
                                    color: soft,
                                    border: Border(
                                      top: BorderSide(color: line),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '进入工单调度',
                                        style: TextStyle(
                                          color: ink2,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Icon(
                                        Icons.arrow_outward_rounded,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _RecommendationPanel(
                        defect: current,
                        onDispatch: onOpenDispatch,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 208,
            child: ConsolePanel(
              child: Column(
                children: [
                  const PanelHeading(
                    eyebrow: 'LATEST EVENTS',
                    title: '最新病害事件',
                    trailing: [
                      Icon(Icons.sync_rounded, size: 14, color: muted),
                      SizedBox(width: 5),
                      Text('刚刚更新', style: TextStyle(color: muted, fontSize: 9)),
                    ],
                  ),
                  Expanded(
                    child: _RecentTable(
                      defects: store.defects,
                      onSelect: onSelect,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.summary});

  final WorkspaceSummary summary;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.route_rounded,
        '监测路段',
        summary.monitoredKm.toStringAsFixed(1),
        'km',
        '3 条示范路段',
        blue,
        blueSoft,
      ),
      (
        Icons.sensors_rounded,
        '在线终端',
        '${summary.activeTerminals}',
        '/ ${summary.totalTerminals}',
        '在线率 66.7%',
        teal,
        tealSoft,
      ),
      (
        Icons.warning_amber_rounded,
        '待研判病害',
        '${summary.pendingCount}',
        '处',
        '${summary.highRiskCount} 处高风险',
        red,
        redSoft,
      ),
      (
        Icons.assignment_late_outlined,
        '未闭环工单',
        '${summary.openOrderCount}',
        '单',
        '2 个班组执行',
        amber,
        amberSoft,
      ),
    ];
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: items[index].$7,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(
                        items[index].$1,
                        size: 19,
                        color: items[index].$6,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[index].$2,
                            style: const TextStyle(
                              color: muted,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: items[index].$3,
                                  style: const TextStyle(
                                    color: ink,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Consolas',
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${items[index].$4}',
                                  style: const TextStyle(
                                    color: muted,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            items[index].$5,
                            style: const TextStyle(color: muted, fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (index < items.length - 1)
              Container(width: 1, height: 50, color: line),
          ],
        ],
      ),
    );
  }
}

class _RecommendationPanel extends StatelessWidget {
  const _RecommendationPanel({required this.defect, required this.onDispatch});

  final Defect? defect;
  final VoidCallback onDispatch;

  @override
  Widget build(BuildContext context) {
    return ConsolePanel(
      padding: const EdgeInsets.all(14),
      child: defect == null
          ? const Text('当前无待研判病害')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: orange,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '系统研判',
                      style: TextStyle(
                        color: ink2,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${defect!.recommendationScore}',
                      style: const TextStyle(
                        color: orange,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Consolas',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  defect!.recommendationReason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF776353),
                    fontSize: 9,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onDispatch,
                    icon: const Icon(Icons.send_rounded, size: 15),
                    label: const Text('进入派发研判'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _RecentTable extends StatelessWidget {
  const _RecentTable({required this.defects, required this.onSelect});

  final List<Defect> defects;
  final ValueChanged<Defect> onSelect;

  @override
  Widget build(BuildContext context) {
    final sorted = [...defects]
      ..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 34,
          dataRowMinHeight: 38,
          dataRowMaxHeight: 42,
          horizontalMargin: 16,
          columnSpacing: 30,
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('病害与位置')),
            DataColumn(label: Text('道路编号')),
            DataColumn(label: Text('终端频次')),
            DataColumn(label: Text('置信度')),
            DataColumn(label: Text('风险')),
            DataColumn(label: Text('状态')),
            DataColumn(label: Text('')),
          ],
          rows: sorted.take(4).map((defect) {
            return DataRow(
              onSelectChanged: (_) => onSelect(defect),
              cells: [
                DataCell(
                  Row(
                    children: [
                      TypeGlyph(defect: defect),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            defect.type,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            defect.roadName,
                            style: const TextStyle(color: muted, fontSize: 8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    defect.roadCode,
                    style: const TextStyle(fontSize: 9, fontFamily: 'Consolas'),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      const Icon(Icons.sensors_rounded, size: 13),
                      const SizedBox(width: 4),
                      Text('${defect.terminalCount}'),
                    ],
                  ),
                ),
                DataCell(Text('${(defect.confidence * 100).round()}%')),
                DataCell(SeverityPill(severity: defect.severity)),
                DataCell(StatusPill(status: defect.status)),
                const DataCell(
                  Icon(Icons.arrow_outward_rounded, size: 15, color: muted),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class TwinPage extends StatelessWidget {
  const TwinPage({
    super.key,
    required this.store,
    required this.selected,
    required this.onSelect,
  });

  final LujianStore store;
  final Defect? selected;
  final ValueChanged<Defect> onSelect;

  @override
  Widget build(BuildContext context) {
    final current = selected ?? store.defects.first;
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ConsolePanel(
                    child: DigitalTwinView(
                      defects: store.defects,
                      selectedDefect: current,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 330,
                  child: ConsolePanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const PanelHeading(
                          eyebrow: 'SPATIAL ENTITIES',
                          title: '空间实体',
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: store.defects.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1, color: line),
                            itemBuilder: (context, index) {
                              final defect = store.defects[index];
                              return QueueTile(
                                defect: defect,
                                selected: defect.id == current.id,
                                onTap: () => onSelect(defect),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 112,
            child: Row(
              children: [
                _TwinMetric(
                  label: '当前病害',
                  value: current.type,
                  meta: current.roadCode,
                  icon: Icons.warning_amber_rounded,
                  color: red,
                ),
                const SizedBox(width: 12),
                _TwinMetric(
                  label: '多终端验证',
                  value: '${current.terminalCount} 个',
                  meta: '置信度 ${(current.confidence * 100).round()}%',
                  icon: Icons.sensors_rounded,
                  color: teal,
                ),
                const SizedBox(width: 12),
                _TwinMetric(
                  label: '空间坐标',
                  value: current.latitude.toStringAsFixed(5),
                  meta: current.longitude.toStringAsFixed(5),
                  icon: Icons.public_rounded,
                  color: blue,
                ),
                const SizedBox(width: 12),
                _TwinMetric(
                  label: '推断尺寸',
                  value:
                      '${current.lengthCm.round()} × ${current.widthCm.toStringAsFixed(1)}',
                  meta: '厘米 · 视觉估计',
                  icon: Icons.straighten_rounded,
                  color: amber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TwinMetric extends StatelessWidget {
  const _TwinMetric({
    required this.label,
    required this.value,
    required this.meta,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String meta;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ConsolePanel(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: muted, fontSize: 9),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    meta,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 8,
                      fontFamily: 'Consolas',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LedgerPage extends StatefulWidget {
  const LedgerPage({
    super.key,
    required this.store,
    required this.selected,
    required this.onSelect,
  });

  final LujianStore store;
  final Defect? selected;
  final ValueChanged<Defect> onSelect;

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  String query = '';
  String severity = '全部风险';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.store.defects.where((defect) {
      final queryMatch =
          query.isEmpty ||
          '${defect.type}${defect.roadCode}${defect.roadName}'
              .toLowerCase()
              .contains(query.toLowerCase());
      final severityMatch =
          severity == '全部风险' ||
          (severity == '高风险' && defect.severity == DefectSeverity.high) ||
          (severity == '中风险' && defect.severity == DefectSeverity.medium) ||
          (severity == '低风险' && defect.severity == DefectSeverity.low);
      return queryMatch && severityMatch;
    }).toList();
    return Padding(
      padding: const EdgeInsets.all(18),
      child: ConsolePanel(
        child: Column(
          children: [
            PanelHeading(
              eyebrow: 'DEFECT LEDGER',
              title: '病害台账 · ${filtered.length} 条',
              trailing: [
                SizedBox(
                  width: 250,
                  height: 34,
                  child: TextField(
                    onChanged: (value) => setState(() => query = value),
                    style: const TextStyle(fontSize: 10),
                    decoration: _inputDecoration(
                      hint: '搜索道路、编号或病害类型',
                      icon: Icons.search_rounded,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: severity,
                    style: const TextStyle(color: ink2, fontSize: 10),
                    items: const [
                      DropdownMenuItem(value: '全部风险', child: Text('全部风险')),
                      DropdownMenuItem(value: '高风险', child: Text('高风险')),
                      DropdownMenuItem(value: '中风险', child: Text('中风险')),
                      DropdownMenuItem(value: '低风险', child: Text('低风险')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => severity = value);
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowHeight: 38,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 54,
                  horizontalMargin: 16,
                  columnSpacing: 32,
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn(label: Text('病害与位置')),
                    DataColumn(label: Text('道路编号')),
                    DataColumn(label: Text('车道 / 桩号')),
                    DataColumn(label: Text('终端频次')),
                    DataColumn(label: Text('置信度')),
                    DataColumn(label: Text('风险')),
                    DataColumn(label: Text('状态')),
                    DataColumn(label: Text('研判分')),
                  ],
                  rows: filtered.map((defect) {
                    return DataRow(
                      selected: widget.selected?.id == defect.id,
                      onSelectChanged: (_) => widget.onSelect(defect),
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              TypeGlyph(defect: defect),
                              const SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    defect.type,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    defect.roadName,
                                    style: const TextStyle(
                                      color: muted,
                                      fontSize: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            defect.roadCode,
                            style: const TextStyle(
                              fontFamily: 'Consolas',
                              fontSize: 9,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${defect.lane}\n${defect.mileage}',
                            style: const TextStyle(fontSize: 8),
                          ),
                        ),
                        DataCell(Text('${defect.terminalCount} 个')),
                        DataCell(Text('${(defect.confidence * 100).round()}%')),
                        DataCell(SeverityPill(severity: defect.severity)),
                        DataCell(StatusPill(status: defect.status)),
                        DataCell(
                          Text(
                            '${defect.recommendationScore}',
                            style: const TextStyle(
                              color: orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Consolas',
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DispatchPage extends StatefulWidget {
  const DispatchPage({
    super.key,
    required this.store,
    required this.selected,
    required this.onSelect,
    required this.refresh,
  });

  final LujianStore store;
  final Defect? selected;
  final ValueChanged<Defect> onSelect;
  final void Function([VoidCallback?]) refresh;

  @override
  State<DispatchPage> createState() => _DispatchPageState();
}

class _DispatchPageState extends State<DispatchPage> {
  String workerId = 'w-01';
  String priority = '高';
  late final TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController(
      text: widget.selected?.recommendationReason ?? '现场确认病害范围后开展处置。',
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  void dispatch(Defect defect) {
    widget.store.dispatch(
      defectId: defect.id,
      workerId: workerId,
      priority: priority,
      note: noteController.text,
    );
    widget.refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('工单已派发 · ${defect.roadCode}'),
        behavior: SnackBarBehavior.floating,
        width: 360,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final queue = widget.store.priorityQueue;
    final selectedInQueue =
        widget.selected != null &&
        queue.any((defect) => defect.id == widget.selected!.id);
    final current = selectedInQueue
        ? widget.selected!
        : (queue.isEmpty ? null : queue.first);
    final existingOrder = current == null
        ? null
        : widget.store.orderForDefect(current.id);

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 340,
            child: ConsolePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PanelHeading(
                    eyebrow: 'TRIAGE QUEUE',
                    title: '待研判病害',
                    trailing: [CountBadge(value: queue.length)],
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: queue.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: line),
                      itemBuilder: (context, index) {
                        final defect = queue[index];
                        return QueueTile(
                          defect: defect,
                          selected: current?.id == defect.id,
                          onTap: () {
                            widget.onSelect(defect);
                            noteController.text = defect.recommendationReason;
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: current == null
                ? const ConsolePanel(child: Center(child: Text('当前没有待研判病害')))
                : Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ConsolePanel(
                                child: DigitalTwinView(
                                  defects: widget.store.defects,
                                  selectedDefect: current,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            SizedBox(
                              width: 370,
                              child: ConsolePanel(
                                padding: const EdgeInsets.all(16),
                                child: _DispatchForm(
                                  defect: current,
                                  workerId: workerId,
                                  priority: priority,
                                  noteController: noteController,
                                  workers: widget.store.workers,
                                  hasOrder: existingOrder != null,
                                  onWorkerChanged: (value) =>
                                      setState(() => workerId = value),
                                  onPriorityChanged: (value) =>
                                      setState(() => priority = value),
                                  onDispatch: () => dispatch(current),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 118,
                        child: ConsolePanel(
                          child: Row(
                            children: [
                              _EvidenceStep(
                                icon: Icons.center_focus_strong_rounded,
                                label: '模型识别',
                                value:
                                    '${current.typeCode} · ${(current.confidence * 100).round()}%',
                              ),
                              const _EvidenceArrow(),
                              _EvidenceStep(
                                icon: Icons.hub_outlined,
                                label: '多帧合并',
                                value: '${current.terminalCount} 个终端',
                              ),
                              const _EvidenceArrow(),
                              _EvidenceStep(
                                icon: Icons.pin_drop_outlined,
                                label: '路段匹配',
                                value: current.roadCode,
                              ),
                              const _EvidenceArrow(),
                              _EvidenceStep(
                                icon: Icons.fact_check_outlined,
                                label: '人工研判',
                                value: '${current.recommendationScore} 分',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _DispatchForm extends StatelessWidget {
  const _DispatchForm({
    required this.defect,
    required this.workerId,
    required this.priority,
    required this.noteController,
    required this.workers,
    required this.hasOrder,
    required this.onWorkerChanged,
    required this.onPriorityChanged,
    required this.onDispatch,
  });

  final Defect defect;
  final String workerId;
  final String priority;
  final TextEditingController noteController;
  final List<Worker> workers;
  final bool hasOrder;
  final ValueChanged<String> onWorkerChanged;
  final ValueChanged<String> onPriorityChanged;
  final VoidCallback onDispatch;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TypeGlyph(defect: defect),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      defect.id,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 8,
                        fontFamily: 'Consolas',
                      ),
                    ),
                    Text(
                      defect.type,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(status: defect.status),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F2),
              borderRadius: BorderRadius.circular(6),
              border: const Border(left: BorderSide(color: orange, width: 3)),
            ),
            child: Row(
              children: [
                ScoreRing(score: defect.recommendationScore, large: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        defect.recommendationAction,
                        style: const TextStyle(
                          color: orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        defect.recommendationReason,
                        style: const TextStyle(
                          color: Color(0xFF766655),
                          fontSize: 9,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          FactRow(label: '道路编号', value: defect.roadCode),
          FactRow(label: '桩号 / 车道', value: '${defect.mileage}  ${defect.lane}'),
          FactRow(
            label: '经纬度',
            value: defect.coordinateLabel.replaceAll('\n', ' / '),
          ),
          const SizedBox(height: 14),
          const Text(
            '作业人员',
            style: TextStyle(
              color: ink2,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: workerId,
            decoration: _inputDecoration(),
            style: const TextStyle(color: ink2, fontSize: 10),
            items: workers
                .map(
                  (worker) => DropdownMenuItem(
                    value: worker.id,
                    child: Text('${worker.name} · ${worker.team}'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onWorkerChanged(value);
            },
          ),
          const SizedBox(height: 12),
          const Text(
            '优先级',
            style: TextStyle(
              color: ink2,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '紧急', label: Text('紧急')),
              ButtonSegment(value: '高', label: Text('高')),
              ButtonSegment(value: '中', label: Text('中')),
              ButtonSegment(value: '低', label: Text('低')),
            ],
            selected: {priority},
            showSelectedIcon: false,
            style: ButtonStyle(
              textStyle: const WidgetStatePropertyAll(
                TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
              ),
              visualDensity: VisualDensity.compact,
              side: const WidgetStatePropertyAll(BorderSide(color: line)),
            ),
            onSelectionChanged: (values) => onPriorityChanged(values.first),
          ),
          const SizedBox(height: 12),
          const Text(
            '派发说明',
            style: TextStyle(
              color: ink2,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: noteController,
            minLines: 3,
            maxLines: 4,
            style: const TextStyle(fontSize: 10),
            decoration: _inputDecoration(hint: '填写现场注意事项'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_outlined, size: 15),
                  label: const Text('转观察'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: hasOrder ? null : onDispatch,
                  icon: Icon(
                    hasOrder
                        ? Icons.check_circle_outline_rounded
                        : Icons.send_rounded,
                    size: 15,
                  ),
                  label: Text(hasOrder ? '已派发' : '确认派发'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvidenceStep extends StatelessWidget {
  const _EvidenceStep({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: teal),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: muted, fontSize: 8)),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: ink2,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvidenceArrow extends StatelessWidget {
  const _EvidenceArrow();

  @override
  Widget build(BuildContext context) {
    return Container(width: 28, height: 1, color: line);
  }
}

class PipelinePage extends StatelessWidget {
  const PipelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final stages = [
      ('01', '终端数据入湖', '图像、时间、坐标、速度', '12,840', '0.8s', blue),
      ('02', '图像质量筛查', '模糊、逆光、遮挡、雨雪', '12,164', '0.2s', teal),
      ('03', 'YOLOv8 病害推理', 'D00 / D10 / D20 / D40', '3,748', '38ms', orange),
      ('04', '多帧去重与聚合', '距离、类型、时间窗判定', '1,126', '12ms', teal),
      ('05', '道路编号与桩号匹配', 'G312 / S107 / 县乡道', '1,126', '21ms', blue),
      ('06', '人工复核', '低置信度与高风险优先', '1,103', '23 待审', amber),
    ];
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          ConsolePanel(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DATA PIPELINE',
                        style: TextStyle(
                          color: muted,
                          fontSize: 8,
                          fontFamily: 'Consolas',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '从终端图像到可执行工单',
                        style: TextStyle(
                          color: ink,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '所有处理阶段均保留事件 ID、终端来源、时空位置与人工复核结果。',
                        style: TextStyle(color: muted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: const Text('运行演示批次'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ConsolePanel(
              child: Column(
                children: [
                  const PanelHeading(
                    eyebrow: 'PIPELINE HEALTH',
                    title: '处理阶段',
                    trailing: [
                      StatusDot(),
                      SizedBox(width: 6),
                      Text(
                        '流水线空闲 · 最近批次 10:48',
                        style: TextStyle(color: muted, fontSize: 9),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          for (
                            var index = 0;
                            index < stages.length;
                            index++
                          ) ...[
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: index == 5
                                      ? const Color(0xFFFBF7F0)
                                      : soft,
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: index == 5
                                        ? const Color(0xFFE9CDB3)
                                        : line,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          stages[index].$1,
                                          style: const TextStyle(
                                            color: muted,
                                            fontSize: 8,
                                            fontFamily: 'Consolas',
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.circle,
                                          size: 7,
                                          color: stages[index].$6,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      stages[index].$2,
                                      style: const TextStyle(
                                        color: ink,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Expanded(
                                      child: Text(
                                        stages[index].$3,
                                        style: const TextStyle(
                                          color: muted,
                                          fontSize: 8,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                    const Divider(height: 18, color: line),
                                    Row(
                                      children: [
                                        Text(
                                          stages[index].$4,
                                          style: const TextStyle(
                                            color: ink,
                                            fontSize: 17,
                                            fontFamily: 'Consolas',
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          stages[index].$5,
                                          style: const TextStyle(
                                            color: muted,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index < stages.length - 1)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFFB6C0BA),
                                  size: 18,
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 185,
            child: Row(
              children: [
                _PipelineInfo(
                  title: '模型基线',
                  eyebrow: 'OPEN SOURCE MODEL',
                  value: 'YOLOv8s · RDD2022',
                  meta: 'AGPL-3.0 · ONNX Runtime · 1024×1024',
                  icon: Icons.memory_rounded,
                ),
                const SizedBox(width: 14),
                _PipelineInfo(
                  title: '数据契约',
                  eyebrow: 'EVENT CONTRACT',
                  value: '12 个核心字段',
                  meta: 'defect_id / road_code / type_code / severity',
                  icon: Icons.data_object_rounded,
                ),
                const SizedBox(width: 14),
                _PipelineInfo(
                  title: '当前吞吐',
                  eyebrow: 'THROUGHPUT',
                  value: '38 ms / 帧',
                  meta: '批量推理 · 4 路终端并发',
                  icon: Icons.speed_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final programs = [
      (
        Icons.account_balance_rounded,
        '路政养护单位',
        '按覆盖公里订阅',
        '从病害发现、人工复核到派发与验收，形成可追踪的养护工单。',
        '年度订阅 · 试点项目',
        '主力服务',
        teal,
        tealSoft,
      ),
      (
        Icons.directions_car_filled_rounded,
        '车企与智能交通企业',
        '云端识别接口',
        '输出病害类别、位置与采集时间，支持技术验证和量产授权。',
        'API 接入 · 算法授权',
        '接口方案',
        blue,
        blueSoft,
      ),
      (
        Icons.school_rounded,
        '高校与科研院所',
        '脱敏数据服务',
        '提供标准化、长时序的道路病害样本，合同限定用途与再分发。',
        '年度数据订阅 · 联合课题',
        '授权模板',
        amber,
        amberSoft,
      ),
      (
        Icons.handshake_rounded,
        '采集合作伙伴',
        '设备减免与服务优惠',
        '公务车、网约车、物流车与养护车按既有线路参与固定采集。',
        '固定线路 + 弹性补采',
        '伙伴计划',
        orange,
        orangeSoft,
      ),
    ];
    final governance = [
      (Icons.sensors_rounded, '最小必要采集', '只处理路面图像、时间、速度与位置，不采集车内影像和音频。'),
      (Icons.lock_outline_rounded, '脱敏与权限分级', '车牌、人脸与可识别场景脱敏，按政府、车企、科研角色授权。'),
      (Icons.key_rounded, '数据授权边界', '不向第三方出售可识别个人或车辆的原始数据，科研仅提供脱敏或聚合版本。'),
      (Icons.map_outlined, '地图合规', '使用 OpenStreetMap 作为开源底图，不生产、不销售地图成果。'),
    ];
    return Padding(
      padding: const EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                color: ink,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FOUR-PARTY VALUE NETWORK',
                          style: TextStyle(
                            color: Color(0xFF8CA299),
                            fontSize: 8,
                            fontFamily: 'Consolas',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          '一套平台，连接养护、车企、科研与采集伙伴',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '以路政按公里订阅为基本盘，向车企提供云端识别接口与算法授权，向科研院所提供经授权的脱敏数据，并通过设备减免连接社会采集车辆。',
                          style: TextStyle(
                            color: Color(0xFFADBCB4),
                            fontSize: 10,
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 13),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            _ServiceTag(text: '不把未签约意向计入收入'),
                            _ServiceTag(text: '原始数据不转售'),
                            _ServiceTag(text: '工单闭环可审计'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 255,
                    child: Container(
                      height: 142,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131C19),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: const Color(0xFF34463E)),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.apartment_rounded,
                            color: Color(0xFF78B99F),
                            size: 30,
                          ),
                          SizedBox(height: 6),
                          Text(
                            '路鉴智巡',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            '病害数据 · 工单闭环 · 数据服务',
                            style: TextStyle(
                              color: Color(0xFF8DA198),
                              fontSize: 8,
                            ),
                          ),
                          SizedBox(height: 9),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _PartnerChip(
                                icon: Icons.account_balance_rounded,
                                text: '路政',
                              ),
                              _PartnerChip(
                                icon: Icons.directions_car_rounded,
                                text: '车企',
                              ),
                              _PartnerChip(
                                icon: Icons.school_rounded,
                                text: '科研',
                              ),
                              _PartnerChip(
                                icon: Icons.handshake_rounded,
                                text: '伙伴',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth < 900 ? 2 : 4;
                final cardWidth =
                    (constraints.maxWidth - (columns - 1) * 12) / columns;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final program in programs)
                      SizedBox(
                        width: cardWidth,
                        height: 190,
                        child: _ServiceProgramCard(
                          icon: program.$1,
                          audience: program.$2,
                          title: program.$3,
                          detail: program.$4,
                          entry: program.$5,
                          status: program.$6,
                          color: program.$7,
                          background: program.$8,
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 980) {
                  return Column(
                    children: [
                      _PartnerApiPanel(height: 330),
                      const SizedBox(height: 14),
                      _GovernancePanel(items: governance, height: 340),
                    ],
                  );
                }
                return SizedBox(
                  height: 340,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 7, child: _PartnerApiPanel()),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 4,
                        child: _GovernancePanel(items: governance),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            const _ReadinessPanel(),
          ],
        ),
      ),
    );
  }
}

class _ServiceTag extends StatelessWidget {
  const _ServiceTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF22302B),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF354740)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, color: Color(0xFF7DB79F), size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Color(0xFFC0CEC7), fontSize: 8),
          ),
        ],
      ),
    );
  }
}

class _PartnerChip extends StatelessWidget {
  const _PartnerChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF91A69D), size: 14),
        const SizedBox(height: 3),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF8FA299), fontSize: 7),
        ),
      ],
    );
  }
}

class _ServiceProgramCard extends StatelessWidget {
  const _ServiceProgramCard({
    required this.icon,
    required this.audience,
    required this.title,
    required this.detail,
    required this.entry,
    required this.status,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String audience;
  final String title;
  final String detail;
  final String entry;
  final String status;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ConsolePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: soft,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: line),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(color: muted, fontSize: 7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Text(
                    audience,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: Text(
                      detail,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 8,
                        height: 1.55,
                      ),
                    ),
                  ),
                  const Divider(height: 14, color: line),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry,
                          style: const TextStyle(
                            color: ink2,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_outward_rounded,
                        color: muted,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerApiPanel extends StatelessWidget {
  const _PartnerApiPanel({this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ConsolePanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PanelHeading(
              eyebrow: 'PARTNER API / V1',
              title: '车企与平台接入',
              trailing: [Pill(text: '演示可用', color: teal, background: tealSoft)],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: line)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.code_rounded, color: muted, size: 15),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'POST /api/v1/detections',
                      style: TextStyle(
                        color: ink2,
                        fontSize: 9,
                        fontFamily: 'Consolas',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'x-api-key: demo-partner-key',
                    style: TextStyle(
                      color: muted,
                      fontSize: 7,
                      fontFamily: 'Consolas',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(13),
                color: const Color(0xFF17211E),
                child: const SelectableText(
                  '{\n'
                  '  "terminalId": "TERM-XA-017",\n'
                  '  "roadCode": "G312-K1082+350",\n'
                  '  "typeCode": "D10",\n'
                  '  "confidence": 0.93,\n'
                  '  "lat": 34.27386,\n'
                  '  "lng": 109.06421,\n'
                  '  "timestamp": "2026-10-21T10:46:00+08:00"\n'
                  '}',
                  style: TextStyle(
                    color: Color(0xFFBDD3C9),
                    fontSize: 8,
                    height: 1.7,
                    fontFamily: 'Consolas',
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: line)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.file_present_rounded, color: teal, size: 15),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '写入：类别 / 位置 / 置信度 / 时间    读取：GET /api/v1/road-defects',
                      style: TextStyle(
                        color: muted,
                        fontSize: 7,
                        fontFamily: 'Consolas',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GovernancePanel extends StatelessWidget {
  const _GovernancePanel({required this.items, this.height});

  final List<(IconData, String, String)> items;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ConsolePanel(
        child: Column(
          children: [
            const PanelHeading(
              eyebrow: 'DATA GOVERNANCE',
              title: '数据授权与合规',
              trailing: [Icon(Icons.shield_outlined, color: teal, size: 18)],
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 5,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: line),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: tealSoft,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(item.$1, color: teal, size: 15),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.$2,
                                style: const TextStyle(
                                  color: ink,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.$3,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 8,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadinessPanel extends StatelessWidget {
  const _ReadinessPanel();

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.account_balance_rounded,
        '陕西县域公路试点',
        '2 至 3 个路段 · 单段 200 至 500 km · 90 天',
        '试点筹备',
        orange,
        orangeSoft,
      ),
      (
        Icons.directions_car_filled_rounded,
        '车企云端识别接口',
        '输出病害类别、位置与采集时间 · 技术验证方案',
        '方案就绪',
        blue,
        blueSoft,
      ),
      (
        Icons.school_rounded,
        '科研脱敏数据',
        '标准化字段 · 合同限定用途 · 禁止再识别与再分发',
        '授权模板',
        teal,
        tealSoft,
      ),
    ];
    return ConsolePanel(
      child: Column(
        children: [
          const PanelHeading(
            eyebrow: 'COOPERATION PIPELINE',
            title: '合作准备状态',
            trailing: [
              Text(
                '未签约事项均标记为准备状态',
                style: TextStyle(color: muted, fontSize: 8),
              ),
            ],
          ),
          for (var index = 0; index < items.length; index++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: index == items.length - 1
                    ? null
                    : const Border(bottom: BorderSide(color: line)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 31,
                    height: 31,
                    decoration: BoxDecoration(
                      color: items[index].$6,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      items[index].$1,
                      color: items[index].$5,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[index].$2,
                          style: const TextStyle(
                            color: ink,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[index].$3,
                          style: const TextStyle(color: muted, fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                  Pill(
                    text: items[index].$4,
                    color: items[index].$5,
                    background: items[index].$6,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PipelineInfo extends StatelessWidget {
  const _PipelineInfo({
    required this.title,
    required this.eyebrow,
    required this.value,
    required this.meta,
    required this.icon,
  });

  final String title;
  final String eyebrow;
  final String value;
  final String meta;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ConsolePanel(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: teal),
                const SizedBox(width: 8),
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 8,
                    fontFamily: 'Consolas',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(title, style: const TextStyle(color: muted, fontSize: 9)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              meta,
              style: const TextStyle(
                color: muted,
                fontSize: 9,
                fontFamily: 'Consolas',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({String? hint, IconData? icon}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: muted, fontSize: 9),
    prefixIcon: icon == null ? null : Icon(icon, size: 16, color: muted),
    isDense: true,
    filled: true,
    fillColor: soft,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: line),
    ),
  );
}
