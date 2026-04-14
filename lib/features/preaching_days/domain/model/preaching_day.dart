import '../../../blocks/domain/model/block.dart';
import '../../../captains/domain/model/captain.dart';
import '../../../publishers/domain/model/publisher.dart';

class PreachingDay {
  final String id;
  final DateTime date;
  final Captain captain;
  final List<Publisher> participants;
  final List<Block> coveredBlocks;
  final String? notes;
  final DateTime createdAt;

  const PreachingDay({
    required this.id,
    required this.date,
    required this.captain,
    required this.participants,
    required this.coveredBlocks,
    this.notes,
    required this.createdAt,
  });

  int get participantCount => participants.length;
  int get coveredBlockCount => coveredBlocks.length;
}