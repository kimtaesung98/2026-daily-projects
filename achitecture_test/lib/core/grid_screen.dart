import 'package:flutter/material.dart';
import '../feature/weather/screen/weather_screen.dart';

// ─────────────────────────────────────────────
// CORE: Do NOT modify this file after creation.
// Grid layout is the immutable shell.
// Features register themselves as GridNode entries.
// ─────────────────────────────────────────────

class GridNode {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget destination;

  const GridNode({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.destination,
  });
}

// ── Register feature nodes here ──
final List<GridNode> gridNodes = [
  GridNode(
    title: 'Weather',
    subtitle: 'Live forecast & chart',
    icon: Icons.cloud_outlined,
    color: const Color(0xFF4A90D9),
    destination: const WeatherScreen(),
  ),
  // Add more nodes below as your project grows
  GridNode(
    title: 'Coming Soon',
    subtitle: 'Next feature',
    icon: Icons.add_circle_outline,
    color: const Color(0xFF9B9B9B),
    destination: const _PlaceholderScreen(),
  ),
  /*
  추가되는 node
  */
  GridNode(
    title: 'Coming Soon',
    subtitle: 'Next feature',
    icon: Icons.add_circle_outline,
    color: const Color(0xFF9B9B9B),
    destination: const _PlaceholderScreen(),
  ),
];

class GridScreen extends StatelessWidget {
  const GridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Daily Practice',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE0E0E0), height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          // ── Core rule: always 2 columns, expands downward ──
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: gridNodes.length,
          itemBuilder: (context, index) {
            return _GridCard(node: gridNodes[index]);
          },
        ),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final GridNode node;
  const _GridCard({required this.node});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => node.destination),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: node.color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: node.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(node.icon, color: node.color, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    node.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A8A9A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coming Soon')),
      body: const Center(child: Text('Next feature goes here')),
    );
  }
}
