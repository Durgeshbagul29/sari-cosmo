import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:saris_cosmo_center/core/models/address_model.dart';
import 'package:saris_cosmo_center/features/address/controllers/address_controller.dart';

class AddAddressScreen extends StatefulWidget {
  final AddressModel? initialAddress;

  const AddAddressScreen({super.key, this.initialAddress});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = Get.find<AddressController>();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _pinCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _houseCtrl;
  late TextEditingController _roadCtrl;

  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final addr = widget.initialAddress;

    // Split the address string for edit mode
    final fullAddr = addr?.address ?? '';
    final parts = fullAddr.split('\n');
    final house = parts.isNotEmpty ? parts[0] : '';
    final road = parts.length > 1 ? parts.sublist(1).join('\n') : '';

    _nameCtrl = TextEditingController(text: addr?.name ?? '');
    _phoneCtrl = TextEditingController(text: addr?.phone ?? '');
    _pinCtrl = TextEditingController(text: addr?.pincode ?? '');
    _cityCtrl = TextEditingController(text: addr?.city ?? '');
    _stateCtrl = TextEditingController(text: addr?.state ?? '');
    _houseCtrl = TextEditingController(text: house);
    _roadCtrl = TextEditingController(text: road);

    _isDefault = addr?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _pinCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _houseCtrl.dispose();
    _roadCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.initialAddress != null;
      final addressText = '${_houseCtrl.text.trim()}\n${_roadCtrl.text.trim()}';

      final model = AddressModel(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: addressText,
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        pincode: _pinCtrl.text.trim(),
        isDefault: _isDefault,
      );

      bool success;
      if (isEditing) {
        success = await _addressController.updateAddress(widget.initialAddress!.id.toString(), model);
      } else {
        success = await _addressController.addAddress(model);
      }

      if (success && mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialAddress != null;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar:
          AppBar(title: Text(isEditing ? 'Edit Address' : 'Add New Address')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Contact Details'),
              const SizedBox(height: 16),
              _buildTextField('Full Name', Icons.person_outline,
                  controller: _nameCtrl),
              const SizedBox(height: 16),
              _buildTextField('Phone Number', Icons.phone_outlined,
                  keyboardType: TextInputType.phone, controller: _phoneCtrl),
              const SizedBox(height: 32),
              _buildSectionTitle('Address'),
              const SizedBox(height: 16),
              _buildTextField('House No., Building Name', Icons.home_outlined,
                  controller: _houseCtrl),
              const SizedBox(height: 16),
              _buildTextField(
                  'Road Name, Area, Colony', Icons.add_road_outlined,
                  controller: _roadCtrl),
              const SizedBox(height: 16),
              _buildTextField('City', Icons.location_city_outlined,
                  controller: _cityCtrl),
              const SizedBox(height: 16),
              _buildTextField('State', Icons.map_outlined,
                  controller: _stateCtrl),
              const SizedBox(height: 16),
              _buildTextField(
                  'PIN Code', Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  controller: _pinCtrl),
              const SizedBox(height: 24),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Make this my default address',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                activeColor: AppTheme.primary,
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: _addressController.isSubmitting.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _addressController.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(isEditing ? 'Update Address' : 'Save Address',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                )),
              ),
              SizedBox(height: 20 + MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
    );
  }

  Widget _buildTextField(String label, IconData icon,
      {TextInputType? keyboardType, TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textLight, size: 22),
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
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
