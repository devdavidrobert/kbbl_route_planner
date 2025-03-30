// lib/data/repositories/auth_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/core/failures.dart';

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
          scopes: [
            'email',
            'profile',
          ],
          signInOption: SignInOption.standard,
        );

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      _logger.info('Starting Google Sign-In process');
      
      // First ensure we're signed out
      try {
        final currentUser = await _googleSignIn.signInSilently();
        if (currentUser != null) {
          await _googleSignIn.disconnect();
        }
        await _firebaseAuth.signOut();
      } catch (e) {
        _logger.warning('Error during sign out (continuing anyway): $e');
      }
      
      // Add a small delay to ensure previous sign-out is complete
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Get Google sign in
      _logger.info('Showing Google Sign-In UI');
      final googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _logger.warning('Google Sign-In cancelled by user');
        throw Exception('Sign in was cancelled');
      }

      _logger.info('Google Sign-In successful, getting auth tokens');
      final googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        _logger.severe('Google auth tokens are null');
        throw Exception('Failed to get authentication tokens. Please try again.');
      }
      
      // Create Firebase credential
      _logger.info('Creating Firebase credential');
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      _logger.info('Signing in to Firebase');
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
        _logger.severe('Firebase user is null after successful credential sign in');
        throw Exception('Unable to sign in');
      }

      // Verify the email matches
      if (user.email != googleUser.email) {
        _logger.severe('Email mismatch between Google (${googleUser.email}) and Firebase (${user.email})');
        throw Exception('Authentication error: email mismatch');
      }

      _logger.info('Successfully signed in to Firebase. User: ${user.email}');
      
      // Create domain user
      final domainUser = domain.User(
        id: user.uid,
        email: user.email ?? googleUser.email,
        displayName: user.displayName ?? googleUser.displayName,
      );

      // Check if user exists in MongoDB
      _logger.info('Checking if user exists in MongoDB');
      final profileResult = await _userProfileRepository.getUserProfile(domainUser.email);
      
      return await profileResult.fold(
        (failure) {
          if (failure is NetworkFailure) {
            throw Exception('Unable to check user profile. Please check your internet connection.');
          } else {
            throw Exception('Unable to check user profile. Please try again.');
          }
        },
        (profile) {
          if (profile == null) {
            _logger.info('User not found in MongoDB, needs profile creation');
            return AuthResult(
              user: domainUser,
              profile: null,
              needsProfile: true,
            );
          } else {
            _logger.info('User found in MongoDB with profile');
            return AuthResult(
              user: domainUser,
              profile: profile,
              needsProfile: false,
            );
          }
        },
      );
    } catch (e) {
      _logger.severe('Sign in error: $e');
      // Clean up on error
      try {
        await _googleSignIn.disconnect();
        await _firebaseAuth.signOut();
      } catch (cleanupError) {
        _logger.warning('Error during cleanup: $cleanupError');
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
    } catch (e) {
      _logger.severe('Sign out error: $e');
      rethrow;
    }
  }

  @override
  Future<domain.User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        _logger.info('No current user found');
        return null;
      }
      
      _logger.info('Current user found: ${firebaseUser.uid}');
      return domain.User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
      );
    } catch (e) {
      _logger.severe('Error getting current user: $e');
      return null;
    }
  }
}
