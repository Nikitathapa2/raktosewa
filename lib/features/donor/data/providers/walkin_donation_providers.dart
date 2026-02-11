import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/connectivity/network_info.dart';
import '../../../../core/services/storage/token_service.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../../domain/repositories/walkin_donation_repository.dart';
import '../../domain/usecases/register_walkin_donation_usecase.dart';
import '../datasources/walkin_donation_remote_datasource_impl.dart';
import '../repositories/walkin_donation_repository_impl.dart';

// -------------------- Remote DataSource Provider --------------------
final walkinDonationRemoteDataSourceProvider =
    Provider<WalkinDonationRemoteDataSourceImpl>((ref) {
  final userSession = ref.read(userSessionServiceProvider);
  final tokenSession = ref.read(tokenServiceProvider);
  final token = tokenSession.getToken();
  
  final remoteDataSource = WalkinDonationRemoteDataSourceImpl(
    client: http.Client(),
    token: token,
  );
  
  if (token != null) {
    remoteDataSource.setToken(token);
  }
  
  return remoteDataSource;
});

// -------------------- Repository Provider --------------------
final walkinDonationRepositoryProvider =
    Provider<WalkinDonationRepository>((ref) {
  final remoteDataSource = ref.read(walkinDonationRemoteDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  
  return WalkinDonationRepositoryImpl(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

// -------------------- UseCase Provider --------------------
final registerWalkinDonationProvider =
    Provider<RegisterWalkinDonationUsecase>((ref) {
  final repository = ref.read(walkinDonationRepositoryProvider);
  return RegisterWalkinDonationUsecase(repository);
});
