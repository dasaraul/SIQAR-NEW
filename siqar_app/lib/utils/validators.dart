class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Email tidak valid';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    
    if (value != password) {
      return 'Password tidak sama';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    
    final phoneRegExp = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Nomor telepon tidak valid (10-15 digit)';
    }
    return null;
  }

  static String? validateNIP(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIP tidak boleh kosong';
    }
    
    if (value.length < 4) {
      return 'NIP minimal 4 karakter';
    }
    return null;
  }

  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kode OTP tidak boleh kosong';
    }
    
    final otpRegExp = RegExp(r'^[0-9]{6}$');
    if (!otpRegExp.hasMatch(value)) {
      return 'Kode OTP harus 6 digit angka';
    }
    return null;
  }
  
  static String? validateLatitude(String? value) {
    if (value == null || value.isEmpty) {
      return 'Latitude tidak boleh kosong';
    }
    
    try {
      final latitude = double.parse(value);
      if (latitude < -90 || latitude > 90) {
        return 'Latitude harus antara -90 dan 90';
      }
    } catch (e) {
      return 'Latitude harus berupa angka';
    }
    return null;
  }
  
  static String? validateLongitude(String? value) {
    if (value == null || value.isEmpty) {
      return 'Longitude tidak boleh kosong';
    }
    
    try {
      final longitude = double.parse(value);
      if (longitude < -180 || longitude > 180) {
        return 'Longitude harus antara -180 dan 180';
      }
    } catch (e) {
      return 'Longitude harus berupa angka';
    }
    return null;
  }
  
  static String? validateRadius(String? value) {
    if (value == null || value.isEmpty) {
      return 'Radius tidak boleh kosong';
    }
    
    try {
      final radius = int.parse(value);
      if (radius < 10) {
        return 'Radius minimal 10 meter';
      }
    } catch (e) {
      return 'Radius harus berupa angka';
    }
    return null;
  }
}