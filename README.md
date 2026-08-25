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

Base URL API di-set lewat `--dart-define` (default: `http://10.0.2.2:8000/api`, cocok untuk Android emulator yang mengakses `admin-siakad` di localhost host machine). Base URL **tanpa** `/v1` — versi endpoint (`/v1/app/...`, `/v1/student/...`) sudah ditambahkan otomatis lewat `ApiConfig`. Contoh untuk device fisik atau server lain:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
```

### Mekanisme update aplikasi

Karena aplikasi belum didistribusikan lewat Play Store, tiap kali dibuka aplikasi mengecek versi terbaru ke `GET /api/v1/app/version` (backend `admin-siakad`, resource Filament **Rilis Aplikasi Mobile**). Jika ada rilis baru: update opsional menampilkan dialog yang bisa ditutup ("Nanti"), update wajib (ditandai *mandatory* oleh admin) memblokir aplikasi sampai APK terbaru diunduh & diinstal lewat installer bawaan Android.

## Struktur

Struktur project standar Flutter (`lib/`, `android/`, `ios/`, dst). Kode aplikasi ada di `lib/main.dart`.
