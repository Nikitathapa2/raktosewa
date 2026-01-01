import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:raktosewa/core/constants/hive_table_constant.dart';
import 'package:raktosewa/features/auth/data/models/donor_model.dart';

class DonorHiveScreen extends StatefulWidget {
  const DonorHiveScreen({super.key});

  @override
  State<DonorHiveScreen> createState() => _DonorHiveScreenState();
}

class _DonorHiveScreenState extends State<DonorHiveScreen> {
  List<DonorModel> donors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDonors();
  }

  Future<void> loadDonors() async {
    setState(() {
      isLoading = true;
    });

    try {
      final donorBox = await Hive.openBox<DonorModel>(
        HiveTableConstant.donorTable,
      );
      setState(() {
        donors = donorBox.values.toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading donors: $e')));
      }
    }
  }

  Future<void> _deleteDonor(String donorId) async {
    try {
      final donorBox = await Hive.openBox<DonorModel>(
        HiveTableConstant.donorTable,
      );
      await donorBox.delete(donorId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donor deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        loadDonors();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting donor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String name,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Donor'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Database'),
        backgroundColor: const Color(0xFF136DEC),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadDonors),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF136DEC)),
            )
          : donors.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Donors Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Donors will appear here after registration',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: donors.length,
              itemBuilder: (context, index) {
                final donor = donors[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF136DEC),
                      child: Text(
                        donor.fullName.isNotEmpty
                            ? donor.fullName[0].toUpperCase()
                            : 'D',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      donor.fullName.isEmpty
                          ? 'Donor ${index + 1}'
                          : donor.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteConfirmation(
                            context,
                            donor.fullName,
                            () => _deleteDonor(donor.id),
                          );
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          donor.email,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'DONOR',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    childrenPadding: const EdgeInsets.all(16),
                    children: [
                      _buildSection('Personal Information', [
                        _info('Full Name', donor.fullName),
                        _info('Email', donor.email),
                        _info('Phone', donor.phone),
                        _info('Blood Group', donor.bloodGroup),
                        _info('Date of Birth', donor.dob),
                        _info('Address', donor.address),
                      ]),
                      const Divider(height: 24),
                      _buildSection('System Information', [
                        _info('User ID', donor.id),
                        _info('Password', donor.password),
                      ]),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF136DEC),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _info(String label, String value) {
    if (value.isEmpty || value == 'N/A') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
