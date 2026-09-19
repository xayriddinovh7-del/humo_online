import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Auth uchun remote data source (Firebase orqali)
class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<({UserModel user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const ServerException(message: 'Foydalanuvchi topilmadi');
      }

      final token = await firebaseUser.getIdToken() ?? '';
      
      // Firestore'dan foydalanuvchi ma'lumotlarini olish
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      UserModel userModel;
      if (userDoc.exists) {
        userModel = UserModel.fromJson(userDoc.data()!);
        // ID ni har ehtimolga qarshi to'g'rilab qo'yamiz
        if (userModel.id.isEmpty) {
          userModel = userModel.copyWith(id: firebaseUser.uid);
        }
      } else {
        // Agar Firestore da ma'lumot topilmasa, default yaratamiz
        userModel = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? email,
          role: 'STUDENT',
        );
      }

      return (
        user: userModel,
        accessToken: token,
        refreshToken: token, // Firebase o'zi token yangilashni boshqaradi
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw const UnauthorizedException(message: 'Email yoki parol xato');
      }
      throw ServerException(message: e.message ?? 'Login xatoligi');
    } catch (e) {
      throw ServerException(message: 'Login xatoligi: $e');
    }
  }

  Future<({UserModel user, String accessToken, String refreshToken})> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (password != passwordConfirmation) {
      throw const ValidationException(message: 'Parollar mos emas');
    }

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const ServerException(message: 'Ro\'yxatdan o\'tishda xatolik');
      }

      // Ismni yangilash
      await firebaseUser.updateDisplayName(name);

      final userModel = UserModel(
        id: firebaseUser.uid,
        name: name,
        email: email,
        role: 'STUDENT',
        createdAt: DateTime.now(),
      );

      // Firestore ga ma'lumotni saqlash
      await _firestore.collection('users').doc(firebaseUser.uid).set(userModel.toJson());

      final token = await firebaseUser.getIdToken() ?? '';

      return (
        user: userModel,
        accessToken: token,
        refreshToken: token,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw const ValidationException(message: 'Bu email allaqachon ro\'yxatdan o\'tgan');
      }
      throw ServerException(message: e.message ?? 'Ro\'yxatdan o\'tishda xatolik');
    } catch (e) {
      throw ServerException(message: 'Ro\'yxatdan o\'tishda xatolik: $e');
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'Parolni tiklash xati yuborilmadi');
    } catch (e) {
      throw ServerException(message: 'Xatolik yuz berdi: $e');
    }
  }

  Future<UserModel> getMe() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      throw const UnauthorizedException(message: 'Foydalanuvchi tizimga kirmagan');
    }

    try {
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      } else {
        return UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          role: 'STUDENT',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Profilni yuklashda xatolik: $e');
    }
  }
}
