import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lujian_core/lujian_core.dart';

const mapSize = Size(760, 540);

class WorkerMap extends StatelessWidget {
  const WorkerMap({
    super.key,
    required this.defects,
    required this.selected,
    required this.onSelect,
  });

  final List<Defect> defects;
  final Defect? selected;
  final ValueChanged<Defect> onSelect;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: InteractiveViewer(
        minScale: 0.9,
        maxScale: 4,
        boundaryMargin: const EdgeInsets.all(80),
        child: SizedBox(
          width: mapSize.width,
          height: mapSize.height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              Defect? nearest;
              var nearestDistance = 40.0;
              for (var index = 0; index < defects.length; index++) {
                final point = _markerPoint(defects[index], index);
                final distance = (details.localPosition - point).distance;
                if (distance < nearestDistance) {
                  nearestDistance = distance;
                  nearest = defects[index];
                }
              }
              if (nearest != null) onSelect(nearest);
            },
            child: CustomPaint(
              painter: RoadMapPainter(defects: defects, selected: selected),
            ),
          ),
        ),
      ),
    );
  }
}

Offset _markerPoint(Defect defect, int index) {
  final x = 105 + (defect.longitude - 109.035) * 12000 + (index % 2) * 12;
  final y = 85 + (defect.latitude - 34.25) * 14500 - (index % 3) * 18;
  return Offset(
    x.clamp(58, mapSize.width - 58),
    y.clamp(58, mapSize.height - 58),
  );
}

class RoadMapPainter extends CustomPainter {
  RoadMapPainter({required this.defects, required this.selected});

  final List<Defect> defects;
  final Defect? selected;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE7EBE6));

    final blockPaint = Paint()..color = const Color(0xFFF4F5F2);
    final blockBorder = Paint()
      ..color = const Color(0xFFD9DFD9)
      ..style = PaintingStyle.stroke;
    final blocks = <Rect>[
      const Rect.fromLTWH(35, 30, 120, 90),
      const Rect.fromLTWH(175, 26, 150, 108),
      const Rect.fromLTWH(350, 34, 170, 92),
      const Rect.fromLTWH(545, 24, 170, 108),
      const Rect.fromLTWH(25, 150, 160, 104),
      const Rect.fromLTWH(210, 150, 112, 96),
      const Rect.fromLTWH(350, 160, 165, 110),
      const Rect.fromLTWH(540, 155, 175, 118),
      const Rect.fromLTWH(35, 290, 118, 120),
      const Rect.fromLTWH(178, 282, 150, 128),
      const Rect.fromLTWH(355, 300, 132, 115),
      const Rect.fromLTWH(515, 290, 198, 125),
      const Rect.fromLTWH(50, 438, 160, 82),
      const Rect.fromLTWH(240, 445, 135, 75),
      const Rect.fromLTWH(405, 440, 140, 84),
      const Rect.fromLTWH(570, 435, 150, 88),
    ];
    for (final block in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, const Radius.circular(2)),
        blockPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, const Radius.circular(2)),
        blockBorder,
      );
    }

    final river = Path()
      ..moveTo(680, -20)
      ..cubicTo(615, 120, 720, 210, 650, 310)
      ..cubicTo(595, 390, 680, 470, 635, 570)
      ..lineTo(760, 570)
      ..lineTo(760, -20)
      ..close();
    canvas.drawPath(river, Paint()..color = const Color(0xFFC8DBDE));

    final roadBorder = Paint()
      ..color = const Color(0xFFC8D0C9)
      ..strokeWidth = 13
      ..style = PaintingStyle.stroke;
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;
    final route = Paint()
      ..color = const Color(0xFFE7A86D)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    Path horizontal = Path()
      ..moveTo(-20, 235)
      ..cubicTo(170, 205, 320, 225, 470, 246)
      ..cubicTo(590, 264, 670, 250, 780, 256);
    canvas.drawPath(horizontal, roadBorder);
    canvas.drawPath(horizontal, road);
    canvas.drawPath(horizontal, route);

    final secondRoad = Path()
      ..moveTo(-20, 405)
      ..cubicTo(160, 385, 285, 405, 450, 414)
      ..cubicTo(580, 422, 680, 405, 780, 420);
    canvas.drawPath(secondRoad, roadBorder);
    canvas.drawPath(secondRoad, road);

    final verticalRoads = [
      Path()
        ..moveTo(145, -20)
        ..cubicTo(168, 130, 150, 255, 170, 420)
        ..cubicTo(181, 482, 176, 515, 182, 570),
      Path()
        ..moveTo(407, -20)
        ..cubicTo(392, 130, 410, 290, 397, 420)
        ..cubicTo(391, 480, 405, 520, 392, 570),
      Path()
        ..moveTo(548, -20)
        ..cubicTo(560, 145, 548, 250, 563, 375)
        ..cubicTo(572, 450, 550, 500, 565, 570),
    ];
    for (final path in verticalRoads) {
      canvas.drawPath(path, roadBorder);
      canvas.drawPath(path, road);
    }

    final labelStyle = const TextStyle(
      color: Color(0xFF8E9B93),
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    _drawText(canvas, 'G312 沪霍线', const Offset(210, 212), labelStyle);
    _drawText(canvas, 'S107 关中环线', const Offset(225, 389), labelStyle);
    _drawText(canvas, '纺渭路', const Offset(122, 115), labelStyle);
    _drawText(canvas, '东三环', const Offset(377, 255), labelStyle);
    _drawText(canvas, '灞桥区', const Offset(85, 320), labelStyle);
    _drawText(canvas, '浐灞生态区', const Offset(527, 330), labelStyle);
    _drawText(canvas, '灞河', const Offset(692, 160), labelStyle);

    for (var index = 0; index < defects.length; index++) {
      final defect = defects[index];
      final point = _markerPoint(defect, index);
      final active = selected?.id == defect.id;
      final color = switch (defect.severity) {
        DefectSeverity.high => const Color(0xFFD44F35),
        DefectSeverity.medium => const Color(0xFFD58B31),
        DefectSeverity.low => const Color(0xFF2F7A6C),
      };
      if (active) {
        canvas.drawCircle(
          point,
          23,
          Paint()..color = color.withValues(alpha: 0.14),
        );
      }
      canvas.drawCircle(
        point,
        active ? 12 : 9,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        point,
        active ? 9 : 6.5,
        Paint()..color = color,
      );
      if (active) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(point.dx + 14, point.dy - 28, 116, 28),
          const Radius.circular(5),
        );
        canvas.drawRRect(rect, Paint()..color = const Color(0xEE17201E));
        _drawText(
          canvas,
          '${defect.type} · ${defect.terminalCount}终端',
          Offset(point.dx + 23, point.dy - 20),
          const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        );
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant RoadMapPainter oldDelegate) =>
      oldDelegate.selected != selected || oldDelegate.defects != defects;
}

class EvidenceView extends StatelessWidget {
  const EvidenceView({
    super.key,
    required this.defect,
    this.height = 240,
  });

  final Defect defect;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: EvidencePainter(defect)),
      ),
    );
  }
}

class EvidencePainter extends CustomPainter {
  EvidencePainter(this.defect);

  final Defect defect;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF1D2925));
    final asphalt = Path()
      ..moveTo(size.width * 0.18, 0)
      ..lineTo(size.width * 0.82, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(asphalt, Paint()..color = const Color(0xFF303A37));

    final edgePaint = Paint()
      ..color = const Color(0xFFDD9258)
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(size.width * 0.18, 0),
      Offset(0, size.height),
      edgePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.82, 0),
      Offset(size.width, size.height),
      edgePaint,
    );

    final lanePaint = Paint()..color = const Color(0xFFD6D1C5);
    for (var index = 0; index < 5; index++) {
      final t = index / 5;
      final y = size.height * (0.08 + t * 0.9);
      final width = size.width * (0.028 + t * 0.035);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2, y),
            width: width,
            height: size.height * (0.04 + t * 0.04),
          ),
          const Radius.circular(2),
        ),
        lanePaint,
      );
    }

    final crack = Paint()
      ..color = const Color(0xFF080D0C)
      ..strokeWidth = defect.severity == DefectSeverity.high ? 4 : 2.4
      ..style = PaintingStyle.stroke;
    final random = math.Random(defect.id.hashCode);
    var point = Offset(size.width * 0.58, size.height * 0.35);
    for (var index = 0; index < 12; index++) {
      final next = point +
          Offset(
            random.nextDouble() * 26 - 10,
            random.nextDouble() * 22 + 4,
          );
      canvas.drawLine(point, next, crack);
      point = next;
    }

    final box = Rect.fromLTWH(
      size.width * 0.50,
      size.height * 0.29,
      size.width * 0.43,
      size.height * 0.54,
    );
    canvas.drawRect(
      box,
      Paint()
        ..color = const Color(0xFFD86B32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final label = RRect.fromRectAndRadius(
      Rect.fromLTWH(box.left, box.top - 28, 108, 27),
      const Radius.circular(3),
    );
    canvas.drawRRect(label, Paint()..color = const Color(0xFFD86B32));
    _drawText(
      canvas,
      '${defect.typeCode} · ${(defect.confidence * 100).round()}%',
      Offset(box.left + 8, box.top - 21),
      const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        fontFamily: 'Consolas',
      ),
    );
    _drawText(
      canvas,
      '证据 01 / 03',
      Offset(14, size.height - 24),
      const TextStyle(color: Color(0xFFBFC9C3), fontSize: 9),
    );
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant EvidencePainter oldDelegate) =>
      oldDelegate.defect != defect;
}
