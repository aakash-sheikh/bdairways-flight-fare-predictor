import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fare_prediction.dart';

/// Handles all reads/writes to Cloud Firestore.
///
/// Schema (collection: "predictions"):
///   source: string
///   destination: string
///   cabinClass: string
///   airline: string
///   seasonality: string
///   daysBeforeDeparture: number
///   durationHrs: number
///   predictedFare: number
///   createdAt: timestamp
///
/// This gives you a real, growing dataset of demo usage you can show
/// live during the viva ("here's every prediction this app has made").
class FirestoreService {
  final _db = FirebaseFirestore.instance;
  static const _collection = 'predictions';

  /// Save a completed prediction to Firestore.
  Future<void> logPrediction(FarePrediction prediction) async {
    await _db.collection(_collection).add(prediction.toFirestore());
  }

  /// Stream the most recent predictions, newest first.
  /// Use this to power a simple "recent activity" list in the UI.
  Stream<List<FarePrediction>> recentPredictions({int limit = 20}) {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FarePrediction.fromFirestore(doc.data()))
            .toList());
  }

  /// Simple aggregate: how many predictions have been logged in total.
  /// Firestore doesn't do server-side COUNT on the free tier the same way
  /// SQL does, so for a demo this reads the collection size directly.
  /// For production scale, use a Cloud Function-maintained counter instead.
  Future<int> totalPredictionCount() async {
    final snapshot = await _db.collection(_collection).count().get();
    return snapshot.count ?? 0;
  }
}
