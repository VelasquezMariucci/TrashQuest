import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;
  
  // Posiciones extraídas exactamente de tu captura de pantalla
  final List<Alignment> _markers = [
    const Alignment(-0.80, -0.30), // Camino curva izquierda
    const Alignment(-0.30, 0.15),  // Cruce central cerca flamencos
    const Alignment(0.25, -0.30),  // Camino lémures/dinosaurio
    const Alignment(0.65, -0.90),  // Arriba derecha edificio
    const Alignment(0.40, 0.80),   // Abajo derecha murciélagos
  ];

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onScaleChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerOnToucan();
    });
  }

  void _centerOnToucan() {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    
    // Dimensiones fijas del mapa
    const mapW = 1600.0;
    const mapH = 1100.0;
    
    // Alineación del Tucán: Alignment(-0.1, 0.3)
    final toucanX = (mapW / 2) + (-0.1 * (mapW / 2));
    final toucanY = (mapH / 2) + (0.30 * (mapH / 2));
    
    // Zoom inicial
    const scale = 2.5; 
    
    // Matrix de transformación
    final matrix = Matrix4.identity()
      ..translate(
        (screenW / 2) - (toucanX * scale),
        (screenH / 2) - (toucanY * scale)
      )
      ..scale(scale);
      
    _transformationController.value = matrix;
  }
  
  void _onScaleChanged() {
    final newScale = _transformationController.value.getMaxScaleOnAxis();
    if (newScale != _currentScale) {
      setState(() {
        _currentScale = newScale;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onScaleChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _showBinDetails(BuildContext context, int id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.recycling, color: Colors.green, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Punto de Reciclaje #$id', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Text('Zona interactiva', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Deposita aquí tu basura y usa el escáner para sumar puntos a tu perfil ecológico.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: const Text('IR AL ESCÁNER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                context.push('/scanner');
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildMarker(Alignment alignment, int id) {
    final double baseIconSize = 45.0;
    final double iconSize = (baseIconSize / _currentScale).clamp(15.0, 60.0);
    
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: () => _showBinDetails(context, id),
        child: Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ]
          ),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.recycling, 
              color: const Color(0xFF2E7D32), 
              size: iconSize * 0.6,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mapa interactivo
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 6.0,
            constrained: false, 
            child: Stack(
              children: [
                // Imagen del mapa
                SizedBox(
                  width: 1600,
                  height: 1100,
                  child: Image.asset(
                    'assets/mapa_faunia.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.green[50],
                        alignment: Alignment.center,
                        child: const Text(
                          'Cargando mapa...',
                          style: TextStyle(color: Colors.green),
                        ),
                      );
                    },
                  ),
                ),
                // Marcadores fijos
                Positioned.fill(
                  child: Stack(
                    children: _markers.asMap().entries.map((entry) {
                      return _buildMarker(entry.value, entry.key + 1);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Header Flotante
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        )
                      ]
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map, color: Color(0xFF2E7D32), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Mapa Faunia',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110.0), // Padding to clear bottom nav
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2E7D32),
          elevation: 4,
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
          label: const Text('Escanear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () => context.push('/scanner'),
        ),
      ),
    );
  }
}
