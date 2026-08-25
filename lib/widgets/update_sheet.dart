import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../services/update_service.dart';
import '../theme/app_palette.dart';

/// Shown when a newer release is available. [mandatory] releases hide the
/// "Nanti" option and can't be dismissed — the student must update before
/// continuing, since there's no Play Store to auto-push the fix later.
class UpdateSheet extends StatefulWidget {
  const UpdateSheet({super.key, required this.info, required this.mandatory});

  final UpdateInfo info;
  final bool mandatory;

  static Future<void> show(
    BuildContext context, {
    required UpdateInfo info,
    required bool mandatory,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: !mandatory,
      // ignore: deprecated_member_use
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => PopScope(
        canPop: !mandatory,
        child: UpdateSheet(info: info, mandatory: mandatory),
      ),
    );
  }

  @override
  State<UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends State<UpdateSheet> {
  final _service = UpdateService();
  bool _downloading = false;
  double _progress = 0;
  String? _error;

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _startUpdate() async {
    final url = widget.info.downloadUrl;
    if (url == null) return;

    setState(() {
      _downloading = true;
      _error = null;
    });

    try {
      final path = await _service.downloadApk(
        url,
        onProgress: (p) => setState(() => _progress = p),
      );
      await OpenFilex.open(path);
    } catch (e) {
      setState(() => _error = 'Gagal mengunduh pembaruan. Periksa koneksi internet dan coba lagi.');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: p.accentSoft, shape: BoxShape.circle),
              child: Icon(Icons.system_update_rounded, color: p.accent, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              widget.mandatory ? 'Pembaruan Wajib' : 'Pembaruan Tersedia',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: p.ink),
            ),
            const SizedBox(height: 6),
            Text(
              'Versi ${widget.info.latestVersionName ?? '-'} sudah tersedia.'
              '${widget.mandatory ? ' Update wajib dilakukan untuk melanjutkan.' : ''}',
              style: TextStyle(fontSize: 13.5, color: p.inkSoft, height: 1.4),
            ),
            if ((widget.info.releaseNotes ?? '').isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: p.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.info.releaseNotes!,
                  style: TextStyle(fontSize: 12.5, color: p.inkSoft, height: 1.4),
                ),
              ),
            ],
            if (_downloading) ...[
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  minHeight: 8,
                  backgroundColor: p.surfaceVariant,
                  color: p.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _progress > 0 ? 'Mengunduh… ${(_progress * 100).toStringAsFixed(0)}%' : 'Mengunduh…',
                style: TextStyle(fontSize: 12, color: p.inkFaint),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(fontSize: 12.5, color: p.danger)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                if (!widget.mandatory)
                  Expanded(
                    child: TextButton(
                      onPressed: _downloading ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(foregroundColor: p.inkSoft),
                      child: const Text('Nanti'),
                    ),
                  ),
                if (!widget.mandatory) const SizedBox(width: 10),
                Expanded(
                  flex: widget.mandatory ? 1 : 1,
                  child: FilledButton(
                    onPressed: _downloading ? null : _startUpdate,
                    style: FilledButton.styleFrom(
                      backgroundColor: p.accent,
                      foregroundColor: p.accentOn,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_downloading ? 'Mengunduh…' : 'Update Sekarang'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
