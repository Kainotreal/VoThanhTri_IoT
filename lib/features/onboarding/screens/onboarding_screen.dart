import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/pagination_indicator.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _mockupController = PageController();
  final PageController _textController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Empower Your Home,\nSimplify Your Life',
      'description': 'Transform your living space into a smarter,\nmore connected home with Smartify.\nAll at your fingertips.',
    },
    {
      'title': 'Effortless Control,\nAutomate, & Secure',
      'description': 'Smartify empowers you to control your\ndevices, & automate your routines. Embrace a\nworld where your home adapts to your needs.',
    },
    {
      'title': 'Efficiency that Saves,\nComfort that Lasts.',
      'description': "Take control of your home's energy usage, set\npreferences, and enjoy a space that adapts to\nyour needs while saving power.",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Sync mockup swipe to text
    _mockupController.addListener(() {
      if (_mockupController.page != null) {
        _textController.jumpTo(_mockupController.offset);
      }
    });
  }

  @override
  void dispose() {
    _mockupController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < _onboardingData.length - 1) {
      _mockupController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.getStarted);
    }
  }

  void _onSkip() {
    context.go(AppRoutes.getStarted);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Blue Background (Top Half)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.7, // Extend further down for longer mockup
            child: Container(color: AppColors.primary),
          ),

          // 2. Mockups Layer
          Positioned(
            top: size.height * 0.04, // Better relative positioning
            left: 0,
            right: 0,
            height: size.height * 0.62, // Longer phone mockup
            child: PageView.builder(
              controller: _mockupController,
              itemCount: _onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Center(
                  child: Container(
                    height: size.height * 0.58, // Inner phone height
                    width: size.width * 0.72,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(42),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Container(
                        color: Colors.white,
                        child: _buildMockupForIndex(index),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. White Scoop Overlay (ON TOP of mockup)
          Positioned(
            top: size.height * 0.52, // Lower than half the screen (0.5)
            left: 0,
            right: 0,
            bottom: 0, // Fill all the way down to be seamless
            child: IgnorePointer(
              child: ClipPath(
                clipper: ScoopClipper(),
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // 4. Content Area (Titles, Buttons - TOPMOST)
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.64), // Space matching the lower scoop curve
                Expanded(
                  child: Column(
                    children: [
                      // Text PageView (Synced with mockup)
                      Expanded(
                        child: PageView.builder(
                          controller: _textController,
                          itemCount: _onboardingData.length,
                          physics: const NeverScrollableScrollPhysics(), // Controlled by mockup swipe
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _onboardingData[index]['title']!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1F1F1F),
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _onboardingData[index]['description']!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF757575),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Pagination Dots
                      PaginationIndicator(
                        totalCount: _onboardingData.length,
                        currentIndex: _currentIndex,
                      ),
                      const SizedBox(height: 32),
                      // Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _currentIndex == 2
                            ? PrimaryButton(
                                text: "Let's Get Started",
                                onPressed: _onNext,
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: SecondaryButton(
                                      text: "Skip",
                                      onPressed: _onSkip,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: PrimaryButton(
                                      text: "Continue",
                                      onPressed: _onNext,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockupForIndex(int index) {
    switch (index) {
      case 0: return _buildHomeMockup();
      case 1: return _buildAutomationMockup();
      case 2: return _buildStatsMockup();
      default: return _buildHomeMockup();
    }
  }

  Widget _buildMockupStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 70, height: 20,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('9:41', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Icon(Icons.signal_cellular_alt, size: 9),
                  SizedBox(width: 4), Icon(Icons.wifi, size: 9),
                  SizedBox(width: 4), Icon(Icons.battery_full, size: 9),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeMockup() {
    return Column(
      children: [
        _buildMockupStatusBar(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Text('My Home', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                const SizedBox(width: 4), const Icon(Icons.keyboard_arrow_down, size: 14),
              ]),
              const Row(children: [
                Icon(Icons.smart_toy_outlined, size: 20, color: AppColors.primary),
                SizedBox(width: 12), Icon(Icons.notifications_none_outlined, size: 20),
              ]),
            ],
          ),
        ),
        Container(
          height: 110, margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6392F9), Color(0xFF246BFD)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(children: [
                const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('20 °C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  Text('New York City, USA', style: TextStyle(color: Colors.white70, fontSize: 8)),
                  SizedBox(height: 4), Text('Today Cloudy', style: TextStyle(color: Colors.white, fontSize: 9)),
                ]),
                const Spacer(),
                Stack(alignment: Alignment.center, children: [
                  const Icon(Icons.cloud, color: Colors.white, size: 48),
                  Positioned(right: 0, top: 0, child: Icon(Icons.sunny, color: Colors.orange.shade300, size: 24)),
                ]),
              ]),
              const Spacer(),
              const Row(children: [
                Icon(Icons.air, color: Colors.white70, size: 10), SizedBox(width: 2), Text('AQI 92', style: TextStyle(color: Colors.white70, fontSize: 7)),
                SizedBox(width: 12), Icon(Icons.water_drop_outlined, color: Colors.white70, size: 10), SizedBox(width: 2), Text('78.2%', style: TextStyle(color: Colors.white70, fontSize: 7)),
                SizedBox(width: 12), Icon(Icons.wind_power_outlined, color: Colors.white70, size: 10), SizedBox(width: 2), Text('2.3 m/s', style: TextStyle(color: Colors.white70, fontSize: 7)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _buildMiniCard(const Color(0xFFFFF9EE), Icons.lightbulb_outline, 'Lightning', '12 lights', Colors.amber),
            _buildMiniCard(const Color(0xFFF7F2FF), Icons.videocam_outlined, 'Cameras', '8 cameras', Colors.purple),
            _buildMiniCard(const Color(0xFFFFEEEE), Icons.bolt, 'Electrical', '6 devices', Colors.red),
          ]),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('All Devices', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            const Icon(Icons.more_vert, size: 16),
          ]),
        ),
        const SizedBox(height: 10),
        Row(children: [
          const SizedBox(width: 12), _buildSmallChip('All Rooms (37)', false),
          const SizedBox(width: 8), _buildSmallChip('Living Room (8)', true),
          const SizedBox(width: 8), _buildSmallChip('Bedroom', false),
        ]),
        const Spacer(), _buildHomeIndicator(),
      ],
    );
  }

  Widget _buildAutomationMockup() {
    return Column(
      children: [
        _buildMockupStatusBar(),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('My Home', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            const Row(children: [Icon(Icons.description_outlined, size: 20), SizedBox(width: 12), Icon(Icons.grid_view, size: 20)]),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(children: [
            Expanded(child: Container(
              height: 36, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)),
              alignment: Alignment.center, child: const Text('Automation', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            )),
            const SizedBox(width: 12),
            Expanded(child: Container(
              height: 36, decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(18)),
              alignment: Alignment.center, child: const Text('Tap-to-Run', style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)),
            )),
          ]),
        ),
        const SizedBox(height: 16),
        _buildAutomationItem('Turn ON All the Lights', '1 task', [Icons.access_time, Icons.arrow_forward, Icons.sunny], true),
        _buildAutomationItem('Go to Office', '2 tasks', [Icons.location_on, Icons.arrow_forward, Icons.phone_android, Icons.watch], true),
        _buildAutomationItem('Energy Saver Mode', '2 tasks', [Icons.cloud, Icons.arrow_forward, Icons.shield_moon], false),
        const Spacer(), _buildHomeIndicator(),
      ],
    );
  }

  Widget _buildStatsMockup() {
    return Column(
      children: [
        _buildMockupStatusBar(),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('My Home', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            const Row(children: [Icon(Icons.calendar_month_outlined, size: 20), SizedBox(width: 12), Icon(Icons.more_vert, size: 20)]),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(children: [
            Expanded(child: _buildEnergyCard('This month', '825.40', Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _buildEnergyCard('Previous', '958.75', Colors.blue)),
          ]),
        ),
        const SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFFBFBFB), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(6)), child: const Row(children: [Text('Last 6 Months', style: TextStyle(fontSize: 7)), Icon(Icons.keyboard_arrow_down, size: 8)])),
            ]),
            const SizedBox(height: 12),
            SizedBox(height: 100, child: Stack(clipBehavior: Clip.none, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.end, children: [
                _buildChartBar(35, 'Jul'), _buildChartBar(50, 'Aug'), _buildChartBar(65, 'Sept'), _buildChartBar(85, 'Oct', isSelected: true), _buildChartBar(70, 'Nov'), _buildChartBar(55, 'Dec'),
              ]),
              Positioned(top: 0, left: 0, right: 0, child: Center(child: Transform.translate(offset: const Offset(12, -10), child: Column(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)), child: const Text('118.48 kwh', style: TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold))),
                const Icon(Icons.location_on, color: AppColors.primary, size: 10),
              ])))),
            ])),
          ]),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Devices', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            Icon(Icons.more_vert, size: 16),
          ]),
        ),
        const Spacer(), _buildHomeIndicator(),
      ],
    );
  }

  Widget _buildHomeIndicator() {
    return Container(width: 100, height: 4, margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(2)));
  }

  Widget _buildMiniCard(Color bgColor, IconData icon, String label, String sub, Color color) {
    return Container(width: 72, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: color), const SizedBox(height: 10), Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(fontSize: 7, color: Colors.black45)),
    ]));
  }

  Widget _buildAutomationItem(String title, String tasks, List<IconData> icons, bool isOn) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF5F5F7))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), Text(tasks, style: const TextStyle(color: Colors.black38, fontSize: 8))]),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black26),
        ]),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: icons.map((icon) => Padding(padding: const EdgeInsets.only(right: 8), child: Icon(icon, size: 14, color: AppColors.primary))).toList()),
          SizedBox(width: 32, height: 18, child: Transform.scale(scale: 0.7, child: Switch(value: isOn, onChanged: (v) {}, activeColor: AppColors.primary))),
        ]),
      ]),
    );
  }

  Widget _buildEnergyCard(String label, String val, Color color) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFBFBFB), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.bolt, size: 12, color: color)), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 7, color: Colors.black54))]),
      const SizedBox(height: 6), Text('$val kwh', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    ]));
  }

  Widget _buildChartBar(double height, String label, {bool isSelected = false}) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Container(width: 16, height: height, decoration: BoxDecoration(color: isSelected ? AppColors.primary : const Color(0xFFCADBFF), borderRadius: BorderRadius.circular(4))),
      const SizedBox(height: 6), Text(label, style: const TextStyle(fontSize: 6, color: Colors.black38)),
    ]);
  }

  Widget _buildSmallChip(String label, bool isActive) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: isActive ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isActive ? AppColors.primary : Colors.black12)), child: Text(label, style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.black54)));
  }
}

class ScoopClipper extends CustomClipper<ui.Path> {
  @override
  ui.Path getClip(Size size) {
    ui.Path path = ui.Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, 80, size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<ui.Path> oldClipper) => false;
}
