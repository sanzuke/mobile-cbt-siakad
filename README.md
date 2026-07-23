# mobile-cbt-siakad

Aplikasi mobile (Flutter) untuk siswa SIAKAD — pengerjaan ujian CBT (offline-capable, kiosk mode) dan akses materi pembelajaran di tablet.

Backend/API dikonsumsi dari repo [`admin-siakad`](https://github.com/sanzuke/admin-siakad) (Laravel 12). Dokumen rencana teknis ada di `admin-siakad/docs/CBT_MOBILE_APP_PLAN.md`.

## Stack

- Flutter (stable channel)
- Dart
- REST API (Sanctum token auth) ke backend `admin-siakad`

## Branch

- `main` — stabil / rilis
- `dev` — branch development aktif

## Menjalankan

```bash
flutter pub get
flutter run
```

Base URL API di-set lewat `--dart-define`, contoh:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

## Struktur

Struktur project standar Flutter (`lib/`, `android/`, `ios/`, dst). Kode aplikasi ada di `lib/main.dart`.
