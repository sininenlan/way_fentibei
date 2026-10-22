import 'package:flutter/material.dart';
import 'package:lujian_core/lujian_core.dart';

import 'painters.dart';

const _ink = Color(0xFF17201E);
const _canvas = Color(0xFFF3F5F1);
const _surface = Colors.white;
const _soft = Color(0xFFF7F9F6);
const _line = Color(0xFFDDE3DE);
const _muted = Color(0xFF6D7873);
const _teal = Color(0xFF2F7A6C);
const _tealSoft = Color(0xFFDFEEE9);
const _orange = Color(0xFFD86B32);
const _orangeSoft = Color(0xFFF5E5DA);
const _red = Color(0xFFD44F35);
const _redSoft = Color(0xFFF8E4DE);
const _amber = Color(0xFFD58B31);
const _amberSoft = Color(0xFFF7EBD9);
const _blue = Color(0xFF3E6D91);
const _blueSoft = Color(0xFFE3ECF2);

void main() {
  runApp(const LujianWorkorderApp());
}

class LujianWorkorderApp extends StatelessWidget {
  const LujianWorkorderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '路鉴智巡 · 工单',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: _canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _teal,
          brightness: Brightness.light,
          primary: _teal,
          secondary: _orange,
          surface: _surface,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _ink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _ink,
            side: const BorderSide(color: _line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const WorkorderShell(),
    );
  }
}

class WorkorderShell extends StatefulWidget {
  const WorkorderShell({super.key});

  @override
  State<WorkorderShell> createState() => _WorkorderShellState();
}

class _WorkorderShellState extends State<WorkorderShell> {
  final LujianStore store = LujianStore();
  final String workerId = 'w-01';
  int navIndex = 0;
  Defect? mapSelected;

  Worker get worker => store.workerFor(workerId);

  List<WorkOrder> get myOrders => store.orders
      .where((order) => order.workerId == workerId)
      .toList()
    ..sort((a, b) {
      if (a.status == WorkOrderStatus.completed &&
          b.status != WorkOrderStatus.completed) {
        return 1;
      }
      if (b.status == WorkOrderStatus.completed &&
          a.status != WorkOrderStatus.completed) {
        return -1;
      }
      return a.dueAt.compareTo(b.dueAt);
    });

  void refresh() => setState(() {});

  @override
  void initState() {
    super.initState();
    mapSelected = store.defects.firstWhere(
      (defect) => defect.id == 'DEF-20261021-013',
    );
  }

  void openDefect(Defect defect) {
    final order = store.orderForDefect(defect.id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkOrderDetailPage(
          store: store,
          defect: defect,
          order: order,
          worker: worker,
          onChanged: refresh,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(worker: worker),
            Expanded(
              child: IndexedStack(
                index: navIndex,
                children: [
                  _TasksTab(
                    store: store,
                    orders: myOrders,
                    onOpen: openDefect,
                  ),
                  _MapTab(
                    store: store,
                    selected: mapSelected,
                    onSelect: (defect) =>
                        setState(() => mapSelected = defect),
                    onOpen: openDefect,
                  ),
                  _ProfileTab(worker: worker, orders: myOrders),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: _surface,
          border: Border(top: BorderSide(color: _line)),
        ),
        child: NavigationBar(
          height: 66,
          backgroundColor: _surface,
          indicatorColor: _tealSoft,
          selectedIndex: navIndex,
          onDestinationSelected: (index) => setState(() => navIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment_rounded),
              label: '任务',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map_rounded),
              label: '地图',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.worker});

  final Worker worker;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: _surface,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _ink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.alt_route_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 9),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '路鉴智巡',
                style: TextStyle(
                  color: _ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '养护工单',
                style: TextStyle(
                  color: _muted,
                  fontSize: 8,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: _tealSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                _PulseDot(),
                SizedBox(width: 5),
                Text(
                  '在线',
                  style: TextStyle(
                    color: _teal,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          CircleAvatar(
            radius: 18,
            backgroundColor: _teal,
            child: Text(
              worker.name.characters.first,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
    );
  }
}

class _TasksTab extends StatelessWidget {
  const _TasksTab({
    required this.store,
    required this.orders,
    required this.onOpen,
  });

  final LujianStore store;
  final List<WorkOrder> orders;
  final ValueChanged<Defect> onOpen;

  @override
  Widget build(BuildContext context) {
    final activeTasks =
        orders.where((order) => order.status != WorkOrderStatus.completed).length;
    final nearby = store.defects
        .where((defect) => defect.status != DefectStatus.completed)
        .take(3)
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 28),
      children: [
        const Text(
          '10月21日 · 星期三',
          style: TextStyle(
            color: _muted,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          '早上好，王磊',
          style: TextStyle(
            color: _ink,
            fontSize: 27,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '今日 $activeTasks 项养护任务待处理',
          style: const TextStyle(color: _muted, fontSize: 12),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _MiniStat(
              value: '$activeTasks',
              label: '待处置',
              color: _orange,
            ),
            const SizedBox(width: 8),
            _MiniStat(
              value: '${store.defects.length}',
              label: '附近病害',
              color: _red,
            ),
            const SizedBox(width: 8),
            const _MiniStat(
              value: '4/6',
              label: '终端在线',
              color: _teal,
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionTitle(title: '我的工单', action: '按截止时间排序'),
        const SizedBox(height: 9),
        if (orders.isEmpty)
          const _EmptyTask()
        else
          for (final order in orders) ...[
            _WorkOrderCard(
              defect: store.defects.firstWhere(
                (defect) => defect.id == order.defectId,
              ),
              order: order,
              onTap: () => onOpen(
                store.defects.firstWhere(
                  (defect) => defect.id == order.defectId,
                ),
              ),
            ),
            const SizedBox(height: 9),
          ],
        const SizedBox(height: 9),
        const _SectionTitle(title: '附近高风险', action: '2 km 范围'),
        const SizedBox(height: 9),
        for (final defect in nearby)
          _NearbyCard(defect: defect, onTap: () => onOpen(defect)),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: _surface,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: _muted, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Text(
          action,
          style: const TextStyle(color: _muted, fontSize: 9),
        ),
      ],
    );
  }
}

class _WorkOrderCard extends StatelessWidget {
  const _WorkOrderCard({
    required this.defect,
    required this.order,
    required this.onTap,
  });

  final Defect defect;
  final WorkOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final severity = _severityColors(defect.severity);
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: severity.$2,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      defect.severityLabel,
                      style: TextStyle(
                        color: severity.$1,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    order.status == WorkOrderStatus.inProgress
                        ? Icons.play_circle_outline_rounded
                        : Icons.schedule_rounded,
                    size: 14,
                    color: _muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.statusLabel,
                    style: const TextStyle(color: _muted, fontSize: 9),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                defect.type,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                defect.roadName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted, fontSize: 10),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      defect.roadCode,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 9,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.sensors_rounded, size: 13, color: _teal),
                  const SizedBox(width: 3),
                  Text(
                    '${defect.terminalCount}',
                    style: const TextStyle(
                      color: _teal,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '截止 ${order.dueAt.hour.toString().padLeft(2, '0')}:${order.dueAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: _muted, fontSize: 9),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _muted,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyCard extends StatelessWidget {
  const _NearbyCard({required this.defect, required this.onTap});

  final Defect defect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            Container(
              width: 9,
              height: 36,
              decoration: BoxDecoration(
                color: _severityColors(defect.severity).$1,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${defect.type} · ${defect.roadCode}',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${defect.terminalCount} 个终端捕获 · ${defect.statusLabel}',
                    style: const TextStyle(color: _muted, fontSize: 9),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _muted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _EmptyTask extends StatelessWidget {
  const _EmptyTask();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: _teal, size: 30),
          SizedBox(height: 8),
          Text(
            '当前没有待处理工单',
            style: TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapTab extends StatelessWidget {
  const _MapTab({
    required this.store,
    required this.selected,
    required this.onSelect,
    required this.onOpen,
  });

  final LujianStore store;
  final Defect? selected;
  final ValueChanged<Defect> onSelect;
  final ValueChanged<Defect> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '养护地图',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '双指缩放 · 拖动查看 · 点击病害点位',
                    style: TextStyle(color: _muted, fontSize: 9),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: _tealSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '离线矢量底图',
                  style: TextStyle(
                    color: _teal,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: WorkerMap(
              defects: store.defects,
              selected: selected,
              onSelect: onSelect,
            ),
          ),
        ),
        if (selected != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 15),
            decoration: const BoxDecoration(
              color: _surface,
              border: Border(top: BorderSide(color: _line)),
            ),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _severityColors(selected!.severity).$1,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${selected!.type} · ${selected!.roadCode}',
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${selected!.terminalCount} 个终端捕获 · ${selected!.coordinateLabel.replaceAll('\n', ' / ')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 8),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => onOpen(selected!),
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    textStyle: const TextStyle(fontSize: 10),
                  ),
                  child: const Text('查看详情'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.worker, required this.orders});

  final Worker worker;
  final List<WorkOrder> orders;

  @override
  Widget build(BuildContext context) {
    final completed = orders
        .where((order) => order.status == WorkOrderStatus.completed)
        .length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _ink,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: _teal,
                child: Text(
                  worker.name.characters.first,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    worker.team,
                    style: const TextStyle(
                      color: Color(0xFFB1C0B9),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    worker.phone,
                    style: const TextStyle(
                      color: Color(0xFF81948B),
                      fontSize: 9,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _MiniStat(
              value: '${orders.length}',
              label: '累计工单',
              color: _blue,
            ),
            const SizedBox(width: 8),
            _MiniStat(
              value: '$completed',
              label: '今日完成',
              color: _teal,
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionTitle(title: '设置', action: ''),
        const SizedBox(height: 9),
        Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _line),
          ),
          child: const Column(
            children: [
              _SettingsItem(
                icon: Icons.offline_pin_outlined,
                title: '离线数据',
                value: '已同步',
              ),
              Divider(height: 1, color: _line),
              _SettingsItem(
                icon: Icons.notifications_outlined,
                title: '工单通知',
                value: '开启',
              ),
              Divider(height: 1, color: _line),
              _SettingsItem(
                icon: Icons.security_outlined,
                title: '采集与隐私',
                value: '最小化采集',
              ),
              Divider(height: 1, color: _line),
              _SettingsItem(
                icon: Icons.info_outline_rounded,
                title: '版本',
                value: '1.0.0 Native',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: _ink, size: 19),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: _muted, fontSize: 9),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: _muted, size: 17),
        ],
      ),
    );
  }
}

class WorkOrderDetailPage extends StatefulWidget {
  const WorkOrderDetailPage({
    super.key,
    required this.store,
    required this.defect,
    required this.order,
    required this.worker,
    required this.onChanged,
  });

  final LujianStore store;
  final Defect defect;
  final WorkOrder? order;
  final Worker worker;
  final VoidCallback onChanged;

  @override
  State<WorkOrderDetailPage> createState() => _WorkOrderDetailPageState();
}

class _WorkOrderDetailPageState extends State<WorkOrderDetailPage> {
  bool busy = false;

  Future<void> updateOrder(WorkOrderStatus status) async {
    final order = widget.order;
    if (order == null || busy) return;
    setState(() => busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 280));
    widget.store.updateOrder(order.id, status);
    widget.onChanged();
    if (!mounted) return;
    setState(() => busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == WorkOrderStatus.completed ? '处置完成，工单已归档' : '已开始处置',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defect = widget.defect;
    final order = widget.order;
    final severity = _severityColors(defect.severity);
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 4,
        title: const Text(
          '工单详情',
          style: TextStyle(
            color: _ink,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _StatusBadge(status: defect.status),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order?.id ?? defect.id,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 9,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      defect.type,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: severity.$2,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: severity.$1, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      defect.severityLabel,
                      style: TextStyle(
                        color: severity.$1,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          EvidenceView(defect: defect),
          const SizedBox(height: 13),
          Row(
            children: [
              Text(
                '模型置信度 ${(defect.confidence * 100).round()}%',
                style: const TextStyle(color: _muted, fontSize: 10),
              ),
              const Spacer(),
              Text(
                defect.roadName,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DetailGrid(defect: defect),
          const SizedBox(height: 14),
          _DetailSection(
            title: '多终端交叉验证',
            trailing: '${defect.terminalCount} / 7',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(7, (index) {
                    final active = index < defect.terminalCount;
                    return Expanded(
                      child: Container(
                        height: 5,
                        margin: EdgeInsets.only(right: index == 6 ? 0 : 4),
                        decoration: BoxDecoration(
                          color: active ? _teal : const Color(0xFFE5E9E5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  '最近捕获 10.21 09:52 · 采集速度 28 km/h',
                  style: const TextStyle(color: _muted, fontSize: 9),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F2),
              borderRadius: BorderRadius.circular(12),
              border: const Border(left: BorderSide(color: _orange, width: 3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: _orange, size: 17),
                    const SizedBox(width: 5),
                    const Text(
                      '研判建议',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${defect.recommendationScore}',
                      style: const TextStyle(
                        color: _orange,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  defect.recommendationReason,
                  style: const TextStyle(
                    color: Color(0xFF776353),
                    fontSize: 10,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _DetailSection(
            title: '任务动态',
            trailing: order == null
                ? '暂无工单'
                : '截止 ${order.dueAt.hour.toString().padLeft(2, '0')}:${order.dueAt.minute.toString().padLeft(2, '0')}',
            child: Column(
              children: [
                _TimelineItem(
                  title: order == null ? '病害进入研判' : '工单创建',
                  detail:
                      order == null ? '等待调度员确认是否派发。' : order.note,
                  color: _orange,
                ),
                const SizedBox(height: 10),
                _TimelineItem(
                  title:
                      order?.status == WorkOrderStatus.completed ? '处置完成' : '当前状态',
                  detail: order?.statusLabel ?? defect.statusLabel,
                  color: order?.status == WorkOrderStatus.completed
                      ? _teal
                      : _blue,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: order == null
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(
                14,
                10,
                14,
                10 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: const BoxDecoration(
                color: _surface,
                border: Border(top: BorderSide(color: _line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('查看地图'),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: busy
                          ? null
                          : order.status == WorkOrderStatus.assigned
                              ? () => updateOrder(WorkOrderStatus.inProgress)
                              : order.status == WorkOrderStatus.inProgress
                                  ? () =>
                                      updateOrder(WorkOrderStatus.completed)
                                  : null,
                      icon: Icon(
                        order.status == WorkOrderStatus.completed
                            ? Icons.check_circle_rounded
                            : order.status == WorkOrderStatus.assigned
                                ? Icons.camera_alt_outlined
                                : Icons.task_alt_rounded,
                        size: 18,
                      ),
                      label: Text(
                        busy
                            ? '提交中...'
                            : order.status == WorkOrderStatus.completed
                                ? '工单已完成'
                                : order.status == WorkOrderStatus.assigned
                                    ? '开始处置'
                                    : '完成处置',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.defect});

  final Defect defect;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('道路编号', defect.roadCode),
      ('出现频次', '${defect.terminalCount} 个终端'),
      ('纬度', '${defect.latitude.toStringAsFixed(6)}° N'),
      ('经度', '${defect.longitude.toStringAsFixed(6)}° E'),
      ('车道', defect.lane),
      ('桩号', defect.mileage),
    ];
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        children: List.generate(items.length, (index) {
          return Container(
            width: (MediaQuery.sizeOf(context).width - 32) / 2,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: index.isEven ? _line : Colors.transparent,
                ),
                bottom: BorderSide(
                  color: index < 4 ? _line : Colors.transparent,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  items[index].$1,
                  style: const TextStyle(color: _muted, fontSize: 8),
                ),
                const SizedBox(height: 4),
                Text(
                  items[index].$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.trailing,
    required this.child,
  });

  final String title;
  final String trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                trailing,
                style: const TextStyle(color: _muted, fontSize: 9),
              ),
            ],
          ),
          const SizedBox(height: 11),
          child,
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.detail,
    required this.color,
  });

  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                detail,
                style: const TextStyle(color: _muted, fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final DefectStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (status) {
      DefectStatus.completed => (_teal, _tealSoft),
      DefectStatus.inProgress || DefectStatus.dispatched => (_blue, _blueSoft),
      DefectStatus.observing => (_muted, _soft),
      _ => (_orange, _orangeSoft),
    };
    final label = switch (status) {
      DefectStatus.pendingReview => '待复核',
      DefectStatus.awaitingDispatch => '待研判',
      DefectStatus.dispatched => '已派发',
      DefectStatus.inProgress => '处置中',
      DefectStatus.completed => '已完成',
      DefectStatus.observing => '观察中',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

(Color, Color) _severityColors(DefectSeverity severity) {
  return switch (severity) {
    DefectSeverity.high => (_red, _redSoft),
    DefectSeverity.medium => (_amber, _amberSoft),
    DefectSeverity.low => (_teal, _tealSoft),
  };
}
