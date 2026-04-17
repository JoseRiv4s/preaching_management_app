import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportFilters {
  final DateTime month;
  final String? captainId;
  final String? captainName;

  const ReportFilters({
    required this.month,
    this.captainId,
    this.captainName,
  });

  ReportFilters copyWith({
    DateTime? month,
    String? captainId,
    String? captainName,
    bool clearCaptain = false,
  }) {
    return ReportFilters(
      month: month ?? this.month,
      captainId: clearCaptain ? null : captainId ?? this.captainId,
      captainName: clearCaptain ? null : captainName ?? this.captainName,
    );
  }
}

class ReportFiltersNotifier extends Notifier<ReportFilters> {
  @override
  ReportFilters build() => ReportFilters(month: DateTime.now());

  void setMonth(DateTime month) => state = state.copyWith(month: month);

  void setCaptain(String? id, String? name) {
    if (id == null) {
      state = state.copyWith(clearCaptain: true);
    } else {
      state = state.copyWith(captainId: id, captainName: name);
    }
  }
}

final reportFiltersProvider =
    NotifierProvider<ReportFiltersNotifier, ReportFilters>(
  ReportFiltersNotifier.new,
);
