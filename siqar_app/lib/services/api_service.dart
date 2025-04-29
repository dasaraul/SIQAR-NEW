import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siqar_app/models/user_model.dart';
import 'package:siqar_app/models/absensi_model.dart';
import 'package:siqar_app/models/qrcode_model.dart';
import 'package:siqar_app/utils/constants.dart';

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      validateStatus: (status) => status! < 500, // Consider only 5xx as errors
    ));
    
    // Setup request interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }

  // AUTH ENDPOINTS
  
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/register', data: userData);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      
      final responseData = _handleResponse(response);
      
      if (responseData['status'] == true && responseData['data'] != null) {
        // Save token
        final token = responseData['data']['access_token'];
        await _storage.write(key: 'auth_token', value: token);
        
        // Save user data
        final userData = jsonEncode(responseData['data']['user']);
        await _storage.write(key: 'user_data', value: userData);
      }
      
      return responseData;
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post('/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      
      final responseData = _handleResponse(response);
      
      if (responseData['status'] == true && responseData['data'] != null) {
        // Save token
        final token = responseData['data']['access_token'];
        await _storage.write(key: 'auth_token', value: token);
        
        // Save user data
        final userData = jsonEncode(responseData['data']['user']);
        await _storage.write(key: 'user_data', value: userData);
      }
      
      return responseData;
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final response = await _dio.post('/resend-otp', data: {
        'email': email,
      });
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post('/forgot-password', data: {
        'email': email,
      });
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> resetPassword(String token, String password, String passwordConfirmation) async {
    try {
      final response = await _dio.post('/reset-password', data: {
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post('/logout');
      final responseData = _handleResponse(response);
      
      if (responseData['status'] == true) {
        // Clear storage
        await _storage.delete(key: 'auth_token');
        await _storage.delete(key: 'user_data');
      }
      
      return responseData;
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<User?> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      final responseData = _handleResponse(response);
      
      if (responseData['status'] == true && responseData['data'] != null) {
        final userData = responseData['data']['user'];
        
        // Update stored user data
        await _storage.write(key: 'user_data', value: jsonEncode(userData));
        
        return User.fromJson(userData);
      }
      
      return null;
    } catch (e) {
      _handleError(e);
      return null;
    }
  }
  
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data, File? imageFile) async {
    try {
      FormData formData = FormData.fromMap(data);
      
      if (imageFile != null) {
        formData.files.add(MapEntry(
          'foto_profil',
          await MultipartFile.fromFile(imageFile.path, filename: 'profile.jpg'),
        ));
      }
      
      final response = await _dio.post('/update-profile', data: formData);
      final responseData = _handleResponse(response);
      
      if (responseData['status'] == true) {
        // Refresh profile data
        await getProfile();
      }
      
      return responseData;
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // ABSENSI ENDPOINTS
  
  Future<Map<String, dynamic>> scanQR(String qrCode, double latitude, double longitude, String tipe) async {
    try {
      final response = await _dio.post('/absensi/scan-qr', data: {
        'qr_code': qrCode,
        'latitude': latitude,
        'longitude': longitude,
        'tipe': tipe,
      });
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<List<Absensi>?> getAbsensiHistory({String? tanggalMulai, String? tanggalAkhir, String? status, int page = 1}) async {
    try {
      Map<String, dynamic> params = {
        'page': page,
        'per_page': 20,
      };
      
      if (tanggalMulai != null) params['tanggal_mulai'] = tanggalMulai;
      if (tanggalAkhir != null) params['tanggal_akhir'] = tanggalAkhir;
      if (status != null) params['status'] = status;
      
      final response = await _dio.get('/absensi/history', queryParameters: params);
      final responseData = _handleResponse(response);
      
      if (responseData['status'] == true && responseData['data'] != null) {
        final List<dynamic> absensiList = responseData['data']['absensi'];
        return absensiList.map((json) => Absensi.fromJson(json)).toList();
      }
      
      return null;
    } catch (e) {
      _handleError(e);
      return null;
    }
  }
  
  Future<Map<String, dynamic>> getTodayAbsensi() async {
    try {
      final response = await _dio.get('/absensi/today');
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> requestLeave(String tanggal, String status, String keterangan, File? buktiFile) async {
    try {
      FormData formData = FormData.fromMap({
        'tanggal': tanggal,
        'status': status,
        'keterangan': keterangan,
      });
      
      if (buktiFile != null) {
        formData.files.add(MapEntry(
          'bukti',
          await MultipartFile.fromFile(buktiFile.path, filename: 'bukti_${DateTime.now().millisecondsSinceEpoch}.jpg'),
        ));
      }
      
      final response = await _dio.post('/absensi/request-leave', data: formData);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<AbsensiLaporan?> getMonthlyReport({int? tahun, int? bulan, String? karyawanId}) async {
    try {
      Map<String, dynamic> params = {};
      
      if (tahun != null) params['tahun'] = tahun;
      if (bulan != null) params['bulan'] = bulan;
      if (karyawanId != null) params['karyawan_id'] = karyawanId;
      
      final response = await _dio.get('/absensi/monthly-report', queryParameters: params);
      final responseData = _handleResponse(response);
      
      if (responseData['status'] == true && responseData['data'] != null) {
        return AbsensiLaporan.fromJson(responseData['data']);
      }
      
      return null;
    } catch (e) {
      _handleError(e);
      return null;
    }
  }
  
  // QR CODE ENDPOINTS
  
  Future<Map<String, dynamic>> checkQRCode(String kode) async {
    try {
      final response = await _dio.post('/qrcode/check', data: {
        'kode': kode,
      });
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getActiveQRCode() async {
    try {
      final response = await _dio.get('/qrcode/active');
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> generateQRCode(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/qrcode/generate', data: data);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<List<QRCode>?> getAllQRCodes({String? tanggalMulai, String? tanggalAkhir, String? status, String? lokasiId, int page = 1}) async {
    try {
      Map<String, dynamic> params = {
        'page': page,
        'per_page': 20,
      };
      
      if (tanggalMulai != null) params['tanggal_mulai'] = tanggalMulai;
      if (tanggalAkhir != null) params['tanggal_akhir'] = tanggalAkhir;
      if (status != null) params['status'] = status;
      if (lokasiId != null) params['lokasi_id'] = lokasiId;
      
      final response = await _dio.get('/qrcode/all', queryParameters: params);
      final responseData = _handleResponse(response);
      
      if (responseData['status'] == true && responseData['data'] != null) {
        final List<dynamic> qrcodeList = responseData['data']['qrcodes'];
        return qrcodeList.map((json) => QRCode.fromJson(json)).toList();
      }
      
      return null;
    } catch (e) {
      _handleError(e);
      return null;
    }
  }
  
  Future<Map<String, dynamic>> deactivateQRCode(String id) async {
    try {
      final response = await _dio.put('/qrcode/$id/deactivate');
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // LOKASI ENDPOINTS
  
  Future<List<Lokasi>?> getAllLokasi({String? status, String? search, int page = 1}) async {
    try {
      Map<String, dynamic> params = {
        'page': page,
        'per_page': 20,
      };
      
      if (status != null) params['status'] = status;
      if (search != null) params['search'] = search;
      
      final response = await _dio.get('/lokasi', queryParameters: params);
      final responseData = _handleResponse(response);
      
      if (responseData['status'] == true && responseData['data'] != null) {
        final List<dynamic> lokasiList = responseData['data']['lokasi'];
        return lokasiList.map((json) => Lokasi.fromJson(json)).toList();
      }
      
      return null;
    } catch (e) {
      _handleError(e);
      return null;
    }
  }
  
  Future<Lokasi?> getLokasiById(String id) async {
    try {
      final response = await _dio.get('/lokasi/$id');
      final responseData = _handleResponse(response);
      
      if (responseData['status'] == true && responseData['data'] != null) {
        final lokasiData = responseData['data']['lokasi'];
        return Lokasi.fromJson(lokasiData);
      }
      
      return null;
    } catch (e) {
      _handleError(e);
      return null;
    }
  }
  
  Future<Map<String, dynamic>> createLokasi(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/lokasi', data: data);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateLokasi(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/lokasi/$id', data: data);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> deleteLokasi(String id) async {
    try {
      final response = await _dio.delete('/lokasi/$id');
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // USER SESSION MANAGEMENT
  
  Future<User?> getCurrentUser() async {
    try {
      final userData = await _storage.read(key: 'user_data');
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
  
  Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      return token != null;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> clearSession() async {
    await _storage.deleteAll();
  }
  
  // HELPER METHODS
  
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == 401) { // Unauthorized
      // Clear token and user data
      _storage.delete(key: 'auth_token');
      _storage.delete(key: 'user_data');
      
      return {
        'status': false,
        'message': 'Sesi Anda telah berakhir, silakan login kembali',
        'session_expired': true,
      };
    }
    
    if (response.data is Map) {
      return response.data;
    }
    
    return {
      'status': response.statusCode! < 300,
      'message': response.statusMessage,
      'data': response.data,
    };
  }
  
  Map<String, dynamic> _handleError(dynamic error) {
    String message = 'Terjadi kesalahan. Silakan coba lagi nanti.';
    
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        message = 'Koneksi timeout. Silakan periksa koneksi internet Anda.';
      } else if (error.type == DioExceptionType.connectionError) {
        message = 'Tidak dapat terhubung ke server. Silakan periksa koneksi internet Anda.';
      }
    }
    
    return {
      'status': false,
      'message': message,
    };
  }
}