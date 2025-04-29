import 'package:flutter/material.dart';
import 'package:siqar_app/utils/constants.dart';
import 'package:intl/intl.dart';

class StatusCard extends StatelessWidget {
  final Map<String, dynamic>? absensiData;
  
  const StatusCard({
    Key? key,
    required this.absensiData,
  }) : super(key: key);

  String _formatTime(String? time) {
    if (time == null) return '-';
    
    try {
      final dateTime = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return time;
    }
  }
  
  Widget _buildStatusBadge(String status) {
    final Color color = AppConstants.statusColors[status] ?? AppConstants.primaryColor;
    final String label = AppConstants.statusLabels[status] ?? status;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
  
  Widget _buildLocationInfo(Map<String, dynamic>? lokasi) {
    if (lokasi == null) {
      return Row(
        children: [
          const Icon(
            Icons.location_off,
            size: 14,
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            'Lokasi belum diatur',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
    
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 14,
          color: AppConstants.primaryColor,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            lokasi['nama_lokasi'],
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = absensiData?['tanggal'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    final absensi = absensiData?['absensi'];
    final lokasi = absensiData?['lokasi_absensi'];
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tanggal: $today',
                  style: TextStyle(
                    color: AppConstants.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (absensi != null)
                  _buildStatusBadge(absensi['status']),
              ],
            ),
            const SizedBox(height: 16),
            
            // Check-in info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jam Masuk',
                      style: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      absensi?['waktu_masuk'] != null
                          ? _formatTime(absensi?['waktu_masuk'])
                          : 'Belum Absen',
                      style: TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Jam Keluar',
                      style: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      absensi?['waktu_keluar'] != null
                          ? _formatTime(absensi?['waktu_keluar'])
                          : 'Belum Absen',
                      style: TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Location info
            _buildLocationInfo(lokasi),
            
            if (absensi == null && lokasi != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Anda belum melakukan absensi hari ini. Silakan scan QR Code untuk absen.',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            
            if (absensi != null && absensi['keterangan'] != null && absensi['keterangan'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keterangan:',
                      style: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      absensi['keterangan'],
                      style: TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}