class SiswaModel {
  final int id;
  final String nis;
  final String nama;
  final String status; // 'aktif' atau 'nonaktif'
  final int tahunAjaranId;
  final String? tahunAjaranLabel;
  final int totalTunggakanMinggu;
  final double totalTunggakanNominal;

  SiswaModel({
    required this.id,
    required this.nis,
    required this.nama,
    required this.status,
    required this.tahunAjaranId,
    this.tahunAjaranLabel,
    this.totalTunggakanMinggu = 0,
    this.totalTunggakanNominal = 0.0,
  });

  factory SiswaModel.fromJson(Map<String, dynamic> json) {
    return SiswaModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nis: json['nis']?.toString() ?? '',
      nama: json['nama'] ?? '',
      status: json['status'] ?? 'aktif',
      tahunAjaranId: json['tahun_ajaran_id'] is int
          ? json['tahun_ajaran_id']
          : int.tryParse(json['tahun_ajaran_id']?.toString() ?? '0') ?? 0,
      tahunAjaranLabel: json['tahun_ajaran'],
      totalTunggakanMinggu: json['total_tunggakan_minggu'] is int
          ? json['total_tunggakan_minggu']
          : int.tryParse(json['total_tunggakan_minggu']?.toString() ?? '0') ?? 0,
      totalTunggakanNominal: json['total_tunggakan_nominal'] != null
          ? double.tryParse(json['total_tunggakan_nominal'].toString()) ?? 0.0
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nis': nis,
      'nama': nama,
      'status': status,
      'tahun_ajaran_id': tahunAjaranId,
      'tahun_ajaran': tahunAjaranLabel,
      'total_tunggakan_minggu': totalTunggakanMinggu,
      'total_tunggakan_nominal': totalTunggakanNominal,
    };
  }
}
