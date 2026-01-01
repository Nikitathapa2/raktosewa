import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:raktosewa/core/constants/hive_table_constant.dart';
import 'package:raktosewa/features/auth/data/repository/donor_repository_impl.dart';
import '../../data/models/donor_model.dart';
import '../../data/datasources/local/donor_local_datasource_impl.dart';
import '../../domain/usecases/register_donor.dart';
import '../../domain/usecases/login_donor.dart';
import '../state/donor_state.dart';
import '../view_model/donor_viewmodel.dart';

// -------------------- Donor Hive Box Provider --------------------
final donorBoxProvider = Provider<Box<DonorModel>>((ref) {
  return Hive.box<DonorModel>(HiveTableConstant.donorTable);
});

// -------------------- Donor Local Datasource Provider --------------------
final donorLocalDatasourceProvider = Provider<DonorLocalDataSourceImpl>((ref) {
  final box = ref.read(donorBoxProvider);
  return DonorLocalDataSourceImpl(box);
});

// -------------------- Donor Repository Provider --------------------
final donorRepositoryProvider = Provider<DonorRepositoryImpl>((ref) {
  final local = ref.read(donorLocalDatasourceProvider);
  return DonorRepositoryImpl(localDataSource: local);
});

// -------------------- Donor Usecase Providers --------------------
final registerDonorProvider = Provider<RegisterDonor>((ref) {
  final repo = ref.read(donorRepositoryProvider);
  return RegisterDonor(repo);
});

final loginDonorProvider = Provider<LoginDonor>((ref) {
  final repo = ref.read(donorRepositoryProvider);
  return LoginDonor(repo);
});

// -------------------- Donor ViewModel Provider --------------------
final donorViewModelProvider = NotifierProvider<DonorViewModel, DonorState>(
  DonorViewModel.new,
);
