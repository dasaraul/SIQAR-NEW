import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siqar_app/models/absensi_model.dart';
import 'package:siqar_app/providers/absensi_provider.dart';
import 'package:siqar_app/utils/constants.dart';
import 'package:siqar_app/widgets/loading_overlay.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStatus;
  
  @override
  void initState() {
    super.initState();
    // Set default date range to current month
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  Future<void> _loadData() async {
    final absensiProvider = Provider.of<AbsensiProvider>(context, listen: false);
    await absensiProvider.getAbsensiHistory(
      tanggalMulai: _startDate != null ? _dateFormat.format(_startDate!) : null,
      tanggalAkhir: _endDate != null ? _dateFormat.format(_endDate!) : null,
      status: _selectedStatus,
      refresh: true,
    );
  }
  
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: _endDate ?? DateTime.now(),
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppConstants.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      
      await _loadData();
    }
  }
  
  Future<void> _showFilterDialog() async {
    String? status = _selectedStatus;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Status'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String?>(
                  title: const Text('Semua'),
                  value: null,
                  groupValue: status,
                  onChanged: (value) {
                    setState(() {
                      status = value;
                    });
                  },
                ),
                RadioListTile<String?>(
                  title: Text(
                    'Hadir',
                    style: TextStyle(color: AppConstants.statusColors['hadir']),
                  ),
                  value: 'hadir',
                  groupValue: status,
                  onChanged: (value) {
                    setState(() {
                      status = value;
                    });
                  },
                ),
                RadioListTile<String?>(
                  title: Text(
                    'Terlambat',
                    style: TextStyle(color: AppConstants.statusColors['terlambat']),
                  ),
                  value: 'terlambat',
                  groupValue: status,
                  onChanged: (value) {
                    setState(() {
                      status = value;
                    });
                  },
                ),
                RadioListTile<String?>(
                  title: Text(
                    'Izin',
                    style: TextStyle(color: AppConstants.statusColors['izin']),
                  ),
                  value: 'izin',
                  groupValue: status,
                  onChanged: (value) {
                    setState(() {
                      status = value;
                    });
                  },
                ),
                RadioListTile<String?>(
                  title: Text(
                    'Sakit',
                    style: TextStyle(color: AppConstants.statusColors['sakit']),
                  ),
                  value: 'sakit',
                  groupValue: status,
                  onChanged: (value) {
                    setState(() {
                      status = value;
                    });
                  },
                ),
                RadioListTile<String?>(
                  title: Text(
                    'Alpha',
                    style: TextStyle(color: AppConstants.statusColors['alpha']),
                  ),
                  value: 'alpha',
                  groupValue: status,
                  onChanged: (value) {
                    setState(() {
                      status = value;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedStatus = status;
              });
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    final Color color = AppConstants.statusColors[status] ?? AppConstants.primaryColor;
    final String label = AppConstants.statusLabels[status] ?? status;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final absensiProvider = Provider.of<AbsensiProvider>(context);
    final absensiList = absensiProvider.absensiHistory;
    
    return LoadingOverlay(
      isLoading: absensiProvider.loading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Absensi'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
              tooltip: 'Filter Status',
            ),
          ],
        ),
        body: Column(
          children: [
            // Date Range Selector
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: InkWell(
                onTap: () => _selectDateRange(context),
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
                        Icons.date_range,
                        color: AppConstants.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _startDate != null && _endDate != null
                              ? '${DateFormat('d MMM y').format(_startDate!)} - ${DateFormat('d MMM y').format(_endDate!)}'
                              : 'Pilih Rentang Tanggal',
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
            
            // Filter Chips
            if (_selectedStatus != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    const Text(
                      'Filter: ',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Chip(
                      label: Text(
                        AppConstants.statusLabels[_selectedStatus] ?? _selectedStatus!,
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      backgroundColor: AppConstants.statusColors[_selectedStatus],
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                      onDeleted: () {
                        setState(() {
                          _selectedStatus = null;
                        });
                        _loadData();
                      },
                    ),
                  ],
                ),
              ),
            
            // Absensi List
            Expanded(
              child: absensiList == null 
                  ? const Center(child: CircularProgressIndicator())
                  : absensiList.isEmpty 
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: absensiList.length,
                            itemBuilder: (context, index) {
                              return _buildAbsensiItem(absensiList[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
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
            'Belum ada data absensi pada rentang waktu yang dipilih',
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
  
  Widget _buildAbsensiItem(Absensi absensi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, d MMMM y', 'id_ID').format(
                    DateFormat('yyyy-MM-dd').parse(absensi.tanggal)
                  ),
                  style: TextStyle(
                    color: AppConstants.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusBadge(absensi.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jam Masuk',
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        absensi.waktuMasuk ?? '-',
                        style: TextStyle(
                          color: AppConstants.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jam Keluar',
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        absensi.waktuKeluar ?? '-',
                        style: TextStyle(
                          color: AppConstants.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (absensi.lokasiMasuk != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppConstants.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        absensi.lokasiMasuk!,
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            if (absensi.keterangan != null && absensi.keterangan!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keterangan:',
                      style: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      absensi.keterangan!,
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