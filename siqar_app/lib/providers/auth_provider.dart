import 'dart:io';
import 'package:flutter/material.dart';
import 'package:siqar_app/models/user_model.dart';
import 'package:siqar_app/services/api_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, registering, verifying }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String _message = '';
  bool _loading = false;
  
  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String get message => _message;
  bool get loading => _loading;
  bool get isAdmin => _user?.peran == 'admin';
  
  // Initialization
  Future<void> initialize() async {
    _setLoading(true);
    
    bool isLoggedIn = await _apiService.isLoggedIn();
    
    if (isLoggedIn) {
      // Get user profile
      User? user = await _apiService.getProfile();
      
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    
    _setLoading(false);
  }
  
  // Register
  Future<bool> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _status = AuthStatus.registering;
    
    final response = await _apiService.register(userData);
    
    if (response['status'] == true) {
      _message = response['message'];
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _message = response['message'] ?? 'Terjadi kesalahan saat registrasi.';
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
  
  // Verify OTP
  Future<bool> verifyOtp(String email, String otp) async {
    _setLoading(true);
    _status = AuthStatus.verifying;
    
    final response = await _apiService.verifyOtp(email, otp);
    
    if (response['status'] == true) {
      _user = User.fromJson(response['data']['user']);
      _status = AuthStatus.authenticated;
      _message = response['message'];
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _message = response['message'] ?? 'Verifikasi OTP gagal.';
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
  
  // Resend OTP
  Future<bool> resendOtp(String email) async {
    _setLoading(true);
    
    final response = await _apiService.resendOtp(email);
    
    if (response['status'] == true) {
      _message = response['message'];
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _message = response['message'] ?? 'Gagal mengirim ulang OTP.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
  
  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    
    final response = await _apiService.login(email, password);
    
    if (response['status'] == true) {
      _user = User.fromJson(response['data']['user']);
      _status = AuthStatus.authenticated;
      _message = response['message'];
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _message = response['message'] ?? 'Login gagal.';
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
  
  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    
    final response = await _apiService.forgotPassword(email);
    
    if (response['status'] == true) {
      _message = response['message'];
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _message = response['message'] ?? 'Gagal mengirim permintaan reset password.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
  
  // Reset Password
  Future<bool> resetPassword(String token, String password, String passwordConfirmation) async {
    _setLoading(true);
    
    final response = await _apiService.resetPassword(token, password, passwordConfirmation);
    
    if (response['status'] == true) {
      _message = response['message'];
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _message = response['message'] ?? 'Gagal reset password.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
  
  // Logout
  Future<bool> logout() async {
    _setLoading(true);
    
    final response = await _apiService.logout();
    
    // Even if logout fails on server, clear local data
    await _apiService.clearSession();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _message = response['message'] ?? 'Berhasil logout.';
    _setLoading(false);
    notifyListeners();
    return true;
  }
  
  // Get Profile
  Future<bool> getProfile() async {
    _setLoading(true);
    
    User? user = await _apiService.getProfile();
    
    if (user != null) {
      _user = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _message = 'Gagal memuat profil.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
  
  // Update Profile
  Future<bool> updateProfile(Map<String, dynamic> data, File? imageFile) async {
    _setLoading(true);
    
    final response = await _apiService.updateProfile(data, imageFile);
    
    if (response['status'] == true) {
      // Refresh profile
      await getProfile();
      _message = response['message'];
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _message = response['message'] ?? 'Gagal memperbarui profil.';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
  
  // Handle session expired
  void handleSessionExpired() {
    _user = null;
    _status = AuthStatus.unauthenticated;
    _message = 'Sesi Anda telah berakhir, silakan login kembali.';
    notifyListeners();
  }
  
  // Helper
  void _setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }
  
  void clearMessage() {
    _message = '';
    notifyListeners();
  }
}