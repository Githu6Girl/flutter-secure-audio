import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Calculate age
      final now = DateTime.now();
      int age = now.year - dateOfBirth.year;
      if (now.month < dateOfBirth.month ||
          (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
        age--;
      }

      // Save user data to Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'dateOfBirth': dateOfBirth,
        'age': age,
        'createdAt': DateTime.now(),
        'monthlyGoalHours': 20,
      });

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<Map<String, dynamic>> getUserData() async {
    if (currentUser == null) throw Exception('User not logged in');
    
    final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    return doc.data() ?? {};
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'invalid-email':
        return 'Format d\'email invalide.';
      default:
        return 'Erreur d\'authentification: ${e.message}';
    }
  }
}
