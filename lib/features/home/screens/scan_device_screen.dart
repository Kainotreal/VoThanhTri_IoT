import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import 'add_device_screen.dart'; // To get DeviceItem 

class ScanDeviceScreen extends StatefulWidget {
  const ScanDeviceScreen({super.key});

  @override
  State<ScanDeviceScreen> createState() => _ScanDeviceScreenState();
}

class _ScanDeviceScreenState extends State<ScanDeviceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isDisposed = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_lineController);
  }

  void _handleScanSuccess([String? rawData]) {
    if (_isProcessing || _isDisposed) return;
    _isProcessing = true;
    
    // In log để debug
    print("Mã QR quét được: $rawData");

    DeviceItem? device;
    
    if (rawData != null && rawData.isNotEmpty) {
      try {
        final data = jsonDecode(rawData);
        
        // Trích xuất thông tin từ JSON (Chuẩn ESP Provisioning)
        final String name = data['name'] ?? data['prov_name'] ?? 'ESP32 Device';
        final String? pop = data['pop'] ?? data['setup_code'];
        
        device = DeviceItem(
          name: name,
          imageUrl: 'https://cdn3d.iconscout.com/3d/premium/thumb/smart-speaker-5321346-4444923.png',
          pop: pop,
          isFromQR: true,
        );
      } catch (e) {
        // Nếu không phải JSON, thử kiểm tra xem có phải chuỗi thuần không
        print("Lỗi parse JSON QR: $e");
        _showErrorSnackBar('Mã QR không đúng định dạng JSON của thiết bị.');
        _resetScanner();
        return;
      }
    }

    if (device != null) {
      // Dừng camera trước khi chuyển màn hình
      _cameraController.stop();
      if (mounted) {
        context.pushReplacement(AppRoutes.addDevice, extra: device);
      }
    } else {
      _resetScanner();
    }
  }

  void _resetScanner() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_isDisposed) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _lineController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Scan Device',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Real Camera Feed
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? rawValue = barcodes.first.rawValue;
                _handleScanSuccess(rawValue);
              }
            },
          ),
          
          // 2. Scanner Overlay
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),
                
                // Scan Frame
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        // Animated Scan Line
                        AnimatedBuilder(
                          animation: _lineAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: _lineAnimation.value * 246,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueAccent.withOpacity(0.6),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ]
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Instructions
                const Text(
                  "Can't scan the QR code?",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                
                // Enter codes manually button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Enter setup code manually',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Bottom Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Folder Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.folder_outlined, color: Colors.white),
                      ),
                      
                      // Scan Shutter Button (Force trigger for testing)
                      GestureDetector(
                        onTap: () {
                           _handleScanSuccess(null); 
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      
                      // Gallery Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.insert_photo_outlined, color: Colors.white),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
