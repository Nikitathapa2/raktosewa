import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/services/hive/hive_service.dart';
import 'package:raktosewa/features/auth/data/models/donor_model.dart';
import 'package:raktosewa/features/auth/data/models/organization_model.dart';

// Provider for Hive Service
final donorHiveServiceProvider = Provider<DonorHiveService>((ref) {
  return DonorHiveService();
});

class DonorHiveScreen extends ConsumerStatefulWidget {
  const DonorHiveScreen({super.key});

  @override
  ConsumerState<DonorHiveScreen> createState() => _DonorHiveScreenState();
}

class _DonorHiveScreenState extends ConsumerState<DonorHiveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool loading = true;

  List<DonorModel> donors = [];
  List<OrganizationModel> orgs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    final hiveService = ref.read(donorHiveServiceProvider);
    setState(() {
      donors = hiveService.getAllDonors();
      orgs = hiveService.getAllOrganizations(); // Add this method in HiveService if needed
      loading = false;
    });
  }

  void _deleteDonor(String id) async {
    final hiveService = ref.read(donorHiveServiceProvider);
    await hiveService.deleteDonor(id);
    _loadData();
  }

  void _deleteOrganization(String id) async {
    final hiveService = ref.read(donorHiveServiceProvider);
    await hiveService.deleteOrganization(id);
    _loadData();
  }

  void _confirmDelete(String name, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Delete "$name"?'),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Users'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Donors'),
            Tab(text: 'Organizations'),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDonorList(),
                _buildOrganizationList(),
              ],
            ),
    );
  }

  Widget _buildDonorList() {
    if (donors.isEmpty) return const Center(child: Text('No donors found'));

    return ListView.builder(
      itemCount: donors.length,
      itemBuilder: (_, index) {
        final donor = donors[index];
        return ListTile(
          title: Text(donor.fullName),
          subtitle: Text('${donor.email} • ${donor.bloodGroup}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(donor.fullName, () => _deleteDonor(donor.id)),
          ),
        );
      },
    );
  }

  Widget _buildOrganizationList() {
    if (orgs.isEmpty) return const Center(child: Text('No organizations found'));

    return ListView.builder(
      itemCount: orgs.length,
      itemBuilder: (_, index) {
        final org = orgs[index];
        return ListTile(
          title: Text(org.organizationName),
          subtitle: Text(org.email),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(org.organizationName, () => _deleteOrganization(org.id)),
          ),
        );
      },
    );
  }
}
