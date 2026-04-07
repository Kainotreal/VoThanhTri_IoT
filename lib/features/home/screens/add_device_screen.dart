import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/device_service.dart';
import '../../../core/services/provisioning_service.dart';

enum AddDeviceStatus { selecting, found, provisioning, connecting, connected }

class DeviceItem {
  final String name;
  final String imageUrl;
  final String? instruction;
  final String? pop;
  final bool isFromQR;

  const DeviceItem({
    required this.name,
    required this.imageUrl,
    this.instruction,
    this.pop,
    this.isFromQR = false,
  });
}

const List<DeviceItem> _mockDevices = [
  DeviceItem(
    name: 'Smart VI CCTV',
    imageUrl: 'https://cdn3d.iconscout.com/3d/premium/thumb/cctv-camera-5332243-4467049.png',
  ),
  DeviceItem(
    name: 'Smart Webcam',
    imageUrl: 'https://cdn3d.iconscout.com/3d/premium/thumb/webcam-5321356-4444933.png',
  ),
  DeviceItem(
    name: 'Smart V2 CCTV',
    imageUrl: 'https://cdn3d.iconscout.com/3d/premium/thumb/security-camera-5321361-4444938.png',
  ),
  DeviceItem(
    name: 'Smart Lamp',
    imageUrl: 'https://cdn3d.iconscout.com/3d/premium/thumb/smart-bulb-5321345-4444922.png',
    instruction: 'Turn on the light and confirm whether the light blinks rapidly.',
  ),
  DeviceItem(
    name: 'Smart Speaker',
    imageUrl: 'https://cdn3d.iconscout.com/3d/premium/thumb/smart-speaker-5321346-4444923.png',
  ),
  DeviceItem(
    name: 'Wi-Fi Router',
    imageUrl: 'https://cdn3d.iconscout.com/3d/premium/thumb/wifi-router-5321360-4444937.png',
  ),
];

class AddDeviceScreen extends StatefulWidget {
  final DeviceItem? initialDevice;

  const AddDeviceScreen({super.key, this.initialDevice});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> with TickerProviderStateMixin {
  bool isNearbySelected = false; // Start with Manual view to match user path
  late AnimationController _progressController;
  AddDeviceStatus _status = AddDeviceStatus.selecting;
  double _progressValue = 0;
  DeviceItem? _selectedDevice;
  
  final List<String> _categories = ['Popular', 'Lightning', 'Camera', 'Electrical', 'Sensor', 'Gateway'];
  String _selectedCategory = 'Popular';
  
  final TextEditingController _ssidController = TextEditingController(text: 'MyHome_WiFi_2G');
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  
  int _connectionStep = 0; // 0: BLE, 1: WiFi credentials, 2: Internet
  String _connectionStatusText = 'Khởi tạo kết nối...';
  final List<String> _connectionSubtasks = [
    'Tìm kiếm thiết bị qua Bluetooth...',
    'Đang gửi thông tin định danh WiFi...',
    'Đang đợi thiết bị kết nối vào mạng...',
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.initialDevice != null) {
      _selectedDevice = widget.initialDevice;
      _status = AddDeviceStatus.found;
    }
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() {
          _progressValue = _progressController.value;
          
          if (_progressValue < 0.3) _connectionStep = 0;
          else if (_progressValue < 0.7) _connectionStep = 1;
          else _connectionStep = 2;
        });
      });
  }

  Future<void> _startConnecting() async {
    if (_selectedDevice == null) return;
    
    setState(() {
      _status = AddDeviceStatus.connecting;
    });

    final success = await ProvisioningService.provisionDevice(
      deviceName: _selectedDevice!.name,
      pop: _selectedDevice!.pop ?? '12345678', // Default or from QR
      ssid: _ssidController.text,
      password: _passwordController.text,
      onStatusUpdate: (status) {
        if (mounted) {
          setState(() {
            _connectionStatusText = status;
            // Tiến trình mượt mà dựa trên trạng thái
            if (status.contains('tìm kiếm')) _progressValue = 0.2;
            else if (status.contains('xác thực')) _progressValue = 0.4;
            else if (status.contains('gửi')) _progressValue = 0.6;
            else if (status.contains('áp dụng')) _progressValue = 0.8;
            else if (status.contains('Hoàn tất')) _progressValue = 1.0;
          });
        }
      },
    );

    if (success) {
      await _createDeviceOnBackend();
    } else {
      if (mounted) {
        setState(() {
          _status = AddDeviceStatus.found; 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cấp quyền thất bại. Vui lòng kiểm tra Bluetooth/WiFi và thử lại.'))
          );
        });
      }
    }
  }

  Future<void> _createDeviceOnBackend() async {
    if (_selectedDevice == null) return;
    
    // Final step: Register with backend
    final success = await DeviceService.createDevice(
      name: _selectedDevice!.name,
      topic: '/topic/relay', // Adjust based on lab requirements
    );

    if (mounted) {
      setState(() {
        _status = success ? AddDeviceStatus.connected : AddDeviceStatus.found;
      });
    }
  }

  void _selectDevice(DeviceItem device) {
    setState(() {
      _selectedDevice = device;
      _status = AddDeviceStatus.found;
    });
  }


  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _status == AddDeviceStatus.connected 
          ? _buildConnectedAppBar() 
          : _buildStandardAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 16),
          if (_status == AddDeviceStatus.selecting) _buildToggleTabs(),
          if (_status == AddDeviceStatus.selecting) const SizedBox(height: 24),
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildConnectedAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 0,
    );
  }

  PreferredSizeWidget _buildStandardAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          if (_status != AddDeviceStatus.selecting && _status != AddDeviceStatus.connected) {
            // go back to selection view instead of popping the screen
            setState(() {
              _status = AddDeviceStatus.selecting;
              _progressController.stop();
              _progressValue = 0;
            });
          } else {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              Navigator.of(context).pop();
            }
          }
        },
      ),
      title: Text(
        widget.initialDevice != null ? 'Device Detected' : 'Add Device',
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: true,
      actions: [
        if (widget.initialDevice == null) 
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
            onPressed: () {
              context.push(AppRoutes.scanDevice);
            },
          ),
        if (widget.initialDevice != null) 
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
      ],
    );
  }

  Widget _buildToggleTabs() {
    if (widget.initialDevice != null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isNearbySelected = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isNearbySelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Nearby Devices',
                    style: TextStyle(
                      color: isNearbySelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isNearbySelected = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isNearbySelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Add Manual',
                    style: TextStyle(
                      color: !isNearbySelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_status == AddDeviceStatus.selecting) {
      if (isNearbySelected) {
        return const Center(child: Text('Scanning for Nearby Devices...', style: TextStyle(color: Colors.grey)));
      } else {
        return _buildManualAddView();
      }
    }

    if (_selectedDevice == null) return const SizedBox.shrink();

    switch (_status) {
      case AddDeviceStatus.found:
        return _buildFoundView();
      case AddDeviceStatus.provisioning:
        return _buildProvisioningView();
      case AddDeviceStatus.connecting:
        return _buildConnectingView();
      case AddDeviceStatus.connected:
        return _buildConnectedView();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildManualAddView() {
    return Column(
      children: [
        // Horizontal category list
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Devices Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: _mockDevices.length,
            itemBuilder: (context, index) {
              final device = _mockDevices[index];
              return GestureDetector(
                onTap: () => _selectDevice(device),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Image.network(
                            device.imageUrl,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.device_hub, size: 64, color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
                        child: Text(
                          device.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCameraImage() {
    return Image.network(
      _selectedDevice!.imageUrl,
      height: 200,
      errorBuilder: (context, error, stackTrace) => 
          Icon(Icons.videocam, size: 150, color: Colors.grey.shade400),
    );
  }

  Widget _buildHeaderInfo() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          'Connect to device',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi, size: 12, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bluetooth, size: 12, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              'Turn on your WiFi & Bluetooth to connect',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        if (_selectedDevice?.instruction != null) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _selectedDevice!.instruction!,
              style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              _selectedDevice!.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildFoundView() {
    return Column(
      children: [
        _buildHeaderInfo(),
        _buildCameraImage(),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _selectedDevice!.isFromQR 
            ? PrimaryButton(
                text: 'Configure WiFi',
                onPressed: () => setState(() => _status = AddDeviceStatus.provisioning),
              )
            : Column(
                children: [
                  const Text(
                    'Thiết bị này yêu cầu mã QR để kết nối bảo mật.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Quét mã QR',
                    icon: Icons.qr_code_scanner,
                    onPressed: () => context.push(AppRoutes.scanDevice),
                  ),
                ],
              ),
        ),
        const SizedBox(height: 24),
        _buildFooterLearMore(),
      ],
    );
  }

  Widget _buildProvisioningView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: _buildCameraImage(),
          ),
          const SizedBox(height: 32),
          const Text(
            'WiFi Configuration',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please select the WiFi network you want your device to connect to.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 32),
          
          // SSID Input
          const Text('WiFi Name (SSID)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          TextField(
            controller: _ssidController,
            decoration: InputDecoration(
              hintText: 'Enter SSID',
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: const Icon(Icons.wifi, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          
          // Password Input
          const Text('Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Enter Password',
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          
          const SizedBox(height: 48),
          PrimaryButton(
            text: 'Send Provisioning Data',
            onPressed: () {
              // Simulate sending data via BLE
              _startConnecting();
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildConnectingView() {
    return Column(
      children: [
        _buildHeaderInfo(),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CustomPaint(painter: ConnectionProgressPainter(_progressValue)),
                  ),
                  _buildCameraImage(),
                ],
              ),
              const SizedBox(height: 48),
              if (_selectedDevice!.isFromQR) ...[
                 Text(
                   _connectionStatusText,
                   style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                 ),
                 const SizedBox(height: 12),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: List.generate(3, (index) {
                     return Container(
                       margin: const EdgeInsets.symmetric(horizontal: 4),
                       width: index == _connectionStep ? 12 : 8,
                       height: 8,
                       decoration: BoxDecoration(
                         color: index <= _connectionStep ? AppColors.primary : Colors.grey.shade300,
                         borderRadius: BorderRadius.circular(4),
                       ),
                     );
                   }),
                 ),
              ] else ...[
                const Text(
                  'Connecting...',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                '${(_progressValue * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        _buildFooterLearMore(),
      ],
    );
  }

  Widget _buildFooterLearMore() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          const Text(
            "Can't connect with your devices?",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Learn more',
              style: TextStyle(
                color: AppColors.primary, 
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedView() {
    return Column(
      children: [
        const SizedBox(height: 80),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 32),
        const Text(
          'Connected!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Text(
          'You have connected to ${_selectedDevice!.name}.',
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 64),
        _buildCameraImage(),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.transparent),
                      backgroundColor: const Color(0xFFF0F5FF), // Light blue background
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    onPressed: () {
                       if (GoRouter.of(context).canPop()) {
                         context.pop();
                       } else {
                         Navigator.of(context).pop();
                       }
                    },
                    child: const Text(
                      'Go to Homepage',
                      style: TextStyle(
                        color: AppColors.primary, 
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Control Device',
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ConnectionProgressPainter extends CustomPainter {
  final double progress;
  ConnectionProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    final Paint bgPaint = Paint()
      ..color = const Color(0xFFF0F5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    final Paint fgPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0;

    canvas.drawCircle(Offset(centerX, centerY), radius, bgPaint);
    
    final double sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(ConnectionProgressPainter oldDelegate) => oldDelegate.progress != progress;
}
