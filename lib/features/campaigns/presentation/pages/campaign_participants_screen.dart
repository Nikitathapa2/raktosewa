import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/features/campaigns/domain/entities/campaign.dart';
import 'package:raktosewa/features/campaigns/domain/usecases/get_campaign_participants_usecase.dart';
import 'package:raktosewa/features/campaigns/data/providers/campaign_providers.dart';

class CampaignParticipantsScreen extends ConsumerStatefulWidget {
  final Campaign campaign;

  const CampaignParticipantsScreen({
    Key? key,
    required this.campaign,
  }) : super(key: key);

  @override
  ConsumerState<CampaignParticipantsScreen> createState() =>
      _CampaignParticipantsScreenState();
}

class _CampaignParticipantsScreenState
    extends ConsumerState<CampaignParticipantsScreen> {
  bool _isLoading = true;
  List<dynamic> _participants = [];
  String? _errorMessage;
  final Set<String> _deletingParticipantIds = {};

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  Future<void> _fetchParticipants({bool showLoader = true}) async {
    if (widget.campaign.id == null) {
      setState(() {
        _errorMessage = 'Invalid campaign';
        _isLoading = false;
      });
      return;
    }

    if (showLoader) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final usecase = GetCampaignParticipantsUsecase(
      ref.read(campaignRepositoryProvider),
    );

    final result = await usecase(widget.campaign.id!);

    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });
        }
      },
      (participants) {
        if (mounted) {
          setState(() {
            _participants = participants;
            _isLoading = false;
          });
        }
      },
    );
  }

  String? _participantIdOf(dynamic participant) {
    if (participant is Map<String, dynamic>) {
      return (participant['_id'] ?? participant['id']) as String?;
    }
    if (participant is Map) {
      final dynamic rawId = participant['_id'] ?? participant['id'];
      return rawId?.toString();
    }
    return null;
  }

  Future<bool> _confirmDeleteParticipant(dynamic participant) async {
    final name = participant['fullName']?.toString() ?? 'this participant';
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Participant'),
        content: Text(
          'Are you sure you want to delete this participant?\n\n$name',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFEC131E)),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _deleteParticipant(dynamic participant) async {
    final campaignId = widget.campaign.id;
    final participantId = _participantIdOf(participant);

    if (campaignId == null || participantId == null || participantId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete participant. Invalid data.')),
        );
      }
      return false;
    }

    if (mounted) {
      setState(() {
        _deletingParticipantIds.add(participantId);
      });
    }

    final usecase = DeleteCampaignParticipantUsecase(
      ref.read(campaignRepositoryProvider),
    );

    final result = await usecase(campaignId, participantId);

    if (!mounted) return false;

    bool isSuccess = false;
    result.fold(
      (failure) {
        isSuccess = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        isSuccess = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participant deleted successfully')),
        );
      },
    );

    if (mounted) {
      setState(() {
        _deletingParticipantIds.remove(participantId);
      });
    }

    if (isSuccess) {
      await _fetchParticipants(showLoader: false);
    }

    return isSuccess;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Campaign Participants',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF181111),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE6E6E6),
            height: 1,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign Info Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.campaign.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF181111),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC131E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_alt,
                            size: 16,
                            color: Color(0xFFEC131E),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_participants.length} Registered',
                            style: const TextStyle(
                              color: Color(0xFFEC131E),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Participants List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchParticipants,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _participants.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No participants yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Donors will appear here after registration',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchParticipants,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _participants.length,
                              itemBuilder: (context, index) {
                                final participant = _participants[index];
                                final participantId = _participantIdOf(participant);
                                final canDelete =
                                    participantId != null && participantId.isNotEmpty;
                                final isDeleting = canDelete &&
                                    _deletingParticipantIds.contains(participantId);

                                if (!canDelete) {
                                  return _ParticipantCard(
                                    participant: participant,
                                    index: index,
                                    isDeleting: false,
                                  );
                                }

                                return Dismissible(
                                  key: ValueKey('participant_$participantId'),
                                  direction: isDeleting
                                      ? DismissDirection.none
                                      : DismissDirection.endToStart,
                                  background: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    alignment: Alignment.centerRight,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEC131E),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: isDeleting
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.delete_outline,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                  ),
                                  confirmDismiss: (_) async {
                                    final confirm =
                                        await _confirmDeleteParticipant(participant);
                                    if (!confirm) return false;
                                    return _deleteParticipant(participant);
                                  },
                                  child: _ParticipantCard(
                                    participant: participant,
                                    index: index,
                                    isDeleting: isDeleting,
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  final dynamic participant;
  final int index;
  final bool isDeleting;

  const _ParticipantCard({
    required this.participant,
    required this.index,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = participant['fullName'] ?? 'Unknown';
    final email = participant['email'] ?? 'No email';
    final phone = participant['phoneNumber'] ?? 'No phone';
    final bloodGroup = participant['bloodGroup'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar with index
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEC131E), Color(0xFFDD2476)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Participant Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF181111),
                          ),
                        ),
                      ),
                      if (bloodGroup.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC131E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bloodGroup,
                            style: const TextStyle(
                              color: Color(0xFFEC131E),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: Color(0xFF896161),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF896161),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: Color(0xFF896161),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF896161),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isDeleting)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
