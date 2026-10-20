class UserModel {
  final int id;
  final String nama;
  final String username;
  final String role; // 'bendahara' atau 'wali_kelas'

  UserModel({
    required this.id,
    required this.nama,
    required this.username,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nama: json['nama'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? 'bendahara',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'username': username,
      'role': role,
    };
  }
}
