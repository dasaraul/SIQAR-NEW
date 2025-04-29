import 'dart:io';
import 'package:flutter/material.dart';
import 'package:siqar_app/models/absensi_model.dart';
import 'package:siqar_app/models/qrcode_model.dart';
import 'package:siqar_app/services/api_service.dart';

class AbsensiProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // State variables
  bool _loading = false;
  String _message = '';
  Map<String, dynamic>? _todayAbsensi;
  List<Absensi>? _absensiHistory;
  AbsensiLaporan? _monthlyReport;
  QRCode? _scannedQRCode;
  
  // Getters
  bool get loading => _loading;
  String get message => _message;
  Map<String, dynamic>? get todayAbsensi => _todayAbsensi;
  List<Absensi>? get absensiHistory => _absensiHistory;
  AbsensiLaporan? get monthlyReport => _monthlyReport;
  QRCode? get scannedQRCode => _scannedQRCode;
  
  // Get today's attendance status
  Future<void> getTodayAbsensi() async {
    _setLoading(true);
    
    final response = await _apiService.getTodayAbsensi();
    
    if (response['status'] == true) {
      _todayAbsensi = response['data'];
    } else {
      _message = response['message'] ?? 'Gagal memuat status absensi hari ini.';
    }
    
    _setLoading(false);
  }
  
  // Get attendance history
  Future<void> getAbsensiHistory({String? tanggalMulai, String? tanggalAkhir, String? status, bool refresh = false}) async {
    if (refresh) {
      _absensiHistory = null;
    }
    
    _setLoading(true);
    
    final absensiList = await _apiService.getAbsensiHistory(
      tanggalMulai: tanggalMulai,
      tanggalAkhir: tanggalAkhir,
      status: status,
    );
    
    if (absensiList != null) {
      _absensiHistory = absensiList;
    } else {
      _message = 'Gagal memuat riwayat absensi.';
    }
    
    _setLoading(false);
  }
  
  // Scan QR Code for attendance
  Future<bool> scanQRCode(String qrCode, double latitude, double longitude, String tipe) async {
    _setLoading(true);
    
    final response = await _apiService.scanQR(qrCode, latitude, longitude, tipe);
    
    if (response['status'] == true) {
      _message = response['message'];
      // Refresh today's attendance
      await getTodayAbsensi();
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _message = response['message'] ?? 'Gagal melakukan absensi.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
  
  // Request leave/absence
  Future<bool> requestLeave(String tanggal, String status, String keterangan, File? buktiFile) async {
    _setLoading(true);
    
    final response = await _apiService.requestLeave(tanggal, status, keterangan, buktiFile);
    
    if (response['status'] == true) {
      _message = response['message'];
      // Refresh history
      await getAbsensiHistory(refresh: true);
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _message = response['message'] ?? 'Gagal mengajukan izin/sakit.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
  
  // Get monthly report
  Future<void> getMonthlyReport({int? tahun, int? bulan, String? karyawanId}) async {
    _setLoading(true);
    
    final report = await _apiService.getMonthlyReport(
      tahun: tahun,
      bulan: bulan,
      karyawanId: karyawanId,
    );
    
    if (report != null) {
      _monthlyReport = report;
    } else {
      _message = 'Gagal memuat laporan bulanan.';
    }
    
    _setLoading(false);
  }
  
  // Check QR Code
  Future<bool> checkQRCode(String kode) async {
    _setLoading(true);
    
    final response = await _apiService.checkQRCode(kode);
    
    if (response['status'] == true && response['data'] != null) {
      _scannedQRCode = QRCode.fromJson(response['data']['qrcode']);
      _message = response['message'];
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _message = response['message'] ?? 'QR Code tidak valid.';
      _scannedQRCode = null;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
  
  // Get active QR Code
  Future<QRCode?> getActiveQRCode() async {
    _setLoading(true);
    
    final response = await _apiService.getActiveQRCode();
    
    QRCode? qrCode;
    
    if (response['status'] == true && response['data'] != null) {
      qrCode = QRCode.fromJson(response['data']['qrcode']);
    } else {
      _message = response['message'] ?? 'Tidak ada QR Code aktif saat ini.';
    }
    
    _setLoading(false);
    return qrCode;
  }
  
  // Generate QR Code (Admin only)
  Future<bool> generateQRCode(Map<String, dynamic> data) async {
    _setLoading(true);
    
    final response = await _apiService.generateQRCode(data);
    
    if (response['status'] == true) {
      _message = response['message'];
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _message = response['message'] ?? 'Gagal membuat QR Code.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
  
  // Clear all data (for logout)
  void clearData() {
    _todayAbsensi = null;
    _absensiHistory = null;
    _monthlyReport = null;
    _scannedQRCode = null;
    _message = '';
    notifyListeners();
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }
  
  void clearMessage() {
    _message = '';
    notifyListeners();
  }
}