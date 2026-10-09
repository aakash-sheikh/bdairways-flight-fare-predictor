import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents one fare-prediction request and its result.
/// Mirrors the feature set used in the paper's pipeline:
/// Source, Destination, Class, Airline, Seasonality, Days Before Departure,
/// Duration (hrs).
class FarePrediction {
  final String source;
  final String destination;
  final String cabinClass;
  final String airline;
  final String seasonality;
  final int daysBeforeDeparture;
  final double durationHrs;
  final double? predictedFare;
  final DateTime createdAt;

  FarePrediction({
    required this.source,
    required this.destination,
    required this.cabinClass,
    required this.airline,
    required this.seasonality,
    required this.daysBeforeDeparture,
    required this.durationHrs,
    this.predictedFare,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'source': source,
        'destination': destination,
        'cabinClass': cabinClass,
        'airline': airline,
        'seasonality': seasonality,
        'daysBeforeDeparture': daysBeforeDeparture,
        'durationHrs': durationHrs,
      };

  /// Used when writing a completed prediction to Firestore for history/logs.
  Map<String, dynamic> toFirestore() => {
        ...toJson(),
        'predictedFare': predictedFare,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory FarePrediction.fromFirestore(Map<String, dynamic> data) {
    return FarePrediction(
      source: data['source'] as String,
      destination: data['destination'] as String,
      cabinClass: data['cabinClass'] as String,
      airline: data['airline'] as String,
      seasonality: data['seasonality'] as String,
      daysBeforeDeparture: data['daysBeforeDeparture'] as int,
      durationHrs: (data['durationHrs'] as num).toDouble(),
      predictedFare: (data['predictedFare'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

/// Static reference data — mirrors the actual categories found in the
/// BDAirways dataset (3,618 rows, verified during pipeline-building).
class BDAirwaysData {
  static const airports = ['BZL', 'CGP', 'CXB', 'DAC', 'JSR', 'RJH', 'SPD', 'ZYL'];
  static const destinationAirports = ['BZL', 'CGP', 'CXB', 'DAC', 'JSR', 'RJH', 'SPD'];
  static const cabinClasses = ['Economy', 'Business', 'First Class'];
  static const seasons = ['Regular', 'Eid', 'Hajj', 'Winter Holidays'];
  static const airlines = [
    'US-Bangla Airlines',
    'Biman Bangladesh Airlines',
    'Air Astra',
    'NovoAir',
  ];

  /// Official booking sites, verified via web search (Aug 2026).
  static const airlineBookingUrls = {
    'US-Bangla Airlines': 'https://usbair.com/',
    'Biman Bangladesh Airlines': 'https://www.biman-airlines.com/',
    'Air Astra': 'https://airastra.com/',
    'NovoAir': 'https://www.flynovoair.com/',
  };
}
