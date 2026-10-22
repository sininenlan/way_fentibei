import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lujian_core/lujian_core.dart';

import 'common.dart';
import 'pages.dart';
import 'theme.dart';

class LujianControlApp extends StatelessWidget {
  const LujianControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '路鉴智巡 · 总控台',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const ConsoleShell(),
    );
  }
}

class ConsoleShell extends StatefulWidget {
  const ConsoleShell({super.key});

  @override
  State<ConsoleShell> createState() => _ConsoleShellState();
}

class _ConsoleShellState extends State<ConsoleShell> {
  final LujianStore store = LujianStore();
  int section = 0;
  Defect? selected;

  @override
  void initState() {
    super.initState();
    selected = store.priorityQueue.isEmpty ? null : store.priorityQueue.first;
  }

  void refresh([VoidCallback? change]) {
    setState(() {
      change?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expanded = MediaQuery.sizeOf(context).width >= 1120;
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            expanded: expanded,
            selected: section,
            onSelect: (value) => setState(() => section = value),
          ),
          Expanded(
            child: Column(
              children: [
                _TopBar(title: _titles[section], subtitle: _subtitles[section]),
                Expanded(
                  child: switch (section) {
                    0 => DashboardPage(
                      store: store,
                      selected: selected,
                      onSelect: (defect) => setState(() => selected = defect),
                      onOpenDispatch: () => setState(() => section = 3),
                    ),
                    1 => TwinPage(
                      store: store,
                      selected: selected,
                      onSelect: (defect) => setState(() => selected = defect),
                    ),
                    2 => LedgerPage(
                      store: store,
                      selected: selected,
                      onSelect: (defect) => setState(() => selected = defect),
                    ),
                    3 => DispatchPage(
                      store: store,
                      selected: selected,
                      onSelect: (defect) => setState(() => selected = defect),
                      refresh: refresh,
                    ),
                    4 => const PipelinePage(),
                    5 => const ServicePage(),
                    _ => const SizedBox.shrink(),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _titles = ['道路数字孪生控制台', '三维道路孪生', '病害台账', '工单调度', '数据处理流水线', '合作服务'];

const _subtitles = [
  '实时映射道路资产、病害风险与养护动作',
  '可旋转、可定位的病害空间模型',
  '统一查看病害证据、位置与闭环状态',
  '结合风险、频次和现场条件进行人工研判',
  '从终端图像到工单发布的完整事件链',
  '面向路政、车企、科研与采集伙伴的四方服务',
];

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.expanded,
    required this.selected,
    required this.onSelect,
  });

  final bool expanded;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.grid_view_rounded, '总控台'),
      (Icons.view_in_ar_rounded, '数字孪生'),
      (Icons.format_list_bulleted_rounded, '病害台账'),
      (Icons.assignment_outlined, '工单调度'),
      (Icons.account_tree_outlined, '数据处理'),
      (Icons.hub_outlined, '合作服务'),
    ];
    return Container(
      width: expanded ? 210 : 76,
      color: ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 88,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: expanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      Icons.alt_route_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  if (expanded) ...[
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '路鉴智巡',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'CONTROL CENTER',
                          style: TextStyle(
                            color: Color(0xFF82948C),
                            fontSize: 8,
                            fontFamily: 'Consolas',
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Divider(color: Color(0xFF2A3833), height: 1),
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < items.length; index++)
            _NavItem(
              icon: items[index].$1,
              label: items[index].$2,
              active: selected == index,
              expanded: expanded,
              onTap: () => onSelect(index),
            ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.all(expanded ? 14 : 10),
            child: Container(
              padding: EdgeInsets.all(expanded ? 11 : 9),
              decoration: BoxDecoration(
                color: const Color(0xFF202D29),
                borderRadius: BorderRadius.circular(7),
              ),
              child: expanded
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusDot(),
                            SizedBox(width: 6),
                            Text(
                              '数据服务正常',
                              style: TextStyle(
                                color: Color(0xFFD7E3DD),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          '同步延迟 1.8s · 终端 4/6',
                          style: TextStyle(
                            color: Color(0xFF7E9389),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    )
                  : const Center(child: StatusDot()),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.expanded,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: active ? const Color(0xFF26342F) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 42,
            padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 15),
            child: Row(
              mainAxisAlignment: expanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: active ? Colors.white : const Color(0xFF96A79F),
                  size: 18,
                ),
                if (expanded) ...[
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      color: active ? Colors.white : const Color(0xFFA7B5AF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: const BoxDecoration(
        color: surface,
        border: Border(bottom: BorderSide(color: line)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '2026年10月21日 · 灞桥路网',
                style: TextStyle(
                  color: muted.withValues(alpha: 0.9),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: muted, fontSize: 10),
              ),
            ],
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {
              Process.start('cmd', [
                '/c',
                'start',
                '',
                'http://localhost:4174',
              ], mode: ProcessStartMode.detached);
            },
            icon: const Icon(Icons.public_rounded, size: 15),
            label: const Text('Kepler 地图'),
          ),
          const SizedBox(width: 10),
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: soft,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: line),
            ),
            child: const Row(
              children: [
                StatusDot(),
                SizedBox(width: 6),
                Text(
                  'FLUTTER NATIVE · WINDOWS',
                  style: TextStyle(
                    color: muted,
                    fontSize: 8,
                    fontFamily: 'Consolas',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {},
            tooltip: '通知',
            icon: const Icon(Icons.notifications_none_rounded, size: 20),
          ),
          const SizedBox(width: 6),
          const CircleAvatar(
            radius: 17,
            backgroundColor: teal,
            child: Text(
              '值',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '值班调度',
                style: TextStyle(
                  color: ink,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text('路网管理中心', style: TextStyle(color: muted, fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }
}
