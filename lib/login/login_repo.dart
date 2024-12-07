import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginRepo {
  static Future<Map<String, dynamic>> login(String userName, String password) async {
    try {
      QuerySnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: userName)
          .where('password', isEqualTo: password)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        return {
          'login': true,
          'hasPermission': userData['hasPermission'] ?? false,
        };
      } else {
        return {
          'login': false,
          'hasPermission': false,
        };
      }
    } catch (e) {
      log('Login error: $e');
      return {
        'login': false,
        'hasPermission': false,
      };
    }
  }


  static Future<bool> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on FirebaseException catch (e) {
      return false;
    }
  }

  static Future<bool> signUp(
      String userName, String password, bool givePermission) async {
    try {
      await FirebaseFirestore.instance.collection('users').add({
        'userName': userName,
        'password': password,
        'hasPermission': givePermission
      });
      return true;
    } on FirebaseException catch (e) {
      log('====================================== $e');
      return false;
    }
  }
}
