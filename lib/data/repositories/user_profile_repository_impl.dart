// lib/data/repositories/user_profile_repository_impl.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/core/failures.dart';
import '../datasources/remote/user_profile_remote_data_source.dart';
import '../models/user_profile_model.dart';
import '../../../core/error/exceptions.dart';
import 'package:logging/logging.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;
  final Connectivity connectivity;
  final _logger = Logger('UserProfileRepositoryImpl');

  UserProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivity,
  });

  Future<bool> _checkConnectivity() async {
    try {
      final result = await connectivity.checkConnectivity().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw NetworkException('Connectivity check timed out'),
      );
      return result != ConnectivityResult.none;
    } catch (e) {
      _logger.severe('Connectivity check failed: $e');
      return false;
    }
  }

  @override
  Future<Either<Failure, UserProfile?>> getUserProfile(String email) async {
    try {
      if (!await _checkConnectivity()) {
        _logger.warning('No internet connection');
        return Left(NetworkFailure('No internet connection'));
      }

      final model = await remoteDataSource.getUserProfile(email);
      return Right(model?.toEntity());
    } on UnauthorizedException catch (e) {
      _logger.severe('Unauthorized error: $e');
      return Left(AuthFailure(e.toString()));
    } on ServerException catch (e) {
      _logger.severe('Server error: $e');
      return Left(ServerFailure(e.toString()));
    } on NetworkException catch (e) {
      _logger.severe('Network error: $e');
      return Left(NetworkFailure(e.toString()));
    } catch (e, stackTrace) {
      _logger.severe('Unexpected error: $e', e, stackTrace);
      return Left(ServerFailure('Failed to get user profile: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createUserProfile(UserProfile profile) async {
    try {
      if (!await _checkConnectivity()) {
        _logger.warning('No internet connection');
        return Left(NetworkFailure('No internet connection'));
      }

      await remoteDataSource.createUserProfile(UserProfileModel.fromEntity(profile));
      return const Right(null);
    } on UnauthorizedException catch (e) {
      _logger.severe('Unauthorized error: $e');
      return Left(AuthFailure(e.toString()));
    } on ServerException catch (e) {
      _logger.severe('Server error: $e');
      return Left(ServerFailure(e.toString()));
    } on NetworkException catch (e) {
      _logger.severe('Network error: $e');
      return Left(NetworkFailure(e.toString()));
    } catch (e, stackTrace) {
      _logger.severe('Unexpected error: $e', e, stackTrace);
      return Left(ServerFailure('Failed to create user profile: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(UserProfile profile) async {
    try {
      if (!await _checkConnectivity()) {
        _logger.warning('No internet connection');
        return Left(NetworkFailure('No internet connection'));
      }

      await remoteDataSource.updateUserProfile(UserProfileModel.fromEntity(profile));
      return const Right(null);
    } on UnauthorizedException catch (e) {
      _logger.severe('Unauthorized error: $e');
      return Left(AuthFailure(e.toString()));
    } on ServerException catch (e) {
      _logger.severe('Server error: $e');
      return Left(ServerFailure(e.toString()));
    } on NetworkException catch (e) {
      _logger.severe('Network error: $e');
      return Left(NetworkFailure(e.toString()));
    } catch (e, stackTrace) {
      _logger.severe('Unexpected error: $e', e, stackTrace);
      return Left(ServerFailure('Failed to update user profile: $e'));
    }
  }
}
