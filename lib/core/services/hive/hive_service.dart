import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raktosewa/core/constants/hive_table_constant.dart';
import 'package:raktosewa/features/auth/data/models/donor_model.dart';
import 'package:raktosewa/features/auth/data/models/organization_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonorHiveService {
  static const String _schemaVersionKey = 'hive_schema_version';
  static const int _currentSchemaVersion = 2; // Increment when schema changes

  // -------------------- Initialization --------------------
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);

    await _checkAndMigrateSchema();
    _registerAdapters();
    await _openBoxes();
  }

  Future<void> _checkAndMigrateSchema() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getInt(_schemaVersionKey) ?? 0;
    
    if (savedVersion < _currentSchemaVersion) {
      print('Schema version mismatch. Clearing old Hive data...');
      // Delete old boxes
      await Hive.deleteBoxFromDisk(HiveTableConstant.donorTable);
      await Hive.deleteBoxFromDisk(HiveTableConstant.organizationTable);
      // Update version
      await prefs.setInt(_schemaVersionKey, _currentSchemaVersion);
    }
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.donorTypeId)) {
      Hive.registerAdapter(DonorModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.organizationTypeId)) {
      Hive.registerAdapter(OrganizationModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    if (!Hive.isBoxOpen(HiveTableConstant.donorTable)) {
      await Hive.openBox<DonorModel>(HiveTableConstant.donorTable);
    }
    if (!Hive.isBoxOpen(HiveTableConstant.organizationTable)) {
      await Hive.openBox<OrganizationModel>(HiveTableConstant.organizationTable);
    }
  }

  // -------------------- Boxes --------------------
  Box<DonorModel> get _donorBox {
    if (!Hive.isBoxOpen(HiveTableConstant.donorTable)) {
      throw HiveError('Donor box not opened');
    }
    return Hive.box<DonorModel>(HiveTableConstant.donorTable);
  }

  Box<OrganizationModel> get _orgBox {
    if (!Hive.isBoxOpen(HiveTableConstant.organizationTable)) {
      throw HiveError('Organization box not opened');
    }
    return Hive.box<OrganizationModel>(HiveTableConstant.organizationTable);
  }

  // ================= Donor CRUD =================
  Future<DonorModel> createDonor(DonorModel donor) async {
    await _donorBox.put(donor.id, donor);
    return donor;
  }

  List<DonorModel> getAllDonors() => _donorBox.values.toList();

  DonorModel? getDonorById(String id) => _donorBox.get(id);

  Future<void> updateDonor(DonorModel donor) async => _donorBox.put(donor.id, donor);

  Future<void> deleteDonor(String id) async => _donorBox.delete(id);

  // ================= Organization CRUD =================
  Future<OrganizationModel> createOrganization(OrganizationModel org) async {
    await _orgBox.put(org.id, org);
    return org;
  }

  List<OrganizationModel> getAllOrganizations() => _orgBox.values.toList();

  OrganizationModel? getOrganizationById(String id) => _orgBox.get(id);

  Future<void> updateOrganization(OrganizationModel org) async => _orgBox.put(org.id, org);

  Future<void> deleteOrganization(String id) async => _orgBox.delete(id);
}
