import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum GardenElement {
  tree,
  flower,
  grass,
}

class GardenItem {
  final Offset position;
  final GardenElement type;
  final double size;
  final Color color;

  GardenItem({
    required this.position,
    required this.type,
    required this.size,
    required this.color,
  });
}

class ZenGardenScreen extends StatefulWidget {
  const ZenGardenScreen({super.key});

  @override
  State<ZenGardenScreen> createState() => _ZenGardenScreenState();
}

class _ZenGardenScreenState extends State<ZenGardenScreen> {
  List<GardenItem> _items = [];
  GardenElement _selectedElement = GardenElement.tree;
  double _elementSize = 40;

  final Map<GardenElement, List<Color>> _elementColors = {
    GardenElement.tree: [
      const Color(0xFF2D5A27),
      const Color(0xFF1B4721),
      const Color(0xFF133A1B),
    ],
    GardenElement.flower: [
      const Color(0xFFFF69B4),
      const Color(0xFFFFB6C1),
      const Color(0xFFFFA07A),
      const Color(0xFFFF8C00),
      const Color(0xFFFFFF00),
    ],
    GardenElement.grass: [
      const Color(0xFF90EE90),
      const Color(0xFF98FB98),
      const Color(0xFF32CD32),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2F4F),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Zen Garden',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _items = [];
                      });
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

            // Garden Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF8B4513).withOpacity(0.3), // Earth color
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTapDown: _onTapDown,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: ZenGardenPainter(items: _items),
                      child: Container(),
                    ),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms)
                .scale(begin: const Offset(0.8, 0.8)),

            // Tools Panel
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildElementButton(
                        'Tree',
                        Icons.park,
                        GardenElement.tree,
                      ),
                      _buildElementButton(
                        'Flower',
                        Icons.local_florist,
                        GardenElement.flower,
                      ),
                      _buildElementButton(
                        'Grass',
                        Icons.grass,
                        GardenElement.grass,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Size Slider
                  Row(
                    children: [
                      const Icon(Icons.height, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: _elementSize,
                          min: 20,
                          max: 80,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white24,
                          onChanged: (value) {
                            setState(() {
                              _elementSize = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildElementButton(
      String label, IconData icon, GardenElement element) {
    final isSelected = _selectedElement == element;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedElement = element;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2A2F4F) : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2A2F4F) : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);

    // Get random color for the selected element type
    final colors = _elementColors[_selectedElement]!;
    final randomColor = colors[DateTime.now().millisecond % colors.length];

    setState(() {
      _items.add(GardenItem(
        position: point,
        type: _selectedElement,
        size: _elementSize,
        color: randomColor,
      ));
    });
  }
}

class ZenGardenPainter extends CustomPainter {
  final List<GardenItem> items;

  ZenGardenPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    for (var item in items) {
      switch (item.type) {
        case GardenElement.tree:
          _drawTree(canvas, item);
          break;
        case GardenElement.flower:
          _drawFlower(canvas, item);
          break;
        case GardenElement.grass:
          _drawGrass(canvas, item);
          break;
      }
    }
  }

  void _drawTree(Canvas canvas, GardenItem item) {
    final paint = Paint()
      ..color = item.color
      ..style = PaintingStyle.fill;

    // Draw trunk
    final trunkPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: item.position.translate(0, item.size / 3),
        width: item.size / 4,
        height: item.size / 1.5,
      ),
      trunkPaint,
    );

    // Draw tree crown
    final path = Path();
    path.moveTo(item.position.dx, item.position.dy - item.size / 2);
    path.lineTo(
        item.position.dx - item.size / 2, item.position.dy + item.size / 4);
    path.lineTo(
        item.position.dx + item.size / 2, item.position.dy + item.size / 4);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawFlower(Canvas canvas, GardenItem item) {
    final paint = Paint()
      ..color = item.color
      ..style = PaintingStyle.fill;

    // Draw petals
    for (var i = 0; i < 8; i++) {
      final angle = (i * pi / 4);
      final petalPath = Path();
      petalPath.moveTo(item.position.dx, item.position.dy);
      petalPath.quadraticBezierTo(
        item.position.dx + cos(angle) * item.size / 2,
        item.position.dy + sin(angle) * item.size / 2,
        item.position.dx + cos(angle) * item.size / 3,
        item.position.dy + sin(angle) * item.size / 3,
      );
      canvas.drawPath(petalPath, paint);
    }

    // Draw center
    canvas.drawCircle(
      item.position,
      item.size / 6,
      Paint()..color = Colors.yellow,
    );
  }

  void _drawGrass(Canvas canvas, GardenItem item) {
    final paint = Paint()
      ..color = item.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < 5; i++) {
      final path = Path();
      final startX = item.position.dx + (i - 2) * item.size / 8;
      path.moveTo(startX, item.position.dy + item.size / 2);
      path.quadraticBezierTo(
        startX + (i % 2 == 0 ? 5 : -5),
        item.position.dy,
        startX,
        item.position.dy - item.size / 2,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
