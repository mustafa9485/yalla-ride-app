import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yalla_ride_app/utils/constants.dart'; // For error handling

// Data structure to hold pricing information
// This should ideally be fetched from Supabase later, but hardcoded for MVP
const Map<String, double> collectivePricingFromFallujah = {
  'القائم': 25000,
  'العبيدي': 25000,
  'عانة': 20000,
  'راوة': 20000,
  'حديثة': 20000,
  'البغدادي': 15000,
  'هيت': 10000,
  'المحمدي': 10000, // Assuming المحمدي is near هيت
  'كبيسة': 10000,
  'الرطبة': 25000,
  'الخالدية': 5000,
  'الحبانية': 3000,
  'العامرية': 4000, // Assuming عامرية الفلوجة
  'السياحية': 5000,
  'الرمادي': 5000, // Assuming a price for Ramadi itself if needed
};

const Map<String, double> collectivePricingFromRamadi = {
  'القائم': 20000,
  'العبيدي': 20000,
  'عانة': 20000,
  'راوة': 20000,
  'حديثة': 20000,
  'البغدادي': 10000,
  'كبيسة': 10000,
  'الرطبة': 20000,
  'هيت': 8000,
  'الخالدية': 5000,
  'الحبانية': 3000,
  'العامرية': 4000,
  'السياحية': 5000,
  'الفلوجة': 5000, // Assuming a price for Fallujah itself if needed
};

class RideRequestScreen extends StatefulWidget {
  const RideRequestScreen({super.key});

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  String? _pickupLocation;
  String? _destinationLocation;
  String? _rideType;
  double? _estimatedPrice;
  bool _isLoading = false;

  final List<String> _anbarRegions = [
    'الفلوجة', 'الرمادي', 'هيت', 'حديثة', 'عانة', 'القائم', 'الحبانية',
    'الكرمة', 'عامرية الفلوجة', 'الصقلاوية', 'الخالدية', 'الجزيرة',
    'كبيسة', 'بروانة', 'الحقلانية', 'البغدادي', 'راوة', 'العبيدي',
    'عكاشات', 'الرطبة', 'النخيب', 'السياحية', 'المحمدي'
  ];

  final List<String> _rideTypes = [
    'تجميعية الأشخاص', 'عائلية', 'تجميعية VIP',
    'مناسبات داخلية VIP', 'مناسبات داخلية (كبيرة)',
    'توصيل فردي', 'رحلة داخلية واحدة',
  ];

  void _calculatePrice() {
    if (_pickupLocation == null || _destinationLocation == null || _rideType == null) {
      setState(() {
        _estimatedPrice = null;
      });
      return;
    }

    double calculatedPrice = 0;

    switch (_rideType) {
      case 'تجميعية الأشخاص':
        Map<String, double> pricingTable;
        if (_pickupLocation == 'الفلوجة') {
          pricingTable = collectivePricingFromFallujah;
        } else if (_pickupLocation == 'الرمادي') {
          pricingTable = collectivePricingFromRamadi;
        } else {
          calculatedPrice = 5500;
          break;
        }
        calculatedPrice = pricingTable[_destinationLocation] ?? 5500;
        break;
      case 'عائلية':
        calculatedPrice = 20500;
        break;
      case 'تجميعية VIP':
        calculatedPrice = 6500;
        break;
      case 'مناسبات داخلية VIP':
        calculatedPrice = 10000;
        break;
      case 'مناسبات داخلية (كبيرة)':
        calculatedPrice = 25000;
        break;
      case 'توصيل فردي':
        calculatedPrice = 7000;
        break;
      case 'رحلة داخلية واحدة':
        calculatedPrice = 3000;
        break;
      default:
        calculatedPrice = 0;
    }

    setState(() {
      _estimatedPrice = calculatedPrice > 0 ? calculatedPrice : null;
    });
  }

  Future<void> _submitRideRequest() async {
    if (_pickupLocation == null || _destinationLocation == null || _rideType == null || _estimatedPrice == null) {
      context.showErrorSnackBar(message: 'يرجى إكمال جميع الحقول');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client.from('rides').insert({
        'passenger_id': userId,
        'pickup_location_name': _pickupLocation!,
        'destination_location_name': _destinationLocation!,
        'ride_type': _rideType!,
        'estimated_price': _estimatedPrice!,
        'status': 'pending',
      });

      if (mounted) {
        context.showSnackBar(message: 'تم إرسال طلبك بنجاح!');
        // TODO: Optionally navigate away or show a waiting screen
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        context.showErrorSnackBar(message: 'حدث خطأ أثناء إرسال الطلب');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب رحلة جديدة'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DropdownButtonFormField<String>(
            value: _pickupLocation,
            isExpanded: true,
            hint: const Text('اختر نقطة الانطلاق'),
            items: _anbarRegions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: _isLoading ? null : (newValue) {
              setState(() {
                _pickupLocation = newValue;
                if (_destinationLocation == _pickupLocation) {
                  _destinationLocation = null;
                }
                _calculatePrice();
              });
            },
            decoration: const InputDecoration(labelText: 'من'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _destinationLocation,
            isExpanded: true,
            hint: const Text('اختر الوجهة'),
            items: _anbarRegions
                .where((region) => region != _pickupLocation)
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: _isLoading ? null : (newValue) {
              setState(() {
                _destinationLocation = newValue;
                _calculatePrice();
              });
            },
            decoration: const InputDecoration(labelText: 'إلى'),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _rideType,
            isExpanded: true,
            hint: const Text('اختر نوع الرحلة'),
            items: _rideTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: _isLoading ? null : (newValue) {
              setState(() {
                _rideType = newValue;
                _calculatePrice();
              });
            },
            decoration: const InputDecoration(labelText: 'نوع الرحلة'),
          ),
          const SizedBox(height: 24),
          if (_estimatedPrice != null)
            Card(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'السعر التقريبي:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_estimatedPrice?.toStringAsFixed(0)} د.ع',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (_rideType == 'تجميعية الأشخاص' || _rideType == 'تجميعية VIP')
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '(السعر للشخص الواحد)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: (_pickupLocation != null && _destinationLocation != null && _rideType != null && _estimatedPrice != null && !_isLoading)
                ? _submitRideRequest
                : null,
            child: Text(_isLoading ? 'جاري الإرسال...' : 'تأكيد طلب الرحلة'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

