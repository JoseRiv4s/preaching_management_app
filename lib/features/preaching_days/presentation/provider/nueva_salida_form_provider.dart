import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../captains/domain/model/captain.dart';
import '../../../blocks/domain/model/block.dart';
import '../../../publishers/domain/model/publisher.dart';

class NuevaSalidaFormState {
  final DateTime date;
  final Captain? captain;
  final List<Publisher> selectedPublishers;
  final List<Block> selectedBlocks;
  final String? notes;

  const NuevaSalidaFormState({
    required this.date,
    this.captain,
    this.selectedPublishers = const [],
    this.selectedBlocks     = const [],
    this.notes,
  });

  NuevaSalidaFormState copyWith({
    DateTime? date,
    Captain? captain,
    List<Publisher>? selectedPublishers,
    List<Block>? selectedBlocks,
    String? notes,
  }) {
    return NuevaSalidaFormState(
      date:               date               ?? this.date,
      captain:            captain            ?? this.captain,
      selectedPublishers: selectedPublishers ?? this.selectedPublishers,
      selectedBlocks:     selectedBlocks     ?? this.selectedBlocks,
      notes:              notes              ?? this.notes,
    );
  }

  bool get isStep1Valid => captain != null;
  bool get isStep2Valid => selectedPublishers.isNotEmpty;
  bool get isStep3Valid => selectedBlocks.isNotEmpty;
  bool get isComplete   =>
      isStep1Valid && isStep2Valid && isStep3Valid;
}

class NuevaSalidaFormNotifier
    extends AutoDisposeNotifier<NuevaSalidaFormState> {
  @override
  NuevaSalidaFormState build() => NuevaSalidaFormState(
    date: DateTime.now(),
  );

  void setDate(DateTime date) =>
      state = state.copyWith(date: date);

  void setCaptain(Captain captain) =>
      state = state.copyWith(captain: captain);

  void togglePublisher(Publisher publisher) {
    final list = List<Publisher>.from(state.selectedPublishers);
    if (list.contains(publisher)) {
      list.remove(publisher);
    } else {
      list.add(publisher);
    }
    state = state.copyWith(selectedPublishers: list);
  }

  void toggleBlock(Block block) {
    final list = List<Block>.from(state.selectedBlocks);
    if (list.contains(block)) {
      list.remove(block);
    } else {
      list.add(block);
    }
    state = state.copyWith(selectedBlocks: list);
  }

  void setNotes(String notes) =>
      state = state.copyWith(notes: notes.isEmpty ? null : notes);

  void reset() => state = NuevaSalidaFormState(date: DateTime.now());
}

final nuevaSalidaFormProvider = AutoDisposeNotifierProvider<
NuevaSalidaFormNotifier, NuevaSalidaFormState>(
NuevaSalidaFormNotifier.new,
);