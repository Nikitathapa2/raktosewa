import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/network_info.dart';
import '../../domain/entities/walkin_donation.dart';
import '../../domain/repositories/walkin_donation_repository.dart';
import '../datasources/walkin_donation_datasource.dart';
import '../models/walkin_donation_model.dart';

class WalkinDonationRepositoryImpl implements WalkinDonationRepository {
  final IWalkinDonationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  WalkinDonationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, WalkinDonation>> registerWalkinDonation(
    WalkinDonation donation,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final model = WalkinDonationModel.fromEntity(donation);
      final result = await remoteDataSource.registerWalkinDonation(
        donation.organization,
        model,
      );
      return Right(result.toEntity());
    } on Exception catch (e) {
      debugPrint(e.toString());
      return Left(ServerFailure(e.toString()));
    }
  }
}
