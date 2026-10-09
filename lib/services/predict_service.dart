import '../models/fare_prediction.dart';

/// Predicts the total fare locally with a linear regression model fitted on
/// the BDAirways dataset (R² = 0.875 on the full data). No backend needed.
///
/// Note: the paper's best fare model is a Random Forest (test R² = 0.890).
/// The Random Forest cannot run inside Flutter, so this linear model is a
/// lightweight stand-in.
class PredictService {
  static const double _intercept = 10448.611906711947;
  static const double _daysBefore = -28.051114434586786;
  static const double _duration = -43.73989249810302;

  static const Map<String, double> _source = {
    'BZL': -76.85724982784835,
    'CGP': 57.006075460236374,
    'CXB': 137.71768006964894,
    'DAC': 10.4079285319024,
    'JSR': -88.12536512110786,
    'RJH': 23.0804012708898,
    'SPD': -54.28399585790403,
    'ZYL': -8.945474525816746,
  };

  static const Map<String, double> _destination = {
    'BZL': 106.11805821337994,
    'CGP': 36.62710115753465,
    'CXB': -149.38959805001107,
    'DAC': -126.51169452403825,
    'JSR': 3.773401032605902,
    'RJH': 91.30165362877314,
    'SPD': 38.081078541755424,
  };

  static const Map<String, double> _cabinClass = {
    'Business': -298.83897999753935,
    'Economy': -4089.0930405132067,
    'First Class': 4387.932020510748,
  };

  static const Map<String, double> _seasonality = {
    'Eid': 758.7502916932723,
    'Hajj': 1578.5178549933119,
    'Regular': -1831.1402351792783,
    'Winter Holidays': -506.12791150730544,
  };

  static const Map<String, double> _airline = {
    'Air Astra': -2.9663909270655977,
    'Biman Bangladesh Airlines': 66.63179586683793,
    'NovoAir': -25.6912913279307,
    'US-Bangla Airlines': -37.97411361184188,
  };

  Future<double> predictFare(FarePrediction request) async {
    final fare = _intercept +
        (_source[request.source] ?? 0) +
        (_destination[request.destination] ?? 0) +
        (_cabinClass[request.cabinClass] ?? 0) +
        (_seasonality[request.seasonality] ?? 0) +
        (_airline[request.airline] ?? 0) +
        _daysBefore * request.daysBeforeDeparture +
        _duration * request.durationHrs;
    return fare < 1500 ? 1500 : fare;
  }
}