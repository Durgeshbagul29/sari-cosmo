class CourseCategory {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String color;
  final String icon;
  final bool isActive;
  final int coursesCount;

  const CourseCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.color,
    required this.icon,
    required this.isActive,
    required this.coursesCount,
  });

  factory CourseCategory.fromJson(Map<String, dynamic> json) {
    return CourseCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      color: json['color'] ?? '#3b82f6',
      icon: json['icon'] ?? '',
      isActive: json['is_active'] ?? false,
      coursesCount: json['courses_count'] ?? 0,
    );
  }
}
