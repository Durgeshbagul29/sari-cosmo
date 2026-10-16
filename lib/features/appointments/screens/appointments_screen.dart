import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/core/models/models.dart';
import 'package:saris_cosmo_center/core/widgets/common_widgets.dart';
import 'package:saris_cosmo_center/features/search/search_screen.dart';
import 'package:saris_cosmo_center/features/home/widgets/product_card.dart';
import '../controllers/appointment_controller.dart';
import '../models/service_model.dart';
import 'service_detail_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  final Expert? selectedExpert;
  const AppointmentsScreen({super.key, this.selectedExpert});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final AppointmentController _controller = Get.put(AppointmentController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.resetFilters();
      if (widget.selectedExpert != null) {
        _showLegacyBookingSheet(widget.selectedExpert!);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              _controller.resetFilters();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showCategoryFilterSheet,
          ),
        ],
      ),
      body: Obx(() {
        final list = _controller.filteredServices;
        final isLoading = _controller.isLoadingServices.value;

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              _controller.fetchServices(),
              _controller.fetchCategories(),
            ]);
          },
          color: AppTheme.primary,
          child: Column(
            children: [
              _buildActiveFilterChips(),
              Expanded(
                child: list.isEmpty
                    ? (isLoading
                        ? ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            itemCount: 4,
                            itemBuilder: (context, index) => const ServiceCardShimmer(),
                          )
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.spa_outlined,
                                        size: 64,
                                        color: AppTheme.textLight.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No services found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textMedium,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Try adjusting your filters.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ))
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final service = list[index];
                          return ServiceCard(service: service);
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActiveFilterChips() {
    return Obx(() {
      final selectedIds = _controller.selectedCategoryIds;
      if (selectedIds.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          children: selectedIds.map((id) {
            final category = _controller.categories.firstWhereOrNull((c) => c.id == id);
            if (category == null) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: Chip(
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                side: const BorderSide(color: AppTheme.primary, width: 0.5),
                label: Text(
                  category.name,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                deleteIcon: const Icon(Icons.close_rounded, size: 14, color: AppTheme.primary),
                onDeleted: () {
                  _controller.toggleCategorySelection(id);
                },
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  void _showCategoryFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CategoryFilterSheet(),
    );
  }

  void _showLegacyBookingSheet(Expert expert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingSheet(expert: expert),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Get.find<AppointmentController>().resetFilters();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServiceDetailScreen(service: service),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: service.image != null && service.image!.isNotEmpty
                        ? NetworkImageWidget(
                            url: service.image!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primary.withOpacity(0.15),
                                  AppTheme.primary.withOpacity(0.03),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.spa_outlined,
                              color: AppTheme.primary,
                              size: 32,
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (service.category != null)
                          Text(
                            service.category!.name.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          service.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 14, color: AppTheme.textLight),
                            const SizedBox(width: 4),
                            Text(
                              '${service.durationMinutes} mins',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹${service.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.find<AppointmentController>().resetFilters();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ServiceDetailScreen(service: service),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'View Details',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryFilterSheet extends StatelessWidget {
  const _CategoryFilterSheet();

  @override
  Widget build(BuildContext context) {
    final AppointmentController controller = Get.find<AppointmentController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0, color: AppTheme.divider),
              Expanded(
                child: Obx(() {
                  final categoriesList = controller.categories;
                  final selectedIds = controller.selectedCategoryIds;

                  if (controller.isLoadingCategories.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  }

                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      CheckboxListTile(
                        title: const Text('All Categories', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                        value: selectedIds.isEmpty,
                        activeColor: AppTheme.primary,
                        controlAffinity: ListTileControlAffinity.trailing,
                        onChanged: (bool? checked) {
                          if (checked == true) {
                            controller.clearCategorySelection();
                          }
                        },
                      ),
                      ...categoriesList.map((cat) {
                        final isSelected = selectedIds.contains(cat.id);
                        return CheckboxListTile(
                          title: Text(cat.name, style: const TextStyle(color: AppTheme.textDark)),
                          value: isSelected,
                          activeColor: AppTheme.primary,
                          controlAffinity: ListTileControlAffinity.trailing,
                          onChanged: (bool? checked) {
                            controller.toggleCategorySelection(cat.id);
                          },
                        );
                      }),
                    ],
                  );
                }),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BookingSheet extends StatefulWidget {
  final Expert expert;
  const BookingSheet({required this.expert, super.key});

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  final AppointmentController _controller = Get.find<AppointmentController>();

  String? _selectedService;
  DateTime? _selectedDate;
  String? _selectedTime;
  String _paymentMethod = 'online'; // 'online' or 'pay_later'

  static const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<DateTime> _dates = List.generate(7, (index) => DateTime.now().add(Duration(days: index)));

  @override
  void initState() {
    super.initState();
    _selectedDate = _dates.first;

    // Default select first service of the expert if available
    if (widget.expert.services.isNotEmpty) {
      _selectedService = widget.expert.services.first;
    }

    // Load services if empty
    if (_controller.services.isEmpty) {
      _controller.fetchServices().then((_) {
        _fetchSlots();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchSlots();
      });
    }
  }

  ServiceModel? getSelectedServiceModel() {
    if (_selectedService == null) return null;
    try {
      return _controller.services.firstWhere(
        (s) => s.name.toLowerCase().trim() == _selectedService!.toLowerCase().trim(),
      );
    } catch (_) {
      return null;
    }
  }

  void _fetchSlots() {
    final service = getSelectedServiceModel();
    if (service == null || _selectedDate == null) return;
    final formattedDate =
        "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
    _controller.fetchAvailableSlots(
      serviceId: service.id,
      date: formattedDate,
      staffMemberId: int.tryParse(widget.expert.id),
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
    final serviceModel = getSelectedServiceModel();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                widget.expert.imageUrl.isEmpty
                    ? Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 24,
                          color: AppTheme.primary,
                        ),
                      )
                    : NetworkImageWidget(
                        url: widget.expert.imageUrl,
                        height: 48,
                        width: 48,
                        borderRadius: BorderRadius.circular(24),
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book with ${widget.expert.name}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.expert.specialization,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0, color: AppTheme.divider),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Select Service'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.expert.services.map((s) {
                      final isSelected = _selectedService == s;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedService = s;
                            _selectedTime = null;
                          });
                          _fetchSlots();
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
                          child: Text(
                            s,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  if (serviceModel != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Service Price',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMedium,
                            ),
                          ),
                          Text(
                            '₹${serviceModel.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  _sectionTitle('Select Date'),
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
                            });
                            _fetchSlots();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 10),
                            width: 54,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.divider),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  weekday,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : AppTheme.textLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dayStr,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textDark,
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

                  _sectionTitle('Available Time Slots'),
                  const SizedBox(height: 10),
                  Obx(() {
                    if (_controller.isLoadingSlots.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
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
                          'No available slots for this selection. Please try another day or specialist.',
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

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTime = startTime;
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
                            child: Text(
                              displayTime,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textDark,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 24),

                  _sectionTitle('Payment Method'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPaymentMethodTile('Online Payment', 'online', Icons.payment_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPaymentMethodTile('Pay Later', 'pay_later', Icons.storefront_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: serviceModel != null &&
                              _selectedDate != null &&
                              _selectedTime != null
                          ? () {
                              Navigator.pop(context);
                              final formattedDate =
                                  "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
                              _controller.bookServiceAppointment(
                                serviceId: serviceModel.id,
                                staffMemberId: int.tryParse(widget.expert.id),
                                appointmentDate: formattedDate,
                                startTime: _selectedTime!,
                                paymentMethod: _paymentMethod,
                                serviceName: serviceModel.name,
                                staffName: widget.expert.name,
                                price: serviceModel.price,
                              );
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
                        'Confirm Appointment',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(String title, String method, IconData icon) {
    final isSelected = _paymentMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentMethod = method;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.05) : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primary : AppTheme.textLight,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
        t,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppTheme.textDark,
        ),
      );
}

class ServiceCardShimmer extends StatelessWidget {
  const ServiceCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerWidget(
              width: 100,
              height: 100,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerWidget(
                    width: 60,
                    height: 10,
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                  const SizedBox(height: 8),
                  const ShimmerWidget(
                    width: 160,
                    height: 16,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 6),
                  const ShimmerWidget(
                    width: 100,
                    height: 14,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      ShimmerWidget(
                        width: 14,
                        height: 14,
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                      ),
                      SizedBox(width: 4),
                      ShimmerWidget(
                        width: 50,
                        height: 12,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      ShimmerWidget(
                        width: 60,
                        height: 18,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      ShimmerWidget(
                        width: 90,
                        height: 32,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
