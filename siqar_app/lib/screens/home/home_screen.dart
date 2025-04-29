import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siqar_app/providers/auth_provider.dart';
import 'package:siqar_app/providers/absensi_provider.dart';
import 'package:siqar_app/screens/absensi/scan_screen.dart';
import 'package:siqar_app/screens/absensi/history_screen.dart';
import 'package:siqar_app/screens/profile/profile_screen.dart';
import 'package:siqar_app/screens/absensi/report_screen.dart';
import 'package:siqar_app/screens/auth/login_screen.dart';
import 'package:siqar_app/utils/constants.dart';
import 'package:siqar_app/widgets/loading_overlay.dart';
import 'package:siqar_app/widgets/home_header.dart';
import 'package:siqar_app/widgets/status_card.dart';
import 'package:siqar_app/widgets/feature_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  Future<void> _loadData() async {
    final absensiProvider = Provider.of<AbsensiProvider>(context, listen: false);
    await absensiProvider.getTodayAbsensi();
  }
  
  void _navigateToScanScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanScreen()),
    ).then((_) => _loadData());
  }
  
  void _navigateToHistoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }
  
  void _navigateToReportScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportScreen()),
    );
  }
  
  void _navigateToProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }
  
  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final absensiProvider = Provider.of<AbsensiProvider>(context, listen: false);
    
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
      absensiProvider.clearData();
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
  
  Widget _buildAdminFeatures() {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (!authProvider.isAdmin) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Admin Features',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            FeatureCard(
              title: 'Generate QR',
              icon: Icons.qr_code_2,
              color: const Color(0xFF6366F1),
              onTap: () {
                // Navigate to Generate QR Code screen
              },
            ),
            FeatureCard(
              title: 'Manage Locations',
              icon: Icons.location_on,
              color: const Color(0xFF10B981),
              onTap: () {
                // Navigate to Manage Locations screen
              },
            ),
            FeatureCard(
              title: 'Employee List',
              icon: Icons.people,
              color: const Color(0xFFF59E0B),
              onTap: () {
                // Navigate to Employee List screen
              },
            ),
            FeatureCard(
              title: 'Dashboard',
              icon: Icons.dashboard,
              color: const Color(0xFF3B82F6),
              onTap: () {
                // Navigate to Dashboard screen
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final absensiProvider = Provider.of<AbsensiProvider>(context);
    
    return LoadingOverlay(
      isLoading: authProvider.loading || absensiProvider.loading,
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          title: Text(AppConstants.appName),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _logout,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeader(
                  user: authProvider.user,
                  onProfileTap: _navigateToProfileScreen,
                ),
                const SizedBox(height: 16),
                
                // Today's Attendance Status
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Status Absensi Hari Ini',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                StatusCard(
                  absensiData: absensiProvider.todayAbsensi,
                ),
                const SizedBox(height: 16),
                
                // Features
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Menu Utama',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    FeatureCard(
                      title: 'Scan QR',
                      icon: Icons.qr_code_scanner,
                      color: AppConstants.primaryColor,
                      onTap: _navigateToScanScreen,
                    ),
                    FeatureCard(
                      title: 'Riwayat Absensi',
                      icon: Icons.history,
                      color: const Color(0xFF3B82F6),
                      onTap: _navigateToHistoryScreen,
                    ),
                    FeatureCard(
                      title: 'Laporan Bulanan',
                      icon: Icons.assessment,
                      color: const Color(0xFF10B981),
                      onTap: _navigateToReportScreen,
                    ),
                    FeatureCard(
                      title: 'Profil',
                      icon: Icons.person,
                      color: const Color(0xFFF59E0B),
                      onTap: _navigateToProfileScreen,
                    ),
                  ],
                ),
                
                // Admin Features if user is admin
                _buildAdminFeatures(),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}