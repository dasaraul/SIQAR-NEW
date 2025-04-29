import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siqar_app/providers/auth_provider.dart';
import 'package:siqar_app/screens/auth/otp_verification_screen.dart';
import 'package:siqar_app/utils/constants.dart';
import 'package:siqar_app/utils/validators.dart';
import 'package:siqar_app/widgets/custom_button.dart';
import 'package:siqar_app/widgets/custom_text_field.dart';
import 'package:siqar_app/widgets/loading_overlay.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();
  final TextEditingController _departemenController = TextEditingController();
  final TextEditingController _noTeleponController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _namaLengkapController.dispose();
    _nipController.dispose();
    _jabatanController.dispose();
    _departemenController.dispose();
    _noTeleponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }
  
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }
  
  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }
  
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Prepare data
      final Map<String, dynamic> userData = {
        'nama': _namaController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
        'nama_lengkap': _namaLengkapController.text.trim(),
        'nip': _nipController.text.trim(),
        'jabatan': _jabatanController.text.trim(),
        'departemen': _departemenController.text.trim(),
        'no_telepon': _noTeleponController.text.trim(),
        'alamat': _alamatController.text.trim(),
      };
      
      // Register user
      final success = await authProvider.register(userData);
      
      if (success && mounted) {
        // Navigate to OTP verification
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.message),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return LoadingOverlay(
      isLoading: authProvider.loading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registrasi'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Logo
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        '${AppConstants.imagePath}logo.png',
                        width: 80,
                        height: 80,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppConstants.appName,
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConstants.appDescription,
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Account Info Section
                Text(
                  'Informasi Akun',
                  style: TextStyle(
                    color: AppConstants.textPrimaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Nama
                CustomTextField(
                  controller: _namaController,
                  labelText: 'Nama',
                  hintText: 'Masukkan nama Anda',
                  prefixIcon: Icons.person,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                
                // Email
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Masukkan email Anda',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                
                // Password
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Minimal 8 karakter',
                  prefixIcon: Icons.lock,
                  obscureText: _obscurePassword,
                  validator: Validators.validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppConstants.textSecondaryColor,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Confirm Password
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Konfirmasi Password',
                  hintText: 'Masukkan ulang password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) => Validators.validateConfirmPassword(
                    value, 
                    _passwordController.text,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppConstants.textSecondaryColor,
                    ),
                    onPressed: _toggleConfirmPasswordVisibility,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Employee Info Section
                Text(
                  'Informasi Karyawan',
                  style: TextStyle(
                    color: AppConstants.textPrimaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // NIP
                CustomTextField(
                  controller: _nipController,
                  labelText: 'NIP',
                  hintText: 'Masukkan NIP Anda',
                  prefixIcon: Icons.badge,
                  validator: Validators.validateNIP,
                ),
                const SizedBox(height: 16),
                
                // Nama Lengkap
                CustomTextField(
                  controller: _namaLengkapController,
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap Anda',
                  prefixIcon: Icons.person_outline,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                
                // Jabatan
                CustomTextField(
                  controller: _jabatanController,
                  labelText: 'Jabatan',
                  hintText: 'Masukkan jabatan Anda',
                  prefixIcon: Icons.work,
                  validator: (value) => Validators.validateRequired(
                    value, 
                    'Jabatan',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Departemen
                CustomTextField(
                  controller: _departemenController,
                  labelText: 'Departemen',
                  hintText: 'Masukkan departemen Anda',
                  prefixIcon: Icons.business,
                  validator: (value) => Validators.validateRequired(
                    value, 
                    'Departemen',
                  ),
                ),
                const SizedBox(height: 16),
                
                // No Telepon
                CustomTextField(
                  controller: _noTeleponController,
                  labelText: 'No. Telepon',
                  hintText: 'Masukkan nomor telepon Anda',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 16),
                
                // Alamat
                CustomTextField(
                  controller: _alamatController,
                  labelText: 'Alamat',
                  hintText: 'Masukkan alamat Anda',
                  prefixIcon: Icons.location_on,
                  maxLines: 3,
                  validator: (value) => Validators.validateRequired(
                    value, 
                    'Alamat',
                  ),
                ),
                const SizedBox(height: 32),
                
                // Register Button
                CustomButton(
                  text: 'Daftar',
                  onPressed: _register,
                ),
                const SizedBox(height: 16),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: TextStyle(
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}