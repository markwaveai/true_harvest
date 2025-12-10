// widgets/address_selection_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_new/controllers/address_controller.dart';
import 'package:task_new/controllers/address_form_controller.dart';
import 'package:task_new/controllers/location_provider.dart';

class AddressSelectionList extends ConsumerWidget {
  final VoidCallback? onAddressSelected;
  final VoidCallback? onLocationSelected;

  const AddressSelectionList({
    Key? key,
    this.onAddressSelected,
    this.onLocationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressCtrl = ref.watch(addressProvider);
    final locationState = ref.watch(locationProvider);
    final formCtrl = ref.watch(addressFormProvider);

    final savedAddresses = addressCtrl.addresses;
    final hasLocation = locationState.detailedAddress != null &&
      (locationState.detailedAddress!.street.isNotEmpty || locationState.detailedAddress!.fullAddress.isNotEmpty);

    // If there is no saved address but we have location data, ensure the form defaults to location
    if (addressCtrl.address == null && hasLocation && !formCtrl.isCurrentLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (locationState.detailedAddress != null) {
          ref.read(addressFormProvider).loadFromLocation(locationState.detailedAddress!);
        }
      });
    }

    if (savedAddresses.isEmpty && !hasLocation) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Text(
          'No saved addresses. Use current location or add a new address.',
          style: TextStyle(color: Colors.grey[700]),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: savedAddresses.length + (hasLocation ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        // Current Location Option
            if (hasLocation && idx == savedAddresses.length) {
          return RadioListTile<String>(
            value: 'current_location',
            groupValue:
                formCtrl.isCurrentLocation ? 'current_location' : null,
            title: const Text('Current Location'),
            subtitle: Text(
              '${locationState.detailedAddress!.street}, ${locationState.detailedAddress!.city}, ${locationState.detailedAddress!.state} ${locationState.detailedAddress!.zip}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            onChanged: (v) {
              if (v == null) return;
              ref
                  .read(addressFormProvider)
                  .loadFromLocation(locationState.detailedAddress!);
              ref.read(addressProvider).clearAddress();
              onLocationSelected?.call();
            },
          );
        }

        // Saved Addresses
        final address = savedAddresses[idx];
        final isSelected = formCtrl.selectedAddressId == address.id;

        return RadioListTile<String>(
          value: address.id,
          groupValue: isSelected ? address.id : null,
          title: Text(address.name),
          subtitle: Text(address.fullAddress,
              style: TextStyle(color: Colors.grey[700])),
          onChanged: (v) {
            if (v == null) return;
            ref.read(addressFormProvider).loadAddress(address);
            ref.read(addressProvider).selectAddress(idx);
            onAddressSelected?.call();
          },
        );
      },
    );
  }
}
