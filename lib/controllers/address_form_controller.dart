// controllers/address_form_controller.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:task_new/models/address_form_state.dart';
import 'package:task_new/models/address_model.dart';

final addressFormProvider = ChangeNotifierProvider<AddressFormController>(
  (ref) => AddressFormController(),
);

class AddressFormController extends ChangeNotifier {
  AddressFormState _state = AddressFormState();

  AddressFormState get state => _state;

  // Getters for individual fields
  String get name => _state.name;
  String get email => _state.email;
  String get phone => _state.phone;
  String get street => _state.street;
  String get apartment => _state.apartment;
  String get city => _state.city;
  String get stateProvince => _state.state;
  String get zip => _state.zip;
  String get country => _state.country;
  String get instructions => _state.instructions;
  bool get isCurrentLocation => _state.isCurrentLocation;
  String? get selectedAddressId => _state.selectedAddressId;
  String get fullAddress => _state.fullAddress;
  String get shortAddress => _state.shortAddress;
  bool get isValid => _state.isValid;

  // Update individual field
  void updateField(String field, String value) {
    switch (field) {
      case 'name':
        _state = _state.copyWith(name: value);
        break;
      case 'email':
        _state = _state.copyWith(email: value);
        break;
      case 'phone':
        _state = _state.copyWith(phone: value);
        break;
      case 'street':
        _state = _state.copyWith(street: value);
        break;
      case 'apartment':
        _state = _state.copyWith(apartment: value);
        break;
      case 'city':
        _state = _state.copyWith(city: value);
        break;
      case 'stateProvince':
        _state = _state.copyWith(state: value);
        break;
      case 'zip':
        _state = _state.copyWith(zip: value);
        break;
      case 'country':
        _state = _state.copyWith(country: value);
        break;
      case 'instructions':
        _state = _state.copyWith(instructions: value);
        break;
    }
    notifyListeners();
  }

  // Load address from AddressModel
  void loadAddress(AddressModel address) {
    _state = AddressFormState.fromAddressModel(address);
    notifyListeners();
  }

  // Load from location data
  void loadFromLocation(AddressFormState locationData) {
    _state = locationData.copyWith(isCurrentLocation: true);
    notifyListeners();
  }

  // Set address as selected (for tracking)
  void selectAddress(String addressId) {
    _state = _state.copyWith(
      selectedAddressId: addressId,
      isCurrentLocation: false,
    );
    notifyListeners();
  }

  // Set current location as selected
  void selectLocation() {
    _state = _state.copyWith(
      isCurrentLocation: true,
      selectedAddressId: null,
    );
    notifyListeners();
  }

  // Convert form to AddressModel
  AddressModel buildAddressModel() {
    return _state.toAddressModel();
  }

  // Clear form
  void clear() {
    _state = AddressFormState();
    notifyListeners();
  }

  // Clear only address fields, preserve selection state (for "Add New" dialog)
  void clearFieldsOnly() {
    _state = _state.copyWith(
      street: '',
      apartment: '',
      city: '',
      state: '',
      zip: '',
      country: 'India',
      instructions: '',
      // Keep isCurrentLocation and selectedAddressId as-is
    );
    notifyListeners();
  }

  // Batch update multiple fields
  void updateMultiple(Map<String, String> updates) {
    var newState = _state;
    updates.forEach((field, value) {
      switch (field) {
        case 'name':
          newState = newState.copyWith(name: value);
          break;
        case 'email':
          newState = newState.copyWith(email: value);
          break;
        case 'phone':
          newState = newState.copyWith(phone: value);
          break;
        case 'street':
          newState = newState.copyWith(street: value);
          break;
        case 'apartment':
          newState = newState.copyWith(apartment: value);
          break;
        case 'city':
          newState = newState.copyWith(city: value);
          break;
        case 'stateProvince':
          newState = newState.copyWith(state: value);
          break;
        case 'zip':
          newState = newState.copyWith(zip: value);
          break;
        case 'country':
          newState = newState.copyWith(country: value);
          break;
        case 'instructions':
          newState = newState.copyWith(instructions: value);
          break;
      }
    });
    _state = newState;
    notifyListeners();
  }

  // Reset to address model
  void resetToAddress(AddressModel address) {
    loadAddress(address);
  }

  // Reset to location
  void resetToLocation(AddressFormState locationData) {
    loadFromLocation(locationData);
  }
}
