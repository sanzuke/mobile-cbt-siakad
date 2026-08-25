import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../state/session_controller.dart';
import '../theme/app_palette.dart';
import '../widgets/app_mark.dart';
import 'app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nisnController = TextEditingController();
  final _birthController = TextEditingController();

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nisnController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  /// Accepts `dd / MM / yyyy` or `dd/MM/yyyy` (what the field shows) and
  /// converts to `yyyy-MM-dd` for the backend's `date` validation rule.
  String? _isoBirthDate() {
    final raw = _birthController.text.replaceAll(' ', '');
    final parts = raw.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  Future<void> _login() async {
    final nisn = _nisnController.text.trim();
    final birthDate = _isoBirthDate();

    if (nisn.isEmpty || birthDate == null) {
      setState(() => _error = 'Isi NISN dan tanggal lahir dengan format dd / mm / yyyy.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await SessionScope.of(context).login(nisn: nisn, birthDate: birthDate);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Tidak bisa terhubung ke server. Periksa koneksi tablet.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.paper,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 32),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: p.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppMark(size: 44),
                  const SizedBox(height: 16),
                  Text(
                    'Masuk ke Ujian',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gunakan NISN dan tanggal lahir yang terdaftar di sekolah.',
                    style: TextStyle(fontSize: 13, color: p.inkSoft),
                  ),
                  const SizedBox(height: 24),
                  _FieldLabel('NISN'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nisnController,
                    keyboardType: TextInputType.number,
                    enabled: !_submitting,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Tanggal Lahir (dd / mm / yyyy)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _birthController,
                    enabled: !_submitting,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(fontSize: 12.5, color: p.danger)),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _login,
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Masuk'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🔒', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 12, color: p.inkFaint, height: 1.5),
                            children: [
                              const TextSpan(text: 'Mode ujian akan mengunci aplikasi lain saat sesi dimulai.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.inkSoft),
    );
  }
}
