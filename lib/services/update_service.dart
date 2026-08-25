import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../config/api_config.dart';

class UpdateInfo {
  const UpdateInfo({
    required this.updateAvailable,
    required this.isMandatory,
    required this.latestVersionCode,
    this.latestVersionName,
    this.releaseNotes,
    this.downloadUrl,
  });

  final bool updateAvailable;
  final bool isMandatory;
  final int latestVersionCode;
  final String? latestVersionName;
  final String? releaseNotes;
  final String? downloadUrl;

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      updateAvailable: json['update_available'] as bool? ?? false,
      isMandatory: json['is_mandatory'] as bool? ?? false,
      latestVersionCode: json['latest_version_code'] as int? ?? 0,
      latestVersionName: json['latest_version_name'] as String?,
      releaseNotes: json['release_notes'] as String?,
      downloadUrl: json['download_url'] as String?,
    );
  }
}

class UpdateService {
  UpdateService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Returns null if the check fails (offline, backend down, etc.) — the
  /// caller should treat that as "no update info available" and let the
  /// user into the app rather than blocking on a network hiccup.
  Future<UpdateInfo?> checkForUpdate({String platform = 'android'}) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersionCode = int.tryParse(info.buildNumber) ?? 0;

      final uri = Uri.parse('${ApiConfig.baseUrl}/v1/app/version').replace(
        queryParameters: {
          'platform': platform,
          'current_version_code': '$currentVersionCode',
        },
      );

      final response = await _client.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) return null;

      return UpdateInfo.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Downloads the APK to app-private storage and returns its local path.
  Future<String> downloadApk(
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    final request = http.Request('GET', Uri.parse(url));
    final response = await _client.send(request);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengunduh pembaruan (status ${response.statusCode}).');
    }

    final total = response.contentLength ?? 0;
    var received = 0;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/siakad-cbt-update.apk');
    final sink = file.openWrite();

    await response.stream.map((chunk) {
      received += chunk.length;
      if (total > 0) onProgress?.call(received / total);
      return chunk;
    }).pipe(sink);

    await sink.close();
    return file.path;
  }

  void dispose() => _client.close();
}
