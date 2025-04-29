class User {
  final String id;
  final String nama;
  final String email;
  final String peran;
  final String? status;
  final String? fotoProfil;
  final String? terakhirLogin;
  final Karyawan? karyawan;

  User({
    required this.id,
    required this.nama,
    required this.email,
    required this.peran,
    this.status,
    this.fotoProfil,
    this.terakhirLogin,
    this.karyawan,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      peran: json['peran'],
      status: json['status'],
      fotoProfil: json['foto_profil'],
      terakhirLogin: json['terakhir_login'],
      karyawan: json['karyawan'] != null ? Karyawan.fromJson(json['karyawan']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'peran': peran,
      'status': status,
      'foto_profil': fotoProfil,
      'terakhir_login': terakhirLogin,
      'karyawan': karyawan?.toJson(),
    };
  }
}

class Karyawan {
  final String id;
  final String nip;
  final String namaLengkap;
  final String jabatan;
  final String departemen;
  final String noTelepon;
  final String? alamat;
  final String? tanggalBergabung;
  final String? statusKaryawan;

  Karyawan({
    required this.id,
    required this.nip,
    required this.namaLengkap,
    required this.jabatan,
    required this.departemen,
    required this.noTelepon,
    this.alamat,
    this.tanggalBergabung,
    this.statusKaryawan,
  });

  factory Karyawan.fromJson(Map<String, dynamic> json) {
    return Karyawan(
      id: json['id'],
      nip: json['nip'],
      namaLengkap: json['nama_lengkap'],
      jabatan: json['jabatan'],
      departemen: json['departemen'],
      noTelepon: json['no_telepon'],
      alamat: json['alamat'],
      tanggalBergabung: json['tanggal_bergabung'],
      statusKaryawan: json['status_karyawan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nip': nip,
      'nama_lengkap': namaLengkap,
      'jabatan': jabatan,
      'departemen': departemen,
      'no_telepon': noTelepon,
      'alamat': alamat,
      'tanggal_bergabung': tanggalBergabung,
      'status_karyawan': statusKaryawan,
    };
  }
}