import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../widgets/app_mark.dart';
import 'app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nisnController = TextEditingController(text: '0081234521');
  final _birthController = TextEditingController(text: '14 / 03 / 2011');

  @override
  void dispose() {
    _nisnController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  void _login() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
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
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Tanggal Lahir'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _birthController,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text('Masuk'),
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
                              const TextSpan(text: 'Tablet ini terdaftar untuk '),
                              TextSpan(
                                text: 'MTs · Kelas 8B',
                                style: TextStyle(color: p.ink, fontWeight: FontWeight.w600),
                              ),
                              const TextSpan(
                                text:
                                    '. Mode ujian akan mengunci aplikasi lain saat sesi dimulai.',
                              ),
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
