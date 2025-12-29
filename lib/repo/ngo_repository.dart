import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gonullunet_app/models/ngo_model.dart';

class NgoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Ngo>> getNgosStream() {
    return _firestore
        .collection('users')
        .where('userType', isEqualTo: 'ngo')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Ngo.fromFirestore(doc)).toList();
    });
  }
}
