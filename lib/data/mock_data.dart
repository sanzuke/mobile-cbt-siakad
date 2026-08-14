/// Placeholder data for fields `/api/v1/student/*` doesn't return yet
/// (kelas/wali/device — see `StudentResource` on the backend). Real exam
/// data now comes from `lib/models/exam_models.dart` + `lib/services/exam_service.dart`;
/// this file only backs the leftover mock fields on ProfileScreen/ShellHeader.
class Student {
  final String name;
  final String nisn;
  final String kelas;
  final String birthDate;
  final String waliName;
  final String waliContact;
  final String avatarInitials;
  final String deviceLabel;

  const Student({
    required this.name,
    required this.nisn,
    required this.kelas,
    required this.birthDate,
    required this.waliName,
    required this.waliContact,
    required this.avatarInitials,
    required this.deviceLabel,
  });
}

const currentStudent = Student(
  name: 'Ahmad Fauzan',
  nisn: '0081234521',
  kelas: '8B — MTs',
  birthDate: '14 Maret 2011',
  waliName: 'Suherman',
  waliContact: '0812-xxxx-xxxx',
  avatarInitials: 'AF',
  deviceLabel: 'Kelas 8B — Unit 14',
);
