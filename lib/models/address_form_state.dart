// models/address_form_state.dart
import 'package:task_new/models/address_model.dart';

class AddressFormState {
  final String name;
  final String email;
  final String phone;
  final String street;
  final String apartment;
  final String city;
  final String state;
  final String zip;
  final String country;
  final String instructions;
  final bool isCurrentLocation;
  final String? selectedAddressId;

  AddressFormState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.street = '',
    this.apartment = '',
    this.city = '',
    this.state = '',
    this.zip = '',
    this.country = 'India',
    this.instructions = '',
    this.isCurrentLocation = false,
    this.selectedAddressId,
  });

  // Get full address string
  String get fullAddress {
    final parts = [street, apartment, city, state, zip, country]
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  // Get short address string
  String get shortAddress {
    return '$city, $state';
  }

  // Create AddressModel from form state
  AddressModel toAddressModel() {
    return AddressModel(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      street: street.trim(),
      apartment: apartment.trim(),
      city: city.trim(),
      state: state.trim(),
      zip: zip.trim(),
      country: country.trim(),
      deliveryInstructions: instructions.trim().isEmpty ? null : instructions.trim(),
    );
  }

  // Create from AddressModel
  factory AddressFormState.fromAddressModel(AddressModel address) {
    return AddressFormState(
      name: address.name,
      email: address.email,
      phone: address.phone,
      street: address.street,
      apartment: address.apartment,
      city: address.city,
      state: address.state,
      zip: address.zip,
      country: address.country,
      instructions: address.deliveryInstructions ?? '',
      isCurrentLocation: false,
      selectedAddressId: address.id,
    );
  }

  // Create from location data
  factory AddressFormState.fromLocationData(Map<String, String> location) {
    return AddressFormState(
      street: location['street'] ?? '',
      city: location['city'] ?? '',
      state: location['state'] ?? '',
      zip: location['zip'] ?? '',
      country: location['country'] ?? 'India',
      isCurrentLocation: true,
    );
  }

  // Copy with updates
  AddressFormState copyWith({
    String? name,
    String? email,
    String? phone,
    String? street,
    String? apartment,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? instructions,
    bool? isCurrentLocation,
    String? selectedAddressId,
  }) {
    return AddressFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      apartment: apartment ?? this.apartment,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      country: country ?? this.country,
      instructions: instructions ?? this.instructions,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
    );
  }

  // Clear all fields
  AddressFormState clear() {
    return AddressFormState(
      country: 'India',
      state: 'India',
    );
  }

  // Check if form is valid
  bool get isValid {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        street.isNotEmpty &&
        city.isNotEmpty &&
        state.isNotEmpty &&
        zip.isNotEmpty &&
        country.isNotEmpty;
  }
}
