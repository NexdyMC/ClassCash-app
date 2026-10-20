import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isObscureOld = true;
  bool _isObscureNew = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi password baru tidak cocok!'),
          backgroundColor: AppColors.redDanger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = await AuthService.getUser();
    final response = await ApiService.post('auth.php?action=change_password', {
      'user_id': user?.id ?? 0,
      'old_password': _oldPasswordController.text,
      'new_password': _newPasswordController.text,
    });

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.greenSuccess,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.redDanger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ganti Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Ubah Kata Sandi Akun',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Masukkan password lama untuk verifikasi dan ketik password baru Anda.',
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 20),

                        // Password Lama
                        TextFormField(
                          controller: _oldPasswordController,
                          obscureText: _isObscureOld,
                          decoration: InputDecoration(
                            labelText: 'Password Saat Ini',
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscureOld ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                              onPressed: () => setState(() => _isObscureOld = !_isObscureOld),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Password lama wajib diisi';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Baru
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: _isObscureNew,
                          decoration: InputDecoration(
                            labelText: 'Password Baru',
                            prefixIcon: const Icon(Icons.lock_reset_outlined, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                              onPressed: () => setState(() => _isObscureNew = !_isObscureNew),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Password baru wajib diisi';
                            if (val.length < 5) return 'Password minimal 5 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Ulangi Password Baru
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _isObscureNew,
                          decoration: const InputDecoration(
                            labelText: 'Konfirmasi Password Baru',
                            prefixIcon: Icon(Icons.check_circle_outline, size: 20),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Konfirmasi password wajib diisi';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Tombol Simpan
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleChangePassword,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Simpan Password Baru'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
