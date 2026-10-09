import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/fare_prediction.dart';
import '../services/firestore_service.dart';
import '../services/predict_service.dart';
import '../theme/app_theme.dart';

class PredictorScreen extends StatefulWidget {
  const PredictorScreen({super.key});

  @override
  State<PredictorScreen> createState() => _PredictorScreenState();
}

class _PredictorScreenState extends State<PredictorScreen> {
  String _source = 'DAC';
  String _destination = 'CXB';
  String _cabinClass = 'Economy';
  String _airline = 'US-Bangla Airlines';
  String _seasonality = 'Regular';
  double _daysBeforeDeparture = 30;
  double _durationHrs = 1.1;

  final _predictService = PredictService();
  final _firestoreService = FirestoreService();

  bool _loading = false;
  double? _result;
  String? _error;
  String? _logStatus;

  Future<void> _openBookingSite() async {
    final url = BDAirwaysData.airlineBookingUrls[_airline];
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '',
    decimalDigits: 0,
  );

  Future<void> _runPrediction() async {
    if (_source == _destination) {
      setState(() => _error = 'Source and destination must be different.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _logStatus = null;
    });

    final request = FarePrediction(
      source: _source,
      destination: _destination,
      cabinClass: _cabinClass,
      airline: _airline,
      seasonality: _seasonality,
      daysBeforeDeparture: _daysBeforeDeparture.round(),
      durationHrs: _durationHrs,
    );

    try {
      final fare = await _predictService.predictFare(request);
      setState(() => _result = fare);

      // Log to Firestore. A logging failure must not hide the prediction.
      try {
        await _firestoreService.logPrediction(FarePrediction(
          source: _source,
          destination: _destination,
          cabinClass: _cabinClass,
          airline: _airline,
          seasonality: _seasonality,
          daysBeforeDeparture: _daysBeforeDeparture.round(),
          durationHrs: _durationHrs,
          predictedFare: fare,
        ));
        setState(() => _logStatus = 'Saved to Firestore.');
      } catch (e) {
        debugPrint('Firestore error: $e');
        setState(() => _logStatus = 'Not saved to Firestore: $e');
      }
    } catch (e) {
      setState(() => _error = 'Could not calculate the fare.\n\n$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildForm(),
          const SizedBox(height: 20),
          _buildResult(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Booking details',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _dropdown(
                    label: 'From',
                    value: _source,
                    items: BDAirwaysData.airports,
                    onChanged: (v) => setState(() => _source = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdown(
                    label: 'To',
                    value: _destination,
                    items: BDAirwaysData.destinationAirports,
                    onChanged: (v) => setState(() => _destination = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _dropdown(
              label: 'Cabin class',
              value: _cabinClass,
              items: BDAirwaysData.cabinClasses,
              onChanged: (v) => setState(() => _cabinClass = v!),
            ),
            const SizedBox(height: 12),
            _dropdown(
              label: 'Airline',
              value: _airline,
              items: BDAirwaysData.airlines,
              onChanged: (v) => setState(() => _airline = v!),
            ),
            const SizedBox(height: 12),
            _dropdown(
              label: 'Seasonality',
              value: _seasonality,
              items: BDAirwaysData.seasons,
              onChanged: (v) => setState(() => _seasonality = v!),
            ),
            const SizedBox(height: 16),
            Text('Days before departure: ${_daysBeforeDeparture.round()}',
                style:
                    const TextStyle(fontSize: 13, color: AppColors.grey)),
            Slider(
              value: _daysBeforeDeparture,
              min: 1,
              max: 90,
              divisions: 89,
              activeColor: AppColors.navy,
              onChanged: (v) => setState(() => _daysBeforeDeparture = v),
            ),
            Text('Flight duration (hrs): ${_durationHrs.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 13, color: AppColors.grey)),
            Slider(
              value: _durationHrs,
              min: 0.5,
              max: 1.8,
              divisions: 130,
              activeColor: AppColors.navy,
              onChanged: (v) => setState(() => _durationHrs = v),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _runPrediction,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Predict fare'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResult() {
    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7E6E1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(_error!,
            style: const TextStyle(color: AppColors.red, fontSize: 13)),
      );
    }

    if (_result == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'Fill in the booking details and tap "Predict fare" to see the '
          'model output. Each prediction is logged to Firestore.',
          style: TextStyle(color: AppColors.grey, fontSize: 13),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PREDICTED TOTAL FARE',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Color(0xFF8FA6B3))),
          const SizedBox(height: 8),
          Text('${_currencyFormat.format(_result)} BDT',
              style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text('$_source \u2192 $_destination \u00b7 $_cabinClass \u00b7 $_airline',
              style: const TextStyle(fontSize: 13, color: Color(0xFFBFD9E3))),
          const SizedBox(height: 10),
          const Text(
            'Estimate from a linear model (R\u00b2 = 0.875). The paper\'s best '
            'fare model is a Random Forest (test R\u00b2 = 0.890).',
            style: TextStyle(fontSize: 12, color: Color(0xFF8FA6B3)),
          ),
          if (_logStatus != null) ...[
            const SizedBox(height: 8),
            Text(_logStatus!,
                style: const TextStyle(fontSize: 12, color: Color(0xFFBFD9E3))),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _openBookingSite,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: AppColors.navy,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text('Book on $_airline\'s official site',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}