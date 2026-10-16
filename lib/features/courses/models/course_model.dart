import 'course_category_model.dart';

class CourseInstructor {
  final int id;
  final String name;

  const CourseInstructor({
    required this.id,
    required this.name,
  });

  factory CourseInstructor.fromJson(Map<String, dynamic> json) {
    return CourseInstructor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Course {
  final int id;
  final String title;
  final String slug;
  final String shortDescription;
  final String? thumbnail;
  final int durationWeeks;
  final double price;
  final double? salePrice;
  final double effectivePrice;
  final int? maxStudents;
  final bool isPublished;
  final String status;
  final String? startsAt;
  final String? endsAt;
  final CourseCategory category;
  final CourseInstructor instructor;
  final String createdAt;
  final String description;
  final List<dynamic> modules;

  const Course({
    required this.id,
    required this.title,
    required this.slug,
    required this.shortDescription,
    this.thumbnail,
    required this.durationWeeks,
    required this.price,
    this.salePrice,
    required this.effectivePrice,
    this.maxStudents,
    required this.isPublished,
    required this.status,
    this.startsAt,
    this.endsAt,
    required this.category,
    required this.instructor,
    required this.createdAt,
    required this.description,
    required this.modules,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      shortDescription: json['short_description'] ?? '',
      thumbnail: json['thumbnail'],
      durationWeeks: json['duration_weeks'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      salePrice: json['sale_price'] != null ? (json['sale_price'] as num).toDouble() : null,
      effectivePrice: (json['effective_price'] ?? 0).toDouble(),
      maxStudents: json['max_students'],
      isPublished: json['is_published'] ?? false,
      status: json['status'] ?? '',
      startsAt: json['starts_at'],
      endsAt: json['ends_at'],
      category: CourseCategory.fromJson(json['category'] ?? {}),
      instructor: CourseInstructor.fromJson(json['instructor'] ?? {}),
      createdAt: json['created_at'] ?? '',
      description: json['description'] ?? '',
      modules: json['modules'] ?? [],
    );
  }

  // Helper getters to map to legacy properties without storing extra state
  String? get imageUrl => thumbnail;
  String get duration => '$durationWeeks ${durationWeeks == 1 ? "Week" : "Weeks"}';
  String get longDescription => description;
  bool get isFree => effectivePrice <= 0;
  int get lessons {
    int count = 0;
    for (var m in modules) {
      if (m is Map && m['lessons'] is List) {
        count += (m['lessons'] as List).length;
      }
    }
    return count;
  }
}
