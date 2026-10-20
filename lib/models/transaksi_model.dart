class TransaksiModel {
  final int id;
  final String jenis; // 'masuk' atau 'keluar'
  final double nominal;
  final String tanggal;
  final String keterangan;
  final String? namaSiswa;
  final String? nomorStruk;
  final String? dibuatOlehNama;

  TransaksiModel({
    required this.id,
    required this.jenis,
    required this.nominal,
    required this.tanggal,
    required this.keterangan,
    this.namaSiswa,
    this.nomorStruk,
    this.dibuatOlehNama,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    return TransaksiModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      jenis: json['jenis'] ?? 'masuk',
      nominal: json['nominal'] != null
          ? double.tryParse(json['nominal'].toString()) ?? 0.0
          : (json['jumlah'] != null ? double.tryParse(json['jumlah'].toString()) ?? 0.0 : 0.0),
      tanggal: json['tanggal'] ?? '',
      keterangan: json['keterangan'] ?? '',
      namaSiswa: json['nama_siswa'],
      nomorStruk: json['nomor_struk'],
      dibuatOlehNama: json['dibuat_oleh_nama'],
    );
  }
}
