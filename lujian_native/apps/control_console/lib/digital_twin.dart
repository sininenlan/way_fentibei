import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lujian_core/lujian_core.dart';

const _twinBackground = Color(0xFF111A18);
const _roadColor = Color(0xFF303A37);
const _roadEdge = Color(0xFFDA8B51);
const _gridColor = Color(0xFF273430);
const _teal = Color(0xFF55AA8B);

class DigitalTwinView extends StatefulWidget {
  const DigitalTwinView({
    super.key,
    required this.defects,
    required this.selectedDefect,
    this.compact = false,
  });

  final List<Defect> defects;
  final Defect? selectedDefect;
  final bool compact;

  @override
  State<DigitalTwinView> createState() => _DigitalTwinViewState();
}

class _DigitalTwinViewState extends State<DigitalTwinView> {
  double yaw = -0.55;
  double pitch = 0.34;
  bool dragging = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ColoredBox(
        color: _twinBackground,
        child: Stack(
          children: [
            Positioned.fill(
              child: MouseRegion(
                cursor: dragging
                    ? SystemMouseCursors.grabbing
                    : SystemMouseCursors.grab,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (_) => setState(() => dragging = true),
                  onPanUpdate: (details) {
                    setState(() {
                      yaw += details.delta.dx * 0.008;
                      pitch = (pitch + details.delta.dy * 0.005).clamp(
                        0.08,
                        0.7,
                      );
                    });
                  },
                  onPanEnd: (_) => setState(() => dragging = false),
                  onPanCancel: () => setState(() => dragging = false),
                  child: CustomPaint(
                    painter: RoadTwinPainter(
                      defects: widget.defects,
                      selectedDefect: widget.selectedDefect,
                      yaw: yaw,
                      pitch: pitch,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 15,
              left: 16,
              child: _TwinHeader(
                selected: widget.selectedDefect,
                compact: widget.compact,
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Row(
                children: [
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xCC1D2925),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: const Color(0xFF394842)),
                    ),
                    child: const Row(
                      children: [
                        _LiveDot(),
                        SizedBox(width: 6),
                        Text(
                          '实时网格',
                          style: TextStyle(
                            color: Color(0xFFB8C8C1),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  Tooltip(
                    message: '重置视角',
                    child: InkWell(
                      onTap: () => setState(() {
                        yaw = -0.55;
                        pitch = 0.34;
                      }),
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xCC1D2925),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: const Color(0xFF394842)),
                        ),
                        child: const Icon(
                          Icons.center_focus_strong_rounded,
                          color: Color(0xFFB8C8C1),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              bottom: 14,
              child: Row(
                children: [
                  _TwinLegend(color: const Color(0xFFD9543A), text: '高风险'),
                  const SizedBox(width: 10),
                  _TwinLegend(color: const Color(0xFFD7953B), text: '中风险'),
                  const SizedBox(width: 10),
                  _TwinLegend(color: _teal, text: '低风险'),
                ],
              ),
            ),
            Positioned(
              right: 14,
              bottom: 13,
              child: Text(
                widget.selectedDefect == null
                    ? '3D ROAD MESH  ·  DRAG TO ORBIT'
                    : '${widget.selectedDefect!.roadCode}  ·  ${widget.selectedDefect!.coordinateLabel.replaceAll('\n', ' / ')}',
                style: const TextStyle(
                  color: Color(0xFF7F958B),
                  fontSize: 9,
                  fontFamily: 'Consolas',
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TwinHeader extends StatelessWidget {
  const _TwinHeader({required this.selected, required this.compact});

  final Defect? selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ROAD DIGITAL TWIN  /  LIVE MESH',
          style: TextStyle(
            color: Color(0xFF71877D),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            fontFamily: 'Consolas',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          selected?.roadCode ?? 'G312 · 灞桥示范段',
          style: TextStyle(
            color: const Color(0xFFE9F0EC),
            fontSize: compact ? 14 : 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          selected == null
              ? '道路资产、终端与病害的空间映射'
              : '${selected!.type}  ·  ${selected!.terminalCount} 个终端捕获',
          style: const TextStyle(
            color: Color(0xFF9BAFA6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _TwinLegend extends StatelessWidget {
  const _TwinLegend({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF9FB2AA), fontSize: 9),
        ),
      ],
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(controller),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
      ),
    );
  }
}

class _Vec3 {
  const _Vec3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;
}

class _Projected {
  const _Projected(this.position, this.scale, this.depth);

  final Offset position;
  final double scale;
  final double depth;
}

class RoadTwinPainter extends CustomPainter {
  RoadTwinPainter({
    required this.defects,
    required this.selectedDefect,
    required this.yaw,
    required this.pitch,
  });

  final List<Defect> defects;
  final Defect? selectedDefect;
  final double yaw;
  final double pitch;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final center = Offset(size.width * 0.52, size.height * 0.53);
    final focal = math.min(size.width, size.height) * 1.95;

    _Projected project(_Vec3 point) {
      final cosYaw = math.cos(yaw);
      final sinYaw = math.sin(yaw);
      final x1 = point.x * cosYaw + point.z * sinYaw;
      final z1 = -point.x * sinYaw + point.z * cosYaw;
      final cosPitch = math.cos(pitch);
      final sinPitch = math.sin(pitch);
      final y2 = point.y * cosPitch - z1 * sinPitch;
      final z2 = point.y * sinPitch + z1 * cosPitch;
      final depth = 30 + z2;
      final scale = focal / depth;
      return _Projected(
        Offset(center.dx + x1 * scale, center.dy - y2 * scale),
        scale,
        z2,
      );
    }

    void drawLine3D(
      Canvas target,
      _Vec3 a,
      _Vec3 b,
      Paint paint,
    ) {
      target.drawLine(project(a).position, project(b).position, paint);
    }

    void drawPolygon3D(
      Canvas target,
      List<_Vec3> points,
      Paint paint,
    ) {
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final projected = project(points[i]).position;
        if (i == 0) {
          path.moveTo(projected.dx, projected.dy);
        } else {
          path.lineTo(projected.dx, projected.dy);
        }
      }
      path.close();
      target.drawPath(path, paint);
    }

    final gridPaint = Paint()
      ..color = _gridColor
      ..strokeWidth = 1;
    for (var x = -24; x <= 24; x += 3) {
      drawLine3D(
        canvas,
        _Vec3(x.toDouble(), -0.42, -30),
        _Vec3(x.toDouble(), -0.42, 30),
        gridPaint,
      );
    }
    for (var z = -30; z <= 30; z += 3) {
      drawLine3D(
        canvas,
        _Vec3(-24, -0.42, z.toDouble()),
        _Vec3(24, -0.42, z.toDouble()),
        gridPaint,
      );
    }

    drawPolygon3D(
      canvas,
      const [
        _Vec3(-8.4, -0.16, -28),
        _Vec3(8.4, -0.16, -28),
        _Vec3(8.4, -0.16, 28),
        _Vec3(-8.4, -0.16, 28),
      ],
      Paint()..color = const Color(0xFF46514D),
    );
    drawPolygon3D(
      canvas,
      const [
        _Vec3(-6.2, 0, -28),
        _Vec3(6.2, 0, -28),
        _Vec3(6.2, 0, 28),
        _Vec3(-6.2, 0, 28),
      ],
      Paint()..color = _roadColor,
    );
    drawLine3D(
      canvas,
      const _Vec3(-5.9, 0.012, -28),
      const _Vec3(-5.9, 0.012, 28),
      Paint()
        ..color = _roadEdge
        ..strokeWidth = 2.3,
    );
    drawLine3D(
      canvas,
      const _Vec3(5.9, 0.012, -28),
      const _Vec3(5.9, 0.012, 28),
      Paint()
        ..color = _roadEdge
        ..strokeWidth = 2.3,
    );

    final lanePaint = Paint()..color = const Color(0xFFD8D5C8);
    for (var z = -26.0; z < 28; z += 4.2) {
      drawPolygon3D(
        canvas,
        [
          _Vec3(-0.12, 0.016, z),
          _Vec3(0.12, 0.016, z),
          _Vec3(0.12, 0.016, z + 2.1),
          _Vec3(-0.12, 0.016, z + 2.1),
        ],
        lanePaint,
      );
    }

    for (var i = 0; i < 8; i++) {
      final z = -25.0 + i * 7.3;
      drawLine3D(
        canvas,
        _Vec3(-5.6, 0.018, z),
        _Vec3(5.6, 0.018, z),
        Paint()
          ..color = const Color(0x223D9E87)
          ..strokeWidth = 1,
      );
    }

    final orderedDefects = [...defects];
    for (var index = 0; index < orderedDefects.length; index++) {
      final defect = orderedDefects[index];
      final z = -20 + index * 6.2;
      final x = ((index % 3) - 1) * 2.3;
      final color = _severityColor(defect.severity);
      final active = selectedDefect?.id == defect.id;
      final base = project(_Vec3(x, 0.03, z));
      final top = project(_Vec3(x, active ? 3.6 : 2.6, z));

      final beaconPaint = Paint()
        ..color = color.withValues(alpha: active ? 0.95 : 0.72)
        ..strokeWidth = active ? 2.4 : 1.4;
      canvas.drawLine(base.position, top.position, beaconPaint);
      canvas.drawCircle(
        top.position,
        active ? 5.2 : 3.2,
        Paint()..color = color,
      );

      final ringRect = Rect.fromCenter(
        center: base.position,
        width: (active ? 42 : 28) * base.scale / 20,
        height: (active ? 20 : 13) * base.scale / 20,
      );
      canvas.drawOval(
        ringRect,
        Paint()
          ..color = color.withValues(alpha: active ? 0.82 : 0.46)
          ..style = PaintingStyle.stroke
          ..strokeWidth = active ? 2.6 : 1.5,
      );
      if (active) {
        final label = _drawLabel(
          defect.type,
          top.position + const Offset(8, -24),
          color,
        );
        canvas.drawRRect(label.$1, Paint()..color = const Color(0xEE1A2421));
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${defect.type}  ${(defect.confidence * 100).round()}%',
            style: const TextStyle(
              color: Color(0xFFF3F7F5),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          label.$2 + const Offset(6, 4),
        );
      }
    }

    for (var i = 0; i < 6; i++) {
      final z = -22.0 + i * 9;
      final base = project(_Vec3(-7.2, 0.1, z));
      final top = project(_Vec3(-7.2, 2.7, z));
      canvas.drawLine(
        base.position,
        top.position,
        Paint()
          ..color = const Color(0xFF51645C)
          ..strokeWidth = 1.2,
      );
      canvas.drawCircle(
        top.position,
        3,
        Paint()..color = const Color(0xFF55AA8B),
      );
    }
  }

  (RRect, Offset) _drawLabel(String text, Offset position, Color accent) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$text  00%',
        style: const TextStyle(fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        position.dx,
        position.dy,
        textPainter.width + 12,
        textPainter.height + 8,
      ),
      const Radius.circular(4),
    );
    return (rect, position);
  }

  Color _severityColor(DefectSeverity severity) => switch (severity) {
        DefectSeverity.high => const Color(0xFFD9543A),
        DefectSeverity.medium => const Color(0xFFD7953B),
        DefectSeverity.low => _teal,
      };

  @override
  bool shouldRepaint(covariant RoadTwinPainter oldDelegate) =>
      oldDelegate.yaw != yaw ||
      oldDelegate.pitch != pitch ||
      oldDelegate.selectedDefect != selectedDefect ||
      oldDelegate.defects != defects;
}
