import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siqar_app/providers/auth_provider.dart';
import 'package:siqar_app/screens/auth/login_screen.dart';
import 'package:siqar_app/screens/profile/edit_profile_screen.dart';
import 'package:siqar_app/utils/constants.dart';
import 'package:siqar_app/widgets/loading_overlay.dart';
import 'package:siqar_app/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProfile();
    });
  }
  
  Future<void> _refreshProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.getProfile();
  }
  
  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await authProvider.logout();
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
  
  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    ).then((_) => _refreshProfile());
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final karyawan = user?.karyawan;
    
    return LoadingOverlay(
      isLoading: authProvider.loading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(24),
                  color: AppConstants.primaryColor,
                  child: Column(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: user?.fotoProfil != null 
                            ? NetworkImage(user!.fotoProfil!)
                            : null,
                        child: user?.fotoProfil == null
                            ? Text(
                                user?.nama.isNotEmpty == true 
                                    ? user!.nama.substring(0, 1).toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryColor,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Name
                      Text(
                        user?.nama ?? 'Nama Pengguna',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          user?.peran == 'admin' ? 'Admin' : 'Karyawan',
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Employee Info
                if (karyawan != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Karyawan',
                          style: TextStyle(
                            color: AppConstants.textPrimaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoItem('NIP', karyawan.nip),
                        _buildInfoItem('Nama Lengkap', karyawan.namaLengkap),
                        _buildInfoItem('Jabatan', karyawan.jabatan),
                        _buildInfoItem('Departemen', karyawan.departemen),
                        _buildInfoItem('No. Telepon', karyawan.noTelepon),
                        if (karyawan.tanggalBergabung != null)
                          _buildInfoItem(
                            'Tanggal Bergabung',
                            DateFormat('d MMMM y', 'id_ID').format(
                              DateTime.parse(karyawan.tanggalBergabung!),
                            ),
                          ),
                        if (karyawan.statusKaryawan != null)
                          _buildInfoItem(
                            'Status Karyawan',
                            karyawan.statusKaryawan == 'tetap'
                                ? 'Karyawan Tetap'
                                : karyawan.statusKaryawan == 'kontrak'
                                    ? 'Karyawan Kontrak'
                                    : 'Magang',
                          ),
                        if (karyawan.alamat != null && karyawan.alamat!.isNotEmpty)
                          _buildInfoItem('Alamat', karyawan.alamat!),
                      ],
                    ),
                  ),
                
                // Account Info
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
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
                      _buildInfoItem('Email', user?.email ?? '-'),
                      if (user?.terakhirLogin != null)
                        _buildInfoItem(
                          'Login Terakhir',
                          DateFormat('d MMMM y HH:mm', 'id_ID').format(
                            DateTime.parse(user!.terakhirLogin!),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Actions
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      CustomButton(
                        text: 'Edit Profil',
                        icon: Icons.edit,
                        onPressed: _navigateToEditProfile,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Logout',
                        icon: Icons.exit_to_app,
                        outlined: true,
                        backgroundColor: AppConstants.errorColor,
                        onPressed: _logout,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // App Info
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        '${AppConstants.appName} - ${AppConstants.appDescription}',
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Versi ${AppConstants.appVersion}',
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppConstants.textPrimaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}