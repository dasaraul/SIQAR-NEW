class QRCode {
  final String id;
  final String? kode;
  final String deskripsi;
  final String tanggal;
  final String? waktuMulai;
  final String? waktuBerakhir;
  final String status;
  final String? imageUrl;
  final Lokasi? lokasi;
  final bool valid;

  QRCode({
    required this.id,
    this.kode,
    required this.deskripsi,
    required this.tanggal,
    this.waktuMulai,
    this.waktuBerakhir,
    required this.status,
    this.imageUrl,
    this.lokasi,
    this.valid = false,
  });

  factory QRCode.fromJson(Map<String, dynamic> json) {
    return QRCode(
      id: json['id'],
      kode: json['kode'],
      deskripsi: json['deskripsi'],
      tanggal: json['tanggal'],
      waktuMulai: json['waktu_mulai'],
      waktuBerakhir: json['waktu_berakhir'],
      status: json['status'] ?? 'nonaktif',
      imageUrl: json['image_url'],
      lokasi: json['lokasi'] != null ? Lokasi.fromJson(json['lokasi']) : null,
      valid: json['valid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode': kode,
      'deskripsi': deskripsi,
      'tanggal': tanggal,
      'waktu_mulai': waktuMulai,
      'waktu_berakhir': waktuBerakhir,
      'status': status,
      'image_url': imageUrl,
      'lokasi': lokasi?.toJson(),
      'valid': valid,
    };
  }
}

class Lokasi {
  final String id;
  final String namaLokasi;
  final String alamat;
  final double? latitude;
  final double? longitude;
  final int? radius;
  final String? status;
  final String? keterangan;

  Lokasi({
    required this.id,
    required this.namaLokasi,
    required this.alamat,
    this.latitude,
    this.longitude,
    this.radius,
    this.status,
    this.keterangan,
  });

  factory Lokasi.fromJson(Map<String, dynamic> json) {
    return Lokasi(
      id: json['id'],
      namaLokasi: json['nama_lokasi'],
      alamat: json['alamat'],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      radius: json['radius'] != null ? int.parse(json['radius'].toString()) : null,
      status: json['status'],
      keterangan: json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lokasi': namaLokasi,
      'alamat': alamat,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'status': status,
      'keterangan': keterangan,
    };
  }
}