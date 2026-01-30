import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/services/hive/hive_service.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/data/datasources/local/donor_local_datasource_impl.dart';
import 'package:raktosewa/features/auth/data/datasources/local/organization_local_datasource_impl.dart';

// Centralized providers for local persistence so presentation remains storage-agnostic.
final hiveStorageProvider = Provider<DonorHiveService>((ref) {
  return DonorHiveService();
});

final donorLocalDatasourceProvider = Provider<DonorLocalDataSourceImpl>((ref) {
  return DonorLocalDataSourceImpl(
    ref.read(hiveStorageProvider),
    ref.read(userSessionServiceProvider),
    ref.read(tokenServiceProvider),
  );
});

final organizationLocalDatasourceProvider =
    Provider<OrganizationLocalDataSourceImpl>((ref) {
  return OrganizationLocalDataSourceImpl(
    ref.read(hiveStorageProvider),
    ref.read(userSessionServiceProvider),
    ref.read(tokenServiceProvider),
  );
});
