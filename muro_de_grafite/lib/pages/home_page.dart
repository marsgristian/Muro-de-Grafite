import 'package:flutter/material.dart';
import '../components/drawing_canvas.dart';
import '../components/tool_palette.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../providers/drawing_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ui.Image? _backgroundImage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMuralBackground();
  }

  Future<void> _loadMuralBackground() async {
    try {
      final db = FirebaseDatabase.instance.ref();
      final snapshot = await db.child('public_drawings/current').get();
      if (snapshot.exists && snapshot.value is String) {
        final base64 = snapshot.value as String;
        final bytes = base64Decode(base64);
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        setState(() {
          _backgroundImage = frame.image;
          _loading = false;
        });
        return;
      }
    } catch (e) {
      print('Erro ao carregar mural do Firebase: $e');
    }
    // Fallback: carrega wall.jpg
    final data = await rootBundle.load('assets/wall.jpg');
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _backgroundImage = frame.image;
      _loading = false;
    });
  }

  Future<ui.Image> _loadBackgroundImage() async {
    final data = await rootBundle.load('assets/wall.jpg');
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<void> _publishDrawing(BuildContext context) async {
    final provider = Provider.of<DrawingProvider>(context, listen: false);
    final wallSize = const Size(1920, 1080);
    try {
      print('Iniciando exportação do mural...');
      final bg = _backgroundImage ?? await _loadBackgroundImage();
      final base64 = await DrawingCanvas.exportToBase64(
        background: bg,
        lines: provider.lines,
        size: wallSize,
        provider: provider,
      );
      print('Exportação concluída. Tamanho base64: \\${base64.length} bytes');
      // if (base64.length > 900 * 1024) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('O mural ficou muito grande para o limite gratuito do Firebase. Diminua o desenho e tente novamente.')),
      //   );
      //   return;
      // }
      print('Exportação concluída. Enviando para o Firebase...');
      final db = FirebaseDatabase.instance.ref();
      await db.child('public_drawings/current').set(base64);
      print('Envio para o Firebase concluído!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mural publicado!')),
      );
      // Atualiza o background localmente
      setState(() {
        _backgroundImage = bg;
      });
    } catch (e, st) {
      print('Erro ao publicar mural: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao publicar mural: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const wallSize = Size(1920, 1080); // Tamanho fixo da parede
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // Área de navegação
                  Positioned.fill(
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 1,
                      constrained: false,
                      child: SizedBox(
                        width: wallSize.width,
                        height: wallSize.height,
                        child: Stack(
                          children: [
                            // Imagem de fundo dinâmica
                            if (_backgroundImage != null)
                              Positioned.fill(
                                child: RawImage(
                                  image: _backgroundImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            // Canvas de desenho
                            const Positioned.fill(
                              child: DrawingCanvas(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Paleta lateral de ferramentas
                  Positioned(
                    left: 16,
                    top: 16,
                    bottom: 16,
                    child: ToolPalette(),
                  ),
                  // Botão "Publicar desenho"
                  Positioned(
                    right: 32,
                    bottom: 32,
                    child: ElevatedButton(
                      onPressed: () => _publishDrawing(context),
                      child: const Text('Publicar desenho'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
} 