import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project/utils/colorconstants.dart';
import 'package:flutter_project/views/pages/Auth/login_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

// User Model
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    this.photoURL,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      photoURL: map['photoURL'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? photoURL,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SignupScreenController with ChangeNotifier {
  bool islogined = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> registerUser({
    required String password,
    required String email,
    required Map<String, String> userData,
    required BuildContext context,
  }) async {
    try {
      islogined = true;
      notifyListeners();

      // Create user with Firebase Auth
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(userData['name']);

        // Save user data to Firestore
        UserModel userModel = UserModel(
          uid: credential.user!.uid,
          email: email,
          name: userData['name']!,
          phone: userData['phone']!,
          address: userData['address']!,
          city: userData['city']!,
          state: userData['state']!,
          zipCode: userData['zipCode']!,
          photoURL: credential.user!.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toMap());

        islogined = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      log('Firebase Auth Error: ${e.code}');
      
      String errorMessage = 'Registration failed. Please try again.';
      
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colorconstants.primarycolor,
        ),
      );

      islogined = false;
      notifyListeners();
    } catch (e) {
      log('Registration Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed. Please try again.'),
          backgroundColor: Colorconstants.primarycolor,
        ),
      );
      islogined = false;
      notifyListeners();
    }
    return false;
  }
}

class LoginScreenController with ChangeNotifier {
  bool islogined = false;
  bool googleislogined = false;
  UserModel? currentUser;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      islogined = true;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _loadUserData(credential.user!.uid);
        islogined = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      log('Firebase Auth Error: ${e.code}');
      
      String errorMessage = 'Login failed. Please try again.';
      
      if (e.code == 'invalid-email') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Wrong password provided for that user.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colorconstants.primarycolor,
        ),
      );

      islogined = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> googleSignin() async {
    try {
      googleislogined = true;
      notifyListeners();

      final GoogleSignInAccount? guser = await GoogleSignIn().signIn();
      if (guser == null) {
        log('Google Sign-In cancelled by the user.');
        googleislogined = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication? gauth = await guser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gauth?.accessToken,
        idToken: gauth?.idToken,
      );

      var response = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (response.user != null) {
        // Check if user data exists in Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(response.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Create user data for Google sign-in users
          UserModel userModel = UserModel(
            uid: response.user!.uid,
            email: response.user!.email!,
            name: response.user!.displayName ?? 'User',
            phone: '', // Will be updated in profile
            address: '', // Will be updated in profile
            city: '', // Will be updated in profile
            state: '', // Will be updated in profile
            zipCode: '', // Will be updated in profile
            photoURL: response.user!.photoURL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await _firestore
              .collection('users')
              .doc(response.user!.uid)
              .set(userModel.toMap());
        }

        await _loadUserData(response.user!.uid);
        googleislogined = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      log('Google Sign-In Error: $e');
      googleislogined = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> _loadUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        currentUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      log('Error loading user data: $e');
    }
  }

  Future<bool> updateUserProfile({
    required Map<String, String> userData,
    required BuildContext context,
  }) async {
    try {
      if (currentUser == null || _auth.currentUser == null) return false;

      // Update display name in Firebase Auth if name changed
      if (userData['name'] != null && userData['name'] != currentUser!.name) {
        await _auth.currentUser!.updateDisplayName(userData['name']);
      }

      // Update user data in Firestore
      UserModel updatedUser = currentUser!.copyWith(
        name: userData['name'],
        phone: userData['phone'],
        address: userData['address'],
        city: userData['city'],
        state: userData['state'],
        zipCode: userData['zipCode'],
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(updatedUser.toMap());

      currentUser = updatedUser;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      return true;
    } catch (e) {
      log('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          backgroundColor: Colorconstants.primarycolor,
        ),
      );
      return false;
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      currentUser = null;
      islogined = false;
      googleislogined = false;
      notifyListeners();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      log('Error during sign out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out. Please try again.'),
          backgroundColor: Colorconstants.primarycolor,
        ),
      );
    }
  }

  Future<void> getCurrentUser() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await _loadUserData(user.uid);
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;
}