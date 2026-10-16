class Enrollment {
  final int id;
  final EnrollmentUser user;
  final EnrollmentCourse course;
  final String status;
  final double progressPercent;
  final String paymentStatus;
  final double amountPaid;
  final String enrolledAt;
  final String? completedAt;
  final List<LessonProgress> lessonProgress;
  final EnrollmentCertificate? certificate;

  Enrollment({
    required this.id,
    required this.user,
    required this.course,
    required this.status,
    required this.progressPercent,
    required this.paymentStatus,
    required this.amountPaid,
    required this.enrolledAt,
    this.completedAt,
    required this.lessonProgress,
    this.certificate,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] ?? 0,
      user: EnrollmentUser.fromJson(json['user'] ?? {}),
      course: EnrollmentCourse.fromJson(json['course'] ?? {}),
      status: json['status'] ?? '',
      progressPercent: (json['progress_percent'] ?? 0).toDouble(),
      paymentStatus: json['payment_status'] ?? '',
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      enrolledAt: json['enrolled_at'] ?? '',
      completedAt: json['completed_at']?.toString(),
      lessonProgress: (json['lesson_progress'] as List? ?? [])
          .map((e) => LessonProgress.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      certificate: json['certificate'] == null
          ? null
          : json['certificate'] is Map
              ? EnrollmentCertificate.fromJson(Map<String, dynamic>.from(json['certificate'] as Map))
              : null,
    );
  }
}

class EnrollmentUser {
  final int id;
  final String name;
  final String email;

  EnrollmentUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory EnrollmentUser.fromJson(Map<String, dynamic> json) {
    return EnrollmentUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class EnrollmentCourse {
  final int id;
  final String title;
  final String slug;
  final String? thumbnail;
  final List<dynamic> modules;

  EnrollmentCourse({
    required this.id,
    required this.title,
    required this.slug,
    this.thumbnail,
    required this.modules,
  });

  factory EnrollmentCourse.fromJson(Map<String, dynamic> json) {
    return EnrollmentCourse(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      thumbnail: json['thumbnail'],
      modules: json['modules'] ?? [],
    );
  }
}

class LessonProgress {
  final int lessonId;
  final String status;
  final String? attendedAt;
  final String? completedAt;

  LessonProgress({
    required this.lessonId,
    required this.status,
    this.attendedAt,
    this.completedAt,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      lessonId: json['lesson_id'] ?? 0,
      status: json['status'] ?? 'not_started',
      attendedAt: json['attended_at'],
      completedAt: json['completed_at'],
    );
  }
}

class EnrollmentCertificate {
  final String code;
  final String issuedAt;
  final String url;

  EnrollmentCertificate({
    required this.code,
    required this.issuedAt,
    required this.url,
  });

  bool get isNotEmpty => code.isNotEmpty;

  factory EnrollmentCertificate.fromJson(Map<String, dynamic> json) {
    return EnrollmentCertificate(
      code: json['code'] ?? '',
      issuedAt: json['issued_at'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class CertificateDetail {
  final String certificateCode;
  final String issuedAt;
  final CertificateStudent student;
  final CertificateCourse course;
  final String? completedAt;
  final bool verified;

  CertificateDetail({
    required this.certificateCode,
    required this.issuedAt,
    required this.student,
    required this.course,
    this.completedAt,
    required this.verified,
  });

  factory CertificateDetail.fromJson(Map<String, dynamic> json) {
    return CertificateDetail(
      certificateCode: json['certificate_code'] ?? '',
      issuedAt: json['issued_at'] ?? '',
      student: CertificateStudent.fromJson(json['student'] ?? {}),
      course: CertificateCourse.fromJson(json['course'] ?? {}),
      completedAt: json['completed_at']?.toString(),
      verified: json['verified'] ?? false,
    );
  }
}

class CertificateStudent {
  final String name;
  final String email;

  CertificateStudent({
    required this.name,
    required this.email,
  });

  factory CertificateStudent.fromJson(Map<String, dynamic> json) {
    return CertificateStudent(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class CertificateCourse {
  final String title;
  final String slug;

  CertificateCourse({
    required this.title,
    required this.slug,
  });

  factory CertificateCourse.fromJson(Map<String, dynamic> json) {
    return CertificateCourse(
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}
