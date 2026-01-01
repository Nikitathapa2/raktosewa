import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raktosewa/core/constants/hive_table_constant.dart';
import 'package:raktosewa/features/auth/data/models/donor_model.dart';

class DonorHiveService {
  // Register adapter (safe)
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);

    registerAdapter();
    await openBox();
  }

  void registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.donorTypeId)) {
      Hive.registerAdapter(DonorModelAdapter());
    }
  }

  // Open donor box safely
  Future<void> openBox() async {
    if (!Hive.isBoxOpen(HiveTableConstant.dbName)) {
      await Hive.openBox<DonorModel>(HiveTableConstant.dbName);
    }
  }

  // Box getter (safe)
  Box<DonorModel> get _donorBox {
    if (!Hive.isBoxOpen(HiveTableConstant.dbName)) {
      throw HiveError('Donor box not opened');
    }
    return Hive.box<DonorModel>(HiveTableConstant.dbName);
  }

  // ================= CRUD =================

  Future<DonorModel> createDonor(DonorModel donor) async {
    await _donorBox.put(donor.id, donor);
    return donor;
  }

  List<DonorModel> getAllDonors() {
    return _donorBox.values.toList();
  }

  DonorModel? getDonorById(String id) {
    return _donorBox.get(id);
  }

  Future<void> updateDonor(DonorModel donor) async {
    await _donorBox.put(donor.id, donor);
  }

  Future<void> deleteDonor(String id) async {
    await _donorBox.delete(id);
  }
}
