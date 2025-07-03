import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ToolPalette extends StatefulWidget {
  const ToolPalette({Key? key}) : super(key: key);

  @override
  State<ToolPalette> createState() => _ToolPaletteState();
}

class _ToolPaletteState extends State<ToolPalette> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final drawing = Provider.of<DrawingProvider>(context);
    if (_hidden) {
      return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: SizedBox(
            width: 40,
            height: 40,
            child: FloatingActionButton(
            
              mini: true,
              backgroundColor: Colors.white,
              elevation: 2,
              onPressed: () => setState(() => _hidden = false),
              child: const Icon(Icons.chevron_right, color: Colors.black),
              tooltip: 'Mostrar ferramentas',
            ),
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Transform.scale(
          scale: 1,
          alignment: Alignment.topLeft,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left),
                      tooltip: 'Esconder ferramentas',
                      onPressed: () => setState(() => _hidden = true),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ToggleButtons(
                        isSelected: [
                          drawing.activeTool == ToolType.brush,
                          drawing.activeTool == ToolType.eraser,
                          drawing.activeTool == ToolType.pan,
                        ],
                        onPressed: (index) {
                          if (index == 0) drawing.setTool(ToolType.brush);
                          if (index == 1) drawing.setTool(ToolType.eraser);
                          if (index == 2) drawing.setTool(ToolType.pan);
                        },
                        children: const [
                          Tooltip(message: 'Pincel', child: Icon(Icons.brush)),
                          Tooltip(message: 'Borracha', child: Icon(Icons.remove)),
                          Tooltip(message: 'Mover', child: Icon(Icons.pan_tool)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.undo),
                        tooltip: 'Desfazer',
                        onPressed: drawing.lines.isNotEmpty ? drawing.undo : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.redo),
                        tooltip: 'Refazer',
                        onPressed: drawing.canRedo ? drawing.redo : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  
                  if (drawing.activeTool != ToolType.eraser) const SizedBox(height: 10),
                  // Slider de tamanho do pincel/borracha
                  if (drawing.activeTool != ToolType.pan)
                    Column(
                      children: [
                        const Text('Tamanho'),
                        Slider(
                          min: 2,
                          max: 32,
                          value: drawing.width,
                          onChanged: (v) => drawing.setWidth(v),
                          onChangeEnd: (v) => drawing.setWidth(v),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  // Botão balde (preencher)
                  if (drawing.activeTool == ToolType.bucket)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.format_color_fill),
                      label: const Text('Preencher'),
                      onPressed: () => drawing.fill(drawing.color),
                    ),
                  
                  
                  // Seletor de cor profissional e histórico de cores
                  Transform.scale(
                    scale: 1,
                    alignment: Alignment.center,
                    child: _ColorPickerWithHistory(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



// Adicionar widget do color picker e histórico
class _ColorPickerWithHistory extends StatefulWidget {
  @override
  State<_ColorPickerWithHistory> createState() => _ColorPickerWithHistoryState();
}

class _ColorPickerWithHistoryState extends State<_ColorPickerWithHistory> {
  Color pickerColor = Colors.black;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final drawing = Provider.of<DrawingProvider>(context);
    pickerColor = drawing.color;
  }

  @override
  Widget build(BuildContext context) {
    final drawing = Provider.of<DrawingProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cor'),
        const SizedBox(height: 4),
        ColorPicker(
          pickerColor: drawing.color,
          onColorChanged: (color) {
            drawing.setColor(color);
            setState(() {
              pickerColor = color;
            });
          },
          enableAlpha: true,
          displayThumbColor: false,
          pickerAreaHeightPercent: 0.4,

          //portraitOnly: true,

          pickerAreaBorderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }
} 