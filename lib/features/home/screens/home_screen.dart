import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/primary_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedRoomIndex = 1; // "Living Room" selected by default
  int _bottomNavIndex = 0;

  final List<String> _rooms = ['All Rooms', 'Living Room', 'Bedroom', 'Kitchen', 'Office'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildWeatherCard(),
                        const SizedBox(height: 24),
                        _buildSectionHeader('All Devices'),
                        const SizedBox(height: 16),
                        _buildRoomFilters(),
                        const SizedBox(height: 40),
                        _buildEmptyState(),
                        const SizedBox(height: 100), // Space for bottom nav/FAB
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _buildFloatingButtons(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          const Text('My Home', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1F1F1F))),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 28, color: Color(0xFF1F1F1F)),
          const Spacer(),
          // Robot Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blue.shade100, width: 1.5)),
            child: const Icon(Icons.smart_toy_outlined, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 16),
          // Notification Bell
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                child: const Icon(Icons.notifications_none_outlined, size: 24, color: Color(0xFF1F1F1F)),
              ),
              Positioned(right: 1, top: 1, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 1.5))))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      width: double.infinity,
      height: 200, // Increased height to prevent overflow
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A7DFF), Color(0xFF246BFD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF246BFD).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Geometric Pattern Background
            Positioned.fill(child: CustomPaint(painter: WeatherPatternPainter())),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20), // Slightly reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '20 °C',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 44, // Slightly reduced to fit better
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'New York City, USA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Today Cloudy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildWeatherExtra(Icons.air, 'AQI 92'),
                      const SizedBox(width: 16),
                      _buildWeatherExtra(Icons.water_drop_outlined, '78.2%'),
                      const SizedBox(width: 16),
                      _buildWeatherExtra(Icons.wind_power_outlined, '2.0 m/s'),
                    ],
                  ),
                ],
              ),
            ),
            
            // Weather Illustration
            Positioned(
              right: 0,
              top: 20,
              child: SizedBox(
                width: 170,
                height: 140,
                child: Stack(
                  children: [
                    // Sun
                    Positioned(
                      right: 25,
                      top: 15,
                      child: Container(
                        width: 75,
                        height: 75,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFE082), Color(0xFFFF9800)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFF9800),
                              blurRadius: 20,
                              spreadRadius: -5,
                            )
                          ],
                        ),
                      ),
                    ),
                    // Background Cloud (more transparent)
                    Positioned(
                      right: 5,
                      bottom: 25,
                      child: Icon(
                        Icons.cloud,
                        size: 90,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    // Foreground Cloud (solid/main)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Icon(
                        Icons.cloud,
                        size: 120,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherExtra(IconData icon, String label) {
    // Custom icon mapper for better match
    IconData displayIcon = icon;
    if (icon == Icons.air) displayIcon = Icons.spa; // Using spa for leaf icon (AQI)

    return Row(
      children: [
        Icon(displayIcon, size: 16, color: Colors.white.withOpacity(0.9)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(1.0),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1F1F1F))),
        const Icon(Icons.more_vert, color: Colors.black26),
      ],
    );
  }

  Widget _buildRoomFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_rooms.length, (index) {
          final isSelected = _selectedRoomIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedRoomIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.primary : Colors.black.withOpacity(0.05)),
                  boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
                ),
                child: Text(_rooms[index], style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          // Empty State Illustration
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(left: 40, child: _buildClipboard(color: Colors.black.withOpacity(0.02), rotation: -0.15)),
                _buildClipboard(color: Colors.white, hasClip: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('No Devices', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F1F1F))),
          const SizedBox(height: 12),
          const Text('You haven\'t added a device yet.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black38, fontWeight: FontWeight.w500)),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: PrimaryButton(
              text: 'Add Device',
              onPressed: () {},
              icon: Icons.add,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClipboard({required Color color, double rotation = 0, bool hasClip = false}) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 100, height: 130,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), boxShadow: color == Colors.white ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))] : null),
        child: hasClip ? Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(top: -10, child: Container(width: 40, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)))),
            Positioned(top: 5, child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))),
            Column(
              children: [
                const SizedBox(height: 30),
                ...List.generate(3, (index) => Container(width: 60, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)))),
              ],
            ),
          ],
        ) : null,
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Positioned(
      bottom: 20, left: 0, right: 0,
            child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Voice Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF0F5FF), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
              child: const Icon(Icons.mic_none, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            // Add Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))]),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 30), // Padding for home indicator
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_filled, 'Home'),
          _buildNavItem(1, Icons.check_box_outlined, 'Smart'),
          _buildNavItem(2, Icons.insights_outlined, 'Reports'),
          _buildNavItem(3, Icons.person_outline, 'Account'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _bottomNavIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppColors.primary : Colors.black26, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isSelected ? AppColors.primary : Colors.black26, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}

class WeatherPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double side = 40.0;
    final double h = side * 0.866; // height adjustment for hex grid

    for (double y = -h; y < size.height + h; y += h * 2) {
      for (double x = -side; x < size.width + side; x += side * 3) {
        _drawIsometricCube(canvas, x, y, side, h, paint);
        _drawIsometricCube(canvas, x + side * 1.5, y + h, side, h, paint);
      }
    }
  }

  void _drawIsometricCube(Canvas canvas, double x, double y, double side, double h, Paint paint) {
    final path = Path();
    path.moveTo(x, y);
    path.lineTo(x + side, y);
    path.lineTo(x + side * 1.5, y + h);
    path.lineTo(x + side, y + h * 2);
    path.lineTo(x, y + h * 2);
    path.lineTo(x - side * 0.5, y + h);
    path.close();
    canvas.drawPath(path, paint);

    // Cube inner lines
    canvas.drawLine(Offset(x, y), Offset(x + side * 0.5, y + h), paint);
    canvas.drawLine(Offset(x + side * 1.5, y + h), Offset(x + side * 0.5, y + h), paint);
    canvas.drawLine(Offset(x + side * 0.5, y + h), Offset(x + side, y + h * 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
