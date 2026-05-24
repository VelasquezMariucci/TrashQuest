import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class CSGORoulette extends StatefulWidget {
  final List<String> prizes;
  final String winningPrize;
  final VoidCallback onAnimationComplete;

  const CSGORoulette({
    super.key, 
    required this.prizes, 
    required this.winningPrize,
    required this.onAnimationComplete,
  });

  @override
  State<CSGORoulette> createState() => _CSGORouletteState();
}

class _CSGORouletteState extends State<CSGORoulette> {
  final ScrollController _scrollController = ScrollController();
  final double _itemWidth = 120.0;
  late List<String> _rouletteItems;
  double _viewportWidth = 0.0;
  bool _spun = false;

  @override
  void initState() {
    super.initState();
    // 50 items. Winning item is at index 40.
    _rouletteItems = List.generate(50, (index) {
      if (index == 40) return widget.winningPrize;
      return widget.prizes[Random().nextInt(widget.prizes.length)];
    });
  }

  void _spin() {
    if (_spun || _viewportWidth == 0.0) return;
    _spun = true;

    // Calculamos el centro exacto del viewport real del ListView
    final offset = (40 * _itemWidth) - (_viewportWidth / 2) + (_itemWidth / 2);

    // Randomize stopping point within the winning item
    final randomOffset = Random().nextDouble() * (_itemWidth * 0.6) - (_itemWidth * 0.3);

    _scrollController.animateTo(
      offset + randomOffset,
      duration: const Duration(seconds: 4),
      curve: Curves.easeOutCubic,
    ).then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          widget.onAnimationComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (!_spun) {
            _viewportWidth = constraints.maxWidth;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _spin();
            });
          }
          
          return Stack(
            alignment: Alignment.center,
            children: [
              ListView.builder(
                controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _rouletteItems.length,
            itemBuilder: (context, index) {
              final prize = _rouletteItems[index];
              final isTryAgain = prize.contains('intentando');
              
              return SizedBox(
                width: _itemWidth,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
                  decoration: BoxDecoration(
                    color: isTryAgain ? Colors.grey[200] : const Color(0xFFFFECB3), // amber 100
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTryAgain ? Colors.grey[400]! : Colors.amber[600]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isTryAgain ? Icons.sentiment_dissatisfied : Icons.card_giftcard,
                        color: isTryAgain ? Colors.grey : Colors.amber[700],
                        size: 30,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          prize,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Red indicator line
          Container(
            width: 4,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.red,
              boxShadow: [
                BoxShadow(color: Colors.red.withAlpha(100), blurRadius: 8)
              ]
            ),
          ),
        ],
      );
    },
  ),
);
  }
}

class ChestScreen extends StatefulWidget {
  const ChestScreen({super.key});

  @override
  State<ChestScreen> createState() => _ChestScreenState();
}

class _ChestScreenState extends State<ChestScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  final items = [
    '10% Descuento Restaurante',
    '¡Sigue intentando!',
    'Fastpass Atracción',
    '¡Sigue intentando!',
    'Entrada 2x1',
    '¡Sigue intentando!',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openChest() {
    final userProvider = context.read<UserProvider>();
    if (userProvider.points >= 500) {
      if (_isOpen) {
        setState(() {
          _isOpen = false;
        });
      }
      userProvider.spendPoints(500);
      
      _controller.forward(from: 0.0).then((_) {
        setState(() {
          _isOpen = true;
        });
        
        int winIndex = Random().nextInt(items.length);
        final winningPrize = items[winIndex];

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sorteando premio...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  const SizedBox(height: 20),
                  CSGORoulette(
                    prizes: items,
                    winningPrize: winningPrize,
                    onAnimationComplete: () {
                      Navigator.pop(context); // Close roulette dialog
                      
                      if (!winningPrize.contains('intentando')) {
                        userProvider.addPrize(winningPrize);
                      }
                      
                      _showPrizeDialog(winningPrize);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Necesitas al menos 500 puntos para abrir el cofre.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showPrizeDialog(String prize) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: prize.contains('intentando') ? Colors.grey[100] : const Color(0xFFFFF8E1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  prize.contains('intentando') ? Icons.sentiment_dissatisfied : Icons.card_giftcard,
                  size: 60,
                  color: prize.contains('intentando') ? Colors.grey : Colors.amber[700],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                prize.contains('intentando') ? '¡Casi!' : '¡Enhorabuena!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                prize.contains('intentando') ? 'El cofre estaba vacío esta vez.' : 'Has encontrado:\n$prize',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Aceptar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final points = context.watch<UserProvider>().points;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120.0), // clear bottom nav
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Recompensas',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: const Color(0x1A4CAF50), blurRadius: 20, offset: const Offset(0, 10))
                      ]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.eco, color: Colors.green, size: 30),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            const Text('Saldo actual', style: TextStyle(color: Colors.grey)),
                            Text(
                              '$points pts',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Cofre Animado
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final dx = sin(_controller.value * 4 * pi) * 15;
                      final scale = 1.0 + sin(_controller.value * pi) * 0.1;
                      return Transform.translate(
                        offset: Offset(dx, 0),
                        child: Transform.scale(
                          scale: scale,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      _isOpen ? Icons.inventory_2 : Icons.inventory,
                      size: 180,
                      color: Colors.amber[700],
                      shadows: const [
                        Shadow(color: Color(0x80FFC107), blurRadius: 30)
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Abrir cofre: 500 pts', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _openChest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 8,
                          shadowColor: const Color(0x80FFC107),
                        ),
                        child: const Text('ABRIR COFRE MISTERIOSO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                      ),
                    ),
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
