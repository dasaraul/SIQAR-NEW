import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:siqar_app/providers/absensi_provider.dart';
import 'package:siqar_app/utils/constants.dart';
import 'package:siqar_app/widgets/loading_overlay.dart';
import 'package:siqar_app/widgets/custom_button.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  bool _isQRChecked = false;
  bool _hasPermission = false;
  String _scanType = 'masuk'; // Default scan type
  bool _isTorchOn = false;
  
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }
  
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        setState(() {
          _hasPermission = false;
        });
        return;
      }
    }
    
    setState(() {
      _hasPermission = true;
    });
  }
  
  Future<Position?> _getCurrentLocation() async {
    try {
      if (!_hasPermission) {
        await _checkLocationPermission();
        if (!_hasPermission) {
          _showErrorDialog(
            'Izin lokasi dibutuhkan',
            'Aplikasi membutuhkan izin lokasi untuk melakukan absensi. Silakan aktifkan izin lokasi pada pengaturan perangkat Anda.'
          );
          return null;
        }
      }
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
    } catch (e) {
      _showErrorDialog(
        'Gagal Mendapatkan Lokasi', 
        'Terjadi kesalahan saat mendapatkan lokasi Anda. Pastikan GPS Anda aktif.'
      );
      return null;
    }
  }
  
  Future<void> _processScanResult(String code) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    // Check QR Code
    final absensiProvider = Provider.of<AbsensiProvider>(context, listen: false);
    final isValidQR = await absensiProvider.checkQRCode(code);
    
    if (!isValidQR) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(absensiProvider.message),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
      return;
    }
    
    setState(() {
      _isQRChecked = true;
      _isProcessing = false;
    });
  }
  
  Future<void> _submitAttendance() async {
    setState(() {
      _isProcessing = true;
    });
    
    // Get current location
    final position = await _getCurrentLocation();
    if (position == null) {
      setState(() {
        _isProcessing = false;
      });
      return;
    }
    
    // Submit attendance
    final absensiProvider = Provider.of<AbsensiProvider>(context, listen: false);
    final qrCode = absensiProvider.scannedQRCode;
    
    if (qrCode == null || qrCode.kode == null) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('QR Code tidak valid'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
      return;
    }
    
    final success = await absensiProvider.scanQRCode(
      qrCode.kode!,
      position.latitude,
      position.longitude,
      _scanType,
    );
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(absensiProvider.message),
            backgroundColor: AppConstants.successColor,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(absensiProvider.message),
            backgroundColor: AppConstants.errorColor,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScannerView() {
    if (!_hasPermission) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 80,
                color: AppConstants.textSecondaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Izin Lokasi Dibutuhkan',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Aplikasi membutuhkan izin lokasi untuk melakukan absensi. Silakan aktifkan izin lokasi pada pengaturan perangkat Anda.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Berikan Izin Lokasi',
                onPressed: _checkLocationPermission,
                icon: Icons.location_on,
              ),
            ],
          ),
        ),
      );
    }
    
    if (_isQRChecked) {
      final absensiProvider = Provider.of<AbsensiProvider>(context);
      final qrCode = absensiProvider.scannedQRCode;
      
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: AppConstants.successColor,
              ),
              const SizedBox(height: 24),
              Text(
                'QR Code Valid',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (qrCode != null)
                Column(
                  children: [
                    Text(
                      qrCode.deskripsi,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tanggal: ${qrCode.tanggal}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (qrCode.waktuMulai != null && qrCode.waktuBerakhir != null)
                      Text(
                        'Waktu: ${qrCode.waktuMulai} - ${qrCode.waktuBerakhir}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    if (qrCode.lokasi != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Lokasi: ${qrCode.lokasi!.namaLokasi}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 32),
              Text(
                'Pilih Jenis Absensi:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<String>(
                    value: 'masuk',
                    groupValue: _scanType,
                    onChanged: (value) {
                      setState(() {
                        _scanType = value!;
                      });
                    },
                    activeColor: AppConstants.primaryColor,
                  ),
                  const Text('Absen Masuk'),
                  const SizedBox(width: 24),
                  Radio<String>(
                    value: 'keluar',
                    groupValue: _scanType,
                    onChanged: (value) {
                      setState(() {
                        _scanType = value!;
                      });
                    },
                    activeColor: AppConstants.primaryColor,
                  ),
                  const Text('Absen Keluar'),
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Lakukan Absensi',
                onPressed: _submitAttendance,
                loading: _isProcessing,
                icon: Icons.check,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isQRChecked = false;
                  });
                },
                child: Text(
                  'Scan Ulang',
                  style: TextStyle(color: AppConstants.primaryColor),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (barcode, args) {
            if (barcode.rawValue != null && mounted && !_isProcessing) {
              final code = barcode.rawValue!;
              if (code.isNotEmpty) {
                _processScanResult(code);
              }
            }
          },
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppConstants.primaryColor,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.saturation,
                      ),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
              // Scanline animation
              Center(
                child: AnimatedPositioned(
                  duration: const Duration(seconds: 2),
                  top: 0,
                  curve: Curves.easeInOut,
                  child: Container(
                    width: 250,
                    height: 2,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final absensiProvider = Provider.of<AbsensiProvider>(context);
    
    return LoadingOverlay(
      isLoading: absensiProvider.loading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          actions: [
            if (!_isQRChecked)
              IconButton(
                icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
                onPressed: () {
                  setState(() {
                    _isTorchOn = !_isTorchOn;
                    _scannerController.toggleTorch();
                  });
                },
              ),
            if (!_isQRChecked)
              IconButton(
                icon: const Icon(Icons.flip_camera_ios),
                onPressed: () {
                  _scannerController.switchCamera();
                },
              ),
          ],
        ),
        body: _buildScannerView(),
      ),
    );
  }
  
  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}