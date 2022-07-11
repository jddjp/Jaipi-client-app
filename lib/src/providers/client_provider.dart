

import 'package:cloud_firestore/cloud_firestore.dart';

class ClientProvider {

  static const collectionPath = "clients";

  /**
   * Get client info
   */
  static Future<DocumentSnapshot> getInfo(String uid) {
    return FirebaseFirestore.instance.collection(collectionPath)
      .doc(uid)
      .get();
  }

  /**
   * Update client info
   */
  static Future update(String uid, { String name, String phoneNumber, String email }) {
    return FirebaseFirestore.instance.collection(collectionPath)
      .doc(uid)
      .update({
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email
      });
  }
}