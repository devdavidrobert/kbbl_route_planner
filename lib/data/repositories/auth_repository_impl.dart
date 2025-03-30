// lib/data/repositories/auth_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final UserProfileRepository _userProfileRepository;
  final _logger = Logger('AuthRepositoryImpl');

  AuthRepositoryImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required UserProfileRepository userProfileRepository,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _userProfileRepository = userProfileRepository,
        _googleSignIn = googleSignIn ?? GoogleSignIn(
          scopes: ['email', 'profile'],
          signInOption: SignInOption.standard,
        );

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      _logger.info('Starting Google Sign-In process');
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();

      _logger.info('Showing Google Sign-In UI');
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _logger.warning('Google Sign-In cancelled by user');
        throw Exception('Sign in was cancelled');
      }

      _logger.info('Google Sign-In successful, getting auth tokens');
      final googleAuth = await googleUser.authentication;
      _logger.fine('GoogleAuth: accessToken=${googleAuth.accessToken}, idToken=${googleAuth.idToken}');
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        _logger.severe('Google auth tokens are null');
        throw Exception('Failed to get authentication tokens');
      }

      domain.User domainUser;
      try {
        _logger.info('Creating Firebase credential');
        final credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        _logger.info('Signing in to Firebase');
        final userCredential = await _firebaseAuth.signInWithCredential(credential);
        _logger.fine('UserCredential: user=${userCredential.user}, additionalInfo=${userCredential.additionalUserInfo}');
        final user = userCredential.user;
        if (user == null) {
          _logger.severe('Firebase user is null');
          throw Exception('Unable to sign in');
        }
        _logger.info('Firebase user: ${user.email}, ${user.uid}');
        domainUser = domain.User(
          id: user.uid,
          email: user.email ?? googleUser.email,
          displayName: user.displayName ?? googleUser.displayName,
        );
      } catch (firebaseError, stackTrace) {
        _logger.warning('Firebase sign-in failed, falling back to Google user: $firebaseError', firebaseError, stackTrace);
        domainUser = domain.User(
          id: googleUser.id,
          email: googleUser.email,
          displayName: googleUser.displayName,
        );
      }

      _logger.info('Checking user profile in MongoDB for: ${domainUser.email}');
      final profileResult = await _userProfileRepository.getUserProfile(domainUser.email);
      return profileResult.fold(
        (failure) {
          _logger.severe('Profile check failed: ${failure.message}');
          throw Exception('Profile check failed: ${failure.message}');
        },
        (profile) => AuthResult(
          user: domainUser,
          profile: profile,
          needsProfile: profile == null,
        ),
      );
    } catch (e, stackTrace) {
      _logger.severe('Sign in error: $e', e, stackTrace);
      try {
        await _googleSignIn.signOut();
        await _firebaseAuth.signOut();
      } catch (cleanupError) {
        _logger.warning('Cleanup failed: $cleanupError');
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      _logger.info('Starting sign out process');
      await Future.wait([
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
      ]);
      _logger.info('Sign out successful');
    } catch (e, stackTrace) {
      _logger.severe('Sign out error: $e', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<domain.User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        _logger.info('No current user found in Firebase, checking Google');
        final googleUser = await _googleSignIn.signInSilently();
        if (googleUser == null) {
          _logger.info('No current user found');
          return null;
        }
        return domain.User(
          id: googleUser.id,
          email: googleUser.email,
          displayName: googleUser.displayName,
        );
      }
      _logger.info('Current user found: ${firebaseUser.uid}');
      return domain.User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
      );
    } catch (e, stackTrace) {
      _logger.severe('Error getting current user: $e', e, stackTrace);
      return null;
    }
  }
}