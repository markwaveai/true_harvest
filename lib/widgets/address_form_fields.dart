// widgets/address_form_fields.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/address_form_controller.dart';
import 'package:task_new/widgets/custom_textfield.dart';

class AddressFormFields extends ConsumerStatefulWidget {
  final bool includePersonalInfo;
  final bool includeInstructions;
  final bool includedeliveryInstructions;
  final GlobalKey<FormState>? formKey;

  const AddressFormFields({
    Key? key,
    this.includePersonalInfo = true,
    this.includeInstructions = true,
    this.includedeliveryInstructions=true,
    this.formKey,
  }) : super(key: key);

  @override
  ConsumerState<AddressFormFields> createState() => _AddressFormFieldsState();
}

class _AddressFormFieldsState extends ConsumerState<AddressFormFields> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _apartmentController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _countryController;
  late TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final formCtrl = ref.read(addressFormProvider);
    _nameController = TextEditingController(text: formCtrl.name);
    _emailController = TextEditingController(text: formCtrl.email);
    _phoneController = TextEditingController(text: formCtrl.phone);
    _streetController = TextEditingController(text: formCtrl.street);
    _apartmentController = TextEditingController(text: formCtrl.apartment);
    _cityController = TextEditingController(text: formCtrl.city);
    _stateController = TextEditingController(text: formCtrl.stateProvince);
    _zipController = TextEditingController(text: formCtrl.zip);
    _countryController = TextEditingController(text: formCtrl.country);
    _instructionsController = TextEditingController(text: formCtrl.instructions);
    // Attach listeners to keep the AddressFormController in sync
    _nameController.addListener(() => ref.read(addressFormProvider).updateField('name', _nameController.text));
    _emailController.addListener(() => ref.read(addressFormProvider).updateField('email', _emailController.text));
    _phoneController.addListener(() => ref.read(addressFormProvider).updateField('phone', _phoneController.text));
    _streetController.addListener(() => ref.read(addressFormProvider).updateField('street', _streetController.text));
    _apartmentController.addListener(() => ref.read(addressFormProvider).updateField('apartment', _apartmentController.text));
    _cityController.addListener(() => ref.read(addressFormProvider).updateField('city', _cityController.text));
    _stateController.addListener(() => ref.read(addressFormProvider).updateField('stateProvince', _stateController.text));
    _zipController.addListener(() => ref.read(addressFormProvider).updateField('zip', _zipController.text));
    _countryController.addListener(() => ref.read(addressFormProvider).updateField('country', _countryController.text));
    _instructionsController.addListener(() => ref.read(addressFormProvider).updateField('instructions', _instructionsController.text));
  }

  @override
  void dispose() {
    // Remove listeners then dispose
    _nameController.removeListener(() {});
    _emailController.removeListener(() {});
    _phoneController.removeListener(() {});
    _streetController.removeListener(() {});
    _apartmentController.removeListener(() {});
    _cityController.removeListener(() {});
    _stateController.removeListener(() {});
    _zipController.removeListener(() {});
    _countryController.removeListener(() {});
    _instructionsController.removeListener(() {});
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.includePersonalInfo) ...[
            // Name Field
            CustomTextField(
              label: 'Full Name',
              controller: _nameController,
              hintText: 'John Doe',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Email Field
            CustomTextField(
              label: 'Email',
              controller: _emailController,
              hintText: 'john@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!value.contains('@')) {
                  return 'Please enter valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Phone Field
            CustomTextField(
              label: 'Phone Number',
              controller: _phoneController,
              hintText: '+91 9876543210',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
          ],
          // Street Address
          CustomTextField(
            label: 'Street Address',
            controller: _streetController,
            hintText: '123 Main Street',
            prefixIcon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter street address';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          // Apartment
          CustomTextField(
            label: 'Apartment, Suite, etc.',
            controller: _apartmentController,
            hintText: 'Plot No. / Apartment (Optional)',
            prefixIcon: Icons.apartment_outlined,
            isOptional: true,
          ),
          const SizedBox(height: 12),
          // City and State Row
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'City',
                  controller: _cityController,
                  hintText: 'Your City',
                  prefixIcon: Icons.location_city,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'State',
                  controller: _stateController,
                  hintText: 'State',
                  prefixIcon: Icons.map_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ZIP and Country Row
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'ZIP Code',
                  controller: _zipController,
                  hintText: '110001',
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'Country',
                  controller: _countryController,
                  hintText: 'India',
                  prefixIcon: Icons.public,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          if (widget.includeInstructions) ...[
            const SizedBox(height: 24),
            Text(
              'Delivery Instructions (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!, width: 1),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[50],
              ),
              child: TextField(
                controller: _instructionsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'E.g., Ring doorbell twice, Leave at gate, etc.',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
