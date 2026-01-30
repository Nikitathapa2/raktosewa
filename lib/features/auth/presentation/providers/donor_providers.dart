import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/services/connectivity/network_info.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/data/datasources/remote/donor_remote_datasourceImp.dart';
import 'package:raktosewa/features/auth/data/providers/auth_local_providers.dart';
import 'package:raktosewa/features/auth/data/repository/donor_repository_impl.dart';
import '../../domain/usecases/register_donor_usecase.dart';
import '../../domain/usecases/login_donor_usecase.dart';
import '../state/donor_state.dart';
import '../view_model/donor_viewmodel.dart';

// -------------------- Donor Repository Provider --------------------
final donorRepositoryProvider = Provider<DonorRepositoryImpl>((ref) {
  final local = ref.read(donorLocalDatasourceProvider);
  final remote = ref.read(donorUserRemoteProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return DonorRepositoryImpl(
    localDataSource: local,
    remoteDataSource: remote,
    networkInfo: networkInfo,
    userSessionService: userSessionService,
  );
});

// -------------------- Donor Usecase Providers --------------------
final registerDonorProvider = Provider<RegisterDonorUsecase>((ref) {
  final repo = ref.read(donorRepositoryProvider);
  return RegisterDonorUsecase(repo);
});

final loginDonorProvider = Provider<LoginDonorUsecase>((ref) {
  final repo = ref.read(donorRepositoryProvider);
  return LoginDonorUsecase(repo);
});

// -------------------- Donor ViewModel Provider --------------------
final donorViewModelProvider = NotifierProvider<DonorViewModel, DonorState>(
  DonorViewModel.new,
);


