class DashboardModel {
  final int totalOrders;
  final int pendingOrders;
  final int totalSpent;
  final int enrolledCourses;
  final int activeCourses;
  final int completedCourses;
  final int appointments;
  final int upcomingAppointments;

  DashboardModel({
    this.totalOrders = 0,
    this.pendingOrders = 0,
    this.totalSpent = 0,
    this.enrolledCourses = 0,
    this.activeCourses = 0,
    this.completedCourses = 0,
    this.appointments = 0,
    this.upcomingAppointments = 0,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalOrders: _parseInt(json['total_orders']),
      pendingOrders: _parseInt(json['pending_orders']),
      totalSpent: _parseInt(json['total_spent']),
      enrolledCourses: _parseInt(json['enrolled_courses']),
      activeCourses: _parseInt(json['active_courses']),
      completedCourses: _parseInt(json['completed_courses']),
      appointments: _parseInt(json['appointments']),
      upcomingAppointments: _parseInt(json['upcoming_appointments']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
