import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import '../appointments/controllers/appointment_controller.dart';
import '../appointments/models/appointment_model.dart';
import 'package:saris_cosmo_center/core/utils/app_snackbar.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final AppointmentController _controller = Get.find<AppointmentController>();
  final ScrollController _upcomingScrollController = ScrollController();
  final ScrollController _historyScrollController = ScrollController();

  String _selectedStatus = 'All';
  String _sortBy = 'Date: Newest';

  @override
  void initState() {
    super.initState();
    _controller.currentPage = 1;
    _controller.fetchUserAppointments();
    _upcomingScrollController.addListener(_onScrollUpcoming);
    _historyScrollController.addListener(_onScrollHistory);
  }

  void _onScrollUpcoming() {
    if (_upcomingScrollController.position.pixels >= _upcomingScrollController.position.maxScrollExtent - 200) {
      _controller.fetchUserAppointments(loadMore: true);
    }
  }

  void _onScrollHistory() {
    if (_historyScrollController.position.pixels >= _historyScrollController.position.maxScrollExtent - 200) {
      _controller.fetchUserAppointments(loadMore: true);
    }
  }

  @override
  void dispose() {
    _upcomingScrollController.dispose();
    _historyScrollController.dispose();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final parts = dateStr.split('-');
      if (parts.length < 3) return dateStr;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      if (month < 1 || month > 12) return dateStr;
      return '$day ${months[month]} $year';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '';
    try {
      final parts = timeStr.split(':');
      if (parts.length < 2) return timeStr;
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return timeStr;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
      case 'canceled':
        return AppColors.error;
      default:
        return AppTheme.textMedium;
    }
  }

  List<AppointmentModel> _getProcessedAppointments(List<AppointmentModel> appointments) {
    List<AppointmentModel> result = List.from(appointments);

    // Apply status filter
    if (_selectedStatus != 'All') {
      result = result.where((a) => a.status.toLowerCase() == _selectedStatus.toLowerCase()).toList();
    }

    // Apply sorting
    if (_sortBy == 'Date: Newest') {
      result.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
    } else if (_sortBy == 'Date: Oldest') {
      result.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    } else if (_sortBy == 'Price: Low to High') {
      result.sort((a, b) => a.amount.compareTo(b.amount));
    } else if (_sortBy == 'Price: High to Low') {
      result.sort((a, b) => b.amount.compareTo(a.amount));
    }

    return result;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter & Sort Appointments',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(color: AppTheme.divider),
                      const SizedBox(height: 16),
                      
                      // Status Filters
                      const Text('Filter by Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textDark)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'].map((status) {
                          final isSelected = _selectedStatus == status;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() => _selectedStatus = status);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primary : AppTheme.cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.divider),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppTheme.textMedium,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Sort Options
                      const Text('Sort by', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textDark)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['Date: Newest', 'Date: Oldest', 'Price: Low to High', 'Price: High to Low'].map((opt) {
                          final isSelected = _sortBy == opt;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() => _sortBy = opt);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primary : AppTheme.cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.divider),
                              ),
                              child: Text(
                                opt,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppTheme.textMedium,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedStatus = 'All';
                                  _sortBy = 'Date: Newest';
                                });
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.divider),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Reset Filters', style: TextStyle(color: AppTheme.textMedium, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {}); // trigger rebuild of My Appointments Screen
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('My Appointments'),
          elevation: 0,
          backgroundColor: AppTheme.surface,
          foregroundColor: AppTheme.textDark,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list_rounded),
              onPressed: _showFilterBottomSheet,
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textLight,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUpcomingTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTab() {
    return RefreshIndicator(
      onRefresh: () => _controller.fetchUserAppointments(),
      color: AppTheme.primary,
      child: Obx(() {
        if (_controller.isLoadingAppointments.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }

        final rawAppointments = _controller.userAppointments;
        final processed = _getProcessedAppointments(rawAppointments);
        final upcoming = processed
            .where((a) => a.status.toLowerCase() == 'pending' || a.status.toLowerCase() == 'confirmed')
            .toList();

        if (upcoming.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _upcomingScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
          ),
          itemCount: upcoming.length + (_controller.isLoadingMoreAppointments.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == upcoming.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              );
            }
            return _buildUpcomingCard(context, upcoming[index]);
          },
        );
      }),
    );
  }

  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: () => _controller.fetchUserAppointments(),
      color: AppTheme.primary,
      child: Obx(() {
        if (_controller.isLoadingAppointments.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }

        final rawAppointments = _controller.userAppointments;
        final processed = _getProcessedAppointments(rawAppointments);
        final past = processed
            .where((a) => a.status.toLowerCase() == 'completed' || a.status.toLowerCase() == 'cancelled' || a.status.toLowerCase() == 'canceled')
            .toList();

        if (past.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _historyScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
          ),
          itemCount: past.length + (_controller.isLoadingMoreAppointments.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == past.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              );
            }
            return _buildPastCard(context, past[index]);
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 64,
              color: AppTheme.textLight.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Appointments Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMedium,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Book wellness services and view schedule here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, AppointmentModel appointment) {
    final statusColor = _getStatusColor(appointment.status);
    final serviceName = appointment.service?.name ?? 'Wellness Treatment';
    final staffName = appointment.staffMember?.name ?? 'Assigned Expert';
    final dateStr = _formatDate(appointment.appointmentDate);
    final timeStr = _formatTime(appointment.startTime);

    return GestureDetector(
      onTap: () => _showAppointmentDetailSheet(context, appointment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          appointment.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${appointment.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                serviceName,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Expert: $staffName',
                style: const TextStyle(
                  color: AppTheme.textMedium,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.textLight),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textLight),
                    const SizedBox(width: 8),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _onReschedulePressed(context, appointment),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reschedule',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPastCard(BuildContext context, AppointmentModel appointment) {
    final statusColor = _getStatusColor(appointment.status);
    final serviceName = appointment.service?.name ?? 'Wellness Treatment';
    final dateStr = _formatDate(appointment.appointmentDate);
    final timeStr = _formatTime(appointment.startTime);

    return GestureDetector(
      onTap: () => _showAppointmentDetailSheet(context, appointment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                appointment.status.toLowerCase() == 'completed'
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateStr  •  $timeStr  •  ₹${appointment.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                appointment.status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppointmentDetailSheet(BuildContext context, AppointmentModel initialModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppointmentDetailSheet(
        initialModel: initialModel,
        onReschedulePressed: (appt) => _onReschedulePressed(context, appt),
      ),
    );
  }

  void _onReschedulePressed(BuildContext context, AppointmentModel appointment) {
      AppSnackbar.error(
        'Reschedule Limit Reached',
        'This appointment has already been rescheduled the maximum 2 times.',
      );
      return;

    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (_) => _RescheduleAppointmentSheet(appointment: appointment),
    // );
  }
}

class _AppointmentDetailSheet extends StatefulWidget {
  final AppointmentModel initialModel;
  final Function(AppointmentModel) onReschedulePressed;
  const _AppointmentDetailSheet({
    required this.initialModel,
    required this.onReschedulePressed,
  });

  @override
  State<_AppointmentDetailSheet> createState() => _AppointmentDetailSheetState();
}

class _AppointmentDetailSheetState extends State<_AppointmentDetailSheet> {
  final AppointmentController _controller = Get.find<AppointmentController>();
  late Future<AppointmentModel?> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _controller.fetchAppointmentDetail(widget.initialModel.id);
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final parts = dateStr.split('-');
      if (parts.length < 3) return dateStr;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      if (month < 1 || month > 12) return dateStr;
      return '$day ${months[month]} $year';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '';
    try {
      final parts = timeStr.split(':');
      if (parts.length < 2) return timeStr;
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return timeStr;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
      case 'canceled':
        return AppColors.error;
      default:
        return AppTheme.textMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: FutureBuilder<AppointmentModel?>(
        future: _detailFuture,
        builder: (context, snapshot) {
          final detail = snapshot.data ?? widget.initialModel;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          final serviceName = detail.service?.name ?? 'Wellness Treatment';
          final staffName = detail.staffMember?.name ?? 'Assigned Expert';
          final dateStr = _formatDate(detail.appointmentDate);
          final timeStr = (detail.endTime != null && detail.endTime!.isNotEmpty)
              ? '${_formatTime(detail.startTime)} - ${_formatTime(detail.endTime!)}'
              : _formatTime(detail.startTime);
          final statusColor = _getStatusColor(detail.status);
          final isPendingOrConfirmed = detail.status.toLowerCase() == 'pending' || detail.status.toLowerCase() == 'confirmed';

          return SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Appointment Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0, color: AppTheme.divider),
                if (isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: statusColor.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  detail.status.toLowerCase() == 'completed'
                                      ? Icons.check_circle_rounded
                                      : (detail.status.toLowerCase() == 'cancelled' || detail.status.toLowerCase() == 'canceled'
                                          ? Icons.cancel_rounded
                                          : Icons.pending_actions_rounded),
                                  color: statusColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Booking Number: ${detail.bookingNumber}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Status: ${detail.status.toUpperCase()}',
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Service & Practitioner',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow(Icons.spa_outlined, 'Service', serviceName),
                                const Divider(color: AppTheme.divider, height: 24),
                                _buildInfoRow(Icons.person_outline_rounded, 'Practitioner', staffName),
                                if (detail.service != null && detail.service!.durationMinutes > 0) ...[
                                  const Divider(color: AppTheme.divider, height: 24),
                                  _buildInfoRow(Icons.access_time_rounded, 'Duration', '${detail.service!.durationMinutes} mins'),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Schedule Details',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow(Icons.calendar_today_rounded, 'Date', dateStr),
                                const Divider(color: AppTheme.divider, height: 24),
                                _buildInfoRow(Icons.access_time_rounded, 'Time', timeStr),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Payment Info',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow(Icons.currency_rupee_rounded, 'Total Amount', '₹${detail.amount.toStringAsFixed(0)}'),
                                const Divider(color: AppTheme.divider, height: 24),
                                _buildInfoRow(Icons.payment_rounded, 'Method', detail.paymentMethod.toUpperCase()),
                                const Divider(color: AppTheme.divider, height: 24),
                                _buildInfoRow(Icons.verified_user_outlined, 'Status', detail.paymentStatus.toUpperCase()),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          if ((detail.notes != null && detail.notes!.isNotEmpty) ||
                              (detail.adminNotes != null && detail.adminNotes!.isNotEmpty) ||
                              (detail.cancellationReason != null && detail.cancellationReason!.isNotEmpty)) ...[
                            const Text(
                              'Additional Notes',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.divider),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (detail.notes != null && detail.notes!.isNotEmpty) ...[
                                    _buildNotesSection('My Notes', detail.notes!),
                                  ],
                                  if (detail.adminNotes != null && detail.adminNotes!.isNotEmpty) ...[
                                    if (detail.notes != null && detail.notes!.isNotEmpty)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Divider(color: AppTheme.divider),
                                      ),
                                    _buildNotesSection('Clinic Notes', detail.adminNotes!),
                                  ],
                                  if (detail.cancellationReason != null && detail.cancellationReason!.isNotEmpty) ...[
                                    if ((detail.notes != null && detail.notes!.isNotEmpty) ||
                                        (detail.adminNotes != null && detail.adminNotes!.isNotEmpty))
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Divider(color: AppTheme.divider),
                                      ),
                                    _buildNotesSection('Cancellation Reason', detail.cancellationReason!, color: Colors.red),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          if (isPendingOrConfirmed) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.cancel_outlined, size: 16),
                                    label: const Text('Cancel Booking'),
                                    onPressed: () => _confirmCancelAppointment(context, detail.id),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.calendar_month_rounded, size: 16, color: Colors.white),
                                    label: const Text('Reschedule', style: TextStyle(color: Colors.white)),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      widget.onReschedulePressed(detail);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (detail.status.toLowerCase() == 'completed') ...[
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.rate_review_outlined, size: 16, color: Colors.white),
                                    label: const Text('Write a Review', style: TextStyle(color: Colors.white)),
                                    onPressed: () {
                                      final slug = detail.service?.slug;
                                      if (slug != null && slug.isNotEmpty) {
                                        _showWriteReviewSheet(context, slug);
                                      } else {
                                        AppSnackbar.error(
                                          'Error',
                                          'Unable to review this service.',
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textLight),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMedium,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(String title, String content, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color ?? AppTheme.textLight,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 13,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  void _confirmCancelAppointment(BuildContext context, int appointmentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Appointment?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to cancel this booking? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No, Keep It', style: TextStyle(color: AppTheme.textMedium)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await _controller.cancelServiceAppointment(appointmentId);
              if (success && mounted) {
                Navigator.pop(context);
                AppSnackbar.success(
                  'Success',
                  'Appointment cancelled successfully.',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showWriteReviewSheet(BuildContext context, String slug) {
    int selectedRating = 5;
    final titleController = TextEditingController();
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Write a Review',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Rate this Service',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        final isSelected = starValue <= selectedRating;
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              selectedRating = starValue;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                              color: AppTheme.ratingStar,
                              size: 36,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Review Title',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Summarize your experience',
                        hintStyle: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Review Comment',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Share your feedback about this service...',
                        hintStyle: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(() {
                      final isSubmitting = _controller.isSubmittingReview.value;
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (commentController.text.trim().isEmpty) {
                                    AppSnackbar.error(
                                      'Error',
                                      'Please enter a comment',
                                    );
                                    return;
                                  }
                                  final success = await _controller.submitServiceReview(
                                    slug,
                                    selectedRating,
                                    titleController.text.trim(),
                                    commentController.text.trim(),
                                  );
                                  if (success) {
                                    Navigator.pop(ctx);
                                    AppSnackbar.success(
                                      'Success',
                                      'Review submitted successfully!',
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Submit Review',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _RescheduleAppointmentSheet extends StatefulWidget {
  final AppointmentModel appointment;
  const _RescheduleAppointmentSheet({required this.appointment});

  @override
  State<_RescheduleAppointmentSheet> createState() => _RescheduleAppointmentSheetState();
}

class _RescheduleAppointmentSheetState extends State<_RescheduleAppointmentSheet> {
  final AppointmentController _controller = Get.find<AppointmentController>();

  DateTime? _selectedDate;
  String? _selectedTime;
  int? _selectedStaffId;
  String? _selectedStaffName;

  static const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  late List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    // Generate next 7 dates starting tomorrow for rescheduling
    _dates = List.generate(7, (index) => DateTime.now().add(Duration(days: index + 1)));
    _selectedDate = _dates.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSlots();
    });
  }

  void _fetchSlots() {
    if (_selectedDate == null) return;
    final formattedDate =
        "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
    
    // We fetch slots for this service, without staff restriction to let the user select any specialist
    _controller.fetchAvailableSlots(
      serviceId: widget.appointment.serviceId,
      date: formattedDate,
    );
  }

  String _formatTimeSlot(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length < 2) return timeStr;
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceName = widget.appointment.service?.name ?? 'Wellness Treatment';

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.calendar_month_rounded, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reschedule Appointment',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          serviceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 0, color: AppTheme.divider),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select New Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 64,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _dates.length,
                        itemBuilder: (context, index) {
                          final dateObj = _dates[index];
                          final isSelected = _selectedDate?.day == dateObj.day &&
                              _selectedDate?.month == dateObj.month;
                          final weekday = _weekdays[dateObj.weekday % 7];
                          final dayStr = dateObj.day.toString();

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = dateObj;
                                _selectedTime = null;
                                _selectedStaffId = null;
                                _selectedStaffName = null;
                              });
                              _fetchSlots();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 10),
                              width: 54,
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primary : AppTheme.cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primary : AppTheme.divider,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    weekday,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.8)
                                          : AppTheme.textLight,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dayStr,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppTheme.textDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Available Slots',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(() {
                      if (_controller.isLoadingSlots.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                              strokeWidth: 2.5,
                            ),
                          ),
                        );
                      }

                      final slots = _controller.availableSlots;
                      if (slots.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'No available slots for this day. Please pick another date.',
                            style: TextStyle(
                              color: AppTheme.textMedium,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: slots.map((slot) {
                          final startTime = slot['start_time']?.toString() ?? '';
                          final endTime = slot['end_time']?.toString() ?? '';
                          final isSelected = _selectedTime == startTime;
                          final displayTime = '${_formatTimeSlot(startTime)} - ${_formatTimeSlot(endTime)}';
                          final staffName = slot['staff_member']?['user']?['name'] ?? 
                                            slot['staff_member']?['name'] ?? 
                                            'Specialist';

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTime = startTime;
                                _selectedStaffId = slot['staff_member_id'] as int?;
                                _selectedStaffName = staffName;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primary : AppTheme.cardBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primary : AppTheme.divider,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    displayTime,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppTheme.textDark,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    staffName,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white.withOpacity(0.8) : AppTheme.textLight,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 30),

                    if (_selectedTime != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Rescheduling with $_selectedStaffName at ${_formatTimeSlot(_selectedTime!)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedTime != null
                            ? () async {
                                final formattedDate =
                                    "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
                                
                                final success = await _controller.rescheduleServiceAppointment(
                                  appointmentId: widget.appointment.id,
                                  staffMemberId: _selectedStaffId,
                                  appointmentDate: formattedDate,
                                  startTime: _selectedTime!,
                                );

                                if (success && mounted) {
                                  Navigator.pop(context);
                                  AppSnackbar.success(
                                    'Success',
                                    'Appointment rescheduled successfully!',
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Confirm Reschedule',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
