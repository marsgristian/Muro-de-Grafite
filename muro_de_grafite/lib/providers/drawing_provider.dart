import 'package:flutter/material.dart';

enum ToolType { brush, eraser, bucket, pan }

class DrawnLine {
  final List<Offset> normalizedPoints;
  final Color color;
  final double width;
  final ToolType tool;

  DrawnLine({
    required this.normalizedPoints,
    required this.color,
    required this.width,
    required this.tool,
  });
}

class DrawingProvider extends ChangeNotifier {
  List<DrawnLine> _lines = [];
  List<DrawnLine> get lines => _lines;

  final List<DrawnLine> _redoStack = [];
  bool get canRedo => _redoStack.isNotEmpty;

  ToolType _activeTool = ToolType.brush;
  ToolType get activeTool => _activeTool;

  Color _color = Colors.black;
  Color get color => _color;

  double _width = 4.0;
  double get width => _width;

  Offset _canvasOffset = Offset.zero;
  Offset get canvasOffset => _canvasOffset;

  Offset? lastPanPosition;

  bool _isDrawing = false;

  void setTool(ToolType tool) {
    _activeTool = tool;
    notifyListeners();
  }

  void setColor(Color color) {
    _color = color;
    notifyListeners();
  }

  void setWidth(double width) {
    _width = width;
    notifyListeners();
  }

  void addPoint(Offset point) {
    if (_activeTool == ToolType.eraser) {
      eraseAtPoint(point);
      return;
    }
    _redoStack.clear();
    if (!_isDrawing) {
      _lines.add(DrawnLine(normalizedPoints: [point], color: _color, width: _width, tool: _activeTool));
      _isDrawing = true;
    } else {
      _lines.last.normalizedPoints.add(point);
    }
    notifyListeners();
  }

  void eraseAtPoint(Offset point) {
    _lines.removeWhere((line) =>
      line.normalizedPoints.any((p) => (p - point).distance < _width * 1.2)
    );
    notifyListeners();
  }

  void endLine() {
    _isDrawing = false;
    notifyListeners();
  }

  void undo() {
    if (_lines.isNotEmpty) {
      _redoStack.add(_lines.removeLast());
      notifyListeners();
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      _lines.add(_redoStack.removeLast());
      notifyListeners();
    }
  }

  void clear() {
    _lines.clear();
    _redoStack.clear();
    notifyListeners();
  }

  void fill(Color color) {
    clear();
    _lines.add(DrawnLine(normalizedPoints: [Offset.zero], color: color, width: double.infinity, tool: ToolType.bucket));
    notifyListeners();
  }

  void panCanvas(Offset delta, {Size? imageSize, Size? viewportSize}) {
    _canvasOffset += delta;
    if (imageSize != null && viewportSize != null) {
      _canvasOffset = _limitOffset(_canvasOffset, imageSize, viewportSize);
    }
    notifyListeners();
  }

  Offset _limitOffset(Offset offset, Size imageSize, Size viewportSize) {
    double maxX = 0;
    double maxY = 0;
    double minX = viewportSize.width - imageSize.width;
    double minY = viewportSize.height - imageSize.height;
    // Se a imagem for menor que a viewport, centraliza
    if (imageSize.width <= viewportSize.width) {
      minX = maxX = (viewportSize.width - imageSize.width) / 2;
    }
    if (imageSize.height <= viewportSize.height) {
      minY = maxY = (viewportSize.height - imageSize.height) / 2;
    }
    double x = offset.dx.clamp(minX, maxX);
    double y = offset.dy.clamp(minY, maxY);
    return Offset(x, y);
  }

  void resetCanvasOffset() {
    _canvasOffset = Offset.zero;
    notifyListeners();
  }

  // Utilitário para converter ponto real para normalizado
  Offset toNormalized(Offset point, Size imageSize) {
    return Offset(point.dx / imageSize.width, point.dy / imageSize.height);
  }

  // Utilitário para converter ponto normalizado para real
  Offset toReal(Offset normalized, Size imageSize) {
    return Offset(normalized.dx * imageSize.width, normalized.dy * imageSize.height);
  }
} 