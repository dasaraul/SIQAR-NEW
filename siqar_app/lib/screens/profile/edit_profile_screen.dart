import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:siqar_app/providers/auth_provider.dart';
import 'package:siqar_app/utils/constants.dart';
import 'package:siqar_app/utils/validators.dart';
import 'package:siqar_app/widgets/loading_overlay.dart';
import 'package:siqar_app/widgets/custom_button.dart';
import 'package:siqar_app/widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _noTeleponController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  
  File? _imageFile;
  bool _isDataInitialized = false;
  
  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _namaLengkapController.dispose();
    _noTeleponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataInitialized) {
      _initializeData();
      _isDataInitialized = true;
    }
  }
  
  void _initializeData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _namaController.text = user.nama;
      _emailController.text = user.email;
      
      if (user.karyawan != null) {
        _namaLengkapController.text = user.karyawan!.namaLengkap;
        _noTeleponController.text = user.karyawan!.noTelepon;
        if (user.karyawan!.alamat != null) {
          _alamatController.text = user.karyawan!.alamat!;
        }
      }
    }
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }
  
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Prepare data
      final Map<String, dynamic> data = {
        'nama': _namaController.text.trim(),
      };
      
      // Add employee data if available
      if (authProvider.user?.karyawan != null) {
        data['nama_lengkap'] = _namaLengkapController.text.trim();
        data['no_telepon'] = _noTeleponController.text.trim();
        data['alamat'] = _alamatController.text.trim();
      }
      
      // Add email if changed
      if (_emailController.text.trim() != authProvider.user?.email) {
        data['email'] = _emailController.text.trim();
      }
      
      // Update profile
      final success = await authProvider.updateProfile(data, _imageFile);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.message),
            backgroundColor: AppConstants.successColor,
          ),
        );
        Navigator.pop(context);
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
    final user = authProvider.user;
    
    return LoadingOverlay(
      isLoading: authProvider.loading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profil'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _imageFile != null 
                            ? FileImage(_imageFile!) as ImageProvider
                            : user?.fotoProfil != null 
                                ? NetworkImage(user!.fotoProfil!) 
                                : null,
                        child: _imageFile == null && user?.fotoProfil == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey.shade400,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Account Info section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      
                      if (user?.karyawan != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Informasi Karyawan',
                          style: TextStyle(
                            color: AppConstants.textPrimaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Nama Lengkap
                        CustomTextField(
                          controller: _namaLengkapController,
                          labelText: 'Nama Lengkap',
                          hintText: 'Masukkan nama lengkap Anda',
                          prefixIcon: Icons.badge,
                          validator: Validators.validateName,
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
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Warning alert if email changed
                if (_isDataInitialized && _emailController.text != user?.email)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppConstants.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppConstants.warningColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: AppConstants.warningColor,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Mengubah email akan memerlukan verifikasi ulang dan logout otomatis.',
                            style: TextStyle(
                              color: AppConstants.textPrimaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Submit button
                CustomButton(
                  text: 'Simpan Perubahan',
                  onPressed: _updateProfile,
                  icon: Icons.save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}