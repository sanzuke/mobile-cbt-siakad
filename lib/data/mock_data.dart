/// Placeholder data standing in for the future `/api/v1/student/*` backend
/// (see admin-siakad/docs/CBT_MOBILE_APP_PLAN.md). Swap for real API calls
/// once that endpoint exists.
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

class ExamSummary {
  final String subjectShort;
  final String title;
  final String teacherNote;
  final int questionCount;
  final int durationMinutes;
  final int attemptsAllowed;
  final String scheduleNote;
  final bool isOpen;

  const ExamSummary({
    required this.subjectShort,
    required this.title,
    required this.teacherNote,
    required this.questionCount,
    required this.durationMinutes,
    required this.attemptsAllowed,
    required this.scheduleNote,
    required this.isOpen,
  });
}

const activeExam = ExamSummary(
  subjectShort: 'FQ',
  title: 'Ulangan Harian — Fiqih',
  teacherNote: "Bab Thaharah & Sholat Jama' Qashar · Ustadz Zainal Abidin",
  questionCount: 25,
  durationMinutes: 60,
  attemptsAllowed: 1,
  scheduleNote: 'Tutup 14:30',
  isOpen: true,
);

const scheduledExam = ExamSummary(
  subjectShort: 'MTK',
  title: 'Penilaian Tengah Semester — Matematika',
  teacherNote: '',
  questionCount: 40,
  durationMinutes: 90,
  attemptsAllowed: 1,
  scheduleNote: 'Dibuka besok, 08:00',
  isOpen: false,
);

class HistoryEntry {
  final String title;
  final String date;
  final int? score;
  final bool pending;

  const HistoryEntry({
    required this.title,
    required this.date,
    this.score,
    this.pending = false,
  });
}

const historyEntries = [
  HistoryEntry(title: 'Ulangan Harian — Bahasa Arab', date: '18 Jul 2026', score: 88),
  HistoryEntry(title: 'Ulangan Harian — Tahfidz', date: '12 Jul 2026', score: 92),
  HistoryEntry(title: 'Ulangan Harian — IPA', date: '05 Jul 2026', pending: true),
];

class ExamQuestion {
  final String text;
  final List<String> options;

  const ExamQuestion({required this.text, required this.options});
}

final List<ExamQuestion> fiqihQuestions = List.generate(activeExam.questionCount, (i) {
  if (i == 5) {
    return const ExamQuestion(
      text:
          "Berikut ini yang termasuk rukun wudhu menurut mazhab Syafi'i adalah, kecuali ...",
      options: [
        'Niat ketika membasuh wajah',
        'Membasuh kedua tangan sampai siku',
        'Mengusap seluruh kepala',
        'Tertib atau berurutan',
        'Membaca basmalah di awal wudhu',
      ],
    );
  }
  return ExamQuestion(
    text: "Soal nomor ${i + 1} — materi Bab Thaharah & Sholat Jama' Qashar.",
    options: const ['Pilihan A', 'Pilihan B', 'Pilihan C', 'Pilihan D', 'Pilihan E'],
  );
});
