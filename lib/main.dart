import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt_handler.dart';

void main() {
  runApp(const MaterialApp(
    home: KitchenLightPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class KitchenLightPage extends StatefulWidget {
  const KitchenLightPage({super.key});

  @override
  State<KitchenLightPage> createState() => _KitchenLightPageState();
}

class _KitchenLightPageState extends State<KitchenLightPage> {
  bool isOn = false;
  double intensity = 0.5;
  final MqttHandler mqttHandler = MqttHandler();

  @override
  void initState() {
    super.initState();
    mqttHandler.connect();
  }

  static const Color _bgColor = Color(0xFF233329);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              // Khu vực hiển thị đèn và hiệu ứng
              Expanded(
                child: _buildLampSection(),
              ),
              _buildDeviceInfo(),
              const SizedBox(height: 30),
              _buildCustomSwitch(),
              const SizedBox(height: 10),
              _buildIntensitySlider(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            SizedBox(width: 5),
            Text("Kitchen", style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        StreamBuilder<MqttConnectionState>(
          stream: mqttHandler.connectionState,
          initialData: MqttConnectionState.disconnected,
          builder: (context, snapshot) {
            Color statusColor = Colors.red;
            String statusText = "Disconnected";
            if (snapshot.data == MqttConnectionState.connected) {
              statusColor = Colors.green;
              statusText = "Connected";
            } else if (snapshot.data == MqttConnectionState.connecting) {
              statusColor = Colors.orange;
              statusText = "Connecting...";
            }

            return Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
                ),
                const SizedBox(width: 8),
                Text(statusText, style: TextStyle(color: statusColor, fontSize: 12)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLampSection() {
    return Stack(
      alignment: Alignment.topRight,
      clipBehavior: Clip.none,
      children: [
        // 1. QUẦNG SÁNG TỎA SAU ĐÈN
        Positioned(
          top: -35,
          right: -205, // Dịch sang phải 100px
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 700,
            height: 700,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(0.0, 0.0),
                colors: isOn
                    ? [
                  Colors.white.withOpacity(intensity * 0.7),
                  _bgColor.withOpacity(0),
                ]
                    : [
                  Colors.black.withOpacity(0.8),
                  _bgColor.withOpacity(0),
                ],
                stops: isOn ? const [0.1, 0.8] : const [0.0, 0.7],
              ),
            ),
          ),
        ),

        // 2. HIỆU ỨNG HÌNH BÁN NGUYỆT SIÊU SÁNG (Nằm ngay miệng đèn)


        // 2. HÌNH ẢNH CHIẾC ĐÈN 
        Positioned(
          top: -60,
          right: -100, 
          child: SizedBox(
            height: 480, 
            child: Image.asset(
              'assets/lamp.png',
              fit: BoxFit.contain,
            ),
          ),
        ),

        // 3. BÓNG ĐÈN (Render trên cùng)
        if (isOn)
          Positioned(
            top: 280, // Căn chỉnh cho khớp tâm miệng đèn
            right: 90, 
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isOn ? 1.0 : 0.0,
              child: Image.asset(
                'assets/light.png',
                width: 100, 
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDeviceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Island Kitchen Bar",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text("LED Pendant Ceiling Light",
            style: TextStyle(color: Colors.white60, fontSize: 16)),
      ],
    );
  }

  Widget _buildCustomSwitch() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isOn = !isOn;
              if (isOn && intensity < 0.1) intensity = 0.5;
              mqttHandler.publish('/topic/relay', isOn ? '1' : '0');
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 55,
            height: 28,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isOn ? const Color(0xFF8BA695).withOpacity(0.4) : Colors.white12,
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                decoration: BoxDecoration(
shape: BoxShape.circle,
                  color: isOn ? const Color(0xFF324D3E) : Colors.white70,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Text(isOn ? "ON" : "OFF",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildIntensitySlider() {
    return AnimatedOpacity(
      opacity: isOn ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: IgnorePointer(
        ignoring: !isOn,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text("Light Intensity",
                style: TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              children: [
                // Icon đèn nhỏ (bên trái)
                Image.asset(
                  'assets/icon1.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),

                // Thanh Slider nằm giữa
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white12,
                      thumbColor: Colors.white,
                      // Xóa bỏ padding mặc định của Slider để icon sát lại gần
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: intensity,
                      onChanged: (val) {
                        setState(() {
                          intensity = val;
                          if (intensity <= 0.05) {
                            isOn = false;
                            mqttHandler.publish('/topic/relay', '0');
                          }
                          mqttHandler.publish('/topic/led', (intensity * 100).toInt().toString());
                        });
                      },
                    ),
                  ),
                ),

                // Icon đèn lớn/sáng hơn (bên phải)
                Image.asset(
                  'assets/icon2.png',
                  width: 26,
                  height: 26,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}