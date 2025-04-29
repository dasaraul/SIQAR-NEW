import 'package:flutter/material.dart';
import 'package:siqar_app/models/user_model.dart';
import 'package:siqar_app/utils/constants.dart';
import 'package:intl/intl.dart';

class HomeHeader extends StatelessWidget {
  final User? user;
  final VoidCallback? onProfileTap;
  
  const HomeHeader({
    Key? key,
    required this.user,
    this.onProfileTap,
  }) : super(key: key);

  String _greeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 19) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }
  
  String _formatDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: AppConstants.accentColor,
              backgroundImage: user?.fotoProfil != null 
                  ? NetworkImage(user!.fotoProfil!) 
                  : null,
              child: user?.fotoProfil == null 
                  ? Text(
                      user?.nama.isNotEmpty == true 
                          ? user!.nama.substring(0, 1).toUpperCase() 
                          : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.nama ?? 'Pengguna',
                  style: TextStyle(
                    color: AppConstants.textPrimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(),
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}