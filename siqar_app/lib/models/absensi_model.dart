class Absensi {
  final String id;
  final String tanggal;
  final String? hari;
  final String? waktuMasuk;
  final String? waktuKeluar;
  final String status;
  final String? lokasiMasuk;
  final String? lokasiKeluar;
  final String? keterangan;

  Absensi({
    required this.id,
    required this.tanggal,
    this.hari,
    this.waktuMasuk,
    this.waktuKeluar,
    required this.status,
    this.lokasiMasuk,
    this.lokasiKeluar,
    this.keterangan,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) {
    return Absensi(
      id: json['id'],
      tanggal: json['tanggal'],
      hari: json['hari'],
      waktuMasuk: json['waktu_masuk'],
      waktuKeluar: json['waktu_keluar'],
      status: json['status'],
      lokasiMasuk: json['lokasi_masuk'],
      lokasiKeluar: json['lokasi_keluar'],
      keterangan: json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': tanggal,
      'hari': hari,
      'waktu_masuk': waktuMasuk,
      'waktu_keluar': waktuKeluar,
      'status': status,
      'lokasi_masuk': lokasiMasuk,
      'lokasi_keluar': lokasiKeluar,
      'keterangan': keterangan,
    };
  }
}

class AbsensiLaporan {
  final String periode;
  final int tahun;
  final int bulan;
  final int totalHariKerja;
  final int totalHadir;
  final int totalTerlambat;
  final int totalIzin;
  final int totalSakit;
  final int totalAlpha;
  final double persentaseKehadiran;
  final double persentaseKeterlambatan;
  final Map<String, dynamic>? karyawan;

  AbsensiLaporan({
    required this.periode,
    required this.tahun,
    required this.bulan,
    required this.totalHariKerja,
    required this.totalHadir,
    required this.totalTerlambat,
    required this.totalIzin,
    required this.totalSakit,
    required this.totalAlpha,
    required this.persentaseKehadiran,
    required this.persentaseKeterlambatan,
    this.karyawan,
  });

  factory AbsensiLaporan.fromJson(Map<String, dynamic> json) {
    return AbsensiLaporan(
      periode: json['periode'],
      tahun: json['tahun'],
      bulan: json['bulan'],
      totalHariKerja: json['total_hari_kerja'],
      totalHadir: json['total_hadir'],
      totalTerlambat: json['total_terlambat'],
      totalIzin: json['total_izin'],
      totalSakit: json['total_sakit'],
      totalAlpha: json['total_alpha'],
      persentaseKehadiran: json['persentase_kehadiran'].toDouble(),
      persentaseKeterlambatan: json['persentase_keterlambatan'].toDouble(),
      karyawan: json['karyawan'],
    );
  }
}