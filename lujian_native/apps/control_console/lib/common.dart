import 'package:flutter/material.dart';
import 'package:lujian_core/lujian_core.dart';

import 'theme.dart';

class ConsolePanel extends StatelessWidget {
  const ConsolePanel({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: line),
      ),
      child: child,
    );
  }
}

class PanelHeading extends StatelessWidget {
  const PanelHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.trailing = const [],
  });

  final String eyebrow;
  final String title;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 59,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: line)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  color: muted,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Consolas',
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: const TextStyle(
                  color: ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Spacer(),
          ...trailing,
        ],
      ),
    );
  }
}

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, this.size = 7});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF58B28F),
        shape: BoxShape.circle,
      ),
    );
  }
}

class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 27,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: orangeSoft,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$value',
        style: const TextStyle(
          color: orange,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          fontFamily: 'Consolas',
        ),
      ),
    );
  }
}

class ScoreRing extends StatelessWidget {
  const ScoreRing({super.key, required this.score, this.large = false});

  final int score;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final high = score >= 80;
    return Container(
      width: large ? 48 : 31,
      height: large ? 48 : 31,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: high ? redSoft : amberSoft,
        border: Border.all(
          color: high ? const Color(0xFFECC1B8) : const Color(0xFFE9D3AD),
        ),
      ),
      child: Text(
        '$score',
        style: TextStyle(
          color: high ? red : amber,
          fontSize: large ? 15 : 9,
          fontWeight: FontWeight.w800,
          fontFamily: 'Consolas',
        ),
      ),
    );
  }
}

class QueueTile extends StatelessWidget {
  const QueueTile({
    super.key,
    required this.defect,
    required this.selected,
    required this.onTap,
  });

  final Defect defect;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? soft : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          child: Row(
            children: [
              ScoreRing(score: defect.recommendationScore),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${defect.type} · ${defect.terminalCount}个终端',
                      style: const TextStyle(
                        color: ink,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      defect.roadCode,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 8,
                        fontFamily: 'Consolas',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9AA49F),
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TypeGlyph extends StatelessWidget {
  const TypeGlyph({super.key, required this.defect});

  final Defect defect;

  @override
  Widget build(BuildContext context) {
    final color = switch (defect.severity) {
      DefectSeverity.high => red,
      DefectSeverity.medium => amber,
      DefectSeverity.low => teal,
    };
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        defect.type.characters.first,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class SeverityPill extends StatelessWidget {
  const SeverityPill({super.key, required this.severity});

  final DefectSeverity severity;

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (severity) {
      DefectSeverity.high => (red, redSoft),
      DefectSeverity.medium => (amber, amberSoft),
      DefectSeverity.low => (teal, tealSoft),
    };
    final text = switch (severity) {
      DefectSeverity.high => '高风险',
      DefectSeverity.medium => '中风险',
      DefectSeverity.low => '低风险',
    };
    return Pill(text: text, color: color, background: background);
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final DefectStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (status) {
      DefectStatus.completed => (teal, tealSoft),
      DefectStatus.inProgress || DefectStatus.dispatched => (blue, blueSoft),
      DefectStatus.observing => (muted, soft),
      _ => (orange, orangeSoft),
    };
    final label = switch (status) {
      DefectStatus.pendingReview => '待复核',
      DefectStatus.awaitingDispatch => '待研判',
      DefectStatus.dispatched => '已派发',
      DefectStatus.inProgress => '处置中',
      DefectStatus.completed => '已完成',
      DefectStatus.observing => '观察中',
    };
    return Pill(text: label, color: color, background: background);
  }
}

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.text,
    required this.color,
    required this.background,
  });

  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class FactRow extends StatelessWidget {
  const FactRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 94,
            child: Text(
              label,
              style: const TextStyle(color: muted, fontSize: 9),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: ink2,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                fontFamily: 'Consolas',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
