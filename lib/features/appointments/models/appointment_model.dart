class AppointmentModel {
  final int id;
  final int serviceId;
  final int? staffMemberId;
  final String appointmentDate;
  final String startTime;
  final String paymentMethod;
  final String status;
  final String paymentStatus;
  final int rescheduleCount;
  final String? notes;
  final AppointmentServiceDetail? service;
  final AppointmentStaffDetail? staffMember;
  final String bookingNumber;
  final double amount;
  final String? endTime;
  final String createdAt;
  final String? adminNotes;
  final String? cancellationReason;
  final String? cancelledAt;

  AppointmentModel({
    required this.id,
    required this.serviceId,
    this.staffMemberId,
    required this.appointmentDate,
    required this.startTime,
    required this.paymentMethod,
    required this.status,
    required this.paymentStatus,
    required this.rescheduleCount,
    this.notes,
    this.service,
    this.staffMember,
    required this.bookingNumber,
    required this.amount,
    this.endTime,
    required this.createdAt,
    this.adminNotes,
    this.cancellationReason,
    this.cancelledAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
      serviceId: json['service_id'] is int 
          ? json['service_id'] 
          : (int.tryParse(json['service_id']?.toString() ?? '') ?? 
              (json['service'] != null ? json['service']['id'] ?? 0 : 0)),
      staffMemberId: json['staff_member_id'] is int 
          ? json['staff_member_id'] 
          : (int.tryParse(json['staff_member_id']?.toString() ?? '') ?? 
              (json['staff'] != null ? json['staff']['id'] : (json['staff_member'] != null ? json['staff_member']['id'] : null))),
      appointmentDate: json['appointment_date'] ?? '',
      startTime: json['start_time'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      rescheduleCount: json['reschedule_count'] is int ? json['reschedule_count'] : (int.tryParse(json['reschedule_count']?.toString() ?? '') ?? 0),
      notes: json['notes'],
      service: json['service'] != null
          ? AppointmentServiceDetail.fromJson(json['service'])
          : null,
      staffMember: json['staff'] != null
          ? AppointmentStaffDetail.fromJson(json['staff'])
          : (json['staff_member'] != null
              ? AppointmentStaffDetail.fromJson(json['staff_member'])
              : null),
      bookingNumber: json['booking_number'] ?? '',
      amount: json['amount'] is num ? (json['amount'] as num).toDouble() : (double.tryParse(json['amount']?.toString() ?? '') ?? 0.0),
      endTime: json['end_time'],
      createdAt: json['created_at'] ?? '',
      adminNotes: json['admin_notes'],
      cancellationReason: json['cancellation_reason'],
      cancelledAt: json['cancelled_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'staff_member_id': staffMemberId,
      'appointment_date': appointmentDate,
      'start_time': startTime,
      'payment_method': paymentMethod,
      'status': status,
      'payment_status': paymentStatus,
      'reschedule_count': rescheduleCount,
      'notes': notes,
      'service': service?.toJson(),
      'staff_member': staffMember?.toJson(),
      'booking_number': bookingNumber,
      'amount': amount,
      'end_time': endTime,
      'created_at': createdAt,
      'admin_notes': adminNotes,
      'cancellation_reason': cancellationReason,
      'cancelled_at': cancelledAt,
    };
  }
}

class AppointmentServiceDetail {
  final int id;
  final String name;
  final String slug;
  final double price;
  final int durationMinutes;
  final String? image;

  AppointmentServiceDetail({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.durationMinutes,
    this.image,
  });

  factory AppointmentServiceDetail.fromJson(Map<String, dynamic> json) {
    final nameStr = json['name'] ?? '';
    final fallbackSlug = nameStr.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9\-]'), '');
    return AppointmentServiceDetail(
      id: json['id'] ?? 0,
      name: nameStr,
      slug: json['slug'] ?? fallbackSlug,
      price: (json['price'] ?? 0).toDouble(),
      durationMinutes: json['duration_minutes'] ?? 0,
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'price': price,
      'duration_minutes': durationMinutes,
      'image': image,
    };
  }
}

class AppointmentStaffDetail {
  final int id;
  final String name;
  final String? specialization;
  final String? image;

  AppointmentStaffDetail({
    required this.id,
    required this.name,
    this.specialization,
    this.image,
  });

  factory AppointmentStaffDetail.fromJson(Map<String, dynamic> json) {
    String nameVal = json['name'] ?? '';
    if (nameVal.isEmpty && json['user'] != null) {
      nameVal = json['user']['name'] ?? '';
    }
    return AppointmentStaffDetail(
      id: json['id'] ?? 0,
      name: nameVal,
      specialization: json['specialization'] ?? json['role'],
      image: json['image'] ?? json['photo'] ?? json['profile_photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'image': image,
    };
  }
}
