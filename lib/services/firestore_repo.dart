import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stock_item.dart';
import '../models/usage.dart';

class FirestoreRepo {
  FirestoreRepo._privateConstructor();
  static final FirestoreRepo instance = FirestoreRepo._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Auth
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Stock items
  Stream<List<StockItem>> stockItemsStream() {
    return _db.collection('stock_items').snapshots().map((snap) {
      return snap.docs.map((d) => StockItem.fromMap({...d.data(), 'id': d.id})).toList();
    });
  }

  Future<void> addStockItem(StockItem item) {
    return _db.collection('stock_items').doc(item.id).set(item.toMap());
  }

  Future<void> updateStockItem(StockItem item) {
    return _db.collection('stock_items').doc(item.id).update(item.toMap());
  }

  Future<void> removeStockItem(String id) {
    return _db.collection('stock_items').doc(id).delete();
  }

  // Usages
  Stream<List<Usage>> usagesStream() {
    return _db.collection('daily_usages').orderBy('date', descending: true).snapshots().map((snap) {
      return snap.docs.map((d) => Usage.fromMap({...d.data(), 'id': d.id})).toList();
    });
  }

  Future<void> addUsage(Usage usage) async {
    await _db.collection('daily_usages').doc(usage.id).set(usage.toMap());

    // Decrement stock quantity atomically
    final stockRef = _db.collection('stock_items').doc(usage.stockItemId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(stockRef);
      if (snap.exists) {
        final currentQty = (snap.data()?['quantity'] is num) ? (snap.data()!['quantity'] as num).toDouble() : double.tryParse(snap.data()?['quantity'].toString() ?? '0') ?? 0.0;
        final newQty = (currentQty - usage.quantity).clamp(0.0, double.infinity);
        tx.update(stockRef, {'quantity': newQty});
      }
    });
  }
}
