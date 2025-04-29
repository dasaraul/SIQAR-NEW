import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siqar_app/models/absensi_model.dart';
import 'package:siqar_app/providers/absensi_provider.dart';
import 'package:siqar_app/utils/constants.dart';
import 'package:siqar_app/widgets/loading_overlay.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReport();
    });
  }
  
  Future<void> _loadReport() async {
    final absensiProvider = Provider.of<AbsensiProvider>(context, listen: false);
    await absensiProvider.getMonthlyReport(
      tahun: _selectedYear,
      bulan: _selectedMonth,
    );
  }
  
  Future<void> _selectYearMonth() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Pilih Periode'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Year selection
                Row(
                  children: [
                    const Text('Tahun: '),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<int>(
                        value: _selectedYear,
                        isExpanded: true,
                        items: List.generate(
                          5,
                          (index) => DropdownMenuItem(
                            value: DateTime.now().year - index,
                            child: Text('${DateTime.now().year - index}'),
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedYear = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Month selection
                Row(
                  children: [
                    const Text('Bulan: '),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<int>(
                        value: _selectedMonth,
                        isExpanded: true,
                        items: List.generate(
                          12,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text(DateFormat('MMMM', 'id_ID').format(
                              DateTime(2023, index + 1, 1),
                            )),
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMonth = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadReport();
                },
                child: const Text('Terapkan'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildReportCard(AbsensiLaporan report) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.periode,
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            // Attendance statistics
            _buildStatItem(
              'Total Hari Kerja',
              '${report.totalHariKerja} hari',
              Icons.calendar_today,
            ),
            _buildStatItem(
              'Total Kehadiran',
              '${report.totalHadir} hari',
              Icons.check_circle,
              AppConstants.successColor,
            ),
            _buildStatItem(
              'Total Keterlambatan',
              '${report.totalTerlambat} hari',
              Icons.watch_later,
              AppConstants.warningColor,
            ),
            _buildStatItem(
              'Total Izin',
              '${report.totalIzin} hari',
              Icons.vacation_rounded,
              AppConstants.infoColor,
            ),
            _buildStatItem(
              'Total Sakit',
              '${report.totalSakit} hari',
              Icons.medical_services,
              AppConstants.infoColor,
            ),
            _buildStatItem(
              'Total Alpha',
              '${report.totalAlpha} hari',
              Icons.cancel,
              AppConstants.errorColor,
            ),
            const Divider(),
            const SizedBox(height: 8),
            
            // Percentages
            Text(
              'Persentase Kehadiran:',
              style: TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: report.persentaseKehadiran / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getAttendanceColor(report.persentaseKehadiran),
              ),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Text(
              '${report.persentaseKehadiran}%',
              style: TextStyle(
                color: _getAttendanceColor(report.persentaseKehadiran),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Persentase Keterlambatan:',
              style: TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: report.persentaseKeterlambatan / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLatenessColor(report.persentaseKeterlambatan),
              ),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Text(
              '${report.persentaseKeterlambatan}%',
              style: TextStyle(
                color: _getLatenessColor(report.persentaseKeterlambatan),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? AppConstants.textSecondaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppConstants.textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getAttendanceColor(double percentage) {
    if (percentage >= 90) {
      return AppConstants.successColor;
    } else if (percentage >= 75) {
      return AppConstants.warningColor;
    } else {
      return AppConstants.errorColor;
    }
  }
  
  Color _getLatenessColor(double percentage) {
    if (percentage <= 5) {
      return AppConstants.successColor;
    } else if (percentage <= 15) {
      return AppConstants.warningColor;
    } else {
      return AppConstants.errorColor;
    }
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Data',
            style: TextStyle(
              color: AppConstants.textPrimaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada data laporan pada periode yang dipilih',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final absensiProvider = Provider.of<AbsensiProvider>(context);
    final report = absensiProvider.monthlyReport;
    
    return LoadingOverlay(
      isLoading: absensiProvider.loading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan Bulanan'),
        ),
        body: Column(
          children: [
            // Period selector
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: InkWell(
                onTap: _selectYearMonth,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: AppConstants.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DateFormat('MMMM yyyy', 'id_ID').format(
                            DateTime(_selectedYear, _selectedMonth, 1),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Report content
            Expanded(
              child: report == null
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadReport,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: _buildReportCard(report),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}