import '../../domain/model/territory_summary.dart';
import '../../domain/model/preaching_day_summary.dart';

class HomeMockData {
  static final List<TerritorySummary> territories = [
    TerritorySummary(
      id: '1',
      name: 'Territorio Central',
      blocks: [
        BlockSummary(id: 'b1', blockNumber: 'A1', status: BlockStatus.completed),
        BlockSummary(id: 'b2', blockNumber: 'A2', status: BlockStatus.completed),
        BlockSummary(id: 'b3', blockNumber: 'A3', status: BlockStatus.inProgress),
        BlockSummary(id: 'b4', blockNumber: 'A4', status: BlockStatus.pending),
        BlockSummary(id: 'b5', blockNumber: 'B1', status: BlockStatus.completed),
        BlockSummary(id: 'b6', blockNumber: 'B2', status: BlockStatus.pending),
        BlockSummary(id: 'b7', blockNumber: 'B3', status: BlockStatus.inProgress),
        BlockSummary(id: 'b8', blockNumber: 'B4', status: BlockStatus.pending),
        BlockSummary(id: 'b9', blockNumber: 'C1', status: BlockStatus.pending),
        BlockSummary(id: 'b10', blockNumber: 'C2', status: BlockStatus.completed),
        BlockSummary(id: 'b11', blockNumber: 'C3', status: BlockStatus.pending),
        BlockSummary(id: 'b12', blockNumber: 'C4', status: BlockStatus.inProgress),
      ],
    ),
    TerritorySummary(
      id: '2',
      name: 'Territorio Norte',
      blocks: [
        BlockSummary(id: 'b13', blockNumber: 'N1', status: BlockStatus.pending),
        BlockSummary(id: 'b14', blockNumber: 'N2', status: BlockStatus.pending),
        BlockSummary(id: 'b15', blockNumber: 'N3', status: BlockStatus.completed),
        BlockSummary(id: 'b16', blockNumber: 'N4', status: BlockStatus.inProgress),
        BlockSummary(id: 'b17', blockNumber: 'N5', status: BlockStatus.pending),
        BlockSummary(id: 'b18', blockNumber: 'N6', status: BlockStatus.completed),
      ],
    ),
    TerritorySummary(
      id: '3',
      name: 'Territorio Sur',
      blocks: [
        BlockSummary(id: 'b19', blockNumber: 'S1', status: BlockStatus.completed),
        BlockSummary(id: 'b20', blockNumber: 'S2', status: BlockStatus.completed),
        BlockSummary(id: 'b21', blockNumber: 'S3', status: BlockStatus.pending),
        BlockSummary(id: 'b22', blockNumber: 'S4', status: BlockStatus.pending),
        BlockSummary(id: 'b23', blockNumber: 'S5', status: BlockStatus.inProgress),
        BlockSummary(id: 'b24', blockNumber: 'S6', status: BlockStatus.pending),
        BlockSummary(id: 'b25', blockNumber: 'S7', status: BlockStatus.completed),
        BlockSummary(id: 'b26', blockNumber: 'S8', status: BlockStatus.pending),
      ],
    ),
  ];

  static final List<PreachingDaySummary> todayJourneys = [
    PreachingDaySummary(
      id: 'pd1',
      date: DateTime.now(),
      captainName: 'Hno. Carlos G.',
      publisherCount: 8,
      territoryName: 'Territorio Central',
      coveredBlocks: ['A1', 'A2', 'A3'],
    ),
    PreachingDaySummary(
      id: 'pd2',
      date: DateTime.now(),
      captainName: 'Hna. María L.',
      publisherCount: 5,
      territoryName: 'Territorio Norte',
      coveredBlocks: ['N1', 'N2'],
    ),
    PreachingDaySummary(
      id: 'pd3',
      date: DateTime.now(),
      captainName: 'Hno. Pedro R.',
      publisherCount: 6,
      territoryName: 'Territorio Sur',
      coveredBlocks: ['S1', 'S2', 'S3'],
    ),
  ];
}