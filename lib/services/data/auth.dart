import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Stream<QuerySnapshot> userStream() {
    return usersCollection.snapshots();
  }

  Future<void> createUser(
      {required Map<String, dynamic> userMap, required String uid}) async {
    try {
      await usersCollection.doc(uid).set(userMap);
    } on FirebaseException catch (e) {
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }
}
