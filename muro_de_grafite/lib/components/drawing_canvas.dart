import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:convert';

class DrawingCanvas extends StatelessWidget {
  const DrawingCanvas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingProvider>(
      builder: (context, drawing, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final imageSize = Size(constraints.maxWidth, constraints.maxHeight);
            final isPanTool = drawing.activeTool == ToolType.pan;
            return IgnorePointer(
              ignoring: isPanTool,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: isPanTool ? null : (details) {
                  final local = (context.findRenderObject() as RenderBox?)?.globalToLocal(details.globalPosition);
                  if (local != null) {
                    final normalized = drawing.toNormalized(local, imageSize);
                    drawing.addPoint(normalized);
                  }
                },
                onPanUpdate: isPanTool ? null : (details) {
                  final local = (context.findRenderObject() as RenderBox?)?.globalToLocal(details.globalPosition);
                  if (local != null) {
                    final normalized = drawing.toNormalized(local, imageSize);
                    drawing.addPoint(normalized);
                  }
                },
                onPanEnd: isPanTool ? null : (_) {
                  drawing.endLine();
                },
                child: CustomPaint(
                  painter: _DrawingPainter(drawing.lines, Offset.zero, imageSize, drawing),
                  size: Size.infinite,
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Exporta o mural (imagem de fundo + traços) como PNG base64
  static Future<String> exportToBase64({
    required ui.Image background,
    required List<DrawnLine> lines,
    required Size size,
    required DrawingProvider provider,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Offset.zero & size);
    // Desenha a imagem de fundo
    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: background,
      fit: BoxFit.cover,
    );
    // Desenha os traços
    final painter = _DrawingPainter(lines, Offset.zero, size, provider);
    painter.paint(canvas, size);
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    return base64Encode(pngBytes);
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final Offset offset;
  final Size imageSize;
  final DrawingProvider provider;
  _DrawingPainter(this.lines, this.offset, this.imageSize, this.provider);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    for (final line in lines) {
      if (line.tool == ToolType.bucket) {
        final paint = Paint()
          ..color = line.color
          ..style = PaintingStyle.fill;
        canvas.drawRect(Offset.zero & size, paint);
      } else {
        final paint = Paint()
          ..color = line.tool == ToolType.eraser ? Colors.white : line.color
          ..strokeWidth = line.width
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        for (int i = 0; i < line.normalizedPoints.length - 1; i++) {
          final p1 = provider.toReal(line.normalizedPoints[i], imageSize);
          final p2 = provider.toReal(line.normalizedPoints[i + 1], imageSize);
          canvas.drawLine(p1, p2, paint);
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 