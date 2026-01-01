// lib/features/auth/data/datasources/local/donor_local_datasource_impl.dart
import 'package:hive/hive.dart';
import '../../models/donor_model.dart';
import '../donor_local_datasource.dart';
import '../../../domain/entities/donor.dart';

class DonorLocalDataSourceImpl implements IDonorLocalDataSource {
  final Box<DonorModel> donorBox;

  DonorLocalDataSourceImpl(this.donorBox);

  @override
  Future<Donor> registerDonor(Donor donor) async {
    final model = DonorModel.fromEntity(donor);
    await donorBox.put(model.id, model);
    return model.toEntity();
  }

  @override
  Future<Donor> loginDonor(String email, String password) async {
    // Filter users by email
    final usersWithEmail = donorBox.values
        .where((u) => u.email == email)
        .toList();

    if (usersWithEmail.isEmpty) {
      throw Exception("No account found with this email");
    }

    // Check password
    final model = usersWithEmail.firstWhere(
      (u) => u.password == password,
      orElse: () => throw Exception("Invalid password"),
    );

    return model.toEntity();
  }

  @override
  Future<Donor?> getDonorById(String id) async {
    final model = donorBox.get(id);
    return model?.toEntity();
  }

  @override
  Future<bool> updateDonor(Donor donor) async {
    if (!donorBox.containsKey(donor.id)) return false;
    final model = DonorModel.fromEntity(donor);
    await donorBox.put(donor.id, model);
    return true;
  }

  @override
  Future<bool> deleteDonor(String id) async {
    if (!donorBox.containsKey(id)) return false;
    await donorBox.delete(id);
    return true;
  }
}
